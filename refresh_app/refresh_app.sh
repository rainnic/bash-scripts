#!/bin/bash
#  $HOME/Script/refresh_app.sh
#
#  This script kills and reloads an application after a specified amount of time,
#  moving it in the previous workspace and position
#
#  Created by Nicola Rainiero
#  More info on my site:
#  https://rainnic.altervista.org/en/tag/bash
#
#
#  Usage after editing the SETTINGS section:
#  chmod a+x refresh_app.sh
#  ./refresh_app.sh


## SETTINGS:						# HELP:
executable="/usr/bin/your_application_executable"	# :~$ whereis application_name
process_name="your_application_process"			# :~$ ps -u $USER |more
program_name="your_application_name"			# :~$ wmctrl -l
program_coordinates="2,x,y,width,height"		# :~$ wmctrl -lG (in pixel)
workspace_number=0					# 0 if it is in the first workspace
interval=600 						# in seconds

while true
do 
    kill `pidof $executable`
    sleep 5
    eval "$executable" &
    code=`wmctrl -l | grep -E "$program_name" | sed -e 's/\s.*$//'`
    until [ ! -z "$code" ]
        do
          sleep 0.1
          code=`wmctrl -l | grep -E "$program_name" | sed -e 's/\s.*$//'`
        done
    wmctrl -i -r $code -t $workspace_number # move to exact workspace
    wmctrl -i -r $code -e "$program_coordinates" # move to the exact position
    sleep $interval
done
