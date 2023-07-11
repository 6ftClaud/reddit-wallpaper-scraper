## Reddit wallpaper scraper
## Description
#### Why? 
Have you ever spent hours upon hours looking for a nice wallpaper to use, only to end up being disappointed, because most of them is low quality garbage? Well you don't have to worry anymore, because this script will download the finest wallpapers of Reddit and store them in their respective folders.  
#### How it works
This script finds out the image urls from the reddit json data, downloads the images, checks for duplicates and deletes them if need be, and then finally removes low quality images so you don't end up with a bunch of unusable trash.
### Environment variables
|Key|Definition|Possible values|
|---|---|---|
|DEBUG|See exactly what's happening|`true`|
|SUBREDDITS|List of subreddits separated by comma|`wallpaper,wallpapers`|  
|PIXEL_COUNT|Desired pixel count|Defaults to `4000000`|
|ASPECT_RATIO|Desired aspect ratio|Defaults to `1.7778` (16:9)|
### Run it
#### docker run
```bash
docker run --rm -it \
    -e SUBREDDITS="wallpaper,wallpapers,DigitalArt" \
    -v /home/user/Pictures/Backgrounds:/data \
    ghcr.io/6ftclaud/reddit-wallpaper-scraper/rws:latest
```
#### docker-compose
```yaml
version: "3.7"

services:

  # https://github.com/6ftClaud/reddit-wallpaper-scraper
  reddit-scraper:
    image: ghcr.io/6ftclaud/reddit-wallpaper-scraper/rws:latest
    container_name: reddit-scraper
    volumes:
      - /mnt/Media/Pictures/Backgrounds:/data
    environment:
      SUBREDDITS: "wallpaper,wallpapers,DigitalArt"
    entrypoint: ["bash", "-c"]
    command: ["while true; do /srv/scrape.sh; sleep 1h; done"]
    restart: unless-stopped
    network_mode: bridge
```
