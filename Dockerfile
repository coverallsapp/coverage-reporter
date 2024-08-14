# Stage 1: Build x86_64 Binary
FROM 84codes/crystal:latest AS builder-x86_64

# Set the working directory
WORKDIR /app

# Install required packages
RUN apk add --no-cache yaml-dev musl-dev

# Copy the source code
COPY . .

# Install dependencies and build the x86_64 binary
RUN shards install && crystal build src/cli.cr --release --static --target x86_64-linux-musl -o /app/coveralls-linux-x86_64

# Stage 2: Build aarch64 Binary
FROM 84codes/crystal:latest AS builder-aarch64

# Set the working directory
WORKDIR /app

# Install required packages
RUN apk add --no-cache yaml-dev

# Copy the source code
COPY . .

# Install dependencies and build the aarch64 binary
RUN shards install && crystal build src/cli.cr --release --static --cross-compile --target aarch64-linux-gnu -o /app/coveralls-linux-aarch64

# Stage 3: Final Image with the Binaries
FROM debian:buster-slim
WORKDIR /app

# Copy the binaries from the builder stages
COPY --from=builder-x86_64 /app/coveralls-linux-x86_64 /app/coveralls-linux-x86_64
COPY --from=builder-aarch64 /app/coveralls-linux-aarch64 /app/coveralls-linux-aarch64

# Create a generic linux binary named coveralls-linux
RUN cp /app/coveralls-linux-x86_64 /app/coveralls-linux

# Optionally, set entry point if needed
# ENTRYPOINT ["/app/coveralls-linux"]
