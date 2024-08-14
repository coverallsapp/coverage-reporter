# Stage 1: Build x86_64 binary
FROM crystallang/crystal:1.13.1-buster AS builder-x86_64

# Install necessary build tools and dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    musl-tools \
    && apt-get clean

# Copy source code into the container
WORKDIR /app
COPY . .

# Install dependencies and build the x86_64 binary
RUN shards install && crystal build src/cli.cr --release --static --target x86_64-linux-musl -o /app/coveralls-x86_64

# Stage 2: Build aarch64 binary
FROM crystallang/crystal:1.13.1-buster AS builder-aarch64

# Install necessary build tools and dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc-aarch64-linux-gnu g++-aarch64-linux-gnu musl-tools \
    && apt-get clean

# Copy source code into the container
WORKDIR /app
COPY . .

# Install dependencies and build the aarch64 binary
RUN shards install && crystal build src/cli.cr --release --static --cross-compile --target aarch64-linux-gnu -o /app/coveralls-aarch64

# Stage 3: Final image with just the binaries
FROM debian:buster-slim
WORKDIR /app

# Copy both binaries from the builder stages
COPY --from=builder-x86_64 /app/coveralls-x86_64 /app/coveralls-x86_64
COPY --from=builder-aarch64 /app/coveralls-aarch64 /app/coveralls-aarch64

# Optionally, set entry point if only one binary is needed to be run by default
# ENTRYPOINT ["/app/coveralls-x86_64"]
