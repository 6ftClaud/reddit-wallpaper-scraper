#!/bin/bash
# Requires sed, identify(imagemagick), jq, curl, fdupes, bc

# DEBUG
[[ ${DEBUG} == "true" ]] && set -x

# Pixel count used to determine image quality. 4 Megapixels is good for 1440p.
[ -z ${PIXEL_COUNT} ] && PIXEL_COUNT=4000000

# <- this is 16:9 aspect ratio
[ -z ${ASPECT_RATIO} ] && ASPECT_RATIO=1.7778 

# Iterate over subreddits defined in the environment variable
for sub in ${SUBREDDITS//,/ }
do
    if ! [ -d $sub ];then
        mkdir $sub
    fi
    cd $sub
    echo -e "\nScraping reddit.com/r/${sub}"
    curl -s -A "bash-scrape" https://www.reddit.com/r/${sub}/top.json | \
            jq '.data.children | .[] | .data.url' | \
            while read -r URL; do
                echo "Downloading $URL"
                wget -q $(echo ${URL} | tr -d \")
            done
    cd ..
done

# Remove duplicates
echo -e "\nRemoving duplicate files\n"
fdupes -Ndqr . &> /dev/null
for file in $(find . -type f -regex '.*\.[0123456789]');do mv $file ${file/.[0123456789]};done

# Remove garbage
for file in $(find . -type f -not -name "*.sh" -not -name "*.txt");do
    chmod 0644 $file
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

    pc=$((w * h))
    ar=$(echo "$w/$h" | bc -l)
    
    # Desired aspect ratio (16:9 is ~1.7778)
    if [[ $(echo "$ar>(${ASPECT_RATIO}-0.05)" | bc) -eq 1 && $(echo "$ar<(${ASPECT_RATIO}+0.05)" | bc) -eq 1 ]];then
        :
    else
        echo "$file aspect ratio is  incorrect: $ar"
        rm $file;exit
    fi
    # Desired pixel amount
    if [[ $pc -lt ${PIXEL_COUNT} ]];then
        echo "$file pixel count is less than ${PIXEL_COUNT} : $pc"
        rm $file
    fi
    )
done
