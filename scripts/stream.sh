#!/bin/bash

DVR_PATH=/dvr
PID=0

CONFIG_FILE="/config/scripts/config"

SCREEN_MODE=
REC_FPS=
OSD=
GPIO_LAYOUT=

WFB_FILE="/etc/default/wifibroadcast"
#Ensure WFB-ng is setup and NICs are available
if [[ -f "$WFB_FILE" ]]; then
    NIC_NAMES=$(grep -oP '^WFB_NICS="\K[^"]+' "$WFB_FILE")
    if [[ -n "$NIC_NAMES" ]]; then
        NICS=($NIC_NAMES)
    else
        echo "No NIC names found in WFB_NICS variable. Exiting."
        exit 1
    fi
else
    echo "File $WFB_FILE not found. Exiting."
    exit 1
fi

sudo systemctl is-active --quiet wifibroadcast || sudo systemctl restart wifibroadcast
sudo systemctl is-active --quiet wifibroadcast@gs || sudo systemctl restart wifibroadcast@gs



#Start PixelPilot
pixelpilot --osd --osd-elements 0 --osd-custom-message --osd-refresh 100 --osd-config /config/scripts/osd.json --screen-mode $SCREEN_MODE --dvr-framerate $REC_FPS --dvr-fmp4 --dvr-sequenced-files --dvr-template $DVR_PATH/record_%Y-%m-%d_%H-%M-%S.mp4 &
PID=$!

#Start MSPOSD on gs-side
if [[ "$OSD" == "ground" ]]; then
    msposd_rockchip --osd --ahi 0 --matrix 11 -v -r 5 --master 0.0.0.0:14551 &
fi

while true; do
    sleep 1
done
