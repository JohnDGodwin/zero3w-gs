#!/bin/bash

pixelpilot --screen-mode-list > available_screen_modes.txt

sed -n '2p' available_screen_modes.txt > screen-mode

rm available_screen_modes.txt

exit 0
