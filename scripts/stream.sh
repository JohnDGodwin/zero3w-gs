#!/bin/bash

DVR_PATH=/media
SCREEN_MODE=$(</config/scripts/screen-mode)
REC_FPS=$(</config/scripts/rec-fps)


PID=0
DVR_RUNNING=""

BUTTON=`gpiofind PIN_27`

while true; do

    if [ $PID -ne 0 ]; then
        kill -15 $PID
        sleep 0.1
    fi

    if [ "$DVR_RUNNING" = "off" ]; then
        current_date=$(date +'%m-%d-%Y_%H-%M-%S')
        pixelpilot --osd --osd-elements video,wfbng --screen-mode $SCREEN_MODE --dvr-framerate $REC_FPS --dvr-fmp4 --dvr $DVR_PATH/record_${current_date}.mp4 &
        PID=$!
        DVR_RUNNING="on"
    else
        pixelpilot --osd --osd-elements video,wfbng --screen-mode $SCREEN_MODE &
        PID=$!
        DVR_RUNNING="off"
    fi

    # wait 2s to let user release the button
    sleep 2
    # Wait for button click
    gpiomon -F "%e" -n 1 $BUTTON
done
