# syntax=docker/dockerfile:1

# Build stage
ARG REDIS_VERSION=7.4.2
ARG REDIS_DOWNLOAD_SHA=4dea6fc8ab3e19e9e527dfb38ca6bd83b75a43f12e61ba4b7b00f6513d86e8b5

FROM debian:bookworm-slim AS build

ARG REDIS_VERSION
ARG REDIS_DOWNLOAD_SHA

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        gcc \
        libc6-dev \
        make \
        dpkg-dev \
        libssl-dev \
        libsystemd-dev \
    ; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/src

RUN set -eux; \
    wget -qO redis.tar.gz "https://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz"; \
    echo "${REDIS_DOWNLOAD_SHA} *redis.tar.gz" | sha256sum --check; \
    mkdir -p redis; \
    tar -xzf redis.tar.gz -C redis --strip-components=1; \
    rm redis.tar.gz

WORKDIR /usr/local/src/redis

RUN set -eux; \
    make -j "$(nproc)" \
        BUILD_TLS=yes \
        USE_SYSTEMD=yes \
        CFLAGS="-fstack-protector-strong" \
    ; \
    make install

# Runtime stage
FROM debian:bookworm-slim

RUN set -eux; \
    groupadd -r -g 999 redis; \
    useradd -r -g redis -u 999 redis

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libssl3 \
        libsystemd0 \
        tzdata \
    ; \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/bin/redis-server /usr/local/bin/
COPY --from=build /usr/local/bin/redis-cli /usr/local/bin/
COPY --from=build /usr/local/bin/redis-benchmark /usr/local/bin/
COPY --from=build /usr/local/bin/redis-check-aof /usr/local/bin/
COPY --from=build /usr/local/bin/redis-check-rdb /usr/local/bin/
COPY --from=build /usr/local/bin/redis-sentinel /usr/local/bin/

RUN mkdir /data && chown redis:redis /data

VOLUME /data

WORKDIR /data

COPY --chmod=755 docker-entrypoint.sh /usr/local/bin/

EXPOSE 6379

USER redis

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["redis-server"]
