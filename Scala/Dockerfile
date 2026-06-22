FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends default-jdk scala make \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace