#!/bin/bash
function cfg_processor() {
  while :; do
    read -p "What's your processors type? I or A or vm or vbox [Intel/AMD/VMware/Virtualbox] ? " processors_type
    case $processors_type in
    "Intel" | "intel" | "I" | "i")
      sudo pacman -S intel-ucode xf86-video-intel --noconfirm
      sudo sed -i '/initrd/i\initrd  /intel-ucode.img' /boot/loader/entries/arch.conf
      break
      ;;
    "AMD" | "amd" | "A" | "a")
      sudo pacman -S amd-ucode xf86-video-amdgpu --noconfirm
      sudo sed -i '/initrd/i\initrd  /amd-ucode.img' /boot/loader/entries/arch.conf
      break
      ;;
    "vmware" | "VMware" | "vm" | "VM")
      sudo pacman -S xf86-input-vmmouse xf86-video-vmware mesa open-vm-tools --noconfirm
      sudo systemctl enable vmtoolsd.service
      break
      ;;
    "Virtualbox" | "vbox" | "Vbox")
      sudo pacman -S virtualbox-guest-utils --noconfirm
      sudo systemctl enable vboxservice.service
      break
      ;;
    *)
      echo "You shoud enter right processors type"
      ;;
    esac
  done
}

function cfg_desktop() {
  sudo pacman -S xorg-server xorg-xinit xclip xorg-xsetroot xorg-xrandr pulseaudio pulseaudio-bluetooth pulseaudio-alsa pavucontrol pkgconf ripgrep fd tmux tlp tlp-rdw qt5ct --noconfirm
  for i in $(seq 5); do
    sudo sed -i '$d' /etc/X11/xinit/xinitrc
  done
  echo 'export PATH=$HOME/.local/bin:$PATH' >>~/.zprofile
  echo 'export XCURSOR_THEME="volantes_cursors"' >>~/.zprofile
  echo 'export XCURSOR_SIZE="16"' >>~/.zprofile
  echo 'export QT_QPA_PLATFORMTHEME="qt5ct"' >>~/.zprofile
  echo 'if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then' >>~/.zprofile
  echo '  exec startx' >>~/.zprofile
  echo 'fi' >>~/.zprofile

  mkdir ~/Downloads
  mkdir ~/Documents
  mkdir -p ~/Pictures/Wallpapers
  mkdir ~/Music
  mkdir ~/Videos
  mkdir -p ~/.config/
  rm ~/.bash*

  sudo dd if=/dev/zero of=/swapfile bs=1M count=12288 status=progress
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  sudo sed -i '$a \/swapfile none swap defaults 0 0' /etc/fstab

  # configuration v2ray
  # sudo mv /etc/v2ray/config.json /etc/v2ray/config.json.bak
  # sudo cp ./config.json /etc/v2ray/config.json
  # sudo systemctl enable v2ray
  # sudo systemctl start v2ray
}

function cfg_fun() {

  cd ~/Documents
  git clone git@github.com:R0boter/config.git
  wait
  git clone git@github.com:R0boter/nvim.git ~/.config/nvim
  wait
  git clone git@github.com:R0boter/Suckless.git
  wait
  git clone https://aur.archlinux.org/paru.git
  wait

  cp -r ./config/Wallpapers/* ~/Pictures/Wallpapers/
  cp -r ./config/dunst ~/.config/dunst
  cp -r ./config/fcitx5 ~/.config/fcitx5
  cp -r ./config/mpv ~/.config/mpv
  cp -r ./config/picom ~/.config/picom
  cp -r ./config/ranger ~/.config/ranger
  cp -r ./config/zim ~/.config/zim
  cp -r ./config/qt5ct ~/.config/qt5ct
  cp -r ./config/gtk/gtk-3.0 ~/.config/gtk-3.0
  cp -r ./config/tmux.conf ~/.tmux.conf
  cp -r ./config/zim/zshrc ~/.zshrc
  cp -r ./config/xinitrc ~/.xinitrc

  sudo cp -r ./config/fonts/operator-mono-nerd-font /usr/share/fonts/operator-mono-nerd-font
  sudo cp -r ./config/gtk/gruvbox_dark /usr/share/icons/gruvbox_dark
  sudo cp -r ./config/gtk/volantes_cursors /usr/share/icons/volantes_cursors
  sudo cp -r ./config/gtk/Gruvbox-Dark /usr/share/themes/Gruvbox-Dark
  sudo cp ./config/fonts/local.conf /etc/fonts/local.conf

  # set nvim editor
  sudo ln -s /usr/bin/nvim /usr/bin/vi
  sudo ln -s /usr/bin/nvim /usr/bin/vim

}
function cfg_zh() {
  # fonts Input and chinese
  sudo pacman -S xf86-input-libinput adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts fcitx5 fcitx5-chinese-addons fcitx5-gtk fcitx5-qt fcitx5-material-color --noconfirm
  sudo fc-cache -fs

  echo "If you want to customize the input configuration, please modify the configuration file in /etc/X11/xorg.conf.d/40-libinput.conf"
  echo "The local fonts configuration file is /etc/fonts/local.conf"
  read -p "Press any key......"
}

function install_tools() {
  sudo pacman -Syu
  sudo pacman -S ranger ueberzug mpv picom feh patch firefox librewolf dunst libnotify flameshot telegram-desktop --noconfirm
  sudo pacman -Scc
}
function programs_conf() {
  sudo pacman -S npm python-pip --noconfirm
  wait

  mkdir ~/.pip
  echo "[global]" >~/.pip/pip.conf
  echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >>~/.pip/pip.conf
  sudo pip install neovim

  npm config set registry https://registry.npm.taobao.org

  rustup install stable
}

wait
cfg_processor
cfg_desktop
cfg_fun
cfg_zh
install_tools
programs_conf
