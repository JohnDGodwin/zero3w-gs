#!/bin/bash
#Expand DVR partition
disk=$(df -P / | awk 'NR==2 {print $1}' | cut -d'/' -f3 | sed 's/[0-9]*$//' | sed 's|^|/dev/|' | sed 's/p$//')
partition3=${disk}p3
partition4=${disk}p4

sudo fdisk ${disk} <<EOF
d

n
4


t

11
p
w
EOF

sleep 0.1


sudo mkfs.vfat -F 32 ${partition4}
sudo fatlabel ${partition4} dvr
echo "UUID=$(blkid -s UUID -o value ${partition3})  /config  vfat  defaults,umask=000  0  0" | sudo tee -a /etc/fstab
echo "UUID=$(blkid -s UUID -o value ${partition4})  /dvr  vfat  defaults,umask=000  0  0" | sudo tee -a /etc/fstab
mount ${partition3}
mount ${partition4}

sleep 0.2

# Clean-up
sudo rm /etc/systemd/system/firstboot.service
sudo rm /firstboot.sh

exit 0
