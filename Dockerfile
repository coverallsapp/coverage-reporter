# Use a Debian-based image
FROM debian:buster-slim

# Install necessary dependencies and Crystal
ARG CRYSTAL_VERSION=1.13.1
RUN apt-get update && apt-get install -y \
    curl \
    xz-utils libxml2-dev sqlite3 libsqlite3-dev \
    gcc g++ \
    gcc-aarch64-linux-gnu g++-aarch64-linux-gnu musl-tools \
    && curl -L https://github.com/crystal-lang/crystal/releases/download/${CRYSTAL_VERSION}/crystal-${CRYSTAL_VERSION}-1-linux-x86_64.tar.gz | tar -xz -C /usr/local \
    && ln -s /usr/local/crystal-${CRYSTAL_VERSION}-1/bin/crystal /usr/local/bin/crystal \
    && apt-get clean \
