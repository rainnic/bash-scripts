#!/bin/bash
#
# SETTING:
EXTENSION_IN="mp3" # initial extension
EXTENSION_OUT="mp3" # final extension
RM_FILE=false  # if true, delete initial file after executing command
DEBUG=false    # if true, print statement without executing any command
OPTION="0"
#
# Description of the options:
#
# [0] just clean the file.EXTENSION_IN:
#     replace empty space with "_", remove "(", ")", "-"
#     and put a random character at the beginning
# [1] a commented template
#
#

# Check if the user specifies a destination directory
if [ -n "$1" ]
  then
   directory=$1 # use this new working directory
  else
   directory=$PWD # use the same directory where you have launched the script
fi

eval cd $directory
OLDIFS=$IFS
IFS=$'\n'

for file in `ls *.${EXTENSION_IN}`
do
   newfilename=`echo $file | sed 's/ /_/g'` # change empty spaces with "_"
   newfilename=`echo $newfilename | sed 's/(//g;s/)//g'` # remove "(" and ")"
   newfilename=`echo $newfilename | sed 's/-//g'` # remove "-"
   newfilename=`echo $newfilename | sed "s/'/_/g"` # remove "'" and put "_"
   newfilename=`echo $newfilename | sed 's/^[a-z]_//g'` # remove first "alpha" + "_"

   # Add random character at the beginning
   shuffle=`cat /dev/urandom | tr -cd 'a-z' | head -c 1`
   newfilename="$shuffle"_"$newfilename"

   # Remove the extension
   newfile=${newfilename%.*}
   newfile=`echo $newfile | sed 's/\./_/g'` # if there are some ".", replace them with "_"
   if [ "$DEBUG" == true ]; then echo -e "Remove extension and other dots:\n$newfile"; fi

   if [ "$DEBUG" == true ]; then echo "--------------------"; echo -e "Original file:\n$file"; \
           echo -e "After cleaning:\n$newfile.$EXTENSION_IN"; fi

   if [ "$file" != "$newfile.$EXTENSION_IN" ]
     then
       if [ "$DEBUG" == true ]; then echo -e "Rename file:\nmv $file $newfile.$EXTENSION_IN"; \
           else mv $file $newfile.$EXTENSION_IN;fi
   fi

   case "$OPTION" in
     0)
       if [ "$DEBUG" == true ]; then echo -e "Nothing to do!"; fi
       ;;
#     1) # Add a new option using this template
#       if [ "$DEBUG" == true ]
#         then
#           echo -e "Execute:\n((NEW COMMAND STATEMENT))"
#         else
#           eval ((NEW COMMAND STATEMENT)) \
#           || { echo "$COMMAND failed! Check again the script"; cd $PWD; exit 1; }
#         fi
#       if [[ $RM_FILE == true && $DEBUG == true ]];
#           then echo -e "Delete:\nrm $newfile.$EXTENSION_IN"; fi
#       if [[ $RM_FILE == true && $DEBUG == false ]];
#           then eval rm $newfile.$EXTENSION_IN; fi
#       ;;
     esac
done

# Return in the working directory
cd $PWD
exit 0
