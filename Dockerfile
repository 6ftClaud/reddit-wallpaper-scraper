FROM alpine:latest

RUN apk update \
    && apk upgrade \
    && apk add sed imagemagick jq curl wget fdupes bc bash file

RUN adduser -D -u 1000 -s /bin/bash scraper

COPY src/* /tmp/

RUN mkdir /data

RUN chmod +x /tmp/*.sh \
    && chown scraper:scraper /tmp/*.sh \
    && chown -R scraper:scraper /data

USER scraper:scraper
WORKDIR /data
ENTRYPOINT /tmp/scrape.sh