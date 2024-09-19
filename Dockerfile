# Base image from luislavena's hydrofoil-crystal image
FROM ghcr.io/luislavena/hydrofoil-crystal:1.13 AS base

# install cross-compiler (Zig) with dependencies and utilities
RUN --mount=type=cache,sharing=private,target=/var/cache/apk \
    --mount=type=tmpfs,target=/tmp \
    set -eux -o pipefail; \
    # Tools to extract Zig
    { \
        apk add \
            file \
            tar \
            xz \
        ; \
    }; \
    # Zig
    { \
        cd /tmp; \
        mkdir -p /opt/zig; \
        export ZIG_VERSION=0.13.0; \
        case "$(arch)" in \
        x86_64) \
            export \
                ZIG_ARCH=x86_64 \
                ZIG_SHA256=d45312e61ebcc48032b77bc4cf7fd6915c11fa16e4aad116b66c9468211230ea \
            ; \
            ;; \
        aarch64) \
            export \
                ZIG_ARCH=aarch64 \
                ZIG_SHA256=041ac42323837eb5624068acd8b00cd5777dac4cf91179e8dad7a7e90dd0c556 \
            ; \
            ;; \
        esac; \
        wget -q -O zig.tar.xz https://ziglang.org/download/${ZIG_VERSION}/zig-linux-${ZIG_ARCH}-${ZIG_VERSION}.tar.xz; \
        echo "${ZIG_SHA256} *zig.tar.xz" | sha256sum -c - >/dev/null 2>&1; \
        tar -C /opt/zig --strip-components=1 -xf zig.tar.xz; \
        rm zig.tar.xz; \
        # symlink executable
        ln -nfs /opt/zig/zig /usr/local/bin; \
    }; \
    # smoke check
    [ "$(command -v zig)" = '/usr/local/bin/zig' ]; \
    zig version; \
    zig cc --version

# ---
# Alpine Linux libraries for multi-arch cross-compilation

# Set the library path to include both /lib and /opt/multiarch-libs
ENV LIBRARY_PATH="/lib:/opt/multiarch-libs/aarch64-linux-musl/lib:/opt/multiarch-libs/x86_64-linux-musl/lib"

# Create the target directories for both aarch64 and x86_64
RUN mkdir -p /opt/multiarch-libs/aarch64-linux-musl/lib && \
    mkdir -p /opt/multiarch-libs/x86_64-linux-musl/lib

# Set the include paths for header files for both architectures
ENV CFLAGS="-I/opt/multiarch-libs/aarch64-linux-musl/include -I/opt/multiarch-libs/x86_64-linux-musl/include"
ENV LDFLAGS="-L/opt/multiarch-libs/aarch64-linux-musl/lib -L/opt/multiarch-libs/x86_64-linux-musl/lib"

