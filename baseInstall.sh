#!/bin/bash

# install some base programs
pacman -S man-db which texinfo git wget curl unrar unzip tar gcc make fontconfig neovim archlinuxcn-keyring net-tools v2ray fakeroot rustup nodejs-lts-gallium python3 --noconfirm
wait

# set time zone
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc

# set locale
sed -i 's/#\(en_US.UTF-8\)/\1/' /etc/locale.gen
sed -i 's/#\(zh_CN.UTF-8\)/\1/' /etc/locale.gen
sed -i 's/#\(zh_CN.GBK\)/\1/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' >/etc/locale.conf
clear

# set hostname Archlinux is your hostname
read -p "::==>> What's hostname you want use?(default is Archlinux) : " hostname
if [ ! -n "$hostname" ]; then
  echo 'Archlinux' >/etc/hostname
else
  echo $hostname >/etc/hostname
fi

# set locale hosts file
cat >>/etc/hosts <<'EOF'

127.0.0.1   localhost
::1         localhost
127.0.1.1   "$hostname".localdomain    "$hostname"

EOF

# enable pacman color
sed -i 's/#Color/Color/g' /etc/pacman.conf
sed -i '/Color/a\ILoveCandy' /etc/pacman.conf

# install boot, I used archlinux built-in bootstrap
bootctl --path=/boot install
wait

cat >/boot/loader/loader.conf <<'EOF'
#timeout 3
#console-mode keep
default arch
EOF

cat >/boot/loader/entries/arch.conf <<'EOF'
title    Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=/dev/sda2 rw
EOF
clear
# set root passwd
read -p "::==>> Please set root password(default is toor) : " rpass
if [ ! -n "$rpass" ]; then
  rpass="toor"
fi
echo "root:$rpass" | chpasswd

# creat normal user username and set passwd
echo "::==>> You need enter the username, Usually 5-8 characters!!!"
read -p "::==>> Please set your username : " uname
while [[ -z $uname ]]; do
  echo "::==>> You need enter the username, Usually 5-8 characters!!!"
  read -p "::==>> Please set your username : " uname
done

echo "::==>> You need enter the password, Usually 5-16 characters!!!"
read -p "::==>> Please set your password : " upass
while [[ -z $upass ]]; do
  echo "::==>> You need enter the password, Usually 5-16 characters!!!"
  read -p "::==>> Please set your password : " upass
done

useradd -m -g users -s /usr/bin/zsh -G wheel,uucp $uname && echo "$uname:$upass" | chpasswd

# set sudo file
sed -i '/NOPASSWD/s/^#\ //' /etc/sudoers

# set autologin
mkdir /etc/systemd/system/getty@tty1.service.d/
cat >/etc/systemd/system/getty@tty1.service.d/override.conf <<EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $uname --noclear %I \$TERM
EOF
clear

# set network
pacman -S gnome-keyring networkmanager network-manager-applet bluez bluez-utils --noconfirm
systemctl enable NetworkManager.service
systemctl enable NetworkManager-dispatcher.service
systemctl enable bluetooth.service
systemctl enable v2ray.service
clear

# Add archlinucn sources,The default source is USTC
cat >>/etc/pacman.conf <<'EOF'
[archlinuxcn]
#SigLevel = Optional TrustedOnly
Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch
# #Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
EOF
rm /baseInstall.sh
pacman -Sy
clear
cat <<EOF
 _   _                 _____        _       _         ___ _     _
| \ | | _____      __ | ____|_ __  (_) ___ (_)_ __   |_ _| |_  | |
|  \| |/ _ \ \ /\ / / |  _| | '_ \ | |/ _ \| | '_ \   | || __| | |
| |\  | (_) \ V  V /  | |___| | | || | (_) | | | | |  | || |_  |_|
|_| \_|\___/ \_/\_/   |_____|_| |_|/ |\___/|_|_| |_| |___|\__| (_)
                                 |__/

::==>> Here have some things you need to remember :
::==>> 1. Your root password is $rpass
::==>> 2. Your username is $uname
::==>> 3. Your userpassword is $upass
::==>> 4. The wire-interface configuration complete and configfile is /etc/systemd/network/20-wired.network
::==>> 5. If you have your own DHCP server，you need change the .network configfile，and enable systemd-resolved.service

::==>> If you have WIFI you should remember the location of these files
::==>> 1. Wireless configfile is /etc/systemd/network/25-wireless.network
::==>> 2. WIFI configuration file is /etc/wpa_supplicant/wpa_supplicant.conf

::==>> When you want to connect to WIFI
::==>> You should use command 'wpa_passphrase <ssid> [passphrase] >> /etc/wpa_supplicant/wpa_supplicant.conf' to auto configuration!
::==>> Use command 'wpa_supplicant -B -i <interface> -c /etc/wpa_supplicant/wpa_supplicant.conf' to connect internet!!!"
EOF
