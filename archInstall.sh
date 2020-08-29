#!/bin/bash
function arch_chroot(){
    arch-chroot /mnt "/bin/bash" -c "${1}"
}
function chk_uefi(){
    ls /sys/firmware/efi/efivars >/dev/null 2>&1
    if [ $? -eq 0 ]
    then
        echo "Your system is boot with UEFI! It's great!!!"
        read -p "Let's start your archlife!!!，If your are not ready，you can use ctrl-c to end!!!"
    else
        echo "Sorry! Please use UEFI to boot your system!!!"
        exit 0
    fi
}
function format_disk(){
    printf "y\n" | mkfs.ext4 /dev/sda
    printf "n\n1\n\n+512M\nef00\nw\ny\n" | gdisk /dev/sda && yes | mkfs.fat -F32 /dev/sda1
    printf "n\n2\n\n\n8300\nw\ny\n" | gdisk /dev/sda && yes | mkfs.ext4 /dev/sda2
    mount /dev/sda2 /mnt && mkdir /mnt/boot && mount /dev/sda1 /mnt/boot
}
function cfg_mirror(){
    mv -f /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
    curl -Lo mirrorlist https://www.archlinux.org/mirrorlist/?country=CN&protocol=http&protocol=https&ip_version=4&ip_version=6
    wait
    sed -i 's/^#Server/Server/g' ./mirrorlist
    mv -f ./mirrorlist /etc/pacman.d/mirrorlist
    chmod 644 /etc/pacman.d/mirrorlist
    # Add archlinucn sources,The default source is 163
    echo '[archlinuxcn]' >> /etc/pacman.conf
    echo 'SigLevel = Optional TrustedOnly' >> /etc/pacman.conf
    echo 'Server = http://mirrors.163.com/archlinux-cn/$arch' >> /etc/pacman.conf
    echo '#Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch' >> /etc/pacman.conf
    echo '#Server   = http://repo.archlinuxcn.org/$arch' >> /etc/pacman.conf
}
function install_base(){
    pacstrap /mnt base linux linux-firmware sudo zsh neovim
}
function cfg_system(){
    # creat fstab file
    genfstab -U /mnt >> /mnt/etc/fstab
    # set time zone
    arch_chroot "ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime"
    arch_chroot "hwclock --systohc"
    # set locale
    arch_chroot "sed -i 's/#\(en_US.UTF-8\)/\1/' /etc/locale.gen"
    arch_chroot "sed -i 's/#\(zh_CN.UTF-8\)/\1/' /etc/locale.gen"
    arch_chroot "sed -i 's/#\(zh_CN.GBK\)/\1/' /etc/locale.gen"
    arch_chroot "locale-gen"
    arch_chroot "echo 'LANG=en_US.UTF-8' > /etc/locale.conf"
    # set hostname Archlinux is your hostname
    arch_chroot "echo 'Archlinux' > /etc/hostname"
    # set locale hosts file
    arch_chroot "wget https://raw.githubusercontent.com/googlehosts/hosts/master/hosts-files/hosts -O /etc/hosts"
    # set nvim editor
    arch_chroot "ln -s /usr/bin/nvim /usr/bin/vi"
    arch_chroot "ln -s /usr/bin/nvim /usr/bin/vim"
    # enable pacman color
    arch_chroot "sed -i 's/#Color/Color/g' /etc/pacman.conf"
    arch_chroot "sed -i '/Color/a\ILoveCandy' /etc/pacman.conf"
}
function cfg_boot(){
    arch_chroot "bootctl --path=/boot install"
    wait
    arch_chroot "echo '#timeout 3' > /boot/loader/loader.conf"
    arch_chroot "echo '#console-mode keep' >> /boot/loader/loader.conf"
    arch_chroot "echo 'default arch' >> /boot/loader/loader.conf"
    arch_chroot "echo 'title    Arch Linux' > /boot/loader/entries/arch.conf"
    arch_chroot "echo 'linux   /vmlinuz-linux' >> /boot/loader/entries/arch.conf"
    arch_chroot "echo 'initrd  /initramfs-linux.img' >> /boot/loader/entries/arch.conf"
    arch_chroot "echo 'options root=/dev/sda2 rw' >> /boot/loader/entries/arch.conf"
}
function install_program(){
    arch_chroot "pacman -S which git wget curl unrar unzip tar gcc make fontconfig --noconfirm"
}
function cfg_user(){
    # set root passwd
    arch_chroot "echo 'root:toor' | chpasswd"
    # creat normal user raven and set passwd
    arch_chroot "useradd -m -g users -s /usr/bin/zsh -G wheel,uucp username && echo 'username:passwd' | chpasswd"
    # set sudo file
    arch_chroot "sed -i '/NOPASSWD/s/^#\ //' /etc/sudoers"
}
function cfg_autologin(){
    arch_chroot "mkdir /etc/systemd/system/getty@tty1.service.d/"
    arch_chroot "echo '[Service]' > /etc/systemd/system/getty@tty1.service.d/override.conf"
    arch_chroot "echo 'ExecStart=' >> /etc/systemd/system/getty@tty1.service.d/override.conf"
    arch_chroot "echo 'ExecStart=-/usr/bin/agetty --autologin username --noclear %I \$TERM' >> /etc/systemd/system/getty@tty1.service.d/override.conf"
}
function cfg_net(){
    clear
    ip link
    read -p "This is your interface info，Do you have a wifi interface?[y/n](default:y): " chk
    if [[ -z $chk || $chk == "y" || $chk == "Y" ]];then
        pacstrap /mnt wpa_supplicant bluez bluez-utils
        arch_chroot "echo '[Match]' > /etc/systemd/network/25-wireless.network"
        arch_chroot "echo 'Name=wl*' >> /etc/systemd/network/25-wireless.network"
        arch_chroot "echo '[Network]' >> /etc/systemd/network/25-wireless.network"
        arch_chroot "echo 'DHCP=ipv4' >> /etc/systemd/network/25-wireless.network"

        arch_chroot "echo 'ctrl_interface=/var/run/wpa_supplicant' > /etc/wpa_supplicant/wpa_supplicant.conf"
        arch_chroot "echo 'ctrl_interface_group=wheel' >> /etc/wpa_supplicant/wpa_supplicant.conf"
        arch_chroot "echo 'update_config=1' >> /etc/wpa_supplicant/wpa_supplicant.conf"
        arch_chroot "echo 'fast_reauth=1' >> /etc/wpa_supplicant/wpa_supplicant.conf"
        arch_chroot "echo 'ap_scan=1' >> /etc/wpa_supplicant/wpa_supplicant.conf"
        clear

        echo "Now the wireless configuration complete and configfile is /etc/systemd/network/25-wireless.network"
        echo "and wpa_supplicant generates WIFI configuration file is /etc/wpa_supplicant/wpa_supplicant.conf"
        echo -e "When you want to connect to WIFI，\n You should use command 'wpa_passphrase <ssid> [passphrase] >> /etc/wpa_supplicant/wpa_supplicant.conf' to auto configuration! \n Use command 'wpa_supplicant -B -i <interface> -c /etc/wpa_supplicant/wpa_supplicant.conf' to connect internet!!!"
        read -p "Please remember these files location!!! Press any key......"
    fi
    arch_chroot "echo '[Match]' > /etc/systemd/network/20-wired.network"
    arch_chroot "echo 'Name=en*' >> /etc/systemd/network/20-wired.network"
    arch_chroot "echo '[Network]' >> /etc/systemd/network/20-wired.network"
    arch_chroot "echo 'DHCP=ipv4' >> /etc/systemd/network/20-wired.network"

    arch_chroot "systemctl enable systemd-networkd"
    clear
    echo "Now the wire-interface configuration complete and configfile is /etc/systemd/network/20-wired.network"
    echo "If you have your own DHCP server，you need change the .network configfile，and enable systemd-resolved.service"
    read -p "Please remember this file location!!! Press any key......"

    # set DNS server in /etc/resolv.conf
    echo 'nameserver 114.114.114.114' > /mnt/etc/resolv.conf
    echo 'nameserver 8.8.8.8' >> /mnt/etc/resolv.conf
    # read -p "Do you want to connect to WIFI?[y/n](default:y):  " wifi_chk
    # if [[ -z $wifi_chk || $wifi_chk == "y" || $wifi_chk == "Y" ]];then
    #     read -p "Please enter your wifi-name：  " wifiname
    #     read -p "Please enter your wifi-password：  " wifipasswd
    #     while [[ -z $wifiname || -z $wifipasswd ]]
    #     do
    #         echo "You need enter the wifiname and wifipasswd!!!"
    #         read -p "Please enter your wifi-name：  " ssid
    #         read -p "Please enter your wifi-password：  " passphrase
    #     done

    #     arch_chroot "wpa_passphrase ${ssid} ${passphrase} >> /etc/wpa_supplicant/wpa_supplicant.conf"
    # fi
}

timedatectl set-ntp true
chk_uefi
read -p "Are you sure format your sda[y/n]: " sure_str
if [[ $sure_str != "y" && $sure_str != "Y" ]]
then
    exit 0
fi
format_disk
cfg_mirror
install_base
cfg_system
cfg_boot
install_program
cfg_user
cfg_autologin
cfg_net
