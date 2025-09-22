#!/usr/bin/env bash
# zswap-set.sh

sudo truncate -s 0 /swapfile
sudo chattr +C /swapfile
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap -U clear /swapfile
sudo swapon /swapfile

#Add this lines to /etc/fstab to make it persistence across reboot.

# swap
#/swapfile    none    swap    defaults   0    0
