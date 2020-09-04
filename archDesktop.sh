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
    sudo pacman -S xorg-server xorg-xinit xclip xorg-xsetroot xorg-xrandr alsa-utils --noconfirm
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
    mkdir -p ~/.config/nvim

    rm ~/.bash*
}
function cfg_fun(){

    git clone https://github.com/R0boter/config.git
    git clone https://github.com/R0boter/dwm.git
    git clone https://github.com/R0boter/st.git
    git clone https://github.com/R0boter/dmenu.git
    git clone https://github.com/R0boter/slock.git
    git clone https://github.com/R0boter/wmname.git

    cp -r ./config/Wallpapers/* ~/Pictures/Wallpapers/
    cp -r ./config/linux/dunst ~/.config/dunst
    cp -r ./config/linux/fcitx5 ~/.config/fcitx5
    cp -r ./config/linux/mpv ~/.config/mpv
    cp -r ./config/linux/ranger ~/.config/ranger
    cp -r ./config/linux/zim ~/.config/zim
    cp -r ./config/linux/zim/zshrc ~/.zshrc
    cp -r ./config/linux/xinitrc ~/.xinitrc

    sudo cp -r ./config/fonts/fira-code-nerd /usr/share/fonts/fira-code-nerd 
    sudo cp ./config/fonts/local.conf /etc/fonts/local.conf
    
    cd ./dwm
    sudo make clean install

    cd ../st
    sudo make clean install

    cd ../dmenu
    sudo make clean install

    cd ../slock
    sudo make clean install

    cd ../wmname
    sudo make clean install

    cd ..

    rm -rf ./config
    rm -rf ./dwm
    rm -rf ./dmenu
    rm -rf ./st
    rm -rf ./slock
    rm -rf ./wmname
    
    git clone https://github.com/r0boter/mynvim.git ~/.config/nvim

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
    sudo pacman -S nodejs-lts-erbium yarn python python-pip --noconfirm
    
    yarn config set registry https://registry.yarn.taobao.org
    sudo yarn config set registry https://registry.yarn.taobao.org

    mkdir ~/.pip
    echo "[global]" > ~/.pip/pip.conf
    echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> ~/.pip/pip.conf
    sudo pip install neovim
}

wait
cfg_processor
cfg_desktop
cfg_fun
cfg_zh
install_tools
programs_conf

