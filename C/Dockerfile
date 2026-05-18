FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    valgrind \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app