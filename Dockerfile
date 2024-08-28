# ARG to specify Crystal version and base image tag
ARG CRYSTAL_VERSION=1.13.1
ARG BASE_IMAGE_TAG=ubuntu-22.04

# Stage 1: Build for x86_64
FROM 84codes/crystal:${CRYSTAL_VERSION}-${BASE_IMAGE_TAG} AS builder-x86_64
WORKDIR /app
# Clone the coverage-reporter repository
RUN git clone https://github.com/coverallsapp/coverage-reporter.git .
# Install liblzma-dev and other dependencies
RUN apt-get update && apt-get install -y liblzma-dev libicu-dev
# Install production dependencies and build the binary
RUN shards install --production --ignore-crystal-version \
    && shards build coveralls --production --release --static --no-debug --progress \
    && strip /app/bin/coveralls  # Reduce binary size

# Stage 2: Build for aarch64
FROM 84codes/crystal:${CRYSTAL_VERSION}-${BASE_IMAGE_TAG} AS builder-aarch64
WORKDIR /app
# Copy source code from the x86_64 build
COPY --from=builder-x86_64 /app /app
# Install liblzma-dev and other dependencies
RUN apt-get update && apt-get install -y liblzma-dev libicu-dev
# Install production dependencies and build the binary
RUN shards install --production --ignore-crystal-version \
    && shards build coveralls --production --release --static --no-debug --progress \
    && strip /app/bin/coveralls  # Reduce binary size

# Stage 3a: Export Binary for x86_64
FROM scratch AS x86_64_binary
COPY --from=builder-x86_64 /app/bin/coveralls /coveralls

# Stage 3b: Export Binary for aarch64
FROM scratch AS aarch64_binary
COPY --from=builder-aarch64 /app/bin/coveralls /coveralls
