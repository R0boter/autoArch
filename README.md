# 简介

此仓库存放的主要是我在 ArchLinux 下的安装脚本，包括

1. startInstall 环境初始化，和加载安装脚本
2. baseInstall 系统安装和配置脚本
3. desktopInstall 桌面环境安装和配置脚本

此脚本安装的 archlinux 只支持 UEFI 方式，使用最少的工具，且大部分为 archlinux 基本系统中的内置工具，和 linux 系统下必须存在的工具。

且所有工具都为终端工具，没有图形化工具，如果您有其他需求，请自行安装

之所以使用如此少的工具，是为了做到最小化安装，也防止版本更迭时，因工具产生的其他问题

当你刻录好 Archlinux 启动盘后，进入 live 环境后，先使用如下命令更新仓库源

```sh
pacman -Syy
```

然后安装 Git

```sh
pacman -S git
```

然后使用以下命令克隆此仓库

```sh
git clone --depth=1 https://github.com/r0boter/autoArch
```
详细的脚本执行流程及注意事项，请参考我博客中的[这篇文章](https://mrrobot.eu.org/Archlinux-安装脚本)

## 初始化脚本

文件名：startInstall.sh

用于检测是否是 UEFI 启动、同步硬件时间和格式化硬盘以及安装最基础的 Archlinux 系统

## Archlinux 安装脚本

文件名：baseInstall.sh

用于安装基础工具，配置时区，汉化环境，安装启动器，设置用户，调整小设置以及配置网络

## Archlinux 桌面环境安装脚本

文件名：archDesktop.sh

用于安装 cpu 补丁，X11服务，日常使用软件，及桌面环境，并将我的个人配置移至对应的位置

不建议直接使用此脚本，应根据个人需要对此脚本进行一定的更改，因为此脚本下载的是我的个人配置，如果直接使用此脚本安装是符合我个人习惯的，里面的快捷键，软件设置等都是个性化极强的东西，不一定每个人都适合

但您可以作为参考，用于编写你自己的脚本

详细的脚本执行流程及脚本介绍，请参考我博客中的[这篇文章](https://mrrobot.eu.org/Archlinux-桌面环境安装脚本)
