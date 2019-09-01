Shuffle a list of files into a folder
=====================================

This script kills and reloads an application after a specified amount of time, moving it in the previous workspace and position.

# Usage
First you have to check the SETTINGS section of the script and change if is necessary:

```
## SETTINGS:						# HELP:
executable="/usr/bin/your_application_executable"	# :~$ whereis application_name
process_name="your_application_process"			# :~$ ps -u $USER |more
program_name="your_application_name"			# :~$ wmctrl -l
program_coordinates="2,x,y,width,height"		# :~$ wmctrl -lG (in pixel)
workspace_number=0					# 0 if it is in the first workspace
interval=600 						# in seconds
```

In this case the files to randomize and rename is MP3s and the debug is set to true

After fixed, it works in this manner:

```
chmod a+x refresh_app.sh
./refresh_app.sh
```

Created by Nicola Rainiero

More info on my site:
https://rainnic.altervista.org/en/tag/bash
