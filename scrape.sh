#!/bin/bash
# Requires sed, idenfify(imagemagick), jq, curl

directory="$HOME/Pictures/RedditScrapes" # Directory to download all your images to
desiredpixelcount=5000000 # Pixel count used to determine image quality. 5000000 is 5MP.
current_directory=$(pwd)
cd $directory

# Scrape reddit from .txt file with list of subreddits
subreddit_file="subreddits.txt"
for sub in $(cat $subreddit_file);do
    if ! [ -d $sub ];then
        mkdir $sub
    fi
    cd $sub
    echo -e "\nScraping reddit.com/r/${sub}"
    curl -s -A "bash-scrape" https://www.reddit.com/r/${sub}/top.json | \
            jq '.data.children | .[] | .data.url' | \
            while read -r URL; do
                echo "Downloading $URL"
                wget -q $(echo ${URL} | tr --delete \")
            done
    cd ..
done

# Remove duplicates
echo -e "\nRemoving duplicate files\n"
fdupes -Ndqr . &> /dev/null

# Remove garbage
for file in $(find . -type f -not -name "*.sh" -not -name "*.txt");do
    filetype=$(file -b $file)

    # Remove HTML files
    if [[ $filetype == *"HTML"* ]];then
        echo "$file is an HTML document, removing"
        rm $file
        continue
    fi

    # Remove pictures with less than desired pixel count
    pixelcount=$(identify -verbose $file | grep "Number pixels" | awk '{print $3}')
    if [[ $pixelcount == *"M"* ]];then
        megapixelcount=${pixelcount/M/}
        pixelcount=$(echo "$megapixelcount*1000000" | bc | cut -d. -f1)
    elif [[ $pixelcount ==  *"K"* ]];then
        kilopixelcount=${pixelcount/K/}
        pixelcount=$(echo "$kilopixelcount*1000" | bc | cut -d. -f1)
    fi
    # Desired pixel amount
    if [[ $pixelcount -lt $desiredpixelcount ]];then
        echo "$file pixel count is less than $desiredpixelcount : $pixelcount"
        rm $file
    fi
done
cd $current_directory
