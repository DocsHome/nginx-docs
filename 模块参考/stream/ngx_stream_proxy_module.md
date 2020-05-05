# ngx_stream_proxy_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [proxy_bind](#proxy_bind)
    - [proxy_buffer_size](#proxy_buffer_size)
    - [proxy_connect_timeout](#proxy_connect_timeout)
    - [proxy_download_rate](#proxy_download_rate)
    - [proxy_next_upstream](#proxy_next_upstream)
    - [proxy_next_upstream_timeout](#proxy_next_upstream_timeout)
    - [proxy_next_upstream_tries](#proxy_next_upstream_tries)
    - [proxy_pass](#proxy_pass)
    - [proxy_protocol](#proxy_protocol)
    - [proxy_requests](#proxy_requests)
    - [proxy_responses](#proxy_responses)
    - [proxy_session_drop](#proxy_session_drop)
    - [proxy_socket_keepalive](#proxy_socket_keepalive)
    - [proxy_ssl](#proxy_ssl)
    - [proxy_ssl_certificate](#proxy_ssl_certificate)
    - [proxy_ssl_certificate_key](#proxy_ssl_certificate_key)
    - [proxy_ssl_ciphers](#proxy_ssl_ciphers)
    - [proxy_ssl_crl](#proxy_ssl_crl)
    - [proxy_ssl_name](#proxy_ssl_name)
    - [proxy_ssl_password_file](#proxy_ssl_password_file)
    - [proxy_ssl_protocols](#proxy_ssl_protocols)
    - [proxy_ssl_server_name](#proxy_ssl_server_name)
    - [proxy_ssl_session_reuse](#proxy_ssl_session_reuse)
    - [proxy_ssl_trusted_certificate](#proxy_ssl_trusted_certificate)
    - [proxy_ssl_verify](#proxy_ssl_verify)
    - [proxy_ssl_verify_depth](#proxy_ssl_verify_depth)
    - [proxy_timeout](#proxy_timeout)
    - [proxy_upload_rate](#proxy_upload_rate)

`ngx_stream_proxy_module` 模块（1.9.0）允许通过 TCP、UDP（1.9.13）和 UNIX 域套接字代理数据流。

<a id="example_configuration"></a>

## 示例配置

```nginx
server {
    listen 127.0.0.1:12345;
    proxy_pass 127.0.0.1:8080;
}

server {
    listen 12345;
    proxy_connect_timeout 1s;
    proxy_timeout 1m;
    proxy_pass example.com:12345;
}

server {
    listen 53 udp reuseport;
    proxy_timeout 20s;
    proxy_pass dns.example.com:53;
}

server {
    listen [::1]:12345;
    proxy_pass unix:/tmp/stream.socket;
}
```

<a id="directives"></a>

## 指令

### proxy_bind

|\-|说明|
|------:|------|
|**语法**|**proxy_bind** `address [transparent]` &#124; `off`;|
|**默认**|——|
|**上下文**|stream、server|
|**提示**|该指令在 1.9.2 版本中出现|

使到被代理服务器的出站连接源自指定的本地 IP 地址（`address`）。参数值可以包含变量（1.11.2）。特殊值 `off` 指定不继承上级 `proxy_bind` 指令配置，这使系统可以自动分配本地 IP 地址。

`transparent` 参数（1.11.0）允许到被代理服务器的出站连接源自非本地 IP 地址，例如，来自一个客户端的真实 IP 地址：

```nginx
proxy_bind $remote_addr transparent;
```

为了使此参数生效，通常必须使用[超级用户特权](../核心功能.md#user)运行 nginx worker 进程。在 Linux上，如果指定了 `transparent` 则不需要（1.13.8），worker 进程从 master 进程继承 `CAP_NET_RAW` 能力。还需要配置内核路由表以拦截来自被代理服务器的网络流量。

### proxy_buffer_size

|\-|说明|
|------:|------|
|**语法**|**limit_conn_log_level** `size`;|
|**默认**|proxy_buffer_size 16k;|
|**上下文**|stream、server|
|**提示**|该指令在 1.9.4 版本中出现|

设置读取被代理服务器数据的缓冲区的大小（`size`）。也用于设置读取客户端数据的缓冲区的大小（`size`）。

### proxy_connect_timeout

|\-|说明|
|------:|------|
|**语法**|**proxy_connect_timeout** `time`;|
|**默认**|proxy_connect_timeout 60s;|
|**上下文**|stream、server|

设置与被代理服务器建立连接的超时时间。

### proxy_download_rate

|\-|说明|
|------:|------|
|**语法**|**proxy_download_rate** `rate`;|
|**默认**|proxy_download_rate 0;|
|**上下文**|stream、server|
|**提示**|该指令在 1.9.3 版本中出现|

限制读取被代理服务器数据的速率。`rate` 以每秒字节数指定。零值禁用速率限制。该限制是针对每个连接设置的，因此，如果 nginx 同时打开两个与被代理服务器的连接，则总速率将是指定限制速率的两倍。

参数值可以包含变量（1.17.0）。如果需要根据特定条件限制速率，可参考以下配置示例：

```nginx
map $slow $rate {
    1     4k;
    2     8k;
}

proxy_download_rate $rate;
```

### proxy_next_upstream

|\-|说明|
|------:|------|
|**语法**|**proxy_next_upstream** `on` &#124; `off`;|
|**默认**|proxy_next_upstream on;|
|**上下文**|stream、server|

当连接无法与某个被代理服务器建立连接时，是否将客户端连接传递给下一个服务器。

将连接传递到下一个服务器可能会受到[尝试次数](#proxy_next_upstream_tries)和[时间](#proxy_next_upstream_timeout)的限制。

### proxy_next_upstream_timeout

|\-|说明|
|------:|------|
|**语法**|**proxy_next_upstream_timeout** `time`;|
|**默认**|proxy_next_upstream_timeout 0;|
|**上下文**|stream、server|

设置将连接传递到[下一个服务器](#proxy_next_upstream)的超时时间。`0` 值关闭此限制。

### proxy_next_upstream_tries

|\-|说明|
|------:|------|
|**语法**|**proxy_next_upstream_tries** `number`;|
|**默认**|proxy_next_upstream_tries 0;|
|**上下文**|stream、server|

设置将连接传递到[下一个服务器](#proxy_next_upstream)的尝试次数。`0` 值关闭此限制。

### proxy_pass

|\-|说明|
|------:|------|
|**语法**|**proxy_pass** `address`;|
|**默认**|——|
|**上下文**|server|

设置被代理服务器的地址。该地址可以指定为一个域名或 IP 地址以及端口：

```nginx
proxy_pass localhost:12345;
```

或作为 UNIX 域套接字路径：

```nginx
proxy_pass unix:/tmp/stream.socket;
```

如果一个域名解析为多个地址，则所有这些地址都将以轮询的方式使用。另外，可以将地址指定为一个[服务器组](ngx_stream_upstream_module.md)。

也可以使用变量（1.11.3）指定地址：

```nginx
proxy_pass $upstream;
```

在这种情况下，在配置的[服务器组](ngx_stream_upstream_module.md)中查找服务器名称，如果找不到，则使用一个 [resolver](ngx_stream_core_module.md#resolver)确定服务器名称。

### proxy_protocol

|\-|说明|
|------:|------|
|**语法**|**proxy_protocol** `on` &#124; `off`;|
|**默认**|proxy_protocol off;|
|**上下文**|stream、server|
|**提示**|该指令在 1.9.2 版本中出现|

为到被代理服务器的连接启用 [PROXY 协议](http://www.haproxy.org/download/1.5/doc/proxy-protocol.txt)。

### proxy_requests

|\-|说明|
|------:|------|
|**语法**|**proxy_requests** `number`;|
|**默认**|proxy_requests 0;|
|**上下文**|stream、server|
|**提示**|该指令在 1.15.7 版本中出现|

设置丢弃客户端和现有 UDP 流会话之间绑定的客户端数据报的数量。在收到指定数量的数据报后，来自同一客户端的下一个数据报将启动一个新会话。当所有客户端数据报都发送到被代理服务器并接收到预期的[响应](#proxy_responses)数时，或者达到[超时时间](#proxy_timeout)时，会话将终止。

### proxy_responses

|\-|说明|
|------:|------|
|**语法**|**proxy_responses** `number`;|
|**默认**|——|
|**上下文**|stream、server|
|**提示**|该指令在 1.9.13 版本中出现|

如果使用 [UDP](ngx_stream_core_module.md#udp) 协议，设置响应客户端数据报中来自被代理服务器的数据报期望数。该数字用作会话终止的提示。默认情况下，数据报的数量不受限制。

如果指定零值，则不会响应。但如果收到响应并且会话仍未完成，则该响应将被处理。

### proxy_session_drop

|\-|说明|
|------:|------|
|**语法**|**proxy_session_drop** `on` &#124; `off`;|
|**默认**|proxy_session_drop off;|
|**上下文**|stream、server|
|**提示**|该指令在 1.15.8 版本中出现|

设置在将被代理服务器从组中删除或标记为永久不可用后，是否可以终止与被代理服务器的所有会话。在[重新解析](#resolver)或使用了 API [`DELETE`](ngx_http_api_module.md#deleteStreamUpstreamServer) 命令时，可能会发生这种情况。如果服务器处于[不健康](ngx_stream_upstream_hc_module.md#health_check)状态或使用 API [PATCH](ngx_http_api_module.md#patchStreamUpstreamServer) 命令修改，服务器可标记为永久不可用。当为客户端或被代理服务器处理下一个读取或写入事件时，每个会话都会终止。

> 该指令为[商业订阅](http://nginx.com/products/?_ga=2.125901509.99786210.1588592638-1615340879.1588592638)部分。

### proxy_socket_keepalive

|\-|说明|
|------:|------|
|**语法**|**proxy_socket_keepalive** `on` &#124; `off`;|
|**默认**|proxy_socket_keepalive off;|
|**上下文**|stream、server|
|**提示**|该指令在 1.15.6 版本中出现|

为到被代理服务器的出站连接配置 **TCP keepalive** 行为。默认情况下，操作系统的设置影响到套接字。如果指令设置为 `on` 值，则将为套接字打开 `SO_KEEPALIVE` 套接字选项。

### proxy_ssl

|\-|说明|
|------:|------|
|**语法**|**proxy_ssl** `on` &#124; `off`;|
|**默认**|proxy_ssl off;|
|**上下文**|stream、server|

为到被代理服务器的连接启用 SSL/TLS 协议。

### proxy_ssl_certificate

|\-|说明|
|------:|------|
|**语法**|**proxy_ssl_certificate** `file`;|
|**默认**|——|
|**上下文**|stream、server|

指定一个 PEM 格式的证书文件，用于验证被代理服务器的身份。

### proxy_ssl_certificate_key

|\-|说明|
|------:|------|
|**语法**|**proxy_ssl_certificate_key** `file`;|
|**默认**|——|
|**上下文**|stream、server|

指定一个 PEM 格式的私钥文件，用于验证被代理服务器的身份。

### proxy_ssl_ciphers

|\-|说明|
|------:|------|
|**语法**|**proxy_ssl_ciphers** `ciphers`;|
|**默认**|proxy_ssl_ciphers DEFAULT;|
|**上下文**|stream、server|

指定连接到被代理服务器启用的密码算法。密码算法需要 OpenSSL 库支持。

可以使用 `openssl ciphers` 命令查看完整的算法支持列表。

### proxy_ssl_crl

|\-|说明|
|------:|------|
|**语法**|**proxy_ssl_crl** `file`;|
|**默认**|——|
|**上下文**|stream、server|

指定一个 PEM 格式的吊销证书（CRL）文件，用于[验证](#proxy_ssl_verify)被代理服务器的证书。

### proxy_ssl_name

|\-|说明|
|------:|------|
|**语法**|**proxy_ssl_name** `name`;|
|**默认**|proxy_ssl_name 来自 proxy_pass 的 host;|
|**上下文**|stream、server|

允许覆盖用于[验证](#proxy_ssl_verify)被代理服务器证书的服务器名称，并在与被代理服务器建立连接时[通过 SNI 传递](#proxy_ssl_server_name)。也可以使用变量（1.11.3）指定服务器名称。

默认情况下，使用 [proxy_pass](#proxy_pass) 地址的主机部分。

### proxy_ssl_password_file

|\-|说明|
|------:|------|
|**语法**|**proxy_ssl_password_file** `file`;|
|**默认**|——|
|**上下文**|stream、server|

指定一个保存有[密钥](#proxy_ssl_certificate_key)密码的文件，每个密码独占一行。加载密钥时依次尝试使用这些密码。

### proxy_ssl_protocols

|\-|说明|
|------:|------|
|**语法**|**proxy_ssl_protocols** `[SSLv2] [SSLv3] [TLSv1] [TLSv1.1] [TLSv1.2] [TLSv1.3]`;|
|**默认**|proxy_ssl_protocols TLSv1 TLSv1.1 TLSv1.2;|
|**上下文**|stream、server|

为到被代理服务器的连接启用指定协议。

### proxy_ssl_server_name

|\-|说明|
|------:|------|
|**语法**|**proxy_ssl_server_name** `on` &#124; `off`;|
|**默认**|proxy_ssl_server_name off;|
|**上下文**|stream、server|

与被代理服务器建立连接时，启用或禁用通过 [TLS 服务器名称指示扩展](http://en.wikipedia.org/wiki/Server_Name_Indication)（SNI、RFC 6066）传递服务器名称。

### proxy_ssl_session_reuse

|\-|说明|
|------:|------|
|**语法**|**proxy_ssl_session_reuse** `on` &#124; `off`;|
|**默认**|proxy_ssl_session_reuse on;|
|**上下文**|stream、server|

在使用被代理服务器时是否可以重用 SSL 会话。如果日志中出现错误 `SSL3_GET_FINISHED:digest check failed`，请尝试禁用会话重用。

### proxy_ssl_trusted_certificate

|\-|说明|
|------:|------|
|**语法**|**proxy_ssl_trusted_certificate** `file`;|
|**默认**|——|
|**上下文**|stream、server|

指定一个 PEM 格式的可信 CA 证书文件，该证书用于[验证](#proxy_ssl_verify)被代理服务器的证书。

### proxy_ssl_verify

|\-|说明|
|------:|------|
|**语法**|**proxy_ssl_verify** `on` &#124; `off`;|
|**默认**|proxy_ssl_verify off;|
|**上下文**|stream、server|

启用或禁用被代理服务器证书验证。

### proxy_ssl_verify_depth

|\-|说明|
|------:|------|
|**语法**|**proxy_ssl_verify_depth** `number`;|
|**默认**|proxy_ssl_verify_depth 1;|
|**上下文**|stream、server|

设置被代理服务器证书链验证深度。

### proxy_timeout

|\-|说明|
|------:|------|
|**语法**|**proxy_timeout** `timeout`;|
|**默认**|proxy_timeout 10m;|
|**上下文**|stream、server|

设置客户端或被代理服务器连接两次连续读取或写入操作之间的超时时间（`timeout`）。如果在此时间内没有数据传输，则连接将关闭。

### proxy_upload_rate

|\-|说明|
|------:|------|
|**语法**|**proxy_upload_rate** `rate`;|
|**默认**|proxy_upload_rate 0;|
|**上下文**|stream、server|
|**提示**|该指令在 1.9.3 版本中出现|

限制读取客户端数据的速率。该速率以每秒字节数指定。零值禁用速率限制。该限制只针对单个连接，因此，如果客户端同时打开两个连接，则总速率将是指定限制速率的两倍。

参数值可以包含变量（1.17.0）。如果需要根据特定条件设置限制速率，可参考以下配置示例：

```nginx
map $slow $rate {
    1     4k;
    2     8k;
}

proxy_upload_rate $rate;
```

## 原文档

[http://nginx.org/en/docs/stream/ngx_stream_proxy_module.html](http://nginx.org/en/docs/stream/ngx_stream_proxy_module.html)