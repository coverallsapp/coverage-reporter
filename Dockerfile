# Stage 1: Build x86_64 Binary
FROM 84codes/crystal:master-ubuntu-22.04 as builder-x86_64

# Set the working directory
WORKDIR /app

# Update and upgrade system packages, then install required packages
RUN apt-get update && apt-get install -y libyaml-dev liblzma-dev build-essential

# Copy the source code
COPY . .

# Install dependencies and build the x86_64 binary
RUN shards install && crystal build src/cli.cr --release --static --target x86_64-linux-gnu -o /app/coveralls-linux-x86_64

# Stage 2: Build aarch64 Binary
FROM 84codes/crystal:master-ubuntu-22.04 as builder-aarch64

# Set the working directory
WORKDIR /app

# Check disk space usage
RUN df -h

## Update the package list (hold for solution below)
#RUN apt-get update

## Install libc-bin separately to reduce memory usage during installation (hold for solution below)
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libc-bin

# Try this solution to segfault error installing libc-bin
# From: https://stackoverflow.com/questions/78105004/docker-build-fails-because-unable-to-install-libc-bin
#RUN rm /var/lib/dpkg/info/libc-bin.*
#RUN apt-get clean
#RUN apt-get update
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libc-bin

# Try this solution to segfault error installing libc-bin
# From: https://www.grepper.com/answers/426226/installed+libc-bin+package+post-installation+script+subprocess+returned+error+exit+status+134
# Update and install necessary packages
RUN apt-get update && apt-get install -y curl gnupg
# Handle libc-bin package separately to fix segmentation fault issues
# Move the libc-bin metadata files out of the way
RUN mv /var/lib/dpkg/info/libc-bin.* /tmp/
# Forcefully remove the libc-bin package
RUN dpkg --remove --force-remove-reinstreq libc-bin
# Purge the libc-bin package completely
RUN dpkg --purge libc-bin
# Clean up and update the package list
RUN apt-get clean && apt-get update
# Reinstall the libc-bin package
RUN apt-get install -y libc-bin
# Move the libc-bin metadata files back to their original location
RUN mv /tmp/libc-bin.* /var/lib/dpkg/info/

# Install the remaining packages
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libyaml-dev liblzma-dev gcc-aarch64-linux-gnu build-essential

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
