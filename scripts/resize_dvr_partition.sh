#!/bin/bash

disk=$(df -P / | awk 'NR==2 {print $1}' | cut -d'/' -f3 | sed 's/[0-9]*$//' | sed 's|^|/dev/|' | sed 's/p$//')
partition=$(df -P / | tail -n 1 | awk '/.*/ { print $1 }')

echo "Expanding disk ${disk}, resizing ${partition}"

sudo fdisk ${disk} <<EOF
d

n
4


t

11
p
w
EOF

sleep 0.2

sudo e2fsck -f ${partition}
sudo resize2fs ${partition}

exit
