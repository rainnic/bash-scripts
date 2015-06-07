#!/bin/bash
# pdf2cmyk.sh
#		Created by Nicola Rainiero
#		http://rainnic.altervista.org/tag/bash
#		--------------------------------------
# Usage:
# bash pdf2cmyk.sh <file.pdf>
# ./pdf2cmyk.sh <file.pdf>
#
# Requirements: Ghostscript, ImageMagick
# 
# The script allows you to:
# - check if the input file has already the colorspace in CMYK 
# - convert a <file.pdf> into a new <file_cmyk.pdf> with the colorspace in CMYK
# - create two jpegs
#      <file.jpg> with the original colorspace
#      <file_cmyk.jpg> with the colorspace in CMYK
# - reduce the size of the jpegs by:
    reduction=70     #<-- percent (change if you want)
    quality=85       #<-- 1 to 100 (change if you want, 100 is the best) 
# - print the colorspace for all the files 


# Check if the user specifies a video file
if [ -z "$1" ]; then
	echo "Usage: pdf2cmyk <yourFile.pdf>"
	exit 3
fi

# Check if the file exist
if [ ! -f $1 ]; then
   echo "The file '$1' does not exist"
   exit 3
fi

# Check if the input file has already the colorspace in CMYK 
colorSpace=$(identify -format '%[colorspace]' $1)
if [ "$colorSpace" = "CMYK" ]; then
	read -n 1 -p "The $1 is already in CMYK, do you want to convert it too? " ans_yn
	case "$ans_yn" in
		[Yy]|[Yy][Ee][Ss]) echo " ";;
		*) echo " "; exit 3;;
	esac
fi

# Create a new pdf terminating in "_cmyk" with the CMYK colorspace
gs -o ${1%%.pdf}_cmyk.pdf \
       -sDEVICE=pdfwrite \
       -sProcessColorModel=DeviceCMYK \
       -sColorConversionStrategy=CMYK \
       -sColorConversionStrategyForImages=CMYK \
       $1

# Create two jpg files
convert ${1%%.pdf}_cmyk.pdf ${1%%.pdf}_cmyk.jpg
convert $1 ${1%%.pdf}.jpg

# Save the size of the jpeg
width=$(identify -format "%w"  ${1%%.pdf}.jpg)
height=$(identify -format "%h"  ${1%%.pdf}.jpg)
# Resize them opportunely
if [ "$width" -gt "$height" ]; then
	mogrify -resize $(($width*$reduction/100))x$(($width*$reduction/100)) -quality $quality ${1%%.pdf}.jpg
	mogrify -resize $(($width*$reduction/100))x$(($width*$reduction/100)) -quality $quality ${1%%.pdf}_cmyk.jpg
else
	mogrify -resize $(($height*$reduction/100))x$(($height*$reduction/100)) -quality $quality ${1%%.pdf}.jpg
	mogrify -resize $(($height*$reduction/100))x$(($height*$reduction/100)) -quality $quality ${1%%.pdf}_cmyk.jpg
fi

# Print the colorspace for all the files 
echo "The colorspace for ${1%%.pdf}.jpg is $(identify -format '%[colorspace]' ${1%%.pdf}.jpg)"
echo "The colorspace for ${1%%.pdf}_cmyk.jpg is $(identify -format '%[colorspace]' ${1%%.pdf}_cmyk.jpg)"
echo "The colorspace for $1 is $(identify -format '%[colorspace]' $1)"
echo "The colorspace for ${1%%.pdf}_cmyk.pdf is $(identify -format '%[colorspace]' ${1%%.pdf}_cmyk.pdf)"

exit 0
