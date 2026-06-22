FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    ghc \
    make \
    valgrind \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . /app
RUN chmod +x /app/run-tests.sh || true

ENTRYPOINT ["/bin/sh", "/app/run-tests.sh"]
