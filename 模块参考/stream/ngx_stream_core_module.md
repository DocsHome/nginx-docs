# ngx_stream_core_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [listen](#listen)
    - [preread_buffer_size](#preread_buffer_size)
    - [preread_timeout](#preread_timeout)
    - [proxy_protocol_timeout](#proxy_protocol_timeout)
    - [resolver](#resolver)
    - [resolver_timeout](#resolver_timeout)
    - [server](#server)
    - [stream](#stream)
    - [tcp_nodelay](#tcp_nodelay)
    - [variables_hash_bucket_size](#variables_hash_bucket_size)
    - [variables_hash_max_size](#variables_hash_max_size)
- [内嵌变量](#embedded_variables)

`ngx_stream_core_module` 模块自版本 1.9.0 起可用。默认构建情况下不包含模块，可在构建时使用 `--with-stream` 配置参数启用。

<a id="example_configuration"></a>

## 示例配置

```nginx
worker_processes auto;

error_log /var/log/nginx/error.log info;

events {
    worker_connections  1024;
}

stream {
    upstream backend {
        hash $remote_addr consistent;

        server backend1.example.com:12345 weight=5;
        server 127.0.0.1:12345            max_fails=3 fail_timeout=30s;
        server unix:/tmp/backend3;
    }

    upstream dns {
       server 192.168.0.1:53535;
       server dns.example.com:53;
    }

    server {
        listen 12345;
        proxy_connect_timeout 1s;
        proxy_timeout 3s;
        proxy_pass backend;
    }

    server {
        listen 127.0.0.1:53 udp reuseport;
        proxy_timeout 20s;
        proxy_pass dns;
    }

    server {
        listen [::1]:12345;
        proxy_pass unix:/tmp/stream.socket;
    }
}
```

<a id="directives"></a>

## 指令

### listen

|\-|说明|
|------:|------|
|**语法**|**listen** `address:port [ssl] [udp] [proxy_protocol] [backlog=number] [rcvbuf=size] [sndbuf=size] [bind] [ipv6only=on\|off] [reuseport] [so_keepalive=on\|off\|[keepidle]:[keepintvl]:[keepcnt]]`;|
|**默认**|——|
|**上下文**|server|

为接受连接服务器的 socket 设置 `address` 和 `port`。可仅指定端口。地址也可以是主机名，例如：

```nginx
listen 127.0.0.1:12345;
listen *:12345;
listen 12345;     # same as *:12345
listen localhost:12345;
```

IPv6 地址需要在方括号中指定：

```nginx
listen [::1]:12345;
listen [::]:12345;
```

UNIX 域套接字务必加上 `unix:` 前缀：

```nginx
listen unix:/var/run/nginx.sock;
```

`ssl` 参数允许端口上接受的所有连接都在 SSL 模式下工作。

`udp` 参数配置一个监听 socket 以处理数据报（1.9.13）。

`proxy_protocol` 参数（1.11.4）允许指定端口上接受的所有连接都使用 [PROXY 协议](http://www.haproxy.org/download/1.5/doc/proxy-protocol.txt)。

> 自 1.13.11 版本起支持 PROXY 协议版本 2。

`listen` 指令有几个专门与套接字相关的系统调用的附加参数。

- `backlog=number`

    在 `listen()` 调用中设置 `backlog` 参数，该参数限制挂起连接队列的最大长度（1.9.2）。默认情况下，`backlog` 在 FreeBSD、DragonFly BSD 和 macOS 上设置为 -1，在其他平台上设置为 511。
    
- `rcvbuf=size`

    设置监听套接字的接收缓冲区大小（`SO_RCVBUF` 选项）（1.11.13）。

- `sndbuf=size`

    设置监听套接字的发送缓冲区大小（`SO_SNDBUF` 选项）（1.11.13）。
    
- `bind`

    此参数对给定的 `address:port` 对进行单独的 `bind()` 调用。事实上，如果存在几个具有相同端口但地址不同的 `listen` 指令，并且其中一个 `listen` 指令监听给定的端口（`*:port`）的所有地址，则 nginx 将 `bind()` 仅限于 `*:port` 范围。要注意的是，在这种情况下将调用 `getsockname()` 系统调用以确定接受连接的地址。如果使用了 `ipv6only` 或 `so_keepalive` 参数，那么对于指定的`address:port` 对将始终对 `bind()` 单独调用。

- `ipv6only=on|off`

    此参数确定（通过 `IPV6_V6ONLY` 套接字选项）监听通配符地址 `[::]` 的 IPv6 套接字是接受 IPv6 和 IPv4 连接还是仅接受 IPv6 连接。默认情况下，此参数处于启用状态。它只能在启动时设置一次。

- `reuseport`

    此参数（1.9.1）表示为每个 worker 进程创建一个单独的监听套接字（在 Linux 3.9+ 和 DragonFly BSD 上使用 `SO_REUSEPORT` 套接字选项，在 FreeBSD 12+ 上使用 `SO_REUSEPORT_LB`），允许内核在 worker 进程之间分配传入连接。目前仅适用于 Linux 3.9+、DragonFly BSD 和 FreeBSD 12+（1.15.1）。
    
    > 不恰当地使用此选项可能会产生安全[隐患](http://man7.org/linux/man-pages/man7/socket.7.html)。

- `so_keepalive=on|off|[keepidle]:[keepintvl]:[keepcnt]`

    此参数配置监听套接字的 **TCP keepalive** 行为。如果省略此参数，将启用操作系统的套接字设置。如果将其设置为值 `on`，则为套接字打开 `SO_KEEPALIVE` 选项。如果将其值设置为 `off`，则为套接字关闭 `SO_KEEPALIVE` 选项。某些操作系统支持使用 `TCP_KEEPIDLE`、`TCP_KEEPINTVL` 和 `TCP_KEEPCNT` 套接字选项在每个套接字的基础上设置 TCP keepalive 参数。在此类系统上（目前有 Linux 2.4+、NetBSD 5+ 和 FreeBSD 9.0-STABLE），可以使用 `keepidle`、`keepintvl` 和` keepcnt` 参数配置。可省略一两个参数，在该情况下，相应套接字选项的系统默认设置将生效。例如，
    
    ```nginx
    so_keepalive=30m::10
    ```
    
    将设置空闲超时（`TCP_KEEPIDLE`）为 30 分钟，探测间隔（`TCP_KEEPINTVL`）保留为系统默认值，将探测包数（`TCP_KEEPCNT`）设置为 10 个。

不同的服务器必须侦听不同的 `address:port` 对。

### preread_buffer_size

|\-|说明|
|------:|------|
|**语法**|**preread_buffer_size** `size`;|
|**默认**|preread_buffer_size 16k;|
|**上下文**|stream、server|
|**提示**|该指令在 1.11.5 版本中出现|

指定[预读缓冲区](../../介绍/Nginx如何处理请求.md)的 `size`（大小）。

### preread_timeout

|\-|说明|
|------:|------|
|**语法**|**preread_timeout** `timeout`;|
|**默认**|preread_timeout 30s;|
|**上下文**|stream、server|
|**提示**|该指令在 1.11.5 版本中出现|

指定[预读缓冲区](../../介绍/Nginx如何处理请求.md)的 `timeout`（超时时间）。

### proxy_protocol_timeout

|\-|说明|
|------:|------|
|**语法**|**proxy_protocol_timeout** `timeout`;|
|**默认**|proxy_protocol_timeout 30s;|
|**上下文**|stream、server|
|**提示**|该指令在 1.11.4 版本中出现|

指定读取 PROXY 协议头完成的 `timeout`（超时时间）。如果在此时间内未传输完整个头，则关闭连接。

### resolver

|\-|说明|
|------:|------|
|**语法**|**resolver** `address ... [valid=time] [ipv6=on\|off]`;|
|**默认**|——|
|**上下文**|stream、server|
|**提示**|该指令在 1.11.3 版本中出现|

将用于解析上游服务器名称的域名服务器（Name Server）配置到地址列表中，例如：

```nginx
resolver 127.0.0.1 [::1]:5353;
```

可以将地址指定为一个域名或 IP 地址，以及可附带一个可选端口。如果未指定端口，则使用 53 端口。域名服务器将以循环方式查询。

默认情况下，nginx 将在解析时查找 IPv4 和 IPv6 地址。如果不需要查找 IPv6 地址，可以配置 `ipv6=off` 参数。

默认情况下，nginx 使用响应 TTL 值缓存响应。可选的 `valid` 参数可改写该行为：

```nginx
resolver 127.0.0.1 [::1]:5353 valid=30s;
```

> 在 1.11.3 版本之前，该指令为我们[商业订阅](http://nginx.com/products/?_ga=2.65082989.2133050593.1544107800-1363596925.1544107800)的一部分。

### server

|\-|说明|
|------:|------|
|**语法**|**server** `{ ... }`;|
|**默认**|——|
|**上下文**|stream|

配置 server。

### stream

|\-|说明|
|------:|------|
|**语法**|**stream** `{ ... }`;|
|**默认**|——|
|**上下文**|main|

为指定 stream server 指令的提供配置文件上下文。

### tcp_nodelay

|\-|说明|
|------:|------|
|**语法**|**tcp_nodelay** `on` &#124; `off`;|
|**默认**|tcp_nodelay on;|
|**上下文**|stream、server|
|**提示**|该指令在 1.9.4 版本中出现|

启用或禁用 `TCP_NODELAY` 选项。该选项对客户端和代理服务器连接都有作用。

### variables_hash_bucket_size

|\-|说明|
|------:|------|
|**语法**|**variables_hash_bucket_size** `size`;|
|**默认**|variables_hash_bucket_size 64;|
|**上下文**|stream|
|**提示**|该指令在 1.11.2 版本中出现|

设置变量哈希表的桶大小。设置哈希表的详细信息在单独的[文档](../../介绍/设置哈希.md)有详细说明。

<a id="embedded_variables"></a>

## 内嵌变量

`ngx_stream_core_module` 模块自 1.11.2 版本起支持变量。

- `$binary_remote_addr`

    客户端地址采用二进制形式，值的长度始终为 IPv4 地址的 4 个字节或 IPv6 地址的 16 个字节

- `$bytes_received`

    从客户端收到的字节数（1.11.4）

- `$bytes_sent`

    发送到客户端的字节数

- `$connection`

    连接序列号

- `$hostname`

    主机名

- `$msec`

    以秒为单位的当前时间（精度为毫秒）

- `$nginx_version`

    nginx 版本

- `$pid`

    worker 进程 PID

- `$protocol`

    用于与客户端通信的协议：`TCP` 或 `UDP`（1.11.4）

- `$proxy_protocol_addr`

    来自 PROXY 协议头的客户端地址，否则为空字符串（1.11.4）
    
    必须先在 [listen](#listen) 指令中设置 `proxy_protocol` 参数来启用 PROXY 协议。

- `$proxy_protocol_port`

    来自 PROXY 协议头的客户端端口，否则为空字符串（1.11.4）

    必须先在 [listen](#listen) 指令中设置 `proxy_protocol` 参数来启用 PROXY 协议。

- `$remote_addr`

    客户地址

- `$remote_port`

    客户端端口

- `$server_addr`

    接受连接的服务器地址
    
    计算此变量的值通常需要一次系统调用。为避免系统调用，[listen](#listen) 指令必须指定地址并使用 `bind` 参数。

- `$server_port`

    接受连接的服务器端口

- `$session_time`

    会话持续时间（以秒为单位），精度为毫秒（1.11.4）

- `$status`

    会话状态（1.11.4），可以是以下之一：

    - `200`
        
        会话成功完成
        
    - `400`
    
        无法解析客户端数据，例如 PROXY 协议头
    
    - `403`
    
        禁止访问。例如，当某些客户端地址访问受限时
    
    - `500`
    
        内部服务器错误
        
    - `502`
        
        错误网关，例如，如果无法选择或到达上游服务器。
        
    - `503`
        
        服务不可用，例如，当访问受连接数受限时
        
- `$time_iso8601`
    
    本地时间采用 ISO 8601 标准格式

- `$time_local`

    通用日志（Common Log）格式的本地时间

## 原文档
[http://nginx.org/en/docs/stream/ngx_stream_core_module.html](http://nginx.org/en/docs/stream/ngx_stream_core_module.html)
