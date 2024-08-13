ARG CRYSTAL_VERSION
FROM crystallang/crystal:${CRYSTAL_VERSION}-buster

# Install necessary dependencies for both x86_64 and aarch64
RUN apt-get update && apt-get install -y \
    xz-utils libxml2-dev sqlite3 libsqlite3-dev \
    gcc g++ \
    gcc-aarch64-linux-gnu g++-aarch64-linux-gnu musl-tools \
    && apt-get clean