# Install multi-arch libraries
RUN --mount=type=cache,sharing=private,target=/var/cache/apk \
    --mount=type=tmpfs,target=/tmp \
    set -eux -o pipefail; \
    # Alpine Linux: download and extract packages for each arch
    { \
        supported_arch="aarch64 x86_64"; \
        target_alpine=3.20; \
        cd /tmp; \
        for target_arch in $supported_arch; do \
            target_path="/tmp/$target_arch-apk-chroot"; \
            mkdir -p $target_path/etc/apk; \
            # patch apk repositories to $target_alpine version
            sed -E "s/v\d\.\d+/v$target_alpine/g" /etc/apk/repositories | tee $target_path/etc/apk/repositories; \
            # use apk to download the specific packages
            apk add --root $target_path --arch $target_arch --initdb --no-cache --no-scripts --allow-untrusted \
                gc-dev \
                gmp-dev \
                libevent-dev \
                libevent-static \
                libsodium-dev \
                libsodium-static \
                libxml2-dev \
                libxml2-static \
                openssl-dev \
                openssl-libs-static \
                pcre2-dev \
                sqlite-dev \
                sqlite-static \
                yaml-dev \
                yaml-static \
                zlib-dev \
                zlib-static \
                xz-dev \
                xz-static \
            ; \
            # Copy the correct libz.a for each architecture \
            # This is required because `libz.a` does not otherwise \
            # get installed for `aarh64` and `x86_64` \
            # just for `aarch64-apple-darwin`
            if [ "$target_arch" = "aarch64" ]; then \
                cp $target_path/lib/libz.a /opt/multiarch-libs/aarch64-linux-musl/lib/; \
            elif [ "$target_arch" = "x86_64" ]; then \
                cp $target_path/lib/libz.a /opt/multiarch-libs/x86_64-linux-musl/lib/; \
            fi; \
            # Verify the installed libz.a for each $target_arch
            echo "DEBUG: Checking installed libz.a for $target_arch"; \
            ls -al /tmp/$target_arch-apk-chroot/lib/libz.a; \
            # Debug: List the contents of $target_path/usr/lib/
            echo "DEBUG: Listing contents of $target_path/usr/lib/"; \
            pkg_path="/opt/multiarch-libs/$target_arch-linux-musl"; \
            ls -al $target_path/usr/lib/; \
            mkdir -p $pkg_path/lib/pkgconfig; \
            # copy the static libs & .pc files
            cp $target_path/usr/lib/*.a $pkg_path/lib/; \
            cp $target_path/usr/lib/pkgconfig/*.pc $pkg_path/lib/pkgconfig/; \
            # Debug: List the contents of /opt/multiarch-libs/$target_arch-linux-musl/
            echo "DEBUG: Installed libraries for $target_arch"; \
            echo "DEBUG: Listing contents of $pkg_path"; \
            ls -al $pkg_path/lib/; \
        done; \
    }

# ---
# macOS

# macOS dependencies are installed in separate target
FROM base AS macos-packages
COPY ./scripts/homebrew-downloader.cr /homebrew-downloader.cr

RUN --mount=type=cache,sharing=private,target=/var/cache/apk \
    --mount=type=tmpfs,target=/tmp \
    set -eux -o pipefail; \
    # macOS (Monterey), supports only Apple Silicon (aarch64/arm64)
    { \
        pkg_path="/opt/multiarch-libs/aarch64-apple-darwin"; \
        crystal run /homebrew-downloader.cr -- \
            $pkg_path \
            gmp \
            libevent \
            libgc \
            libiconv \
            libsodium \
            libxml2 \
            libyaml \
            openssl@3 \
            pcre2 \
            sqlite \
            zlib \
        ; \
    }

# copy macOS dependencies back into `base`
FROM base
COPY --from=macos-packages /opt/multiarch-libs/aarch64-apple-darwin /opt/multiarch-libs/aarch64-apple-darwin

# install macOS SDK
RUN --mount=type=cache,sharing=private,target=/var/cache/apk \
    --mount=type=tmpfs,target=/tmp \
    set -eux -o pipefail; \
    { \
        cd /tmp; \
        export \
            MACOS_SDK_VERSION=12.3 \
            MACOS_SDK_MAJOR_VERSION=12 \
            MACOS_SDK_SHA256=3abd261ceb483c44295a6623fdffe5d44fc4ac2c872526576ec5ab5ad0f6e26c \
        ; \
        wget -q -O sdk.tar.xz https://github.com/joseluisq/macosx-sdks/releases/download/${MACOS_SDK_VERSION}/MacOSX${MACOS_SDK_VERSION}.sdk.tar.xz; \
        echo "${MACOS_SDK_SHA256} *sdk.tar.xz" | sha256sum -c - >/dev/null 2>&1; \
        tar -C /opt/multiarch-libs -xf sdk.tar.xz --no-same-owner; \
        rm sdk.tar.xz; \
        # symlink to latest version
        ln -nfs /opt/multiarch-libs/MacOSX${MACOS_SDK_VERSION}.sdk /opt/multiarch-libs/MacOSX${MACOS_SDK_MAJOR_VERSION}.sdk; \
    }

# copy xbuild helper
COPY ./scripts/xbuild.sh /usr/local/bin/xbuild
