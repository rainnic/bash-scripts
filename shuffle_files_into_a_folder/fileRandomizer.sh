#!/bin/bash
#
# Changelog
# 2017/01/14 --> clean/shuffle option and help message
# 2017/01/17 --> fixed the help message and clean the script
# 2017/02/11 --> fixed the debug output and optimized the random iteration 
#
# SETTING:
EXTENSION_IN="mp3" 	# extension of the files to rename
DEBUG=true    		# if true, print statement after executing the command
iterations=36 		# because the maximum number of iterations (a-z0-9) can only be set to 36


# Check if the user specifies a command or a directory, otherwise print the help message
# if [ -z "$1" ] || [ -z "$2" ]
if [ "$1" != "-clean" ] && [ "$1" != "-shuffle" ]
    then
        echo "Usage:" 
        echo  "./random.sh -shuffle directory --> to add a random prefix to a directory of $EXTENSION_IN"
        echo  "./random.sh -clean directory   --> to remove the prefix to a directory of $EXTENSION_IN"
        echo  " "
        echo  "If the directory is omitted, the script check only the working directory"
        echo  " "
        echo  "in the Setting section of the script, you can change:"
        echo  "- the extension of the file (now is '$EXTENSION_IN')"
        echo  "- the number of iterations (now is '$iterations')"
        exit 0
fi

CLEAN=false
if [ "$1" == "-clean" ]
    then
        CLEAN=true # if true, only clean all the file
    else
        if [ "$DEBUG" == true ]; then echo -e " "; echo -e "--> The number of iterations (a-z0-9) is set to '$iterations' <--"; echo -e " "; fi
fi

if [ -n "$2" ]
    then
        directory=$2 # use this new working directory
    else
        directory=$PWD # use the same directory where you have launched the script
fi


eval cd $directory
OLDIFS=$IFS
IFS=$'\n'
container=() # define an empty array
fiter=0

for file in `ls *.${EXTENSION_IN}`
do
    newfilename=`echo $file | sed 's/ /_/g'` # change empty spaces with "_"
    newfilename=`echo $newfilename | sed 's/(//g;s/)//g'` # remove "(" and ")"
    newfilename=`echo $newfilename | sed 's/-//g'` # remove "-"
    newfilename=`echo $newfilename | sed "s/'/_/g"` # remove "'" and put "_"
    newfilename=`echo $newfilename | sed 's/^[a-z0-9]_//g'` # remove first "a-z0-9" only if followed by "_"

    if [ "$CLEAN" == false ]; then
       # Add random character at the beginning

           shuffle=`cat /dev/urandom | tr -cd 'a-z0-9' | head -c 1`
           if [ "$DEBUG" == true ]; then echo "--------------------"; echo -e "The random letter or number is '$shuffle'"; fi
           fiter=$[$fiter+1]
           if [ "$DEBUG" == true ]; then echo "--------------------"; echo -e "The processed file is the number: $fiter"; fi

       if [ "${#container[*]}" == 0 ]
           then
               container=($shuffle)
               newfilename="$shuffle"_"$newfilename"
               if [ "$DEBUG" == true ]; then echo -e "The first element of the array is ${container[@]}"; fi
               if [ "$DEBUG" == true ]; then echo -e "The array now contains ${#container[*]} element/s"; fi
           else
               iter=${#container[*]}
               if [ $iter -lt $iterations ] 
                  then
                      if [ "$DEBUG" == true ]; then echo -e "The array contains $iter element/s"; fi
                      if [ ${#container[*]} -le "1" ]; then shuffle=`cat /dev/urandom | tr -cd 'a-z0-9' | head -c 1`; fi
                      if [ "$DEBUG" == true ]; then echo -e "The new random element is '$shuffle'"; fi
                      # Source: http://stackoverflow.com/questions/3685970/check-if-an-array-contains-a-value
                      if [[ " ${container[@]} " =~ " ${shuffle} " ]]; then
                          while [[ " ${container[@]} " =~ " ${shuffle} " ]]
                              do
                                  shuffle=`cat /dev/urandom | tr -cd 'a-z0-9' | head -c 1`
                                  if [ "$DEBUG" == true ]; then echo -e "This element is already in the array. The new random one is now '$shuffle'"; fi
                          done
                          container[$iter]=$shuffle
                          newfilename="$shuffle"_"$newfilename"
                          if [ "$DEBUG" == true ]; then echo -e "The array now contains ${#container[*]} element/s: ${container[@]}"; fi
                      else
                          container[$iter]=$shuffle
                          newfilename="$shuffle"_"$newfilename"
                          if [ "$DEBUG" == true ]; then echo -e "The array now contains ${#container[*]} element/s: ${container[@]}"; fi
                      fi
                  if [ "$DEBUG" == true ]; then echo -e " "; fi
                  else
                      container=()
                      shuffle=`cat /dev/urandom | tr -cd 'a-z0-9' | head -c 1`
                      container=($shuffle)
                      newfilename="$shuffle"_"$newfilename"
                      if [ "$DEBUG" == true ]; then echo -e "The array now is: ${container[@]}"; fi
                      if [ "$DEBUG" == true ]; then echo -e "The array now contains: ${#container[*]} element/s"; fi
               fi
       fi
    fi

    # Remove the extension
    newfile=${newfilename%.*}
    newfile=`echo $newfile | sed 's/\./_/g'` # if there are some ".", replace them with "_"

    if [ "$DEBUG" == true ]; then echo -e "Original file:\n$file"; echo -e "After cleaning:\n$newfile.$EXTENSION_IN"; echo -e " "; fi

    if [ "$file" != "$newfile.$EXTENSION_IN" ]
         then
             if [ "$DEBUG" == true ]; then echo -e "Rename file:\nmv $file $newfile.$EXTENSION_IN"; echo -e " "; echo -e " "; fi
             mv $file $newfile.$EXTENSION_IN
    fi
done

# Return in the working directory
cd $PWD
exit 0
