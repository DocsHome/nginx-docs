# 在 Win32 平台上使用 Visual C 构建 nginx

## 先决条件

要在 Microsoft Win32® 平台上构建 nginx，您需要：

- Microsoft Visual C编译器。已知 Microsoft Visual Studio® 8 和 10 可以正常工作。
- [MSYS](http://www.mingw.org/wiki/MSYS)。
- 如果您要构建 OpenSSL® 和有 SSL 支持的 nginx，则需要 Perl。例如 [ActivePerl](http://www.activestate.com/activeperl) 或 [Strawberry Perl](http://strawberryperl.com/)。
- [Mercurial](https://www.mercurial-scm.org/) 客户端
- [PCRE](http://www.pcre.org/)、[zlib](http://zlib.net/) 和 [OpenSSL](http://www.openssl.org/) 库源代码。

## 构建步骤

在开始构建之前，确保将 Perl、Mercurial 和 MSYS 的 bin 目录路径添加到 PATH 环境变量中。从 Visual C 目录运行 vcvarsall.bat 脚本设置 Visual C 环境。

构建 nginx：

- 启动 MSYS bash。
- 检出 hg.nginx.org 仓库中的 nginx 源代码。例如：

```bash
hg clone http://hg.nginx.org/nginx
```

- 创建一个 build 和 lib 目录，并将 zlib、PCRE 和 OpenSSL 库源码解压到 lib 目录中：

```bash
mkdir objs
mkdir objs/lib
cd objs/lib
tar -xzf ../../pcre-8.41.tar.gz
tar -xzf ../../zlib-1.2.11.tar.gz
tar -xzf ../../openssl-1.0.2k.tar.gz
```

- 运行 configure 脚本：

```bash
auto/configure --with-cc=cl --builddir=objs --prefix= \
--conf-path=conf/nginx.conf --pid-path=logs/nginx.pid \
--http-log-path=logs/access.log --error-log-path=logs/error.log \
--sbin-path=nginx.exe --http-client-body-temp-path=temp/client_body_temp \
--http-proxy-temp-path=temp/proxy_temp \
--http-fastcgi-temp-path=temp/fastcgi_temp \
--with-cc-opt=-DFD_SETSIZE=1024 --with-pcre=objs/lib/pcre-8.41 \
--with-zlib=objs/lib/zlib-1.2.11 --with-openssl=objs/lib/openssl-1.0.2k \
--with-select_module --with-http_ssl_module
```

- 运行 make：

```bash
nmake -f objs/Makefile
```

## 相关内容

[Windows 下的 nginx](../介绍/Windows下的Nginx.md)

## 原文档

[http://nginx.org/en/docs/howto_build_on_win32.html](http://nginx.org/en/docs/howto_build_on_win32.html)
