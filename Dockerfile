FROM crystallang/crystal:1.8.1-alpine

RUN apk add xz-dev xz-static libxml2-dev libxml2-static sqlite-dev sqlite-static
