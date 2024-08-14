# Stage 1: Install Crystal and Build x86_64 Binary
FROM debian:buster AS builder-x86_64

# Install dependencies and Crystal
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libxml2-dev \
    libyaml-dev \
    libgmp-dev \
    curl \
    git \
    gcc \
    g++ \
    make \
    musl-tools \
    wget \
    gnupg2 \
    apt-transport-https \
    ca-certificates \
    && curl -fsSL https://keybase.io/crystal/pgp_keys.asc | apt-key add - \
    && echo "deb https://dist.crystal-lang.org/apt crystal main" > /etc/apt/sources.list.d/crystal.list \
    && apt-get update \
    && apt-get install -y crystal

# Set the working directory
WORKDIR /app

# Copy the source code
COPY . .

# Install shards dependencies and build the x86_64 binary
RUN shards install && crystal build src/cli.cr --release --static --target x86_64-linux-musl -o /app/coveralls-x86_64

# Stage 2: Install Crystal and Build aarch64 Binary
FROM debian:buster AS builder-aarch64

# Install dependencies and Crystal
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libxml2-dev \
    libyaml-dev \
    libgmp-dev \
    curl \
    git \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    make \
    musl-tools \
    wget \
    gnupg2 \
    apt-transport-https \
    ca-certificates \
    && curl -fsSL https://keybase.io/crystal/pgp_keys.asc | apt-key add - \
    && echo "deb https://dist.crystal-lang.org/apt crystal main" > /etc/apt/sources.list.d/crystal.list \
    && apt-get update \
    && apt-get install -y crystal

# Set the working directory
WORKDIR /app

# Copy the source code
COPY . .

# Install shards dependencies and build the aarch64 binary
RUN shards install && crystal build src/cli.cr --release --static --cross-compile --target aarch64-linux-gnu -o /app/coveralls-aarch64

# Stage 3: Final Image with the Binaries
FROM debian:buster-slim
WORKDIR /app

# Copy the binaries from the builder stages
COPY --from=builder-x86_64 /app/coveralls-x86_64 /app/coveralls-x86_64
COPY --from=builder-aarch64 /app/coveralls-aarch64 /app/coveralls-aarch64

# Optionally, set entry point if needed
# ENTRYPOINT ["/app/coveralls-x86_64"]
