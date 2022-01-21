#!/bin/bash
function cfg_processor(){
    while :
    do
        read -p "What's your processors type? I or A or vm or vbox [Intel/AMD/VMware/Virtualbox] ? " processors_type
        case $processors_type in
            "Intel"|"intel"|"I"|"i")
                sudo pacman -S intel-ucode xf86-video-intel --noconfirm
                sudo sed -i '/initrd/i\initrd  /intel-ucode.img' /boot/loader/entries/arch.conf
                break
            ;;
            "AMD"|"amd"|"A"|"a")
                sudo pacman -S amd-ucode xf86-video-amdgpu --noconfirm
                sudo sed -i '/initrd/i\initrd  /amd-ucode.img' /boot/loader/entries/arch.conf
                break
            ;;
            "vmware"|"VMware"|"vm"|"VM")
                sudo pacman -S xf86-input-vmmouse xf86-video-vmware mesa open-vm-tools --noconfirm
                sudo systemctl enable vmtoolsd.service
                break
            ;;
            "Virtualbox"|"vbox"|"Vbox")
                sudo pacman -S virtualbox-guest-utils --noconfirm
                sudo systemctl enable vboxservice.service
                break
            ;;
            *)
                echo "You shoud enter right processors type"
        esac
    done
}

function cfg_desktop(){
    sudo pacman -S xorg-server xorg-xinit xclip xorg-xsetroot xorg-xrandr alsa-utils v2ray pkgconf ripgrep fd archlinuxcn-keyring --noconfirm
    for i in `seq 5`;do
        sudo sed -i '$d' /etc/X11/xinit/xinitrc
    done
    echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.zprofile
    echo 'if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then' >> ~/.zprofile
    echo '  exec startx' >> ~/.zprofile
    echo 'fi' >> ~/.zprofile

    mkdir ~/Downloads
    mkdir ~/Documents
    mkdir -p ~/Pictures/Wallpapers
    mkdir ~/Music
    mkdir ~/Videos
    mkdir -p ~/.config/
    rm ~/.bash*

    # configuration v2ray
    sudo mv /etc/v2ray/config.json /etc/v2ray/config.json.bak
    sudo cp ./config.json /etc/v2ray/config.json
    sudo systemctl enable v2ray
    sudo systemctl start v2ray

    # some st need include files
    sudo ln -s /usr/include/freetype2/ft2build.h /usr/include/ft2build.h
    sudo ln -s /usr/include/freetype2/freetype /usr/include/freetype

    sudo ln -s /usr/include/harfbuzz/hb-unicode.h /usr/include/hb-unicode.h
    sudo ln -s /usr/include/harfbuzz/hb-font.h /usr/include/hb-font.h
    sudo ln -s /usr/include/harfbuzz/hb-face.h /usr/include/hb-face.h
    sudo ln -s /usr/include/harfbuzz/hb-set.h /usr/include/hb-set.h
    sudo ln -s /usr/include/harfbuzz/hb-draw.h /usr/include/hb-draw.h
    sudo ln -s /usr/include/harfbuzz/hb-deprecated.h /usr/include/hb-deprecated.h
    sudo ln -s /usr/include/harfbuzz/hb-map.h /usr/include/hb-map.h
    sudo ln -s /usr/include/harfbuzz/hb-shape.h /usr/include/hb-shape.h
    sudo ln -s /usr/include/harfbuzz/hb-shape-plan.h /usr/include/hb-shape-plan.h
    sudo ln -s /usr/include/harfbuzz/hb-style.h /usr/include/hb-style.h
    sudo ln -s /usr/include/harfbuzz/hb-version.h /usr/include/hb-version.h
    sudo ln -s /usr/include/harfbuzz/hb-ft.h /usr/include/hb-ft.h
}
function cfg_fun(){

    export http_proxy=127.0.0.1:10809
    export https_proxy=127.0.0.1:10809
    cd ~/Documents
    git clone https://github.com/R0boter/config.git
    wait
    git clone https://github.com/R0boter/nvim.git ~/.config/nvim
    wait
    git clone https://github.com/R0boter/Suckless.git
    wait

    cp -r ./config/Wallpapers/* ~/Pictures/Wallpapers/
    cp -r ./config/dunst ~/.config/dunst
    cp -r ./config/fcitx5 ~/.config/fcitx5
    cp -r ./config/mpv ~/.config/mpv
    cp -r ./config/ranger ~/.config/ranger
    cp -r ./config/zim ~/.config/zim
    cp -r ./config/zim/zshrc ~/.zshrc
    cp -r ./config/xinitrc ~/.xinitrc

    sudo cp -r ./config/fonts/fira-code-nerd /usr/share/fonts/fira-code-nerd
    sudo cp ./config/fonts/local.conf /etc/fonts/local.conf

    cd ./Suckless/dmenu
    sudo make clean install

    cd ../slock
    sudo make clean install

    cd ../wmname
    sudo make clean install

    cd ../st
    sudo make clean install

    cd ../dwm
    sudo make clean install

    # set nvim editor
    ln -s /usr/bin/nvim /usr/bin/vi
    ln -s /usr/bin/nvim /usr/bin/vim

}
function cfg_zh(){
    # fonts Input and chinese
    sudo pacman -S xf86-input-libinput adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts fcitx5 fcitx5-chinese-addons fcitx5-gtk fcitx5-qt fcitx5-material-color --noconfirm
    sudo fc-cache -fs


    echo "If you want to customize the input configuration, please modify the configuration file in /etc/X11/xorg.conf.d/40-libinput.conf"
    echo "The local fonts configuration file is /etc/fonts/local.conf"
    read -p "Press any key......"
}

function install_tools(){
    sudo pacman -Syu
    sudo pacman -S ranger ueberzug mpv xcompmgr habak patch firefox dunst libnotify flameshot --noconfirm
    sudo pacman -Scc
}
function programs_conf(){
    sudo pacman -S nodejs-lts-erbium npm python3 python-pip --noconfirm
    wait

    mkdir ~/.pip
    echo "[global]" > ~/.pip/pip.conf
    echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> ~/.pip/pip.conf
    sudo pip install neovim

    npm config set registry https://registry.npm.taobao.org
}

wait
cfg_processor
cfg_desktop
cfg_fun
cfg_zh
install_tools
programs_conf
