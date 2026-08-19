#!/usr/bin/env sh

# Uncomment this line for verbose output (Keep at top of file)
#set -x

set -eu

# Set the list of supported target platforms
supported_platforms="x86_64-linux-musl aarch64-linux-musl"

# Check if the required number of parameters is provided
if [ $# -ne 3 ]; then
  echo "Usage: $0 <filename> <executable_name> <target_platform>"
  exit 1
fi

# Assign the parameters to variables
filename=$1
executable_name=$2
target_platform=$3

multiarch_root="/opt/multiarch-libs"

# Check if the filename exists
if [ ! -f "$filename" ]; then
  echo "Error: File '$filename' does not exist"
  exit 1
fi

# Check if the target platform is supported
case $target_platform in
  x86_64-linux-musl|aarch64-linux-musl)
    ;;
  *)
    echo "Error: Unsupported target platform '$target_platform'. Supported platforms are: $supported_platforms"
    exit 1
    ;;
esac

# make sure target_path exists
target_path="build/$target_platform"
mkdir -p "$target_path"

# combine path & executable
executable_name="$target_path/$executable_name"

# Print a success message
echo "Compiling '$executable_name' ('$filename')..."

# get only filename without path and change extension to `.o`
object_file="${TMPDIR:-/tmp}/$(basename "${filename%.*}-$target_platform.o")"

# capture output from build
pkg_config_libdir="$multiarch_root/$target_platform/lib/pkgconfig"

# `-Devloop=libevent` is required, not a tuning knob.
#
# Crystal >= 1.19 creates a CLOCK_BOOTTIME timerfd while starting its default
# (epoll) event loop. Sandboxed container runtimes -- gVisor and friends, which
# back Cloud Run, GKE Autopilot and several CI providers -- implement
# timerfd_create() for CLOCK_REALTIME and CLOCK_MONOTONIC only and return EINVAL
# for CLOCK_BOOTTIME. The event loop is built during startup, so the binary dies
# before main() with a (misleadingly named) error:
#
#   Unhandled exception: timerfd_settime: Invalid argument (RuntimeError)
#
# even for `coveralls --version`. Crystal 1.21 hits the same wall a step earlier
# and reports it as "Thread#execution_context cannot be nil" instead. This broke
# v0.6.19, v0.6.20 and v0.6.21 for every user on such a runtime -- 100% of runs,
# not intermittently.
#
# The libevent loop does not use timerfd at all, so it sidesteps the whole
# problem rather than trading one clock for another. Upstream change that
# introduced it: https://github.com/crystal-lang/crystal/pull/16516
#
# Guarded by the regression gate in .github/workflows/build.yml, which runs the
# real shipped binary under a seccomp profile that reproduces those runtimes.
# Revisit if Crystal grows a CLOCK_MONOTONIC fallback, and re-run that gate
# before removing this.
build_cmd="crystal build --release --no-debug --static -Devloop=libevent --cross-compile --target $target_platform"

build_output=$(PKG_CONFIG_LIBDIR="$pkg_config_libdir" $build_cmd "$filename" -o "$object_file")

# check if build succeeded before proceeding
if [ $? -ne 0 ]; then
  echo "Build failed:"
  echo "$build_output"
  exit 1
fi

# Extract the list of libraries from the build output
libs=$(echo "$build_output" | awk '{for (i=1; i<=NF; i++) if ($i ~ /^-l/) print $i}' | tr -d "\`" | tr -d "'" | tr '\n' ' ' | sed 's/ $//')

# workaround awk/sed not detecting `-lssl` on the output
# if found, prepend before crypto dependency
if [[ "$build_output" =~ "lssl" ]]; then
   libs="${libs/crypto/ssl -lcrypto}"
fi

case $target_platform in
  # when targeting `musl`, also include `unwind` as library
  *-linux-musl)
    libs="$libs -lunwind"
    ;;
  *)
    ;;
esac

# prepare link_paths
link_paths="-L$multiarch_root/$target_platform/lib"

link_platform=$target_platform

# Print the list of unique libraries
echo "Linking with: $libs"

# link the object_file with the supplied libraries
# NOTE:
# There is an unavoidable warning that appears in STDOUT when compiling for `aarch64`.
# The warning is harmless and can be ignored.
# See our comment above the `compile-aarch64` target in the Makefile for more info.
link_output=$(zig cc -target "$link_platform" -Wno-deprecated-non-prototype "$object_file" -o "$executable_name" $link_paths $libs)

if [ $? -ne 0 ]; then
  echo "Link failed."
  echo "$link_output"
  exit 1
fi

echo "Done."
