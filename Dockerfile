ARG CRYSTAL_VERSION
FROM crystallang/crystal:${CRYSTAL_VERSION}-alpine

# Install necessary dependencies for both x86_64 and aarch64
RUN apk add --no-cache xz-dev xz-static libxml2-dev libxml2-static sqlite-dev sqlite-static \
    && apk add --no-cache --virtual .build-deps gcc musl-dev g++ \
    && apk add --no-cache --virtual .cross-deps gcc-aarch64-linux-gnu musl-dev-aarch64
