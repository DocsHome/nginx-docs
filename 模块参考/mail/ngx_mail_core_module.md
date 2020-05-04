# ngx_mail_core_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [listen](#listen)
    - [mail](#mail)
    - [protocol](#protocol)
    - [resolver](#resolver)
    - [resolver_timeout](#resolver_timeout)
    - [server](#server)
    - [server_name](#server_name)
    - [timeout](#timeout)

默认不构建此模块，可使用 `--with-mail` 配置参数启用。

<a id="example_configuration"></a>

## 示例配置

```nginx
worker_processes 1;

error_log /var/log/nginx/error.log info;

events {
    worker_connections  1024;
}

mail {
    server_name       mail.example.com;
    auth_http         localhost:9000/cgi-bin/nginxauth.cgi;

    imap_capabilities IMAP4rev1 UIDPLUS IDLE LITERAL+ QUOTA;

    pop3_auth         plain apop cram-md5;
    pop3_capabilities LAST TOP USER PIPELINING UIDL;

    smtp_auth         login plain cram-md5;
    smtp_capabilities "SIZE 10485760" ENHANCEDSTATUSCODES 8BITMIME DSN;
    xclient           off;

    server {
        listen   25;
        protocol smtp;
    }
    server {
        listen   110;
        protocol pop3;
        proxy_pass_error_message on;
    }
    server {
        listen   143;
        protocol imap;
    }
    server {
        listen   587;
        protocol smtp;
    }
}
```

<a id="directives"></a>

## 指令

### listen

|\-|说明|
|:------|:------|
|**语法**|**listen** `address:port [ssl] [backlog=number] [rcvbuf=size] [sndbuf=size] [bind] [ipv6only=on\|off] [so_keepalive=on\|off\|[keepidle]:[keepintvl]:[keepcnt]]`;|
|**默认**|——|
|**上下文**|server|

为将接受请求的服务器的套接字设置地址（`address`）和端口（`port`）。可以仅指定端口。地址也可以是主机名，例如：

```nginx
listen 127.0.0.1:110;
listen *:110;
listen 110;     # same as *:110
listen localhost:110;
```

IPv6 地址在方括号中指定（0.7.58）：

```nginx
listen [::1]:110;
listen [::]:110;
```

UNIX 域套接字使用 `unix:` 前缀指定（1.3.5）：

```nginx
listen unix:/var/run/nginx.sock;
```

不同的服务器必须侦听不同的 `address:port` 对，不能重复。

`ssl` 参数指定该端口上接受的所有连接均应以 SSL 模式工作。

`listen` 指令可以指定几个额外的参数给套接字相关的系统调用。

- `backlog=number`

    在 `listen()` 调用中设置 `backlog` 参数，该参数限制挂起的连接队列的最大长度（1.9.2）。默认情况下，在 FreeBSD、DragonFly BSD 和 mac OS上，`backlog` 设置为 -1，而在其他平台上则设置为 511。

- `rcvbuf=size`

    设置侦听套接字的接收缓冲区大小（`SO_RCVBUF` 选项）（1.11.13）。

- `sndbuf=size`

    设置侦听套接字的发送缓冲区大小（`SO_SNDBUF` 选项）（1.11.13）。

- `bind`

    此参数指示对给定的 `address:port` 对进行单独的 `bind()` 调用。事实上，如果有多个有相同端口但地址不同的 `listen` 指令，并且其中一个 `listen` 指令在给定端口（`*:port`）的所有地址上监听，nginx 只会将绑定（`bind()`）到 `*:port`。要注意的是，这种情况下将进行 `getsockname()` 系统调用，以确定接受连接的地址。如果使用 `ipv6only` 或 `so_keepalive` 参数，则对于给定的 `address:port` 对，将始终进行单独的 `bind()` 调用。

- `ipv6only=on|off`

    此参数确定（通过 `IPV6_V6ONLY` 套接字选项）监听通配符地址 `[::]` 的 IPv6 套接字是否仅接受 IPv6 连接，还是接受 IPv6 和 IPv4 连接。默认情况下，此参数是打开的。启动时只能设置一次。

- `so_keepalive=on|off|[keepidle]:[keepintvl]:[keepcnt]`

    此参数为监听套接字配置「TCP keepalive」行为。如果省略此参数，则套接字的操作系统设置将生效。如果将其设置为值 `on`，则会为套接字打开 `SO_KEEPALIVE` 选项。如果将其设置为值 `off`，则将关闭套接字 `SO_KEEPALIVE` 选项。某些操作系统支持使用 `TCP_KEEPIDLE`、`TCP_KEEPINTVL` 和 `TCP_KEEPCNT` 套接字选项在每个套接字的基础上设置 TCP Keepalive 参数。在此类系统（当前为 Linux 2.4+、NetBSD 5+ 和 FreeBSD 9.0-STABLE）上，可以使用 `keepidle`、`keepintvl` 和 `keepcnt` 参数进行配置。可以省略一个或两个参数，在这种情况下，相应套接字选项的系统默认设置将生效。例如，

    ```nginx
    so_keepalive=30m::10
    ```

    会将闲置超时时间（`TCP_KEEPIDLE`）设置为 30 分钟，将探测间隔（`TCP_KEEPINTVL`）保留为系统默认值，并将探测计数（`TCP_KEEPCNT`）设置为 10 个探测。


### mail

|\-|说明|
|:------|:------|
|**语法**|**mail** `{ ... }`;|
|**默认**|——|
|**上下文**|main|

在指定的邮件服务器指令中提供配置文件上下文。

### protocol

|\-|说明|
|:------|:------|
|**语法**|**protocol** `imap` &#124; `pop3` &#124; `smtp`;|
|**默认**|——|
|**上下文**|server|

设置代理服务器的协议。支持的协议有 [IMAP](./ngx_mail_imap_module.md)、[POP3](./ngx_mail_pop3_module.md) 和 [SMTP](ngx_mail_smtp_module.md)。

如果未设置该指令，则可以基于 [listen](#listen) 指令中指定的为人熟知的默认端口来自动检测协议：

- `imap`：143、993
- `pop3`：110、995
- `smtp`：25、587、465

可以使用[配置](../../How-To/从源码构建nginx.md)参数 `--without-mail_imap_module`、`--without-mail_pop3_module` 和 `--without-mail_smtp_module` 禁用不必要的协议。

### resolver

|\-|说明|
|:------|:------|
|**语法**|**resolver** `address ... [valid=time] [ipv6=on\|off] [status_zone=zone]`;<br/>**resolver** `off`|
|**默认**|resolver off;|
|**上下文**|mail、server|

配置用于查找客户端主机名以将其传递给[身份验证服务器](./ngx_mail_auth_http_module.md)的名称服务器，以及代理 SMTP 时的 [XCLIENT](ngx_mail_proxy_module.md#xclient) 命令。 例如：

```nginx
resolver 127.0.0.1 [::1]:5353;
```

可以使用可选端口（1.3.1、1.2.2）将地址指定为域名或 IP 地址。如果未指定端口，则使用端口 53。以轮询方式查询名称服务器。

> 在 1.1.7 版本之前，只能配置一个名称服务器。从 1.3.1 和 1.2.2 版本开始，支持使用 IPv6 地址指定名称服务器。

默认情况下，nginx 将在解析时同时查找 IPv4 和 IPv6 地址。如果不需要查找 IPv6 地址，则可以指定 `ipv6=off` 参数。

> 从 1.5.8 版本开始，支持将名称解析为 IPv6 地址。

默认情况下，nginx 使用响应的 TTL 值缓存应答。可选的 `valid` 参数可覆盖它：

```nginx
resolver 127.0.0.1 [::1]:5353 valid=30s;
```

> 在1.1.9 版本之前，无法调整缓存时间，nginx 始终将应答缓存 5 分钟。

> 为防止 DNS 欺骗，建议在适当安全的受信任本地网络中配置 DNS 服务器。

可选的 `status_zone` 参数（1.17.1）启用对指定区域中的请求和响应的 DNS 服务器统计信息的[收集]功能(../http/ngx_http_api_module.md#resolvers_)。该参数为我们的[商业订阅](http://nginx.com/products/?_ga=2.151996858.282650095.1578660485-1105498734.1571247330)部分。

特殊值 `off` 禁用解析。

### resolver_timeout

|\-|说明|
|:------|:------|
|**语法**|**resolver_timeout** `time`;|
|**默认**|resolver_timeout 30s;|
|**上下文**|mail、server|

设置 DNS 操作的超时时间，例如：

```nginx
resolver_timeout 5s;
```

### server

|\-|说明|
|:------|:------|
|**语法**|**server** `{ ... }`;|
|**默认**|——|
|**上下文**|mail|

设置服务器的配置。

### server_name

|\-|说明|
|:------|:------|
|**语法**|**server_name** `name`;|
|**默认**|server_name hostname;|
|**上下文**|mail、server|

设置服务器名称，在以下场景中使用的：

- 最开始的 POP3/SMTP 服务器问候语中
- SASL CRAM-MD5 身份验证中的盐值中
- 如果启用了 [XCLIENT](ngx_mail_proxy_module.md#xclient) 命令的传递，则在连接到 SMTP 后端时，在 `EHLO` 命令中

如果未指定指令，则使用计算机的主机名。

### timeout

|\-|说明|
|:------|:------|
|**语法**|**timeout** `time`;|
|**默认**|timeout 60s;|
|**上下文**|mail、server|

设置超时时间，在代理到后端开始之前使用。

## 原文档

- [http://nginx.org/en/docs/mail/ngx_mail_core_module.html](http://nginx.org/en/docs/mail/ngx_mail_core_module.html)
