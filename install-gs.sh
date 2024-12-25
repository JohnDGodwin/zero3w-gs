#!/bin/bash

#This script will setup a radxa zero 3w for OpenIPC

#installing the base system

#setting up a the image
#change passwd for root to root

#edit /etc/ssh/sshd_config to allow for root login via ssh

#sudo systemctl enable ssh
echo "systemctl enable ssh"
systemctl enable ssh

###

#setup scripts folder
echo "setting up scripts folder"
mkdir /config/scripts
cp /zero3w-gs/scripts/* /config/scripts/

###

#setup openipc systemd service
echo "setting up openipc systemd service"
cp /zero3w-gs/openipc/openipc.service /etc/systemd/system/
systemctl disable openipc.service

###

#update and upgrade system
apt update && apt -y upgrade

#install prerequisite programs
apt install -y git cmake build-essential

###

echo "installing media server for dvr"
#install the media server for dvr
apt -y install nginx-light
chmod o+x /media
mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.old
cp /zero3w-gs/nginx/default /etc/nginx/sites-available/

###

echo "installing PixelPilot"
#install PixelPilot
apt install librockchip-mpp-dev libdrm-dev libcairo-dev libspdlog-dev nlohmann-json3-dev gstreamer1.0-rockchip1 librga-dev librga2 librockchip-mpp-dev librockchip-mpp1 librockchip-vpu0 libv4l-rkmpp libgl4es libgl4es-dev
apt --no-install-recommends -y install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools

git clone https://github.com/OpenIPC/PixelPilot_rk.git
cd PixelPilot_rk
cmake -B build
cmake --build build --target install
cd ..

###

echo "hotplugging of wfb-nics configuration"
#configure hotplugging of wfb-nics
git clone https://github.com/JohnDGodwin/hot-plug-wfb-nics.git
cd /zero3w-gs/hot-plug-wfb-nics/
chmod +x autoload-wfb-nics.sh
cp autoload-wfb-nics.sh /config/scripts/
cp init-nics.service /etc/systemd/system/
systemctl enable init-nics.service
cp 98-custom-wifi.rules /etc/udev/rules.d/
cd ..

###

echo "Transferring drivers"
cd /zero3w-gs/drivers
dpkg -i linux-headers-5.10.160-299-rk356x_5.10.160-299_arm64.deb
dpkg -i linux-image-5.10.160-299-rk356x_5.10.160-299_arm64.deb
cd ..

#install AU driver
cp /zero3w-gs/drivers/88XXau_wfb.ko /lib/modules/5.10.160-299-rk356x/kernel/drivers/net/wireless/

#install EU driver
cp /zero3w-gs/drivers/8812eu.ko /lib/modules/5.10.160-299-rk356x/kernel/drivers/net/wireless/

#install 8733bu driver
cp /zero3w-gs/drivers/8733bu.ko /lib/modules/5.10.160-299-rk356x/kernel/drivers/net/wireless/

#install 88x2bu driver
cp /zero3w-gs/drivers/88x2bu.ko /lib/modules/5.10.160-299-rk356x/kernel/drivers/net/wireless/

#install atheros firmware
apt install -y firmware-atheros

###

#install wfb-ng
echo "installing wfb-ng"
git clone https://github.com/svpcom/wfb-ng.git
.zero3w-gs/wfb-ng/scripts/install_gs.sh rtl0

systemctl enable wifibroadcast
systemctl enable wifibroadcast@gs


#edit /etc/wifibroadcast to region 00
cp /zero3w-gs/wfbng/wifibroadcast.cfg /etc/

#transfer stock gs.key to /etc
cp /zero3w-gs/wfbng/gs.key /etc/
