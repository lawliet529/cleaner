FROM alpine:latest

RUN apk add --no-cache bash findutils coreutils tini

COPY cleanup.sh /cleanup.sh
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /cleanup.sh /entrypoint.sh

ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]