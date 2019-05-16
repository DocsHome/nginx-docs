# 从源码构建 nginx

编译时使用 `configure` 命令进行配置。它定义了系统的各个方面，包括了 nginx 进行连接处理使用的方法。最终它会创建出一个 `Makefile`。`configure` 命令支持以下参数：

- **--prefix=path**

    定义一个用于保留服务器文件的目录。此目录也将用于所有通过 `configure` 设置的相对路径（除了库源码路径外）和 `nginx.conf` 配置文件。默认设置为 `/usr/local/nginx` 目录。
- **--sbin-path=path**

    设置 nginx 可执行文件的名称。此名称仅在安装过程中使用。默认情况下，文件名为 `prefix/sbin/nginx`。
- **--conf-path=path**

    设置 `nginx.conf` 配置文件的名称。如果需要，nginx 可以使用不同的配置文件启动，方法是使用命令行参数 `-c` 指定文件。默认情况下，文件名为 `prefix/conf/nginx.conf`。
- **--pid-path=path**

    设置存储主进程的进程 ID 的 nginx.pid 文件名称。安装后，可以在 `nginx.conf` 配置文件中使用 [pid](http://nginx.org/en/docs/ngx_core_module.html#pid) 指令更改文件名。默认文件名为 `prefix/logs/nginx.pid`。
- **--lock-path=path**

    设置锁文件的名称前缀。安装后，可以在 `nginx.conf` 配置文件中使用 [lock_file](http://nginx.org/en/docs/ngx_core_module.html#lock_file) 指令更改对应的值。默认值为 `prefix/logs/nginx.lock`。
- **--error-log-path=path**

    设置主要错误、警告和诊断文件的名称。安装后，可以在 `nginx.conf` 配置文件中使用 [error_log](http://nginx.org/en/docs/ngx_core_module.html#error_log) 指令更改文件名。默认情况下，文件名为 `prefix/logs/error.log`。
- **--http-log-path=path**

    设置 HTTP 服务器主请求日志文件名称。安装后，可以在 `nginx.conf` 配置文件中使用 [access_log](http://nginx.org/en/docs/http/ngx_http_log_module.html#access_log) 指令更改文件名。默认情况下，文件名为 `prefix/logs/access.log`。
- **--build=name**

    设置一个可选的 nginx 构建名称
- **--user=name**

    设置一个非特权用户名称，其凭据将由工作进程使用。安装后，可以在 `nginx.conf` 配置文件中使用 [user](http://nginx.org/en/docs/ngx_core_module.html#user) 指令更改名称。默认的用户名为 `nobody`。
- **--group=name**

    设置一个组的名称，其凭据将由工作进程使用。安装后，可以在 `nginx.conf` 配置文件中使用 [user](http://nginx.org/en/docs/ngx_core_module.html#user) 指令更改名称。默认情况下，组名称设置为一个非特权用户的名称。
- **--with-select_module 和 --without-select_module**

    启用或禁用构建允许服务器使用 `select()` 方法的模块。如果平台不支持其他更合适的方法（如 kqueue、epoll 或 /dev/poll），则将自动构建该模块。
- **--with-poll_module 和 --without-poll_module**

    启用或禁用构建允许服务器使用 `poll()` 方法的模块。如果平台不支持其他更合适的方法（如 kqueue、epoll 或 /dev/poll），则将自动构建该模块。
- **with-threads**
    
    允许使用线程池[thread pools](http://nginx.org/en/docs/ngx_core_module.html#thread_pool)
- **with-file-aio**

    启用在FreeBSD和Linux上[asynchronous file I/O](http://nginx.org/en/docs/http/ngx_http_core_module.html#aio) (aio)指令的使用
- **--without-http_gzip_module**

    禁用构建 HTTP 服务器[响应压缩](http://nginx.org/en/docs/http/ngx_http_gzip_module.html)模块。需要 zlib 库来构建和运行此模块。
- **--without-http_rewrite_module**

    禁用构建允许 HTTP 服务器[重定向请求](http://nginx.org/en/docs/http/ngx_http_rewrite_module.html)和[更改请求 URI](http://nginx.org/en/docs/http/ngx_http_rewrite_module.html) 的模块。需要 PCRE 库来构建和运行此模块。
- **--without-http_proxy_module**

    禁用构建 HTTP 服务器[代理模块](http://nginx.org/en/docs/http/ngx_http_proxy_module.html)。
- **--with-http_ssl_module**

    允许构建可将 [HTTPS 协议支持](http://nginx.org/en/docs/http/ngx_http_ssl_module.html)添加到 HTTP 服务器的模块。默认情况下，此模块参与构建。构建和运行此模块需要 OpenSSL 库支持。
- **with-http_v2_module**

    允许构建一个支持[HTTP/2](http://nginx.org/en/docs/http/ngx_http_v2_module.html) 的模块。默认情况下，该模块不构建。
- **with-http_realip_module**
    
    允许构建[ngx_http_realip_module](http://nginx.org/en/docs/http/ngx_http_realip_module.html) 模块，该模块将客户端地址更改为在指定的header中发送的地址。该模块默认不构建。
- **with-http_addition_module**

    允许构建[ngx_http_addition_module](http://nginx.org/en/docs/http/ngx_http_addition_module.html) 模块，该模块能够在响应之前和之后添加文本。该模块默认不构建。
- **with-http_xslt_module**和**with-http_xslt_module=dynamic**

    允许构建使用一个或者多个XSLT样式表转化为XML响应的[ngx_http_xslt_module](http://nginx.org/en/docs/http/ngx_http_xslt_module.html)。该模块默认不构建。[libxslt](http://xmlsoft.org/XSLT/) 和 [libxml2](http://xmlsoft.org/) 库需要这个模块来构建和启动。
- **with-http_image_filter_module**和**with-http_image_filter_module=dynamic**

    允许构建[ngx_http_image_filter_module](http://nginx.org/en/docs/http/ngx_http_image_filter_module.html) 模块，该模块可以转换 JPEG, GIF, PNG, 和 WebP 格式的图片。该模块默认不构建。
- **with-http_geoip_module**和**with-http_geoip_module=dynamic**
    
    允许构建[ngx_http_geoip_module](http://nginx.org/en/docs/http/ngx_http_geoip_module.html) 模块。该模块根据客户端 IP 地址和预编译[MaxMind](https://www.maxmind.com/en/home) 的数据库创建变量。该模块默认不构建。
- **with-http_sub_module**

    允许构建[ngx_http_sub_module](http://nginx.org/en/docs/http/ngx_http_sub_module.html) 模块。该模块通过将一个指定的字符串替换为另一个来修改相应。该模块默认不构建。
-- **with-http_dav_module**
    
    允许构建[ngx_http_dav_module ](http://nginx.org/en/docs/http/ngx_http_dav_module.html) 模块。该模块通过WebDEV协议提供文件管理自动化。该模块默认不构建。
-- **with-http_flv_module**
    
    允许构建[with-http_flv_module](http://nginx.org/en/docs/http/ngx_http_flv_module.html) 模块。该模块为 Flash Videos (FLV) 文件提供伪流服务器端的支持。该模块默认不构建。
-- **with-http_mp4_module**
    
    允许构建[with-http_mp4_module](http://nginx.org/en/docs/http/ngx_http_mp4_module.html) 模块。该模块为 MP4 文件提供伪流服务器端的支持。该模块默认不构建。
-- **with-http_gunzip_module**
    
    允许构建[with-http_gunzip_module](http://nginx.org/en/docs/http/ngx_http_gunzip_module.html) 模块。该模块使用 `Content-Encoding: gzip` 来解压缩响应对于那些不支持`gzip`编码方法的客户端。该模块默认不构建。
- **--with-pcre=path**

    设置 PCRE 库的源路径。发行版（4.4 至 8.40 版本）需要从 [PCRE](http://www.pcre.org/) 站点下载并提取。其余工作由 nginx 的 `./configure` 和 `make` 完成。该库是 [location](http://nginx.org/en/docs/http/ngx_http_core_module.html#location) 指令和 [ngx_http_rewrite_module](http://nginx.org/en/docs/http/ngx_http_rewrite_module.html) 模块中正则表达式支持所必需的。
- **--with-pcre-jit**

    使用“即时编译（just-in-time compilation）”支持（1.1.12版本的 [pcre_jit](http://nginx.org/en/docs/ngx_core_module.html#pcre_jit) 指令）构建 PCRE 库。
- **--with-zlib=path**

    设置 zlib 库的源路径。发行版（1.1.3 至 1.2.11 版本）需要从 [zlib](http://zlib.net/) 站点下载并提取。其余工作由 nginx 的 `./configure` 和 `make` 完成。该库是 [ngx_http_gzip_module](http://nginx.org/en/docs/http/ngx_http_gzip_module.html) 模块所必需的。
- **--with-cc-opt=parameters**

    设置添加到 CFLAGS 变量的额外参数。当在 FreeBSD 下使用系统的 PCRE 库时，应指定 `--with-cc-opt="-I /usr/local/include"`。如果需要增加 `select()` 所支持的文件数量，也可以在这里指定，如：`--with-cc-opt="-D FD_SETSIZE=2048"`。
- **--with-ld-opt=parameters**

    设置链接期间使用的其他参数。在 FreeBSD 下使用系统 PCRE 库时，应指定--with-ld-opt="-L /usr/local/lib"`。

参数使用示例：

```bash
./configure \
    --sbin-path=/usr/local/nginx/nginx \
    --conf-path=/usr/local/nginx/nginx.conf \
    --pid-path=/usr/local/nginx/nginx.pid \
    --with-http_ssl_module \
    --with-pcre=../pcre-8.40 \
    --with-zlib=../zlib-1.2.11
```

配置完成之后，使用 `make` 和 `make install` 编译和安装 nginx。

## 原文档

[http://nginx.org/en/docs/configure.html](http://nginx.org/en/docs/configure.html)
