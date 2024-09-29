#!/bin/bash

#This script will setup a radxa zero 3w for OpenIPC

#setting up a few things
#step 1 - change passwd for root to root
#step 2 - edit /etc/ssh/sshd_config to allow for root login via ssh
#step 3 - sudo systemctl enable ssh



#installing the base system

#update and upgrade system
sudo apt update && sudo apt -y upgrade

#install prerequisite programs
sudo apt install -y git cmake

#install AU driver
git clone https://github.com/svpcom/rtl8812au.git
cd rtl8812au
sudo ./dkms-install.sh
cd ..

#install EU driver
git clone https://github.com/svpcom/rtl8812eu.git
cd rtl8812eu
sudo ./dkms-install.sh
cd ..

#install wfb-ng
git clone https://github.com/svpcom/wfb-ng.git
cd wfb-ng
sudo ./scripts/install_gs.sh rtl0

sudo systemctl enable wifibroadcast
sudo systemctl enable wifibroadcast@gs

cd ..

#edit /etc/wifibroadcast to region 00
#

#transfer stock gs.key to /etc
cd wfbng_scripts


#install PixelPilot
git clone https://github.com/rockchip-linux/mpp.git
cd mpp
cmake -B build
sudo cmake --build build --target install -j4
cd ..

sudo apt install -y libdrm-dev libcairo-dev
sudo apt --no-install-recommends -y install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools

git clone https://github.com/OpenIPC/PixelPilot_rk.git
cd PixelPilot_rk
cmake -B build
sudo cmake --build build --target install
cd ..


#configure hotplugging of wfb-nics
git clone https://github.com/JohnDGodwin/hot-plug-wfb-nics.git
cd hot-plug-wfb-nics
sudo chmod +x autoload-wfb-nics.sh
sudo cp autoload-wfb-nics.sh /config/scripts/
sudo cp init-nics.service /etc/systemd/system/
sudo systemctl enable init-nics.service
sudo cp 98-custom-wifi.rules /etc/udev/rules.d/
cd ..
