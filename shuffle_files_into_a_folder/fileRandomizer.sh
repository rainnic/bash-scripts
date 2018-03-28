#!/bin/bash
#
# Changelog
# 2017/01/14 --> clean/shuffle option and help message
# 2017/01/17 --> fixed the help message and clean the script
# 2017/02/11 --> fixed the debug output and optimized the random iteration 
# 2018/03/28 --> change the iteration method and added a function to clean the filename
#
# Usage:
#   -shuffle $2  # renames all mp3 files in $2 or $PWD by prefixing a random sequence number and a hyphen
#   -clean $2    # renames all mp3 files in $2 or $PWD by removing any leading digits and a hyphen

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
#OLDIFS=$IFS
#IFS=$'\n'

if [ "$1" = "-clean" ]
then
    for i in *.$ext
    do
        [[ $i =~ ^[0-9]+-(.*) ]] || continue
        mv ${BASH_REMATCH[0]} ${BASH_REMATCH[1]}
    done
    cleanfile
else
    cleanfile
    seq -w 1 `ls *.$ext | wc -l` | shuf | paste - <(ls *.$ext) | while read seq name
    do
        mv $name "$seq-$name"
    done
fi
