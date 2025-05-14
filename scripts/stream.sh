#!/bin/bash

DVR_PATH=/dvr
PID=0

CONFIG_FILE="/config/scripts/config"

if [[ -f "$CONFIG_FILE" ]]; then
    SCREEN_MODE=$(awk '/\[screen mode\]/{f=1} f==1 && /mode =/{print $3; exit}' "$CONFIG_FILE")
    REC_FPS=$(awk '/\[dvr recording\]/{f=1} f==1 && /fps =/{print $3; exit}' "$CONFIG_FILE")
    GPIO_LAYOUT=$(awk '/\[gpio\]/{f=1} f==1 && /gpio_layout =/{print $3; exit}' "$CONFIG_FILE")
    OSD=$(awk '/\[msposd\]/{f=1} f==1 && /render =/{print $3; exit}' "$CONFIG_FILE")
else
    echo "File $CONFIG_FILE not found. Exiting."
    exit 1
fi

#Assign GPIO layout
case "$GPIO_LAYOUT" in
    Ruby|ruby)
        sudo cp /config/scripts/gpio/Ruby.yaml /etc/pixelpilot.yaml
        ;;
    Runcam|runcam)
        sudo cp /config/scripts/gpio/Runcam.yaml /etc/pixelpilot.yaml
        ;;
    Emax|emax)
        sudo cp /config/scripts/gpio/Emax.yaml /etc/pixelpilot.yaml
        ;;
    Custom|custom)
        sudo cp /config/scripts/gpio/Custom.yaml /etc/pixelpilot.yaml
        ;;
    *)
        echo "Invalid GPIO layout specified in $CONFIG_FILE. Exiting."
        exit 1
        ;;
esac


#Ensure WFB-ng is setup and NICs are available
WFB_FILE="/etc/default/wifibroadcast"

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
pixelpilot --osd --osd-custom-message --osd-config /config/scripts/osd.json --screen-mode $SCREEN_MODE --dvr-framerate $REC_FPS --dvr-fmp4 --dvr-sequenced-files --dvr-template $DVR_PATH/record_%Y-%m-%d_%H-%M-%S.mp4 &
PID=$!

#Start MSPOSD on gs-side
if [[ "$OSD" == "ground" ]]; then
    msposd_rockchip --osd --ahi 0 --matrix 11 -v -r 5 --master 0.0.0.0:14551 &
fi

# Keep the script running
while true; do
    sleep 1
done
