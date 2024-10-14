#!/bin/bash

#This script will setup a radxa zero 3w for OpenIPC

#installing the base system

#setting up a the image
#change passwd for root to root

#edit /etc/ssh/sshd_config to allow for root login via ssh

#sudo systemctl enable ssh
echo "systemctl enable ssh"
systemctl enable ssh

#setup scripts folder
echo "setting up scripts folder"
mkdir /config/scripts
cp /zero3w-gs/scripts/* /config/scripts/

#setup openipc systemd service
echo "setting up openipc systemd service"
cp /zero3w-gs/openipc/openipc.service /etc/systemd/system/
systemctl disable openipc.service

#update and upgrade system
apt update && apt -y upgrade

#install prerequisite programs
apt install -y git cmake

echo "installing media server for dvr"
#install the media server for dvr
apt -y install nginx-light
chmod o+x /media
mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.old
cp /zero3w-gs/nginx/default /etc/nginx/sites-available/


echo "Transferring drivers"
#install AU driver
cp /zero3w-gs/drivers/88XXau_wfb.ko /lib/modules/5.10.160-38-rk356x/kernel/drivers/net/wireless/

#install EU driver
cp /zero3w-gs/drivers/8812eu.ko /lib/modules/5.10.160-38-rk356x/kernel/drivers/net/wireless/

#install 8733bu driver
cp /zero3w-gs/drivers/8733bu.ko /lib/modules/5.10.160-38-rk356x/kernel/drivers/net/wireless/


echo "installing wfb-ng"
#install wfb-ng
git clone https://github.com/svpcom/wfb-ng.git
cd wfb-ng
./scripts/install_gs.sh rtl0

systemctl enable wifibroadcast
systemctl enable wifibroadcast@gs

cd /zero3w-gs


#edit /etc/wifibroadcast to region 00
cp /zero3w-gs/wfbng/wifibroadcast.cfg /etc/

#transfer stock gs.key to /etc
cp /zero3w-gs/wfbng/gs.key /etc/


echo "installing PixelPilot"
#install PixelPilot
apt install librockchip-mpp-dev libdrm-dev libcairo-dev gstreamer1.0-rockchip1 librga-dev librga2 librockchip-mpp-dev librockchip-mpp1 librockchip-vpu0 libv4l-rkmpp libgl4es libgl4es-dev
apt --no-install-recommends -y install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools

git clone https://github.com/OpenIPC/PixelPilot_rk.git
cd PixelPilot_rk
cmake -B build
cmake --build build --target install
cd /zero3w-gs


echo "hotplugging of wfb-nics configuration"
#configure hotplugging of wfb-nics
git clone https://github.com/JohnDGodwin/hot-plug-wfb-nics.git
cd /zero3w-gs/hot-plug-wfb-nics/
chmod +x autoload-wfb-nics.sh
cp autoload-wfb-nics.sh /config/scripts/
cp init-nics.service /etc/systemd/system/
systemctl enable init-nics.service
cp 98-custom-wifi.rules /etc/udev/rules.d/
cd /zero3w-gs

echo "installing ffmpeg"
#prerequisite installs and ffmpeg
sudo apt -y install autoconf automake build-essential cmake git-core libass-dev libfreetype6-dev libgnutls28-dev libmp3lame-dev libsdl2-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev meson ninja-build pkg-config texinfo wget yasm zlib1g-dev libunistring-dev libaom-dev libdav1d-dev
sudo apt -y install nasm libx264-dev libx265-dev libnuma-dev

git clone -b jellyfin-mpp --depth=1 https://github.com/nyanmisaka/mpp.git rkmpp
pushd rkmpp
mkdir rkmpp_build
pushd rkmpp_build
cmake \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TEST=OFF \
    ..
make -j $(nproc)
make install
cd /zero3w-gs

git clone -b jellyfin-rga --depth=1 https://github.com/nyanmisaka/rk-mirrors.git rkrga
meson setup rkrga rkrga_build \
    --prefix=/usr \
    --libdir=lib \
    --buildtype=release \
    --default-library=shared \
   -Dcpp_args=-fpermissive \
   -Dlibdrm=false \
   -Dlibrga_demo=false
ninja -C rkrga_build install
cd /zero3w-gs

git clone --depth=1 https://github.com/nyanmisaka/ffmpeg-rockchip.git ffmpeg
cd ffmpeg
./configure --prefix=/usr --enable-gpl --enable-version3 --enable-libdrm --enable-rkmpp --enable-rkrga --enable-libx264 --enable-libx265 --extra-libs="-lpthread" --extra-cflags="-march=native" --enable-gnutls --enable-libass --enable-libfreetype --enable-libmp3lame --enable-libvorbis --enable-nonfree
make -j $(nproc)

./ffmpeg -decoders | grep rkmpp
./ffmpeg -encoders | grep rkmpp
./ffmpeg -filters | grep rkrga

sudo make install
cd /zero3w-gs
