IMAGE_NAME := crystal-xbuild
VERSION ?= latest

DOCKERFILE := Dockerfile

BINARY_AARCH64 := build/aarch64-linux-musl/coveralls-linux-aarch64
BINARY_X86_64 := build/x86_64-linux-musl/coveralls-linux-x86_64
# Generic name for linux binary, for backward-compatibility
BINARY_LINUX := build/x86_64-linux-musl/coveralls-linux

DIST_DIR := dist
# Developers, if you intend to run these targets on on macOS,
# install gnu-tar with `brew install gnu-tar`as it supports the --transform option
TAR := $(shell if [ $(shell uname) = Darwin ]; then echo gtar; else echo tar; fi)

# Build targets for ci.yml (build and test app)
.PHONY: build-app
build-app:
	shards build coveralls --progress --error-trace

.PHONY: test-app
test-app:
	crystal spec --order random --error-on-warnings

.PHONY: lint-app
lint-app:
	bin/ameba

# Build targets for build.yml (cross-compile linux binaries for release)
.PHONY: build-xbuild-container
build-xbuild-container: $(DOCKERFILE)
	docker build -t ${IMAGE_NAME}:${VERSION} -f ${DOCKERFILE} .

.PHONY: run-xbuild-container
run-xbuild-container: $(DOCKERFILE)
	docker run -it --rm -u $$(id -u):$$(id -g) -v .:/app -w /app ${IMAGE_NAME}:${VERSION} sh -i

.PHONY: compile-x86_64
compile-x86_64:
	docker run --rm -v $(shell pwd):/app -w /app ${IMAGE_NAME}:${VERSION} xbuild src/cli.cr coveralls-linux-x86_64 x86_64-linux-musl

.PHONY: compile-aarch64
compile-aarch64:
	docker run --rm -v $(shell pwd):/app -w /app ${IMAGE_NAME}:${VERSION} xbuild src/cli.cr coveralls-linux-aarch64 aarch64-linux-musl

#.PHONY: copy-linux
## Create the generic "coveralls-linux" binary by copying from the x86_64 version
#copy-linux:
#	cp $(BINARY_X86_64) $(BINARY_LINUX)

.PHONY: strip-aarch64
strip-aarch64: $(BINARY_AARCH64)
	docker run --rm -v $(shell pwd):/app -w /app ${IMAGE_NAME}:${VERSION} strip $(BINARY_AARCH64)

.PHONY: strip-x86_64
strip-x86_64: $(BINARY_X86_64)
	docker run --rm -v $(shell pwd):/app -w /app ${IMAGE_NAME}:${VERSION} zig objcopy --strip-all $(BINARY_X86_64) $(BINARY_X86_64)-stripped
	mv $(BINARY_X86_64)-stripped $(BINARY_X86_64)

#.PHONY: strip-linux
#strip-linux: $(BINARY_LINUX)
#	docker run --rm -v $(shell pwd):/app -w /app ${IMAGE_NAME}:${VERSION} zig objcopy --strip-all $(BINARY_LINUX) $(BINARY_LINUX)-stripped
#	mv $(BINARY_LINUX)-stripped $(BINARY_LINUX)

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

# Test containers for different architectures
# Ubuntu 22.04 (amd64)
.PHONY: ubuntu-amd64
ubuntu-amd64:
	docker run -it --rm --platform linux/amd64 -v .:/app -w /app ubuntu:22.04 bash -i

# Ubuntu 22.04 (aarch64)
.PHONY: ubuntu-aarch64
ubuntu-aarch64:
	docker run -it --rm --platform linux/aarch64 -v .:/app -w /app ubuntu:22.04 bash -i
