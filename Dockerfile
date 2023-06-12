FROM alpine:latest

# Download necessary packages
RUN apk update \
    && apk upgrade \
    && apk add sed imagemagick jq curl wget fdupes bc bash file

# Add docker user
RUN adduser -D -u 1000 -s /bin/bash docker

# Copy source code
COPY --chown=docker:docker src/* /srv/
# Set permissions
RUN chmod +x /srv/*.sh && chown docker:docker /srv/*.sh

# Create Volume
RUN mkdir /data && chown -R docker:docker /data
VOLUME /data

# Set user and working directory
USER docker
WORKDIR /data

# Set entrypoint
ENTRYPOINT /srv/scrape.sh
