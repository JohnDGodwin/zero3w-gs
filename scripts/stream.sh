#!/bin/bash

DVR_PATH=/media
SCREEN_MODE=$(</config/scripts/screen-mode)
REC_FPS=$(</config/scripts/rec-fps)
DVR_SENTINEL=$(</config/scripts/dvr-sentinel)

PID=0
BUTTON=`gpiofind PIN_32`

pixelpilot --osd --osd-elements video --screen-mode $SCREEN_MODE --dvr-framerate $REC_FPS --dvr-fmp4 --dvr-template $DVR_PATH/record_$DVR_SENTINEL.mp4 &
PID=$!

while true; do
    # Wait for button click
    gpiomon -F %e -n 1 $BUTTON
    echo "toggle DVR for $PID"
    kill -SIGUSR1 $PID
    # wait 2s to let user release the button
    sleep 2
done
