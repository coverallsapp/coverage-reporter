# Stage 1: Install Crystal and Build x86_64 Binary
FROM debian:buster AS builder-x86_64

# Install dependencies
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
    wget

# Install Crystal
RUN wget https://github.com/crystal-lang/crystal/releases/download/1.13.1/crystal-1.13.1-1-linux-x86_64.tar.gz \
    && tar -xzf crystal-1.13.1-1-linux-x86_64.tar.gz \
    && mv crystal-1.13.1-1 /usr/local/crystal \
    && ln -s /usr/local/crystal/bin/crystal /usr/local/bin/crystal \
    && apt-get install -f

# Set the working directory
WORKDIR /app

# Copy the source code
COPY . .

# Install shards dependencies and build the x86_64 binary
RUN shards install && crystal build src/cli.cr --release --static --target x86_64-linux-musl -o /app/coveralls-x86_64

# Stage 2: Install Crystal and Build aarch64 Binary
FROM debian:buster AS builder-aarch64

# Install dependencies
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
    wget

# Install Crystal (manually)
RUN wget https://github.com/crystal-lang/crystal/releases/download/1.13.1/crystal-1.13.1-1-linux-x86_64.tar.gz \
    && tar -xzf crystal-1.13.1-1-linux-x86_64.tar.gz \
    && mv crystal-1.13.1-1 /usr/local/crystal \
    && ln -s /usr/local/crystal/bin/crystal /usr/local/bin/crystal \
    && apt-get install -f

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
