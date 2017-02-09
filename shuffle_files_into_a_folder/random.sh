#!/bin/bash
#
# MP3 with target Volume sets to 95 db
# Last edited on 2017/01/14 --> added a clean/shuffle option and help
#
# SETTING:
EXTENSION_IN="mp3" # initial extension
EXTENSION_OUT="mp3" # final extension
RM_FILE=false  # if true, delete initial file after executing command
DEBUG=false    # if true, print statement without executing any command
CLEAN=false    # if true, only clean all the file
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

if [ -z "$1" ] || [ -z "$2" ]
  then
   echo "Usage: -clean or -shuffle and directory"
   echo ""
   exit 0
fi

if [ "$1" == "-clean" ]
  then
   CLEAN=true # if true, only clean all the file
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
container=()
fiter=0
iterazioni=28

for file in `ls *.${EXTENSION_IN}`
do
   newfilename=`echo $file | sed 's/ /_/g'` # change empty spaces with "_"
   newfilename=`echo $newfilename | sed 's/(//g;s/)//g'` # remove "(" and ")"
   newfilename=`echo $newfilename | sed 's/-//g'` # remove "-"
   newfilename=`echo $newfilename | sed "s/'/_/g"` # remove "'" and put "_"
   newfilename=`echo $newfilename | sed 's/^[a-z0-9]_//g'` # remove first "alpha" + "_"

   # Vecchio random Add random character at the beginning
   #shuffle=`cat /dev/urandom | tr -cd 'a-z0-9' | head -c 1`
   #newfilename="$shuffle"_"$newfilename"

if [ "$CLEAN" == false ]; then
# INIZIO NUOVO

# Add random character at the beginning
   shuffle=`cat /dev/urandom | tr -cd 'a-z0-9' | head -c 1`
   fiter=$[$fiter+1]
   echo "Il file processato è il numero $fiter"

if [ "${#container[*]}" == 0 ]
   then
      container=($shuffle)
      newfilename="$shuffle"_"$newfilename"
      echo "la prima matrice è ${container[@]}"
      echo "La matrice ora contiene ${#container[*]} elementi"
   else
      iter=${#container[*]}
      echo "La matrice contiene $iter elementi"
      if [ $iter -lt $iterazioni ] 
         then
         shuffle=`cat /dev/urandom | tr -cd 'a-z0-9' | head -c 1`
                          # fonte: http://stackoverflow.com/questions/3685970/check-if-an-array-contains-a-value
                          if [[ " ${container[@]} " =~ " ${shuffle} " ]]; then
                            while [[ " ${container[@]} " =~ " ${shuffle} " ]]
                               do
                               shuffle=`cat /dev/urandom | tr -cd 'a-z0-9' | head -c 1`
                            done
                            container[$iter]=$shuffle
                            newfilename="$shuffle"_"$newfilename"
                            echo "UGUALE La matrice ora contiene ${#container[*]} elementi"
                          else
                            container[$iter]=$shuffle
                            newfilename="$shuffle"_"$newfilename"
                            echo "DIFFERENTE La matrice ora contiene ${#container[*]} elementi"
                          fi
         echo "la nuova matrice è ${container[@]}"
         echo " "
         else
         container=()
         shuffle=`cat /dev/urandom | tr -cd 'a-z0-9' | head -c 1`
      container=($shuffle)
      newfilename="$shuffle"_"$newfilename"
      echo "la prima matrice è ${container[@]}"
      echo "La matrice ora contiene ${#container[*]} elementi"
         echo "la nuova matrice è ${container[@]}"
      fi
fi

# FINE NUOVO
fi

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
