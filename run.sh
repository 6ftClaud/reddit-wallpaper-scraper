#!/bin/bash
docker build -t 6ftclaud/reddit-scraper:latest .
docker run -it --rm -v /home/claud/Code/reddit-wallpaper-scraper/testdir:/data 6ftclaud/reddit-scraper:latest
