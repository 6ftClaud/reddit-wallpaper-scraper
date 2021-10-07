FROM alpine:latest

RUN apk update \
    && apk upgrade -y \
    && apk add sed identify jq curl fdupes bc

WORKDIR /root

COPY scrape.sh .
COPY subreddits.txt .

RUN chmod +x scrape.sh

RUN echo "while true;do ./scrape.sh;sleep 6h;done"