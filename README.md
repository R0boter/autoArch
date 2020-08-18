# 简介

此仓库存放的主要是我在 ArchLinux 下的一些脚本，包括

1. archlinux 安装脚本
2. archlinux 桌面环境安装和配置脚本

## Archlinux 安装脚本

此脚本是我根据 Archlinux Wiki 上对安装 archlinux 的说明编写的脚本,原则是尽可能安装最少的软件，防止以后版本变更中产生过于复杂的依赖,所以安装脚本，执行完毕后，只有最基础的字符界面，如果需要桌面环境需要另行安装

如果您也是极简主义者，或许您会喜欢平铺式窗口，可以使用我桌面安装脚本，和我配置的 dwm （当然您也可以选择其他窗口管理器，依然可以使用我的桌面环境安装脚本）

Tips: 

1. 为了尽可能少的出现意外情况，此脚本有很大限制，具体限制如下

2. 使用此脚本之前请确保，您在进入 archlinux 安装终端后已经联网且有更新软件源和安装 git

    ```sh
    pacman -Syy
    pacman -S git
    ```

3. 确保您是以 UEFI 方式启动，此脚本不对 Legacy 启动方式兼容

4. 此脚本，默认只有一块磁盘，且 archlinux 将完全使用这块磁盘(因为我个人不是很支持双系统的方式，感觉很麻烦)。如果您有多块磁盘需要挂载可以修改  format_disk 函数

5. 使用此脚本之前必须修改脚本中 cfg_user 函数中的 root 密码(第 109 行，默认为 toor)，用户名(第 111 行，默认为 username)，用户密码(第 111 行，默认为passwd)。和 cfg_autologin 函数中的用户名为您在 cfg_user 函数中修改的用户名(第 119 行，默认为 username)。

    ```sh
    # 你可以在 vim 中使用如下
    :109 s/toor/your-root-passwd/g
    :111 s/username/your-username/g
    :111 s/passwd/your-passwd/g
    :119 s/username/your-username/g
    ```

### 安装脚本流程

1. 检查本地时间，是否正确
2. 检查是否使用 UEFI 启动
3. 格式化硬盘，再次提醒如果您有多块 硬盘请在 format_disk 函数中挂载
4. 我的分区方式，只分了 512M 给启动盘，剩余的作为一个同一的划分给系统，没有交换分区，也没有将家目录单独分区，如果您有自己的分区习惯请修改 format_disk 函数

5. 设置镜像源为中国国内的源，在 cfg_mirror 函数中。另外添加了 163、清华、国内官方源，默认启用 163 源
6. 安装基础系统，分别为 基础包base 和 linux，基础固件驱动 linux-firmware，权限管理工具 sudo，默认shell  zsh，编辑器 neovim
7. 系统设置，
      - 生成挂载文件 fstab
      - 设置时区为上海，并同步硬件时间
      - 设置本地环境变量支持中文，但默认显示是英文(防止字符界面乱码)
      - 设置本地 hosts 文件和本机 hostname，将 github 下各个网址的解析写入 hosts 文件，防止 DNS 污染导致的 github 及其下网址无法访问
      - 设置 nvim 为默认编辑器，并设置 vi 和 vim 的软链接都是 nvim
      - 为 pacman 开启色彩和彩蛋(pacman 进度条变成真正的吃豆人)
8. 启动引导设置，我没有使用常规的 grub 方式引导，而使用的 archlinux 内置的systemd 下的 systemd-boot 工具
      - 一是因为，我使用 arch 的原因就是为了减少系统中无用的工具，所以如果系统有我一定不会使用第三方工具
      - 二是因为，此工具占用更少，启动更快，而且它只支持 UEFI 方式，而且我也没有双系统需求(前面有说)
8. 安装基础软件
      - which 终端一个查找软件，其他 linux 一般自带(很少用，或许我会删掉)
      - git 版本控制软件，不仅仅管理代码用的，linux 下很多软件的安装使用都离不开它
      - wget 和 curl 两款下载工具，比较常用 wget 感觉比 curl 稳定一些，但 curl 感觉更快一些
      - unrar unzip tar 打包软件和解压软件
      - gcc make g++ 编译软件
      - fakeroot binutils 
      - fontconfig 字体配置工具
      - pkgconf
9. 设置root账户密码，并添加新用户，开启使用 sudo 时不用输入密码(其实这个行为挺不安全的，建议对linux不熟的还是把这个关了，通过修改/etc/sudoers 文件)
10. 设置自动登陆(个人是很喜欢这个功能，搭配xinit，就不用登陆管理器了，开机直接进入桌面)
11. 设置网络
      - 网络管理我也没有采用第三方工具，使用的是 archlinux 内置的 system 下的 system-netwoek 工具。理由和引导启动工具一样
      - 首先会让你选择是否存在wifi,如果有wifi会安装 wpa_supplicant，生成wifi网卡配置文件在 /etc/systemd/network/25-wireless.network，生成 wifi 网络的配置文件在 /etc/wpa_supplicant/wpa_supplicant.conf
      - 然后生成有线网卡的配置文件在 /etc/systemd/network/20-wired.network，并开启网络服务
12. 设置域名解析服务器

### 后记

此脚本安装的 archlinux 只支持 UEFI 方式，使用最少的工具，且大部分为 archlinux 基本系统中的内置工具，和 linux 系统下必须存在的工具。

且所有工具都为终端工具，没有图形化工具，如果您有其他需求，请自行安装

之所以使用如此少的工具，是为了做到最小化安装，也防止版本更迭时，因工具产生的其他问题
