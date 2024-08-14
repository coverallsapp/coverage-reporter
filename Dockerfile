# Stage 1: Build the binary
FROM crystallang/crystal:1.13.1-alpine AS builder

# Install necessary build tools and dependencies
RUN apk add --no-cache build-base

# Copy source code into the container
WORKDIR /app
COPY . .

# Install dependencies and build the binary
RUN shards install && crystal build src/cli.cr --release --static --target x86_64-linux-musl -o /app/coveralls

# Stage 2: Final image with just the binary
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/coveralls /app/coveralls

# Run the binary
ENTRYPOINT ["/app/coveralls"]
