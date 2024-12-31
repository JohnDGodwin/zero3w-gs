#!/bin/bash

pixelpilot --screen-mode-list > available_screen_modes.txt

awk -F'[@x]' '{print $3 " " $1 "x" $2 "@" $3}' available_screen_modes.txt | sort -k1,1nr -k2,2nr | awk '!seen[$1]++ {print $2}' > screen-mode
sed -i '2,$d' screen-mode
rm available_screen_modes.txt

exit 0
