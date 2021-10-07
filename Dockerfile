FROM alpine:latest

RUN apk update \
    && apk upgrade \
    && apk add sed imagemagick jq curl fdupes bc bash file

COPY scrape.sh /root/
COPY subreddits.txt /root/

RUN echo "while true;do bash /root/scrape.sh;sleep 6h;done" >> /root/entrypoint.sh

RUN chmod +x /root/*.sh

ENTRYPOINT /root/entrypoint.sh