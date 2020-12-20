# 简介

此仓库存放的主要是我在 ArchLinux 下的安装脚本，包括

1. startInstall 环境初始化，和加载安装脚本
2. baseInstall 系统安装和配置脚本
2. desktopInstall 桌面环境安装和配置脚本

## 初始化脚本

用于检测是否是 UEFI 启动、同步硬件时间和格式化硬以及安装最基础的 Archlinux 系统

## Archlinux 安装脚本

此脚本安装的 archlinux 只支持 UEFI 方式，使用最少的工具，且大部分为 archlinux 基本系统中的内置工具，和 linux 系统下必须存在的工具。

且所有工具都为终端工具，没有图形化工具，如果您有其他需求，请自行安装

之所以使用如此少的工具，是为了做到最小化安装，也防止版本更迭时，因工具产生的其他问题

你可以使用以下命令下载此脚本

```sh
wget https://raw.githubusercontent.com/R0boter/ArchlinuxInstall/master/archInstall.sh
```

详细的脚本执行流程及注意事项，请参考我博客中的[这篇文章](https://roboter.ga/Archlinux-安装脚本)

## Archlinux 桌面环境安装脚本

此脚本是配和平铺式窗口管理器 DWM 使用的，如果您使用的是其他平铺式窗口管理器也可以使用，因为 dwm 的安装是单独分开的

如果您不是使用的窗口管理器，而是使用的其他桌面环境，不建议您使用，但您可以作为参考，用于编写你自己的脚本

你可以使用以下命令下载此脚本

```sh
wget https://raw.githubusercontent.com/R0boter/ArchlinuxInstall/master/archDesktop.sh
```

详细的脚本执行流程及脚本介绍，请参考我博客中的[这篇文章](https://roboter.ga/Archlinux-桌面环境安装脚本)
