FROM eclipse-temurin:17-jdk-jammy

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends make \
    && rm -rf /var/lib/apt/lists/*

COPY . /app

CMD ["/bin/sh"]