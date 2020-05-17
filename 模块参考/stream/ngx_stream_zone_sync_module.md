# ngx_stream_zone_sync_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [zone_sync](#zone_sync)
    - [zone_sync_buffers](#zone_sync_buffers)
    - [zone_sync_connect_retry_interval](#zone_sync_connect_retry_interval)
    - [zone_sync_connect_timeout](#zone_sync_connect_timeout)
    - [zone_sync_interval](#zone_sync_interval)
    - [zone_sync_recv_buffer_size](#zone_sync_recv_buffer_size)
    - [zone_sync_server](#zone_sync_server)
    - [zone_sync_ssl](#zone_sync_ssl)
    - [zone_sync_ssl_certificate](#zone_sync_ssl_certificate)
    - [zone_sync_ssl_certificate_key](#zone_sync_ssl_certificate_key)
    - [zone_sync_ssl_ciphers](#zone_sync_ssl_ciphers)
    - [zone_sync_ssl_crl](#zone_sync_ssl_crl)
    - [zone_sync_ssl_name](#zone_sync_ssl_name)
    - [zone_sync_ssl_password_file](#zone_sync_ssl_password_file)
    - [zone_sync_ssl_protocols](#zone_sync_ssl_protocols)
    - [zone_sync_ssl_server_name](#zone_sync_ssl_server_name)
    - [zone_sync_ssl_trusted_certificate](#zone_sync_ssl_trusted_certificate)
    - [zone_sync_ssl_verify](#zone_sync_ssl_verify)
    - [zone_sync_ssl_verify_depth](#zone_sync_ssl_verify_depth)
    - [zone_sync_timeout](#zone_sync_timeout)
- [API 端点](#stream_zone_sync_status)
- [启动、停止、移除集群节点](#controlling_cluster_node)

`ngx_stream_zone_sync_module` 模块（1.13.8）为同步群集节点之间[共享内存区域](ngx_stream_upstream_module.md#zone)的内容提供了必要的支持。要为特定区域启用同步，相应的模块必须支持此功能。目前，可以同步 HTTP [粘性](../http/ngx_http_upstream_module.md#sticky)会话，有关[大流量 HTTP 请求](../http/ngx_http_limit_req_module.md)的信息以及 [http](../http/ngx_http_keyval_module.md) 和 [stream](ngx_stream_keyval_module.md) 中的键值对。

> 此模块为[商业订阅](http://nginx.com/products/?_ga=2.230988575.1858436578.1589555275-1645619674.1589555275)部分。

<a id="example_configuration"></a>

## 示例配置

最小化配置：


```nginx
http {
    ...

    upstream backend {
       server backend1.example.com:8080;
       server backend2.example.com:8081;

       sticky learn
              create=$upstream_cookie_examplecookie
              lookup=$cookie_examplecookie
              zone=client_sessions:1m sync;
    }

    ...
}

stream {
    ...


    server {
        zone_sync;

        listen 127.0.0.1:12345;

        # cluster of 2 nodes
        zone_sync_server a.example.com:12345;
        zone_sync_server b.example.com:12345;

    }
```

一个启用了 SSL 且使用 DNS 定义群集成员的更复杂配置：

```nginx
...

stream {
    ...

    resolver 127.0.0.1 valid=10s;

    server {
        zone_sync;

        # the name resolves to multiple addresses that correspond to cluster nodes
        zone_sync_server cluster.example.com:12345 resolve;

        listen 127.0.0.1:4433 ssl;

        ssl_certificate     localhost.crt;
        ssl_certificate_key localhost.key;

        zone_sync_ssl on;

        zone_sync_ssl_certificate     localhost.crt;
        zone_sync_ssl_certificate_key localhost.key;
    }
}
```

<a id="directives"></a>

## 指令

### zone_sync

|\-|说明|
|------:|------|
|**语法**|**zone_sync** `file`;|
|**默认**|——|
|**上下文**|server|

启用群集节点间共享内存区域同步。群集节点使用 [zone_sync_server](#zone_sync_server) 指令定义。

### zone_sync_buffers

|\-|说明|
|------:|------|
|**语法**|**zone_sync_buffers** `number size`;|
|**默认**|zone_sync_buffers 8 4k&#124;8k|
|**上下文**|stream、server|

为每个用于推送区域内容的区域缓冲区设置数量（`number`）和大小（`size`）。默认情况下，缓冲区大小等于一个内存页。根据平台的不同，可能是 4K 或 8K。

> 单个缓冲区必须有足够大的容量以容纳要同步的每个区域的条目。

### zone_sync_connect_retry_interval

|\-|说明|
|------:|------|
|**语法**|**zone_sync_connect_retry_interval** `time`;|
|**默认**|zone_sync_connect_retry_interval 1s;|
|**上下文**|stream、server|

定义到另一个群集节点的连接尝试间隔时间。

### zone_sync_connect_timeout

|\-|说明|
|------:|------|
|**语法**|**zone_sync_connect_timeout** `time`;|
|**默认**|zone_sync_connect_timeout 5s;|
|**上下文**|stream、server|

定义与另一个群集节点建立连接的超时时间。

### zone_sync_interval

|\-|说明|
|------:|------|
|**语法**|**zone_sync_interval** `time`;|
|**默认**|zone_sync_interval 1s;|
|**上下文**|stream、server|

定义共享内存区域的轮询更新时间间隔。

### zone_sync_recv_buffer_size

|\-|说明|
|------:|------|
|**语法**|**zone_sync_recv_buffer_size** `size`;|
|**默认**|zone_sync_recv_buffer_size 4k&#124;8k;|
|**上下文**|stream、server|

为每个连接设置接收缓冲区的大小（`size`），用于解析同步消息的传入流。缓冲区大小必须等于或大于 [zone_sync_buffers](#zone_sync_buffers) 之一。 默认情况下，缓冲区大小等于 [zone_sync_buffers](#zone_sync_buffers) 大小（`size`）乘以 `number`。

### zone_sync_server

|\-|说明|
|------:|------|
|**语法**|**zone_sync_server** `address [resolve]`;|
|**默认**|——|
|**上下文**|server|

定义集群节点的地址（`address`）。该地址可以指定为一个带有必须端口的域名或 IP 地址，也可以指定为以 `unix:` 为前缀的 UNIX 域套接字路径。解析为多个 IP 地址的域名一次定义了多个节点。

`resolve` 参数指示 nginx 监视与该节点的域名对应的 IP 地址的变更，并自动修改配置，而无需重新启动 nginx。

可以动态地将集群节点指定为带有 `resolve` 参数的单个 `zone_sync_server` 指令，也可以将其静态指定为一系列不带参数的指令。

> 每个集群节点只需指定一次。

> 所有集群节点应使用相同的配置。

为了使 `resolve` 参数生效，必须在 [stream](ngx_stream_core_module.md#stream) 块中指定 [resolver](ngx_stream_core_module.md#resolver) 指令。例如：

```nginx
stream {
    resolver 10.0.0.1;

    server {
        zone_sync;
        zone_sync_server cluster.example.com:12345 resolve;
        ...
    }
}
```

### zone_sync_ssl

|\-|说明|
|------:|------|
|**语法**|**zone_sync_ssl** `on` &#124; `off`;|
|**默认**|zone_sync_ssl off;|
|**上下文**|stream、server|

连接到另一个集群服务器启用 SSL/TLS 协议。

### zone_sync_ssl_certificate

|\-|说明|
|------:|------|
|**语法**|**zone_sync_ssl_certificate** `file`;|
|**默认**|——|
|**上下文**|stream、server|

指定一个 PEM 格式的证书文件，用于对另一个集群服务器进行身份验证。

### zone_sync_ssl_certificate_key

|\-|说明|
|------:|------|
|**语法**|**zone_sync_ssl_certificate_key** `file`;|
|**默认**|——|
|**上下文**|stream、server|

指定一个 PEM 格式的密钥文件，用于对另一个集群服务器进行身份验证。

### zone_sync_ssl_ciphers

|\-|说明|
|------:|------|
|**语法**|**zone_sync_ssl_ciphers** `ciphers`;|
|**默认**|zone_sync_ssl_ciphers DEFAULT;|
|**上下文**|stream、server|

指定用于连接到另一个群集服务器启用的密码算法。仅支持 OpenSSL 库的密码算法。

可以使用 `openssl ciphers` 命令查看完整支持列表。

### zone_sync_ssl_crl

|\-|说明|
|------:|------|
|**语法**|**zone_sync_ssl_crl** `file`;|
|**默认**|——|
|**上下文**|stream、server|

指定一个 PEM 格式的吊销证书（CRL）文件，该文件用于验证另一个群集服务器的证书。

### zone_sync_ssl_name

|\-|说明|
|------:|------|
|**语法**|**zone_sync_ssl_name** `name`;|
|**默认**|zone_sync_ssl_name host from zone_sync_server;|
|**上下文**|stream、server|
|**提示**|该指令在 1.15.7 版本中出现|

与集群服务器建立连接时，允许覆盖用于[验证](#zone_sync_ssl_verify)集群服务器证书并通过 [SNI](#zone_sync_ssl_server_name) 传递的服务器名称。

默认情况下，使用 [zone_sync_server](#zone_sync_server) 地址的主机部分，或者使用解析得到的 IP 地址（如果指定了 [resolve](ngx_stream_zone_sync_module.md#resolve) 参数）。

### zone_sync_ssl_password_file

|\-|说明|
|------:|------|
|**语法**|**zone_sync_ssl_password_file** `file`;|
|**默认**|——|
|**上下文**|stream、server|

指定一个存储有[密钥](#zone_sync_ssl_certificate_key)口令的文件，每个口令独占一行。加载密钥时依次尝试这些口令。

### zone_sync_ssl_protocols

|\-|说明|
|------:|------|
|**语法**|**zone_sync_ssl_protocols** `[SSLv2] [SSLv3] [TLSv1] [TLSv1.1] [TLSv1.2] [TLSv1.3]`;|
|**默认**|zone_sync_ssl_protocols TLSv1 TLSv1.1 TLSv1.2;|
|**上下文**|stream、server|

为连接到另一个集群服务器启用指定的协议。

### zone_sync_ssl_server_name

|\-|说明|
|------:|------|
|**语法**|**zone_sync_ssl_server_name** `on` &#124; `off`;|
|**默认**|zone_sync_ssl_server_name off;|
|**上下文**|stream、server|
|**提示**|该指令在 1.15.7 版本中出现|

与其他集群服务器建立连接时，启用或禁用通过 [TLS 服务器名称指示扩展](http://en.wikipedia.org/wiki/Server_Name_Indication)（SNI，RFC 6066）传递服务器名称。

### zone_sync_ssl_trusted_certificate

|\-|说明|
|------:|------|
|**语法**|**zone_sync_ssl_trusted_certificate** `file`;|
|**默认**|——|
|**上下文**|stream、server|

指定一个 PEM 格式的受信 CA 证书文件，该文件用于[验证](#zone_sync_ssl_verify)另一台集群服务器的证书。

### zone_sync_ssl_verify

|\-|说明|
|------:|------|
|**语法**|**zone_sync_ssl_verify** `on` &#124; `off`;|
|**默认**|zone_sync_ssl_verify off;|
|**上下文**|stream、server|

启用或禁用对另一个集群服务器证书的验证。

### zone_sync_ssl_verify_depth

|\-|说明|
|------:|------|
|**语法**|**zone_sync_ssl_verify_depth** `number`;|
|**默认**|zone_sync_ssl_verify_depth 1;|
|**上下文**|stream、server|

设置其他集群服务器证书链的验证深度。

### zone_sync_timeout

|\-|说明|
|------:|------|
|**语法**|**zone_sync_timeout** `timeout`;|
|**默认**|zone_sync_timeout 5s;|
|**上下文**|stream、server|

设置在连接到另一个集群节点时两次连续读取或写入操作之间的超时时间。如果在此时间内没有数据传输，则连接将关闭。

<a id="stream_zone_sync_status"></a>

## API 端点

可通过 [/stream/zone_sync/](../http/ngx_http_api_module.md#stream_zone_sync_) API 端点获得节点的同步状态，该端点返回[以下](../http/ngx_http_api_module.md#def_nginx_stream_zone_sync)指标。

<a id="controlling_cluster_node"></a>

## 启动、停止、移除集群节点

要启动新节点，请更新集群主机名的 DNS 记录，添加新节点的 IP 地址，然后启动实例。新节点将从 DNS 或静态配置中发现其他节点，并将开始向其发送更新。其他节点最终将使用 DNS 查找新节点，并开始向其推送更新。如果是静态配置，则需要重新加载其他节点才能将更新发送到新节点。

要停止节点，请将 `QUIT` 信号发送到实例。该节点将完成区域同步并正常关闭打开的连接。

要删除节点，请更新集群主机名的 DNS 记录，删除该节点的 IP 地址。所有其他节点最终将发现该节点已删除，关闭了与该节点的连接，并且不再尝试连接到该节点。删除节点后，可以按上述停止节点的步骤将其停止。在静态配置的情况下，需要重新加载其他节点以停止向已删除的节点发送更新。

## 原文档

[http://nginx.org/en/docs/stream/ngx_stream_zone_sync_module.html](http://nginx.org/en/docs/stream/ngx_stream_zone_sync_module.html)