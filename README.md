## Reddit wallpaper scraper
## Description
#### What motivated me
Have you ever spent hours upon hours looking for a nice wallpaper to use, only to end up being disappointed, because most of them is low quality garbage? Well you don't have to worry anymore, because this script will download the finest wallpapers of Reddit and store them in their respective folders.  
#### How it works
This script finds out the image urls from the reddit json data, downloads the images, checks for duplicates and deletes them if need be, and then finally removes low quality images so you don't end up with a bunch of unusable trash.
### Dependencies
It requires `curl jq imagemagick sed fdupes` packages to run
### Settings
Change `directory` and `desiredpixelcount` variables to your liking. Also edit `subreddits.txt` file to suit your needs
### Watch it go
Run `./scrape.sh` and watch the magic happen
