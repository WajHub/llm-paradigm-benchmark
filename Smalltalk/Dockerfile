FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
    gnu-smalltalk \
    make \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . /app
RUN find /app -type f \( -name "*.sh" -o -name "*.st" -o -name "Makefile" \) -exec dos2unix {} + \
    && chmod +x /app/run-tests.sh

ENTRYPOINT ["/bin/sh", "/app/run-tests.sh"]
