#!/bin/bash

DVR_PATH=/media
SCREEN_MODE=$(</config/scripts/screen-mode)
REC_FPS=$(</config/scripts/rec-fps)
PID=0

DVR_BUTTON=`gpiofind PIN_32`
UP_BUTTON=`gpiofind PIN_16`
DOWN_BUTTON=`gpiofind PIN_18`
LEFT_BUTTON=`gpiofind PIN_13`
RIGHT_BUTTON=`gpiofind PIN_11`
MHZ_BUTTON=`gpiofind PIN_38`

i=0

full_freq_list=("5180" "5200" "5220" "5240" "5260" "5280" "5300" "5320" "5500" "5520" "5540" "5560" "5580" "5600" "5620" "5640" "5660" "5680" "5700" "5720" "5745" "5765" "5785" "5805" "5825")
full_chan_list=("36" "40" "44" "48" "52" "56" "60" "64" "100" "104" "108" "112" "116" "120" "124" "128" "132" "136" "140" "144" "149" "153" "157" "161" "165")
wide_freq_list=("5180" "5220" "5260" "5300" "5500" "5540" "5580" "5620" "5660" "5700" "5745" "5785" "5825")
wide_chan_list=("36" "44" "52" "60" "100" "108" "116" "124" "132" "140" "149" "157" "165")
FILE="/etc/default/wifibroadcast"
WFB_CFG="/etc/wifibroadcast.cfg"

#Ensure WFB-ng is setup and NICs are available
if [[ -f "$FILE" ]]; then
    NIC_NAMES=$(grep -oP '^WFB_NICS="\K[^"]+' "$FILE")
    if [[ -n "$NIC_NAMES" ]]; then
        NICS=($NIC_NAMES)
    else
        echo "No NIC names found in WFB_NICS variable. Exiting."
        exit 1
    fi
else
    echo "File $FILE not found. Exiting."
    exit 1
fi


#Start PixelPilot
pixelpilot --osd --osd-elements video --screen-mode $SCREEN_MODE --dvr-framerate $REC_FPS --dvr-fmp4 --dvr-template $DVR_PATH/record_%Y-%m-%d_%H-%M-%S.mp4 &
PID=$!


#Begin monitoring gpio for button presses
echo "Monitoring buttons"

while true; do

        DVR_BUTTON_STATE=$(gpioget $DVR_BUTTON)
        MHZ_BUTTON_STATE=$(gpioget $MHZ_BUTTON)
        UP_BUTTON_STATE=$(gpioget $UP_BUTTON)
        DOWN_BUTTON_STATE=$(gpioget $DOWN_BUTTON)

        if [ "$DVR_BUTTON_STATE" -eq 1 ]; then
                echo "toggle DVR for $PID"
                kill -SIGUSR1 $PID
                sleep 1


        elif [ "$MHZ_BUTTON_STATE" -eq 1 ]; then
                echo "toggling 40MHz bandwidth"
                if [[ -f "$WFB_CFG" ]]; then
                        bandwidth=$(grep '^bandwidth =' $WFB_CFG | cut -d'=' -f2 | sed 's/^ //')
                else
                        echo "File $WFB_CFG not found."
                fi

                if [[ $bandwidth -eq 20 ]]; then
                        echo "setting to 40MHz"
                        sudo sed -i "/^bandwidth =/ s/=.*/= 40/" $WFB_CFG
                        sudo systemctl restart wifibroadcast
                elif [[ $bandwidth -eq 40 ]]; then
                        echo "setting to 20MHz"
                        sudo sed -i "/^bandwidth =/ s/=.*/= 20/" $WFB_CFG
                        sudo systemctl restart wifibroadcast
                fi
        
        elif [ "$UP_BUTTON_STATE" -eq 1 ]; then
                bandwidth=$(grep '^bandwidth =' $WFB_CFG | cut -d'=' -f2 | sed 's/^ //')
                if [ "$bandwidth" -eq 20 ]; then
                        i=$((i+1))
                        if [[ $i -gt 24 ]]
                        then
                                i=0
                        fi
                        Freq=${full_freq_list[$i]}
                        Chan=${full_chan_list[$i]}
                        for NIC in "${NICS[@]}"; do
                                sudo iw "$NIC" set freq $Freq
                        done
                        sudo sed -i "s/wifi_channel = .*/wifi_channel = $Chan/" /etc/wifibroadcast.cfg
                        echo "$Freq"
                elif [ "$bandwidth" -eq 40 ]; then
                        i=$((i+1))
                        if [[ $i -gt 12 ]]
                        then
                                i=0
                        fi
                        Freq=${wide_freq_list[$i]}
                        Chan=${wide_chan_list[$i]}
                        for NIC in "${NICS[@]}"; do
                                sudo iw "$NIC" set freq $Freq
                        done
                        sudo sed -i "s/wifi_channel = .*/wifi_channel = $Chan/" /etc/wifibroadcast.cfg
                        echo "$Freq"
                fi

        elif [ "$DOWN_BUTTON_STATE" -eq 1 ]; then
                bandwidth=$(grep '^bandwidth =' $WFB_CFG | cut -d'=' -f2 | sed 's/^ //')
                if [ "$bandwidth" -eq 20 ]; then
                        i=$((i-1))
                        if [[ $i -lt 0 ]]
                        then
                                i=24
                        fi
                        Freq=${full_freq_list[$i]}
                        Chan=${full_chan_list[$i]}
                        for NIC in "${NICS[@]}"; do
                                sudo iw "$NIC" set freq $Freq
                        done
                        sudo sed -i "s/wifi_channel = .*/wifi_channel = $Chan/" /etc/wifibroadcast.cfg
                        echo "$Freq"
                elif [ "$bandwidth" -eq 40 ]; then
                        i=$((i-1))
                        if [[ $i -lt 0 ]]
                        then
                                i=12
                        fi
                        Freq=${wide_freq_list[$i]}
                        Chan=${wide_chan_list[$i]}
                        for NIC in "${NICS[@]}"; do
                                sudo iw "$NIC" set freq $Freq
                        done
                        sudo sed -i "s/wifi_channel = .*/wifi_channel = $Chan/" /etc/wifibroadcast.cfg
                        echo "$Freq"
                fi
        fi
sleep 0.1
done