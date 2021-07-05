#!/bin/bash
# Requires sed, identify(imagemagick), jq, curl, fdupes, bc

#DEBUG
#set -x

directory="$HOME/Pictures/Backgrounds" # Directory to download all your images to
desired_pixel_count=4000000 # Pixel count used to determine image quality. 4 Megapixels is good for 1440p.
desired_aspect_ratio=1.7778 # <- this is 16:9 aspect ratio
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
for file in $(find . -type f -name "*.1");do mv $file ${file/.1};done

# Remove garbage
for file in $(find . -type f -not -name "*.sh" -not -name "*.txt");do
    filetype=$(file -b $file)

    # Remove HTML and GIF files
    if [[ $filetype == *"HTML"* ]] || [[ $file == *".gif"* ]];then
        echo "$file is an unwanted type of file, removing"
        rm $file;continue
    fi

    # Remove pictures with less than desired pixel count or aspect ratio
    identify $file | awk '{print $3}' | ( while read pixels;do
        w=$(echo $pixels | awk -F 'x' '{print $1}')
        h=$(echo $pixels | awk -F 'x' '{print $2}')
    done

    pixelcount=$((w * h))
    aspect_ratio=$(echo "$w/$h" | bc -l)
    
    # Desired aspect ratio (16:9 is ~1.7778)
    if [[ $(echo "$aspect_ratio>($desired_aspect_ratio-0.05)" | bc) -eq 1 && $(echo "$aspect_ratio<($desired_aspect_ratio+0.05)" | bc) -eq 1 ]];then
        :
    else
        echo "$file aspect ratio is  incorrect: $aspect_ratio"
        rm $file;exit
    fi
    # Desired pixel amount
    if [[ $pixelcount -lt $desired_pixel_count ]];then
        echo "$file pixel count is less than $desired_pixel_count : $pixelcount"
        rm $file
    fi
    )
done
cd $current_directory
