#!/bin/bash
# install some base programs
pacman -S which git wget curl unrar unzip tar gcc make fontconfig --noconfirm
wait

# set time zone
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc

# set locale
sed -i 's/#\(en_US.UTF-8\)/\1/' /etc/locale.gen
sed -i 's/#\(zh_CN.UTF-8\)/\1/' /etc/locale.gen
sed -i 's/#\(zh_CN.GBK\)/\1/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

# set hostname Archlinux is your hostname
read -p "What's hostname you want use?(default is Archlinux)" hostname
if [ ! -n "$hostname" ];then
    echo 'Archlinux' > /etc/hostname
else
    echo $hostname > /etc/hostname
fi

# set locale hosts file
cat >> /etc/hosts <<'EOF'

# GitHub Start
52.74.223.119 github.com
192.30.253.119 gist.github.com
54.169.195.247 api.github.com
185.199.111.153 assets-cdn.github.com
151.101.76.133 raw.githubusercontent.com
151.101.108.133 user-images.githubusercontent.com
151.101.76.133 gist.githubusercontent.com
151.101.76.133 cloud.githubusercontent.com
151.101.76.133 camo.githubusercontent.com
151.101.76.133 avatars0.githubusercontent.com
151.101.76.133 avatars1.githubusercontent.com
151.101.76.133 avatars2.githubusercontent.com
151.101.76.133 avatars3.githubusercontent.com
151.101.76.133 avatars4.githubusercontent.com
151.101.76.133 avatars5.githubusercontent.com
151.101.76.133 avatars6.githubusercontent.com
151.101.76.133 avatars7.githubusercontent.com
151.101.76.133 avatars8.githubusercontent.com
# GitHub End
EOF

# set nvim editor
ln -s /usr/bin/nvim /usr/bin/vi
ln -s /usr/bin/nvim /usr/bin/vim

# enable pacman color
sed -i 's/#Color/Color/g' /etc/pacman.conf
sed -i '/Color/a\ILoveCandy' /etc/pacman.conf

# install boot, I used archlinux built-in bootstrap
bootctl --path=/boot install
wait

cat > /boot/loader/loader.conf <<'EOF'
#timeout 3
#console-mode keep
default arch
EOF

cat > /boot/loader/entries/arch.conf <<'EOF'
title    Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=/dev/sda2 rw
EOF

# set root passwd
read -p "Please set root password(default is toor)：" rpass
if [ ! -n "$rpass" ];then
    echo "root:toor" | chpasswd
else
    echo "root:$rpass" | chpasswd
fi

# creat normal user username and set passwd
read -p "Please set your username：" uname
read -p "Please set your password：" upass
useradd -m -g users -s /usr/bin/zsh -G wheel,uucp $uname && echo "$uname:$upass" | chpasswd

# set sudo file
sed -i '/NOPASSWD/s/^#\ //' /etc/sudoers

# set autologin
mkdir /etc/systemd/system/getty@tty1.service.d/
echo '[Service]' > /etc/systemd/system/getty@tty1.service.d/override.conf
echo 'ExecSrtart=' >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo "ExecStart=-/usr/bin/agetty --autologin $uname --noclear" >> /etc/systemd/system/getty@tty1.service.d/override.conf
clear

# set network
read -p "Do you have a wifi interface?[y/n](default:y): " chk
if [[ -z $chk || $chk == "y" || $chk == "Y" ]];then
    pacman -S wpa_supplicant bluez bluez-utils --noconfirm
    cat > /etc/systemd/network/25-wireless.network <<'EOF'
[Match]
Name=wl*
[Network]
DHCP=ipv4
EOF
    cat > /etc/wpa_supplicant/wpa_supplicant.conf <<'EOF'
ctrl_interface=/var/run/wpa_supplicant
ctrl_interface_group=wheel
update_config=1
fast_reauth=1
ap_scan=1
EOF
    cat <<'EOF'
Now the wireless configuration complete and configfile is /etc/systemd/network/25-wireless.network
And wpa_supplicant generates WIFI configuration file is /etc/wpa_supplicant/wpa_supplicant.conf
When you want to connect to WIFI，
You should use command 'wpa_passphrase <ssid> [passphrase] >> /etc/wpa_supplicant/wpa_supplicant.conf' to auto configuration!
Use command 'wpa_supplicant -B -i <interface> -c /etc/wpa_supplicant/wpa_supplicant.conf' to connect internet!!!"
EOF
    read -p "Please remember these files location!!! Press any key......"
fi
cat > /etc/systemd/network/20-wired.network <<'EOF'
[Match]
Name=en*
[Network]
DHCP=ipv4
EOF
systemctl enable systemd-networkd

cat <<'EOF'
Now the wire-interface configuration complete and configfile is /etc/systemd/network/20-wired.network
If you have your own DHCP server，you need change the .network configfile，and enable systemd-resolved.service
EOF
read -p "Please remember this file location!!! Press any key......"

# set DNS server in /etc/resolv.conf
cat > /etc/resolv.conf <<'EOF'
nameserver 114.114.114.114
nameserver 8.8.8.8
EOF

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
# Add archlinucn sources,The default source is USTC
cat >> /etc/pacman.conf <<'EOF'
[archlinuxcn]
#SigLevel = Optional TrustedOnly
Server = https://mirrors.ustc.edu.cn/archlinuxcn/\$arch
#Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/\$arch
#Server = http://mirrors.163.com/archlinux-cn/\$arch
#Server = http://repo.archlinuxcn.org/\$arch
EOF
rm /baseInstall.sh
clear
cat <<'EOF'
 _   _                 _____        _       _         ___ _     _
| \ | | _____      __ | ____|_ __  (_) ___ (_)_ __   |_ _| |_  | |
|  \| |/ _ \ \ /\ / / |  _| | '_ \ | |/ _ \| | '_ \   | || __| | |
| |\  | (_) \ V  V /  | |___| | | || | (_) | | | | |  | || |_  |_|
|_| \_|\___/ \_/\_/   |_____|_| |_|/ |\___/|_|_| |_| |___|\__| (_)
                                 |__/

EOF
