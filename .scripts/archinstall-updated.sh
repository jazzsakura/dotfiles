#!/usr/bin/env -S bash -e

# Cleaning the TTY.
clear
#set -e

# The script that use this file should have two lines on its top as follows:
cd "$(dirname "$0")"
#export base="$(pwd)"

function try { "$@" || sleep 0; }
function v() {
  echo -e "####################################################"
  echo -e "\e[34m[$0]: Next command:\e[0m"
  echo -e "\e[32m$@\e[0m"
  execute=true
  if $ask; then
    while true; do
      echo -e "\e[34mExecute? \e[0m"
      echo "  y = Yes"
      echo "  e = Exit now"
      echo "  s = Skip this command (NOT recommended - your setup might not work correctly)"
      echo "  yesforall = Yes and don't ask again; NOT recommended unless you really sure"
      read -p "====> " p
      case $p in
      [yY])
        echo -e "\e[34mOK, executing...\e[0m"
        break
        ;;
      [eE])
        echo -e "\e[34mExiting...\e[0m"
        exit
        break
        ;;
      [sS])
        echo -e "\e[34mAlright, skipping this one...\e[0m"
        execute=false
        break
        ;;
      "yesforall")
        echo -e "\e[34mAlright, won't ask again. Executing...\e[0m"
        ask=false
        break
        ;;
      *) echo -e "\e[31mPlease enter [y/e/s/yesforall].\e[0m" ;;
      esac
    done
  fi
  if $execute; then x "$@"; else
    echo -e "\e[33m[$0]: Skipped \"$@\"\e[0m"
  fi
}
# When use v() for a defined function, use x() INSIDE its definition to catch errors.
function x() {
  if "$@"; then cmdstatus=0; else cmdstatus=1; fi # 0=normal; 1=failed; 2=failed but ignored
  while [ $cmdstatus == 1 ]; do
    echo -e "\e[31m[$0]: Command \"\e[32m$@\e[31m\" has failed."
    echo -e "You may need to resolve the problem manually BEFORE repeating this command.\e[0m"
    echo "  r = Repeat this command (DEFAULT)"
    echo "  e = Exit now"
    echo "  i = Ignore this error and continue (your setup might not work correctly)"
    read -p " [R/e/i]: " p
    case $p in
    [iI])
      echo -e "\e[34mAlright, ignore and continue...\e[0m"
      cmdstatus=2
      ;;
    [eE])
      echo -e "\e[34mAlright, will exit.\e[0m"
      break
      ;;
    *)
      echo -e "\e[34mOK, repeating...\e[0m"
      if "$@"; then cmdstatus=0; else cmdstatus=1; fi
      ;;
    esac
  done
  case $cmdstatus in
  0) echo -e "\e[34m[$0]: Command \"\e[32m$@\e[34m\" finished.\e[0m" ;;
  1)
    echo -e "\e[31m[$0]: Command \"\e[32m$@\e[31m\" has failed. Exiting...\e[0m"
    exit 1
    ;;
  2) echo -e "\e[31m[$0]: Command \"\e[32m$@\e[31m\" has failed but ignored by user.\e[0m" ;;
  esac
}

# Selecting the kernel flavor to install.
kernel_selector() {
  echo "List of kernels:"
  echo "1) Stable — Vanilla Linux kernel and modules, with a few patches applied."
  echo "2) Hardened — A security-focused Linux kernel."
  echo "3) Longterm — Long-term support (LTS) Linux kernel and modules."
  echo "4) Zen Kernel — Optimized for desktop usage."
  read -r -p "Insert the number of the corresponding kernel: " choice
  echo "$choice will be installed"
  case $choice in
  1)
    kernel=linux
    ;;
  2)
    kernel=linux-hardened
    ;;
  3)
    kernel=linux-lts
    ;;
  4)
    kernel=linux-zen
    ;;
  *)
    echo "You did not enter a valid selection."
    kernel_selector
    ;;
  esac
}

## user input ##

# Selecting the target for the installation.
PS3="Select the disk where Arch Linux is going to be installed: "
select ENTRY in $(lsblk -dpnoNAME | grep -P "/dev/sd|nvme|vd"); do
  DISK=$ENTRY
  echo "Installing Arch Linux on $DISK."
  break
done

