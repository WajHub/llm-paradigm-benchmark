FROM debian:bullseye-slim

# gnu-smalltalk is not packaged for newer Debian releases. Bullseye is past end of life and its
# security mirror no longer serves every package in its index (unzip -> 404), so install from
# the main bullseye archive only.
RUN sed -i '/bullseye-security/d' /etc/apt/sources.list \
    && apt-get update && apt-get install -y \
    gnu-smalltalk \
    make \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . /app
RUN find /app -type f \( -name "*.sh" -o -name "*.st" -o -name "Makefile" \) -exec dos2unix {} + \
    && chmod +x /app/run-tests.sh

ENTRYPOINT ["/bin/sh", "/app/run-tests.sh"]
