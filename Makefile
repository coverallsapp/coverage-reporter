UUID := $(shell id -u)
GUID := $(shell id -g)

IMAGE_NAME := crystal-xbuild
VERSION ?= latest

DOCKERFILE := Dockerfile

BINARY_AARCH64 := build/aarch64-linux-musl/coveralls-linux-aarch64
BINARY_X86_64 := build/x86_64-linux-musl/coveralls-linux-x86_64
# Generic name for linux binary, for backward-compatibility
BINARY_LINUX := build/x86_64-linux-musl/coveralls-linux

DIST_DIR := dist

# DEV NOTE:
# If you intend to run these targets on on MacOS, you'll want to install `gnu-tar` with `brew install gnu-tar`,
# since it supports the `--transform` option we use with `tar` below in our `package` target.
# Otherwise, on MacOS systems, this script will use `gtar` instead of `tar` and, if not installed,
# you can expect it to fail with a related error.
TAR := $(shell if [ $(shell uname) = Darwin ]; then echo gtar; else echo tar; fi)

# ---
# Targets for `ci.yml` (standard CI: build & test app)
# ---

.PHONY: build
build:
	shards build coveralls --progress --error-trace

.PHONY: test
test:
	crystal spec --order random --error-on-warnings

.PHONY: lint
lint:
	bin/ameba

# ---
# Targets for `build.yml` (build binaries for releases: `build-linux` job)
# ---

.PHONY: build-xbuild-container
build-xbuild-container: $(DOCKERFILE)
	docker build -t ${IMAGE_NAME}:${VERSION} -f ${DOCKERFILE} .

.PHONY: run-xbuild-container
run-xbuild-container: $(DOCKERFILE)
	docker run -it --rm -u $(UUID):$(GUID) -v .:/app -w /app ${IMAGE_NAME}:${VERSION} sh -i

.PHONY: compile-x86_64
compile-x86_64:
	docker run --rm -v $(shell pwd):/app -w /app ${IMAGE_NAME}:${VERSION} xbuild src/cli.cr coveralls-linux-x86_64 x86_64-linux-musl

# NOTE:
# There is a known, unavoidable warning that will appear in STDOUT when cross-compiling for `aarch64`.
# It's due to the version of `clang` used by `zig`. The warning is harmless and can be ignored.
# We're supposed to be able to suppress the warning with the `-Wno-deprecated-non-prototype` flag,
# but unfortunately, it doesn't work as expected. ZigLang tracking issue here: https://github.com/ziglang/zig/issues/13385
.PHONY: compile-aarch64
compile-aarch64:
	docker run --rm -v $(shell pwd):/app -w /app ${IMAGE_NAME}:${VERSION} xbuild src/cli.cr coveralls-linux-aarch64 aarch64-linux-musl

.PHONY: strip-aarch64
strip-aarch64: $(BINARY_AARCH64)
	docker run --rm -v $(shell pwd):/app -w /app ${IMAGE_NAME}:${VERSION} /bin/sh -c \
		"zig objcopy --strip-all $(BINARY_AARCH64) $(BINARY_AARCH64)-stripped && \
		mv $(BINARY_AARCH64)-stripped $(BINARY_AARCH64)"

.PHONY: strip-x86_64
strip-x86_64: $(BINARY_X86_64)
	docker run --rm -v $(shell pwd):/app -w /app ${IMAGE_NAME}:${VERSION} /bin/sh -c \
		"zig objcopy --strip-all $(BINARY_X86_64) $(BINARY_X86_64)-stripped && \
		mv $(BINARY_X86_64)-stripped $(BINARY_X86_64)"

.PHONY: compile-and-strip-all
compile-and-strip-all: compile-aarch64 compile-x86_64 strip-aarch64 strip-x86_64

.PHONY: package
package: $(DIST_DIR)
	mkdir -p $(DIST_DIR)
	# Copy the stripped binaries to the `dist/` directory
	cp build/aarch64-linux-musl/coveralls-linux-aarch64 $(DIST_DIR)/
	cp build/x86_64-linux-musl/coveralls-linux-x86_64 $(DIST_DIR)/
	# Copy stripped x86_64 binary as 'coveralls-linux' for compatibility with github-action and orb
	cp $(DIST_DIR)/coveralls-linux-x86_64 $(DIST_DIR)/coveralls-linux
	# Create tarballs, transforming names to 'coveralls'
	for arch in linux linux-aarch64 linux-x86_64; do \
	  $(TAR) -czf $(DIST_DIR)/coveralls-$$arch.tar.gz -C $(DIST_DIR) --transform="s/coveralls-$$arch/coveralls/" coveralls-$$arch; \
	done

# ---
# Test containers for different architectures
# ---

# Ubuntu 22.04 (x86_64/amd64)
.PHONY: ubuntu-x86_64
ubuntu-x86_64:
	docker run -it --rm -u $(UUID):$(GUID) --platform linux/amd64 -v .:/app -w /app ubuntu:22.04 bash -i

# Ubuntu 22.04 (aarch64)
.PHONY: ubuntu-aarch64
ubuntu-aarch64:
	docker run -it --rm -u $(UUID):$(GUID) --platform linux/aarch64 -v .:/app -w /app ubuntu:22.04 bash -i

# ---
# Used for releasing new versions
# ---

# Creates and pushes new tag with annotation for new release
.ONESHELL:
new_version:
	@read -p "New version: " version; \
	read -p "Brief description: " description; \
	echo "Version: $$version"; \
	echo "Description: $$description"; \
	sed -i '' "s/version:.*/version: $${version}/" shard.yml; \
	sed -i '' "s/VERSION = .*/VERSION = \"$$version\"/" src/coverage_reporter.cr; \
	git add shard.yml src/coverage_reporter.cr; \
	git commit --message "$${version}: $${description}"; \
	git tag --annotate v$${version} --message "$${version}: $${description}"; \
	git push origin master --follow-tags