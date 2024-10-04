#!/bin/bash

#This script will setup a radxa zero 3w for OpenIPC

#installing the base system

#setting up a the image
#change passwd for root to root

#edit /etc/ssh/sshd_config to allow for root login via ssh

#sudo systemctl enable ssh
systemctl enable ssh

#setup scripts folder
mkdir /config/scripts
cp scripts/* /config/scripts/

#setup openipc systemd service
cp openipc/openipc.service /etc/systemd/system/
systemctl disable openipc.service

#update and upgrade system
apt update && apt -y upgrade

#install prerequisite programs
apt install -y git cmake

#install AU driver
cp drivers/88XXau_wfb.ko /lib/modules/5.10.160-38-rk356x/kernel/drivers/net/wireless/

#install EU driver
cp drivers/8812eu.ko /lib/modules/5.10.160-38-rk356x/kernel/drivers/net/wireless/

#install wfb-ng
git clone https://github.com/svpcom/wfb-ng.git
cd wfb-ng
./scripts/install_gs.sh rtl0

systemctl enable wifibroadcast
systemctl enable wifibroadcast@gs

cd ..


#edit /etc/wifibroadcast to region 00
cp wfbng/wifibroadcast.cfg /etc/

#transfer stock gs.key to /etc
cp wfbng/gs.key /etc/


#install PixelPilot
apt install -y librockchip-mpp-dev
apt install -y libdrm-dev libcairo-dev
apt --no-install-recommends -y install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools

clone https://github.com/OpenIPC/PixelPilot_rk.git
cd PixelPilot_rk
cmake -B build
cmake --build build --target install
cd ..


#configure hotplugging of wfb-nics
git clone https://github.com/JohnDGodwin/hot-plug-wfb-nics.git
cd hot-plug-wfb-nics
chmod +x autoload-wfb-nics.sh
cp autoload-wfb-nics.sh /config/scripts/
cp init-nics.service /etc/systemd/system/
systemctl enable init-nics.service
cp 98-custom-wifi.rules /etc/udev/rules.d/
cd ..

#install the media server for dvr
apt -y install nginx-light
chmod o+x /media
mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.old
cp nginx/default /etc/nginx/sites-available/