# Confirming the disk selection.
read -r -p "This will delete the current partition table on $DISK. Do you agree [y/N]? " response
response=${response,,}
if [[ ! ("$response" =~ ^(yes|y)$) ]]; then
  echo "Quitting."
  exit
fi

#select kernel
kernel_selector

# Setting username.
read -r -p "Please enter name for a user account (leave empty to skip): " username

# Setting password.
if [[ -n $username ]]; then
  read -r -p "Please enter a password for the user account: " password
fi

# Choose locales.
read -r -p "Please insert the locale you use in this format (xx_XX): " locale

# Choose keyboard layout.
read -r -p "Please insert the keyboard layout you use (la-latin1): " kblayout

## installation ##

# Updating the live environment usually causes more problems than its worth, and quite often can't be done without remounting cowspace with more capacity, especially at the end of any given month.

v pacman -S --noconfirm archlinux-keyring
v pacman-key --init
v pacman-key --populate archlinux
v reflector --verbose -l 50 -n 20 -p http --sort score --save /etc/pacman.d/mirrorlist
v pacman -Sy

# Installing curl
pacman -S --noconfirm curl

# formatting the disk
wipefs -af "$DISK" &>/dev/null
sgdisk -Zo "$DISK" &>/dev/null

# Checking the microcode to install.
CPU=$(grep vendor_id /proc/cpuinfo)
if [[ $CPU == *"AuthenticAMD"* ]]; then
  microcode=amd-ucode
else
  microcode=intel-ucode
fi

# Creating a new partition scheme.
echo "Creating new partition scheme on $DISK."
sgdisk -n 0:0:+512MiB -t 0:ef00 -c 0:ESP $DISK
read -r -p "Please select the size of the root partition (10GB): " size
sgdisk -n 0:0:+"$size" -t 0:8300 -c 0:root $DISK
sgdisk -n 0:0:0 -t 0:8300 -c 0:home $DISK

sleep 0.1
ESP="/dev/$(lsblk $DISK -o NAME,PARTLABEL | grep ESP | cut -d " " -f1 | cut -c7-)"
root="/dev/$(lsblk $DISK -o NAME,PARTLABEL | grep root | cut -d " " -f1 | cut -c7-)"
home="/dev/$(lsblk $DISK -o NAME,PARTLABEL | grep home | cut -d " " -f1 | cut -c7-)"

# Informing the Kernel of the changes.
echo "Informing the Kernel about the disk changes."
partprobe "$DISK"

# Formatting the ESP as FAT32.
echo "Formatting the EFI Partition as FAT32."
mkfs.fat -F 32 -s 2 $ESP &>/dev/null

# Formatting the /root partition as BTRFS.
echo "Formatting the ROOT partition as BTRFS."
mkfs.btrfs -L ARCH-B-ROOT -f -n 32k $root &>/dev/null
mount $root /mnt

# Make an EXT4 filesystem for /home
echo "Make an EXT4 filesystem for /home."
mkfs.ext4 -L ARCH-B-HOME $home &>/dev/null

ESP_UUID="$(lsblk -o UUID $ESP | grep -v UUID)"
root_UUID="$(lsblk -o UUID $root | grep -v UUID)"
home_UUID="$(lsblk -o UUID $home | grep -v UUID)"

# Creating BTRkS subvolumes.
echo "Creating BTRFS subvolumes."
btrfs su cr /mnt/@ &>/dev/null
btrfs su cr /mnt/@/.snapshots &>/dev/null
mkdir -p /mnt/@/.snapshots/1 &>/dev/null
btrfs su cr /mnt/@/.snapshots/1/snapshot &>/dev/null
mkdir -p /mnt/@/boot &>/dev/null
btrfs su cr /mnt/@/boot/grub &>/dev/null
btrfs su cr /mnt/@/opt &>/dev/null
btrfs su cr /mnt/@/root &>/dev/null
btrfs su cr /mnt/@/srv &>/dev/null
btrfs su cr /mnt/@/tmp &>/dev/null
mkdir -p /mnt/@/usr &>/dev/null
btrfs su cr /mnt/@/usr/local &>/dev/null
mkdir -p /mnt/@/var &>/dev/null
btrfs su cr /mnt/@/var/cache &>/dev/null
btrfs su cr /mnt/@/var/log &>/dev/null
btrfs su cr /mnt/@/var/spool &>/dev/null
btrfs su cr /mnt/@/var/tmp &>/dev/null

