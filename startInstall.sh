#!/bin/bash

timedatectl set-ntp true
# check your boot mode, this script only supports uefi boot mode
ls /sys/firmware/efi/efivars >/dev/null 2>&1
if [ $? -eq 0 ]; then

  cat <<'EOF'

        _         _             _             _     _           _        _ _
       / \  _   _| |_ ___      / \   _ __ ___| |__ (_)_ __  ___| |_ __ _| | |
      / _ \| | | | __/ _ \    / _ \ | '__/ __| '_ \| | '_ \/ __| __/ _` | | |
     / ___ \ |_| | || (_) |  / ___ \| | | (__| | | | | | | \__ \ || (_| | | |
    /_/   \_\__,_|\__\___/  /_/   \_\_|  \___|_| |_|_|_| |_|___/\__\__,_|_|_|

   ::==>> Your system is boot with UEFI! It's great!!!
   ::==>> Let's start your archlife!!!，If your are not ready，you can use ctrl-c to end!!!

EOF
  diskName=$(fdisk -l | sed -n '1, 1p' | awk '{print $2}' | sed s'/.$//')
  read -p "::==>> Are you sure format your sda[y/n]: " sure_str
  if [[ $sure_str != "y" && $sure_str != "Y" ]]; then
    exit 0
  fi

  # format your disk
  dd if=/dev/zero of=$diskName bs=1M
  wait
  parted $diskName mklabel gpt
  wait
  parted $diskName mkpart EFI fat32 1MB 513MB
  wait
  parted $diskName set 1 esp on
  wait
  parted $diskName mkpart System ext4 513MB 100%
  wait
  mkfs.fat -F32 $diskName"1"
  wait
  mkfs.ext4 $diskName"2"
  wait
  mount $diskName"2" /mnt
  wait
  mkdir /mnt/boot
  wait
  mount $diskName"1" /mnt/boot
  wait
  # config your mirror source file
  mv -f /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
  curl -Lo mirrorlist "https://www.archlinux.org/mirrorlist/?country=CN&protocol=http&protocol=https&ip_version=4&ip_version=6"
  wait
  sed -i 's/^#Server/Server/g' ./mirrorlist
  mv -f ./mirrorlist /etc/pacman.d/mirrorlist
  chmod 644 /etc/pacman.d/mirrorlist
  pacman -Sy
  # Install the base system
  # pacstrap /mnt base linux linux-firmware sudo zsh btrfs-progs
  pacstrap /mnt base linux linux-firmware sudo zsh
  wait
  # creat fstab file
  genfstab -U /mnt >>/mnt/etc/fstab
  # root change to /mnt
  chmod +x baseInstall.sh
  cp ./baseInstall.sh /mnt/baseInstall.sh
  # set DNS server in /etc/resolv.conf
  cat >/mnt/etc/resolv.conf <<'EOF'
nameserver 114.114.114.114
nameserver 8.8.8.8
EOF
  wait
  arch-chroot /mnt /bin/bash -c "/baseInstall.sh"
else
  echo "::==>> Sorry! Please use UEFI to boot your system!!!"
  exit 0
fi
