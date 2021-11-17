#!/bin/bash

timedatectl set-ntp true
# check your boot mode, this script only supports uefi boot mode
ls /sys/firmware/efi/efivars >/dev/null 2>&1
if [ $? -eq 0 ]
then

    cat <<'EOF'

        _         _             _             _     _           _        _ _
       / \  _   _| |_ ___      / \   _ __ ___| |__ (_)_ __  ___| |_ __ _| | |
      / _ \| | | | __/ _ \    / _ \ | '__/ __| '_ \| | '_ \/ __| __/ _` | | |
     / ___ \ |_| | || (_) |  / ___ \| | | (__| | | | | | | \__ \ || (_| | | |
    /_/   \_\__,_|\__\___/  /_/   \_\_|  \___|_| |_|_|_| |_|___/\__\__,_|_|_|

   ::==>> Your system is boot with UEFI! It's great!!!
   ::==>> Let's start your archlife!!!，If your are not ready，you can use ctrl-c to end!!!

EOF
    read -p "::==>> Are you sure format your sda[y/n]: " sure_str
    if [[ $sure_str != "y" && $sure_str != "Y" ]]
    then
        exit 0
    fi
    # format your disk
    parted /dev/sda mklabel gpt & parted /dev/sda mkpart EFI fat32 1MB 513MB & parted /dev/sda set 1 esp on & parted /dev/sda mkpart System ext4 513MB 100% & mkfs.fat -F32 /dev/sda1 & mkfs.ext4 /dev/sda2
    mount /dev/sda2 /mnt & mkdir /mnt/boot & mount /dev/sda1 /mnt/boot
    # config your mirror source file
    mv -f /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
    curl -Lo mirrorlist https://www.archlinux.org/mirrorlist/?country=CN&protocol=http&protocol=https&ip_version=4&ip_version=6
    wait
    sed -i 's/^#Server/Server/g' ./mirrorlist
    mv -f ./mirrorlist /etc/pacman.d/mirrorlist
    chmod 644 /etc/pacman.d/mirrorlist
    # Install the base system
    # pacstrap /mnt base linux linux-firmware sudo zsh btrfs-progs
    pacstrap /mnt base linux linux-firmware sudo zsh
    wait
    # creat fstab file
    genfstab -U /mnt >> /mnt/etc/fstab
    # root change to /mnt
    chmod +x baseInstall.sh
    cp ./baseInstall.sh /mnt/baseInstall.sh
    # set DNS server in /etc/resolv.conf
    cat > /mnt/etc/resolv.conf <<'EOF'
nameserver 114.114.114.114
nameserver 8.8.8.8
EOF
    wait
    arch-chroot /mnt /bin/bash -c "/baseInstall.sh"
else
    echo "::==>> Sorry! Please use UEFI to boot your system!!!"
    exit 0
fi
