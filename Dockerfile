# ARG to specify Crystal version and base image tag
ARG CRYSTAL_VERSION=1.13.1
ARG BASE_IMAGE_TAG=ubuntu-22.04

# Stage 1: Build for x86_64
FROM 84codes/crystal:${CRYSTAL_VERSION}-${BASE_IMAGE_TAG} AS builder-x86_64
WORKDIR /app
RUN git clone https://github.com/coverallsapp/coverage-reporter.git .
# Install only the necessary dependencies, skipping ameba and kcov
RUN sed -i '/ameba/d' shard.yml \
    && sed -i '/crystal-kcov/d' shard.yml \
    && shards install --ignore-crystal-version \
    && mkdir -p /app/bin \
    && crystal build --release src/coverage_reporter.cr -o /app/bin/coveralls-linux-x86_64

# Stage 2: Build for aarch64
FROM 84codes/crystal:${CRYSTAL_VERSION}-${BASE_IMAGE_TAG} AS builder-aarch64
WORKDIR /app
COPY --from=builder-x86_64 /app /app

# Install dependencies. Ensure ameba and kcov are not present
RUN sed -i '/ameba/d' shard.yml \
    && sed -i '/crystal-kcov/d' shard.yml \
    && rm -rf lib/* \
    && rm -rf .shards \
    && shards install --ignore-crystal-version \
    && mkdir -p /app/bin \
    && crystal build --release src/coverage_reporter.cr -o /app/bin/coveralls-linux-aarch64

# Stage 3a: Export Binary for x86_64
FROM scratch AS x86_64_binary
COPY --from=builder-x86_64 /app/bin/coveralls-linux-x86_64 /

# Stage 3b: Export Binary for aarch64
FROM scratch AS aarch64_binary
COPY --from=builder-aarch64 /app/bin/coveralls-linux-aarch64 /

# Stage 4: Final stage to create a generic binary for backward compatibility
FROM scratch AS final
COPY --from=x86_64_binary /coveralls-linux-x86_64 /coveralls-linux
