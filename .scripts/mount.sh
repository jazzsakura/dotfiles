#!/usr/bin/env bash

mount -o subvol=/@/.snapshots/7681/snapshot /dev/nvme0n1p2 /mnt
mount -o subvol=/@/boot /dev/nvme0n1p2 /mnt/boot
mount -o subvol=/@/root /dev/nvme0n1p2 /mnt/root
mount -o subvol=/@/srv /dev/nvme0n1p2 /mnt/srv
mount -o subvol=/@/var_log /dev/nvme0n1p2 /mnt/var/log
mount -o subvol=/@/var_log_journal /dev/nvme0n1p2 /mnt/var/log/journal
mount -o subvol=/@/var_crash /dev/nvme0n1p2 /mnt/var/crash
mount -o subvol=/@/var_cache /dev/nvme0n1p2 /mnt/var/cache
mount -o subvol=/@/var_tmp /dev/nvme0n1p2 /mnt/var/tmp
mount -o subvol=/@/var_spool /dev/nvme0n1p2 /mnt/var/spool
mount -o subvol=/@/var_lib_libvirt_images /dev/nvme0n1p2 /mnt/var/lib/libvirt/images
mount -o subvol=/@/var_lib_machines /dev/nvme0n1p2 /mnt/var/lib/machines
mount /dev/nvme0n1p1 /mnt/boot/efi
mount /dev/nvme0n1p3 /mnt/home
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
