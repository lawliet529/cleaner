FROM alpine:latest

RUN apk add --no-cache bash findutils coreutils tini

COPY cleanup.sh /cleanup.sh
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /cleanup.sh /entrypoint.sh && \
    mkdir -p /var/log && \
    touch /var/log/cleaner.log && \
    chmod 666 /var/log/cleaner.log

ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]