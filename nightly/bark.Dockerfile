# Stage 1: Build the application
FROM --platform=$BUILDPLATFORM rust:1.91.1-bookworm AS builder

# Install build dependencies including cross-compilation toolchains
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    telnet \
    dos2unix \
    protobuf-compiler \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Clone the repository and checkout the correct tag
RUN git clone https://gitlab.com/ark-bitcoin/bark.git /app
WORKDIR /app

RUN cargo build --release --bin bark

# Stage 2: Create the final image
FROM debian:bookworm-slim

# Install build dependencies including cross-compilation toolchains
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    telnet \
    dos2unix \
    protobuf-compiler \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy the built binary from the builder stage
COPY --from=builder /app/target/release/bark /usr/local/bin/bark

# Copy the start script
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set the entrypoint
CMD ["/usr/local/bin/run.sh"]