chattr +C /mnt/@/var/cache
chattr +C /mnt/@/var/log
chattr +C /mnt/@/var/tmp
chattr +C /mnt/@/var/spool

#Set the default BTRFS Subvol to Snapshot 1 before pacstrapping
btrfs subvolume set-default "$(btrfs subvolume list /mnt | grep "@/.snapshots/1/snapshot" | grep -oP '(?<=ID )[0-9]+')" /mnt

cat <<EOF >>/mnt/@/.snapshots/1/info.xml
<?xml version="1.0"?>
<snapshot>
  <type>single</type>
  <num>1</num>
  <date>1999-03-31 0:00:00</date>
  <description>First Root Filesystem</description>
  <cleanup>number</cleanup>
</snapshot>
EOF

#chmod 600 /mnt/@/.snapshots/1/info.xml

# Optionally, enable quotas in the BTRFS filesystem
btrfs quota enable /mnt
btrfs qgroup create 1/0 /mnt

# Mounting the newly created subvolumes.
umount /mnt
echo "Mounting the newly created subvolumes."
mount UUID=$root_UUID -o compress=zstd /mnt
mkdir -p /mnt/{boot/grub,root,.snapshots,opt,srv,tmp,usr/local,var/cache,var/log,var/spool,var/tmp}
mount -o subvol=@/.snapshots,compress=zstd UUID=$root_UUID /mnt/.snapshots
mount -o subvol=@/boot/grub,compress=zstd UUID=$root_UUID /mnt/boot/grub
mount -o subvol=@/opt,compress=zstd UUID=$root_UUID /mnt/opt
mount -o subvol=@/root,compress=zstd UUID=$root_UUID /mnt/root
mount -o subvol=@/srv,compress=zstd UUID=$root_UUID /mnt/srv
mount -o subvol=@/usr/local,compress=zstd UUID=$root_UUID /mnt/usr/local
mount -o subvol=@/var/cache,nodatacow UUID=$root_UUID /mnt/var/cache
mount -o subvol=@/var/log,nodatacow UUID=$root_UUID /mnt/var/log
mount -o subvol=@/var/spool,nodatacow UUID=$root_UUID /mnt/var/spool
mount -o subvol=@/var/tmp,nodatacow UUID=$root_UUID /mnt/var/tmp

# Make a mountpoint for the ESP(EFI System Partition)
mkdir -p /mnt/efi
mount UUID=$ESP_UUID /mnt/efi

# Make a mount point for the /home partition
mkdir /mnt/home
#mount UUID=$home_UUID /mnt/home
mount $home /mnt/home

#readarray -t pkglist < $HOME/.cache/dots-hyprland/scriptdata/dependencies.conf
readarray -t pkglist <./dependencies.conf

# Pacstrap (setting up a base sytem onto the new root).
# As I said above, I am considering replacing gnome-software with pamac-flatpak-gnome as PackageKit seems very buggy on Arch Linux right now.
echo "Installing the base system (it may take a while)."
# execute per element of the array $pkglist
for i in "${pkglist[@]}"; do v pacstrap /mnt base ${kernel} ${microcode} $i; done

# Generating /etc/fstab.
echo "Generating a new fstab."
genfstab -U /mnt >>/mnt/etc/fstab
#sed -i 's#,subvolid=258,subvol=/@/.snapshots/1/snapshot,subvol=@/.snapshots/1/snapshot##g' /mnt/etc/fstab

# Setting hostname.
read -r -p "Please enter the hostname: " hostname
echo "$hostname" >/mnt/etc/hostname

# Setting hosts file.
echo "Setting hosts file."
cat >/mnt/etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $hostname.localdomain   $hostname
EOF

# Setting up locales.
echo "$locale.UTF-8 UTF-8" >/mnt/etc/locale.gen
echo "LANG=$locale.UTF-8" >/mnt/etc/locale.conf

# Setting up keyboard layout.
read -r -p "Please insert the keyboard layout you use: " kblayout
echo "KEYMAP=$kblayout" >/mnt/etc/vconsole.conf

# Configuring /etc/mkinitcpio.conf
echo "Configuring /etc/mkinitcpio for ZSTD compression."
sed -i 's,#COMPRESSION="zstd",COMPRESSION="zstd",g' /mnt/etc/mkinitcpio.conf

