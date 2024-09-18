#!/usr/bin/env sh

# Uncomment this line for verbose output (Keep at top of file)
set -x

set -eu

# Set the list of supported target platforms
supported_platforms="x86_64-linux-musl aarch64-linux-musl aarch64-apple-darwin"

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
macos_sdk_version="12"

# Check if the filename exists
if [ ! -f "$filename" ]; then
  echo "Error: File '$filename' does not exist"
  exit 1
fi

# Check if the target platform is supported
case $target_platform in
  x86_64-linux-musl|aarch64-linux-musl|aarch64-apple-darwin)
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
build_cmd="crystal build --release --no-debug --static --cross-compile --target $target_platform"

case $target_platform in
  # forces usage of libiconv for macOS
  # Ref: https://github.com/crystal-lang/crystal/pull/14651#issuecomment-2159357235
  *-apple-darwin)
    build_cmd="${build_cmd} -Duse_libiconv"
    ;;
  *)
    ;;
esac
build_output=$(PKG_CONFIG_LIBDIR="$pkg_config_libdir" $build_cmd "$filename" -o "$object_file")

# check if build succeeded before proceeding
if [ $? -ne 0 ]; then
  echo "Build failed:"
  echo $build_output
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

case $target_platform in
  *-apple-darwin)
    # when targeting `darwin`, the link platform is `macos-none`
    link_platform="${target_platform/apple-darwin/macos-none}"

    # we also need to add macOS SDK
    link_paths="$link_paths -L$multiarch_root/MacOSX$macos_sdk_version.sdk/usr/lib"
    ;;
  *)
    link_platform=$target_platform
    ;;
esac

# Print the list of unique libraries
echo "Linking with: $libs"

# link the object_file with the supplied libraries
link_output=$(zig cc -target $link_platform "$object_file" -o "$executable_name" $link_paths $libs -Wno-deprecated-non-prototype)

if [ $? -ne 0 ]; then
  echo "Link failed."
  echo $link_output
  exit 1
fi

echo "Done."
