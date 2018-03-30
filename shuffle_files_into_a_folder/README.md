Shuffle a list of files into a folder
=====================================

The script removes empty spaces and the special characters (', " and -) from the files and then it shuffles them by adding a random number followed by an underscore.

# Usage
First you have to check the SETTINGS section of the script and change if is necessary:

```
# SETTINGS:
EXTENSION_IN="mp3" 	# extension of the files to randomize
```

In this case the files to randomize and rename is MP3s and the debug is set to true

After fixed, it works in this manner:

```
./random.sh -shuffle directory --> to add a random prefix to a directory of mp3
./random.sh -clean directory   --> to remove the prefix to a directory of mp3
./random.sh -tags directory    --> to add id3 tags to a directory of mp3
                                   from the filename: Album-Artist-Title.mp3
```

__NOTE__: the directory is not necessary if you have the files in the working directory.

More info on my site:
http://rainnic.altervista.org/tag/bash
