# Stage 1: Build x86_64 Binary
FROM 84codes/crystal:master-ubuntu-22.04 as builder-x86_64

# Set the working directory
WORKDIR /app

# Install required packages
RUN apt-get update && apt-get install -y libyaml-dev build-essential

# Copy the source code
COPY . .

# Install dependencies and build the x86_64 binary
RUN shards install && crystal build src/cli.cr --release --static --target x86_64-linux-gnu -o /app/coveralls-linux-x86_64

# Stage 2: Build aarch64 Binary
FROM 84codes/crystal:master-ubuntu-22.04 as builder-aarch64

# Set the working directory
WORKDIR /app

# Install required packages
RUN apt-get update && apt-get install -y libyaml-dev gcc-aarch64-linux-gnu build-essential

# Copy the source code
COPY . .

# Install dependencies and build the aarch64 binary
RUN shards install && crystal build src/cli.cr --release --static --cross-compile --target aarch64-linux-gnu -o /app/coveralls-linux-aarch64

# Stage 3: Final Image with the Binaries
FROM ubuntu:22.04
WORKDIR /app

# Copy the binaries from the builder stages
COPY --from=builder-x86_64 /app/coveralls-linux-x86_64 /app/coveralls-linux-x86_64
COPY --from=builder-aarch64 /app/coveralls-linux-aarch64 /app/coveralls-linux-aarch64

# Create a generic linux binary named coveralls-linux
RUN cp /app/coveralls-linux-x86_64 /app/coveralls-linux

# Optionally, set entry point if needed
# ENTRYPOINT ["/app/coveralls-linux"]
