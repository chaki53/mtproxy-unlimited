# MTProxy Unlimited — Telegram MTProxy without 16 secret limit
# Supports up to 10,000 secrets in a single container
# Based on official Telegram MTProxy source code with patched limit

FROM debian:bullseye-slim AS builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git make gcc libssl-dev zlib1g-dev curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

ARG MAX_SECRETS=10000

RUN cd /tmp && \
    git clone https://github.com/TelegramMessenger/MTProxy.git && \
    cd MTProxy && \
    sed -i "s/ext_secret_cnt < 16/ext_secret_cnt < ${MAX_SECRETS}/" net/net-tcp-rpc-ext-server.c && \
    make -j$(nproc)

FROM debian:bullseye-slim

LABEL maintainer="MTProxy Unlimited"
LABEL description="Telegram MTProxy with unlimited secrets support"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libssl1.1 zlib1g curl ca-certificates iproute2 && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /etc/telegram /data

COPY --from=builder /tmp/MTProxy/objs/bin/mtproto-proxy /usr/local/bin/mtproto-proxy
COPY hello-explorers /etc/telegram/hello-explorers-how-are-you-doing
COPY run.sh /run.sh

RUN chmod +x /usr/local/bin/mtproto-proxy /run.sh

EXPOSE 443
VOLUME ["/data"]

ENV WORKERS=2
ENV SECRET=""

CMD ["/bin/bash", "/run.sh"]
