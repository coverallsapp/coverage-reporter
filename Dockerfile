ARG CRYSTAL_VERSION
FROM crystallang/crystal:${CRYSTAL_VERSION}-alpine

RUN apk add xz-dev xz-static libxml2-dev libxml2-static sqlite-dev sqlite-static
