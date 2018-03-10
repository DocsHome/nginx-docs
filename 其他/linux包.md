## nginx：Linux 软件包

目前，nginx 软件支持以下 Linux 发行版：

RHEL/CentOS：

| 版本 | 支持平台 |
|:------|:------|
| 6.x | x86_64，i386 |
| 7.x | x86_64，ppc64le |

Debian：

| 版本 | 代号 | 支持平台 |
|:------|:------|:------|
| 7.x | wheezy | x86_64，i386 |
| 8.x | jessie | x86_64，i386 |
| 9.x | stretch | x86_64，i386 |

Ubuntu：

| 版本 | 代号 | 支持平台 |
|:------|:------|:------|
| 12.04 | precise | x86_64，i386 |
| 14.04 | trusty | x86_64，i386, aarch64/arm64 |
| 16.04 | xenial | x86_64，i386, ppc64el，aarch64/arm64 |
| 16.10 | yakkety | x86_64，i386 |

SLES：

| 版本 | 支持平台 |
|:------|:------|
| 12 | x86_64 |

要启用 Linux 软件包的自动更新，可设置 RHEL/CentOS 发行版的 yum 仓库（repository），Debian/Ubuntu 发行版的 apt 仓库或 SLES 的 zypper 仓库。

## 稳定版本的预构建软件包

要设置 RHEL/CentOS 的 yum 仓库，请创建名为 `/etc/yum.repos.d/nginx.repo` 的文件，其中包含以下内容：

```ini
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/OS/OSRELEASE/$basearch/
gpgcheck=0
enabled=1
```

根据所使用的发行版，使用 `rhel` 或 `centos` 替换掉 `OS`，对于 6.x 或 7.x 版本，将 `OSRELEASE` 替换为 `6` 或 `7`。

对于 Debian/Ubuntu，为了验证 nginx 仓库签名，并且在安装 nginx 软件包时消除关于缺少 PGP 密钥的警告，需要将用于将 nginx 软件包和仓库签署的密钥添加到 `apt` 程序密钥环中。请从我们的网站下载此[密钥](http://nginx.org/keys/nginx_signing.key)，并使用以下命令将其添加到 `apt` 程序密钥环：

```bash
sudo apt-key add nginx_signing.key
```

对于 Debian，使用 Debian 发行版代号替换掉 `codename`，并将以下内容追加到 `/etc/apt/sources.list` 文件末尾：

```bash
deb http://nginx.org/packages/debian/ codename nginx
deb-src http://nginx.org/packages/debian/ codename nginx
```

对于 Ubuntu，使用 Ubuntu 发行版代号替换掉 `codename`，并将以下内容追加到 `/etc/apt/sources.list` 文件末尾：

```bash
deb http://nginx.org/packages/ubuntu/ codename nginx
deb-src http://nginx.org/packages/ubuntu/ codename nginx
```

对于 Debian/Ubuntu，请运行以下命令：

```bash
apt-get update
apt-get install nginx
```

对于 SLES，运行以下命令：

```bash
zypper addrepo -G -t yum -c 'http://nginx.org/packages/sles/12' nginx
```

## 主线版本的预构建软件包

要设置 RHEL/CentOS 的 yum 仓库，请创建名为 `/etc/yum.repos.d/nginx.repo` 的文件，其中包含以下内容：

```ini
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/OS/OSRELEASE/$basearch/
gpgcheck=0
enabled=1
```

根据所使用的发行版，使用 `rhel` 或 `centos` 替换掉 `OS`，对于 6.x 或 7.x 版本，将 `OSRELEASE` 替换为 `6` 或 `7`。

对于 Debian/Ubuntu，为了验证 nginx 仓库签名，并且在安装 nginx 软件包时消除关于缺少 PGP 密钥的警告，必须将用于将 nginx 软件包和仓库签署的密钥添加到 `apt` 程序密钥环中。请从我们的网站下载此 [密钥](http://nginx.org/keys/nginx_signing.key)，并使用以下命令将其添加到 `apt` 程序密钥环：

```bash
sudo apt-key add nginx_signing.key
```

对于 Debian，使用 Debian 发行版代号替换 `codename`，并将以下内容追加到 `/etc/apt/sources.list` 文件末尾：

```bash
deb http://nginx.org/packages/mainline/debian/ codename nginx
deb-src http://nginx.org/packages/mainline/debian/ codename nginx
```

对于 Ubuntu，使用 Ubuntu 发行版代号替换 `codename`，并将以下内容追加到 `/etc/apt/sources.list` 文件末尾：

```bash
deb http://nginx.org/packages/mainline/ubuntu/ codename nginx
deb-src http://nginx.org/packages/mainline/ubuntu/ codename nginx
```

对于 Debian/Ubuntu，请运行以下命令：

```bash
apt-get update
apt-get install nginx
```

对于 SLES，请运行以下命令：

```bash
zypper addrepo -G -t yum -c 'http://nginx.org/packages/mainline/sles/12' nginx
```

## 源码包
源码包可以在 [源码包库](http://hg.nginx.org/pkg-oss?_ga=2.100560158.1468443122.1505551652-1890203964.1497190280) 中找到。

`default` 分支保存当前主线版本的源码包，而 `stable-*` 分支包含了稳定版本的最新源码。要构建二进制包，请在 Debian/Ubuntu 上的 `debian/` 目录或在 RHEL/CentOS/SLES 上的 `rpm/SPECS/` 中运行 `make`。

源码包在 [类 BSD 的两项条款许可证](http://nginx.org/LICENSE) 下发行，与 nginx 相同。

## 动态模块
主 nginx 包使用了所有模块进行构建，没有使用到附加库，以避免额外的依赖。自 1.9.11 版本开始，nginx 支持 [动态模块](http://nginx.org/en/docs/ngx_core_module.html#load_module)，并将以下模块构建为动态模块，以独立软件包的形式发布：

```
nginx-module-geoip
nginx-module-image-filter
nginx-module-njs
nginx-module-perl
nginx-module-xslt
```

## 签名
RPM 软件包和 Debian/Ubuntu 仓库都使用数字签名来验证下载包的完整性和来源。为了检查签名，需要下载 [nginx 签名密钥](http://nginx.org/keys/nginx_signing.key) 并将其导入 rpm 或 apt 程序密钥环：

在 Debian/Ubuntu 上：

```bash
sudo apt-key add nginx_signing.key
```

在 RHEL/CentOS 上；

```bash
sudo rpm --import nginx_signing.key
```

在 SLES 上：

```bash
sudo rpm --import nginx_signing.key
```

Debian/Ubuntu/SLES 签名默认情况被检查，但是在 RHEL/CentOS 上，需要在 `/etc/yum.repos.d/nginx.repo` 文件中进行设置：

```
gpgcheck= 1
```

由于我们的 [PGP 密钥](http://nginx.org/en/pgp_keys.html) 和软件包都位于同一台服务器上，因此它们都是可信的。强烈建议另行验证下载的 PGP 密钥的真实性。PGP 具有“Web of Trust”（信任网络）的概念，当一个密钥是由别人的密钥签署的，而另一个密钥则由另一个密钥签名。它通常可以建立一个从任意密钥到您知道和信任的某人的密钥，从而验证链中第一个密钥的真实性。这个概念在 [GPG Mini Howto](http://www.dewinter.com/gnupg_howto/english/GPGMiniHowto-1.html) 中有详细描述。我们的钥匙有足够的签名，其真实性比较容易检查。

## 原文档

[http://nginx.org/en/linux_packages.html#distributions](http://nginx.org/en/linux_packages.html#distributions)