# Enabling LUKS in GRUB and setting the UUID of the LUKS container.
#echo -e "# Booting with BTRFS subvolume\nGRUB_BTRFS_OVERRIDE_BOOT_PARTITION_DETECTION=true" >>/mnt/etc/default/grub
#sed -i 's#rootflags=subvol=${rootsubvol}##g' /mnt/etc/grub.d/10_linux
#sed -i 's#rootflags=subvol=${rootsubvol}##g' /mnt/etc/grub.d/20_linux_xen

# Enabling NTS
curl https://raw.githubusercontent.com/GrapheneOS/infrastructure/refs/heads/main/etc/chrony.conf >>/mnt/etc/chrony.conf

# Setting GRUB configuration file permissions
chmod 755 /mnt/etc/grub.d/*

# Configure AppArmor Parser caching
sed -i 's/#write-cache/write-cache/g' /mnt/etc/apparmor/parser.conf
sed -i 's,#Include /etc/apparmor.d/,Include /etc/apparmor.d/,g' /mnt/etc/apparmor/parser.conf

# Remove nullok from system-auth
sed -i 's/nullok//g' /mnt/etc/pam.d/system-auth

# Disable coredump
echo "* hard core 0" >>/mnt/etc/security/limits.conf

# Disable su for non-wheel users
bash -c 'cat > /mnt/etc/pam.d/su' <<-'EOF'
#%PAM-1.0
auth		sufficient	pam_rootok.so
# Uncomment the following line to implicitly trust users in the "wheel" group.
#auth		sufficient	pam_wheel.so trust use_uid
# Uncomment the following line to require a user to be in the "wheel" group.
auth		required	pam_wheel.so use_uid
auth		required	pam_unix.so
account		required	pam_unix.so
session		required	pam_unix.so
EOF

# ZRAM configuration
bash -c 'cat > /mnt/etc/systemd/zram-generator.conf' <<-'EOF'
[zram0]
zram-size = ram
compression-algorithm = zstd
EOF

# Configuring the system.
arch-chroot /mnt /bin/bash -e <<EOF

    # Setting up timezone.
    ln -sf /usr/share/zoneinfo/$(curl -s http://ip-api.com/line?fields=timezone) /etc/localtime &>/dev/null

    # Setting up clock.
    hwclock --systohc

    # Generating locales.my keys aren't even on
    echo "Generating locales."
    locale-gen &>/dev/null

    # Generating a new initramfs.
    echo "Creating a new initramfs."
    chmod 600 /boot/initramfs-linux* &>/dev/null
    mkinitcpio -P &>/dev/null

    # Snapper configuration
    umount /.snapshots
    rm -r /.snapshots
    snapper --no-dbus -c root create-config 
    btrfs subvolume delete /.snapshots
    mkdir /.snapshots
    mount -a
    chmod 750 /.snapshots

    # Installing GRUB.
    echo "Installing GRUB on /boot."
    grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB --modules="normal test efi_gop efi_uga search echo linux all_video gfxmenu gfxterm_background gfxterm_menu gfxterm loadenv configfile gzio part_gpt btrfs" &>/dev/null

    # Creating grub config file.
    echo "Creating GRUB config file."
    grub-mkconfig -o /boot/grub/grub.cfg &>/dev/null

    # Adding user with sudo privilege
    if [ -n "$username" ]; then
        echo "Adding $username with root privilege."
        useradd -m $username
        usermod -aG wheel $username

        groupadd -r audit
        gpasswd -a $username audit
    fi
EOF

# Setting user password.
[ -n "$username" ] && echo "Setting user password for ${username}." && echo -e "${password}\n${password}" | arch-chroot /mnt passwd "$username" &>/dev/null

# Giving wheel user sudo access.
sed -i 's/# \(%wheel ALL=(ALL\(:ALL\|\)) ALL\)/\1/g' /mnt/etc/sudoers

# Change audit logging group
echo "log_group = audit" >>/mnt/etc/audit/auditd.conf

# Enabling audit service.
systemctl enable auditd --root=/mnt &>/dev/null

# Enabling openssh server
systemctl enable sshd --root=/mnt &>/dev/null

# Enabling auto-trimming service.
systemctl enable fstrim.timer --root=/mnt &>/dev/null

# Enabling NetworkManager.
systemctl enable NetworkManager --root=/mnt &>/dev/null

# Enabling AppArmor.
echo "Enabling AppArmor."
systemctl enable apparmor --root=/mnt &>/dev/null

# Enabling Firewalld.
echo "Enabling Firewalld."
systemctl enable firewalld --root=/mnt &>/dev/null

# Enabling Reflector timer.
echo "Enabling Reflector."
systemctl enable reflector.timer --root=/mnt &>/dev/null

# Enabling systemd-oomd.
echo "Enabling systemd-oomd."
systemctl enable systemd-oomd --root=/mnt &>/dev/null

# Disabling systemd-timesyncd
systemctl disable systemd-timesyncd --root=/mnt &>/dev/null

# Enabling chronyd
systemctl enable chronyd --root=/mnt &>/dev/null

# Enabling Snapper automatic snapshots.
echo "Enabling Snapper and automatic snapshots entries."
systemctl enable snapper-timeline.timer --root=/mnt &>/dev/null
systemctl enable snapper-cleanup.timer --root=/mnt &>/dev/null
systemctl enable grub-btrfsd.service --root=/mnt &>/dev/null

# Setting umask to 077.
sed -i 's/022/077/g' /mnt/etc/profile
echo "" >>/mnt/etc/bash.bashrc
echo "umask 077" >>/mnt/etc/bash.bashrc

# Enable Periodic Execution of btrfs scrub

TEMP="$(lsblk $DISK -o NAME,PARTLABEL | grep root | cut -d " " -f1 | cut -c7-)"
arch-chroot /mnt systemd-escape --template btrfs-scrub@.timer --path $root
systemctl enable btrfs-scrub@dev-$TEMP.timer --root=/mnt &>/dev/null

## Installing snap-pac-grub
echo "Installing the AUR Helper."
arch-chroot /mnt pacman -S --needed --noconfirm base-devel
arch-chroot -u $username /mnt /bin/bash -e <<EOF

    git clone https://aur.archlinux.org/paru-bin /home/$username/paru-bin
EOF
arch-chroot -u $username /mnt sh -c "cd /home/$username/paru-bin && makepkg -si"
arch-chroot -u $username /mnt sh -c "sudo -u $username paru -Sa snap-pac-grub --noconfirm"

# Edit Snapper Configuration.
arch-chroot /mnt /bin/bash -e <<EOF

    sed -e 's/QGROUP=""/QGROUP="1\/0"/' -i /etc/snapper/configs/root
    sed -e 's/NUMBER_LIMIT="[[:digit:]]*"/NUMBER_LIMIT="10-35"/' -i /etc/snapper/configs/root
    sed -e 's/NUMBER_LIMIT_IMPORTANT="[[:digit:]]*"/NUMBER_LIMIT_IMPORTANT="15-25"/' -i /etc/snapper/configs/root
    sed -e 's/ALLOW_USERS=""/ALLOW_USERS="$username"/' -i /etc/snapper/configs/root
    sed -e 's/TIMELINE_LIMIT_YEARLY="[[:digit:]]*"/TIMELINE_LIMIT_YEARLY="0"/' -i /etc/snapper/configs/root
    sed -e 's/TIMELINE_LIMIT_MONTHLY="[[:digit:]]*"/TIMELINE_LIMIT_MONTHLY="3"/' -i /etc/snapper/configs/root
    sed -e 's/TIMELINE_LIMIT_WEEKLY="[[:digit:]]*"/TIMELINE_LIMIT_WEEKLY="2"/' -i /etc/snapper/configs/root
    sed -e 's/TIMELINE_LIMIT_DAILY="[[:digit:]]*"/TIMELINE_LIMIT_DAILY="5"/' -i /etc/snapper/configs/root
    sed -e 's/TIMELINE_LIMIT_HOURLY="[[:digit:]]*"/TIMELINE_LIMIT_HOURLY="5"/' -i /etc/snapper/configs/root

    # Delete Subvolumes Created by systemd for VMs and Containers 
    btrfs subvolume delete /.snapshots/1/snapshot/var/lib/portables
    # btrfs subvolume delete /.snapshots/1/snapshot/var/lib/machines
EOF

# Finishing up
#echo "Done, you may now wish to reboot (further changes can be done by chrooting into /mnt)."
printf "\e[1;32mDone! you may now wish to reboot (further changes can be done by chrooting into /mnt).\e[0m"
exit
