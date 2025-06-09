#!/usr/bin/env bash

mount -o subvol=/@/.snapshots/3696/snapshot /dev/sda2 /mnt
mount -o subvol=/@/boot /dev/sda2 /mnt/boot
mount -o subvol=/@/root /dev/sda2 /mnt/root
mount -o subvol=/@/srv /dev/sda2 /mnt/srv
mount -o subvol=/@/var_log /dev/sda2 /mnt/var/log
mount -o subvol=/@/var_log_journal /dev/sda2 /mnt/var/log/journal
mount -o subvol=/@/var_crash /dev/sda2 /mnt/var/crash
mount -o subvol=/@/var_cache /dev/sda2 /mnt/var/cache
mount -o subvol=/@/var_tmp /dev/sda2 /mnt/var/tmp
mount -o subvol=/@/var_spool /dev/sda2 /mnt/var/spool
mount -o subvol=/@/var_lib_libvirt_images /dev/sda2 /mnt/var/lib/libvirt/images
mount -o subvol=/@/var_lib_machines /dev/sda2 /mnt/var/lib/machines
mount /dev/sda1 /mnt/boot/efi
mount /dev/sda3 /mnt/home
mount /proc /mnt/proc --bind
mount /dev /mnt/dev --bind
mount /sys /mnt/sys --bind
mount /run /mnt/run --bind
arch-chroot /mnt

# Reinstall Bootloader
# pacman -S linux 
# grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
# grub-mkconfig -o /boot/grub/grub.cfg
# mkinitcpio -P
