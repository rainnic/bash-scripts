#!/bin/bash
#
# Changelog
# 2017/01/14 --> clean/shuffle option and help message
# 2017/01/17 --> fixed the help message and clean the script
# 2017/02/11 --> fixed the debug output and optimized the random iteration 
# 2018/03/28 --> change the iteration method and added a function to clean the filename
# 2018/03/29 --> added clean/shuffle option for MP3 tags
# 2018/03/30 --> added a new feature to write MP3 tags starting from the filename
# 2018/03/31 --> adapted the script to work with any files extension
#
# Usage:
# ./random.sh -shuffle directory --> to add a random prefix to a directory of $ext
# ./random.sh -clean directory   --> to remove the prefix to a directory of $ext
# ./random.sh -tags directory    --> to add id3 tags to a directory of mp3
#                                    from the filename: Album-Artist-Title.mp3
#
# If the directory is omitted, the script check only the working directory
#
# in the Setting section of the script, you can change:
# - the extension of the file (now is '$ext')

# SETTING:
ext=mp3		# extension of the files to rename

function cleanfile {
	for file in *.$ext
        do
        if [ "$file" != `echo $file | sed "s/ /_/g; s/(//g;s/)//g; s/'/_/g"` ]
	then 
             mv "$file" `echo $file | sed "s/ /_/g; s/(//g;s/)//g; s/'/_/g"`
	fi
	done
} 

function tags {
    if [ $ext = "mp3" ]; then
        COUNTER=1
	for file in *.$ext
        do
           res="${file//[^-]}"
           items=${#res}
           artist=`id3v2 -l $file | sed -nE 's/^.*Artist: (.*)/\1/p; s/ //g';`
           artistAlt=`id3v2 -l $file | sed -nE 's/^TPE1 \([^)]*\): (.*)/\1/p'`
           if [ `echo -n $artist | wc -c` == 0 ] && [ `echo -n $artistAlt | wc -c` == 0 ]
           then
                echo " "
                echo "$COUNTER) $file hasn't the tags, they will be added."
                COUNTER=$[$COUNTER +1]
                case "$items" in
                      1)
                           id3v2 --album "NA" $file
                           id3v2 --TALB "NA" $file
                           artist=$(echo $file| cut -d'-' -f 1 | sed "s/_/ /g;s/\.[^.]*$//")
                           id3v2 --artist "$artist" $file
                           id3v2 --TPE1 "$artist" $file
                           title=$(echo $file| cut -d'-' -f 2 | sed "s/_/ /g;s/\.[^.]*$//")
                           id3v2 --song "$title" $file
                           id3v2 --TIT2 "$title" $file
                      ;;
                      2) 
                           album=$(echo $file| cut -d'-' -f 1 | sed "s/_/ /g;s/\.[^.]*$//")
                           id3v2 --album "$album" $file
                           id3v2 --TALB "$album" $file
                           artist=$(echo $file| cut -d'-' -f 2 | sed "s/_/ /g;s/\.[^.]*$//")
                           id3v2 --artist "$artist" $file
                           id3v2 --TPE1 "$artist" $file
                           title=$(echo $file| cut -d'-' -f 3 | sed "s/_/ /g;s/\.[^.]*$//")
                           id3v2 --song "$title" $file
                           id3v2 --TIT2 "$title" $file
                      ;;
                      *)
                           printf "\nDo nothing, the \x1b[31m\"$file\"\x1b[0m has a wrong format:\nonly album-artist-title or artist-title is allowed\n"
                      ;;
                esac;
           fi
        done
    fi
}

# Check if id3v2 exists
if [ $ext = "mp3" ] && ! [ -x "$(command -v id3v2)" ]; then
  printf "\nError: in order to execute correctly the script, you have to install \x1b[31mid3v2\x1b[0m.\n\n" >&2
  exit 1
fi

# Check if the user specifies a command or a directory, otherwise print the help message
# if [ -z "$1" ] || [ -z "$2" ]
if [ "$1" != "-clean" ] && [ "$1" != "-shuffle" ] && [ "$1" != "-tags" ]
    then
        echo "Usage:" 
        echo  "./random.sh -shuffle directory --> to add a random prefix to a directory of $ext"
        echo  "./random.sh -clean directory   --> to remove the prefix to a directory of $ext"
        echo  "./random.sh -tags directory    --> to add id3 tags to a directory of mp3"
        echo  "                                   from the filename: Album-Artist-Title.mp3"
        echo  " "
        echo  "If the directory is omitted, the script check only the working directory"
        echo  " "
        echo  "in the Setting section of the script, you can change:"
        echo  "- the extension of the file (now is '$ext')"
        exit 0
fi

# Go in the selected directory
if [ -n "$2" ]
    then
        directory=$2 # use this new working directory
    else
        directory=$PWD # use the same directory where you have launched the script
fi

eval cd $directory

# Cleaning the prefix number from filename and id3 tags!!!
if [ "$1" = "-clean" ]
then
    for i in *.$ext
    do
      [[ $i =~ ^[0-9]+-(.*) ]] || continue
      if [ $ext = "mp3" ]; then
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
      fi
      mv ${BASH_REMATCH[0]} ${BASH_REMATCH[1]}
    done
    cleanfile
elif [ "$1" = "-shuffle" ]; then
    cleanfile
    seq -w 1 `ls *.$ext | wc -l` | shuf | paste - <(ls *.$ext) | while read seq name
    do
      if [ $ext = "mp3" ]; then
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
      fi
      mv $name "$seq-$name"
    done
elif [ "$1" = "-tags" ]; then
    cleanfile
    tags 
fi
