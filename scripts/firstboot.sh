#!/bin/bash
#Expand DVR partition
disk=$(df -P / | awk 'NR==2 {print $1}' | cut -d'/' -f3 | sed 's/[0-9]*$//' | sed 's|^|/dev/|' | sed 's/p$//')
partition=${disk}p4

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

sudo mkfs.vfat -F 32 ${partition}
echo "UUID=$(blkid -s UUID -o value ${partition})  /dvr  vfat  defaults,umask=000  0  0" | sudo tee -a /etc/fstab
mount ${partition}

sleep 0.2


# Samba stuff
sudo smbpasswd -a radxa <<EOF
radxa
radxa
EOF

sudo systemctl restart smbd &

sleep 0.2

# Clean-up
sudo rm /etc/systemd/system/firstboot.service
sudo rm /config/scripts/firstboot.sh

exit 0
