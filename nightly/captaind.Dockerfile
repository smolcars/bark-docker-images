# Stage 1: Build the application
FROM --platform=$BUILDPLATFORM rust:1.91.1-bookworm AS builder

# Install build dependencies including cross-compilation toolchains
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    libpq-dev \
    curl \
    gnupg2 \
    lsb-release \
    apt-transport-https \
    ca-certificates \
    dos2unix \
    build-essential \
    protobuf-compiler \
    git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Clone the repository and checkout the correct tag
RUN git clone https://gitlab.com/ark-bitcoin/bark.git /app
WORKDIR /app


# Install the correct rust target and build for amd64
RUN cargo build --release --bin captaind


# Stage 2: Create the final image
FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    libpq-dev \
    curl \
    gnupg2 \
    lsb-release \
    apt-transport-https \
    ca-certificates \
    dos2unix \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy the built binary from the builder stage
COPY --from=builder /app/target/release/captaind /usr/local/bin/captaind

# Copy the start script
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Set environment variables
ENV CAPTAIND_CONFIG_PATH="/data/captaind/captaind.toml"

# Set the entrypoint
ENTRYPOINT /usr/local/bin/start.sh
