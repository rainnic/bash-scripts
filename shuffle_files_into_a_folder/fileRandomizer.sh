#!/bin/bash
#
# Changelog
# 2017/01/14 --> clean/shuffle option and help message
# 2017/01/17 --> fixed the help message and clean the script
# 2017/02/11 --> fixed the debug output and optimized the random iteration 
# 2018/03/28 --> change the iteration method and added a function to clean the filename
# 2018/03/29 --> added clean/shuffle option for MP3 tags
#
# Usage:
# ./random.sh -shuffle directory --> to add a random prefix to a directory of $ext
# ./random.sh -clean directory   --> to remove the prefix to a directory of $ext
#
# If the directory is omitted, the script check only the working directory
#
# in the Setting section of the script, you can change:
# - the extension of the file (now is '$ext')

# SETTING:
ext=mp3		# extension of the files to rename
DEBUG=true    	# if true, print statement after executing the command

function cleanfile {
	for file in *.$ext
        do
	#if [ "$file" != `echo $file | sed "s/ /_/g; s/(//g;s/)//g; s/-//g; s/'/_/g"` ]
        if [ "$file" != `echo $file | sed "s/ /_/g; s/(//g;s/)//g; s/'/_/g"` ]
	then 
	     #mv "$file" `echo $file | sed "s/ /_/g; s/(//g;s/)//g; s/-//g; s/'/_/g"`
             mv "$file" `echo $file | sed "s/ /_/g; s/(//g;s/)//g; s/'/_/g"`
	fi
	done
} 

# Check if the user specifies a command or a directory, otherwise print the help message
# if [ -z "$1" ] || [ -z "$2" ]
if [ "$1" != "-clean" ] && [ "$1" != "-shuffle" ]
    then
        echo "Usage:" 
        echo  "./random.sh -shuffle directory --> to add a random prefix to a directory of $ext"
        echo  "./random.sh -clean directory   --> to remove the prefix to a directory of $ext"
        echo  " "
        echo  "If the directory is omitted, the script check only the working directory"
        echo  " "
        echo  "in the Setting section of the script, you can change:"
        echo  "- the extension of the file (now is '$ext')"
        exit 0
fi

if [ -n "$2" ]
    then
        directory=$2 # use this new working directory
    else
        directory=$PWD # use the same directory where you have launched the script
fi

eval cd $directory

if [ "$1" = "-clean" ]
then
    for i in *.$ext
    do
        [[ $i =~ ^[0-9]+-(.*) ]] || continue
        title=`id3v2 -l $i | awk 'gsub(/.*Title  : |Artist.*/,"")'`
        title=`echo $title | sed 's/^[0-9]*-//g'`
        id3v2 --song "$title" $i
        id3v2 --TIT2 "$title" $i
        artist=`id3v2 -l $i | sed -nE 's/^.*Artist: (.*)/\1/p; s/ //g';`
        artist=`echo $artist | sed 's/^[0-9]*-//g'`
        id3v2 --artist "$artist" $i
        id3v2 --TPE1 "$artist" $i
        album=`id3v2 -l $i | awk 'gsub(/.*Album  : |Year:.*/,"")'`
        album=`echo $album | sed 's/^[0-9]*-//g'`
        id3v2 --album "$album" $i
        id3v2 --TALB "$album" $i
        mv ${BASH_REMATCH[0]} ${BASH_REMATCH[1]}
    done
    cleanfile
else
    cleanfile
    seq -w 1 `ls *.$ext | wc -l` | shuf | paste - <(ls *.$ext) | while read seq name
    do
        title=`id3v2 -l $name | awk 'gsub(/.*Title  : |Artist.*/,"")'`
        if [ `echo -n $title | wc -c` = 0 ]; then title=`id3v2 -l $name | sed -nE 's/^TIT2 \([^)]*\): (.*)/\1/p'`; fi
        if [ `echo -n $title | wc -c` = 0 ]; then title=${name%.*}; fi
        id3v2 --song "$seq-$title" $name
        # TIT2
        id3v2 --TIT2 "$seq-$title" $name
        # echo "$seq-$title"
        artist=`id3v2 -l $name | sed -nE 's/^.*Artist: (.*)/\1/p; s/ //g';`
        if [ `echo -n $artist | wc -c` = 0 ]; then artist=`id3v2 -l $name | sed -nE 's/^TPE1 \([^)]*\): (.*)/\1/p'`; fi
        id3v2 --artist "$seq-$artist" $name
        # TPE1
        id3v2 --TPE1 "$seq-$artist" $name
        album=`id3v2 -l $name | awk 'gsub(/.*Album  : |Year:.*/,"")'`
        if [ `echo -n $album | wc -c` = 0 ]; then album=`id3v2 -l $name | sed -nE 's/^TALB \([^)]*\): (.*)/\1/p'`; fi
        id3v2 --album "$seq-$album" $name
        # TALB
        id3v2 --TALB "$seq-$album" $name
        mv $name "$seq-$name"
    done
fi
