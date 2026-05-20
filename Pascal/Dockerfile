FROM debian:bookworm-slim

# Install Free Pascal compiler, make and valgrind for testing
RUN apt-get update && apt-get install -y \
    fpc \
    make \
    valgrind \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy workspace into image and ensure test runner is executable
COPY . /app
RUN chmod +x /app/run-tests.sh || true

ENTRYPOINT ["/bin/sh", "/app/run-tests.sh"]