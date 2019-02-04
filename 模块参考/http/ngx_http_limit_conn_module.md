# ngx_http_limit_conn_module

- [指令](#directives)
    - [limit_conn](#limit_conn)
    - [limit_conn_log_level](#limit_conn_log_level)
    - [limit_conn_status](#limit_conn_status)
    - [limit_conn_zone](#limit_conn_zone)
    - [limit_zone](#limit_zone)

`ngx_http_limit_conn_module` 模块用于限制每个已定义的 key 的连接数量，特别是来自单个 IP 地址的连接数量。

并非所有的连接都会被计数。只有当服务器处理了请求并且已经读取了整个请求头时，连接才被计数。

<a id="example_configuration"></a>

## 示例配置

```nginx
http {
    limit_conn_zone $binary_remote_addr zone=addr:10m;

    ...

    server {

        ...

        location /download/ {
            limit_conn addr 1;
        }
```

<a id="directives"></a>

## 指令

### limit_conn

|\-|说明|
|------:|------|
|**语法**|**limit_conn** `zone number`;|
|**默认**|——|
|**上下文**|http、server、location|

设置给定键值的共享内存区域和最大允许连接数。当超过此限制时，服务器将返回错误响应请求。例如：

```nginx
limit_conn_zone $binary_remote_addr zone=addr:10m;

server {
    location /download/ {
        limit_conn addr 1;
    }
```

同一时间只允许一个 IP 地址一个连接。

> 在 HTTP/2和 SPDY 中，每个并发请求都被视为一个单独的连接。

可以有多个 `limit_conn` 指令。 例如，以下配置将限制每个客户端 IP 连接到服务器的数量，同时限制连接到虚拟服务器的总数：

```nginx
limit_conn_zone $binary_remote_addr zone=perip:10m;
limit_conn_zone $server_name zone=perserver:10m;

server {
    ...
    limit_conn perip 10;
    limit_conn perserver 100;
}
```

当且仅当在当前级别上没有 `limit_conn` 指令时，这些指令才从前一级继承。

### limit_conn_log_level

|\-|说明|
|------:|------|
|**语法**|**limit_conn_log_level** `info` &#124; `notice` &#124; `warn` &#124; `error`;|
|**默认**|limit_conn_log_level error;|
|**上下文**|http、server、location|
|**提示**|该指令在 0.8.18 版本中出现|

当服务器限制连接数时，设置所需的日志记录级别。

### limit_conn_status

|\-|说明|
|------:|------|
|**语法**|**limit_conn_status** `code`;|
|**默认**|limit_conn_status 503;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.3.15 版本中出现|

设置响应拒绝请求返回的状态码。

### limit_conn_zone

|\-|说明|
|------:|------|
|**语法**|**limit_conn_zone** `key zone=name:size`;|
|**默认**|——|
|**上下文**|http|

为共享内存区域设置参数，该区域将保留各种键的状态。特别是，该状态包含当前的连接数。`key` 可以包含文本、变量及其组合。不包括有空键值的请求。

> 在 1.7.6 版本之前，一个 key 可能只包含一个变量。

用法示例：

```nginx
limit_conn_zone $binary_remote_addr zone=addr:10m;
```

在这里，客户端 IP 地址作为 key。请注意，不是 `$remote_addr`，而是使用 `$binary_remote_addr` 变量。`$remote_addr` 变量的大小可以为 7 到 15 个字节不等。存储状态在 32 位平台上占用 32 或 64 字节的内存，在 64 位平台上总是占用 64 字节。对于 IPv4 地址，`$binary_remote_addr` 变量的大小始终为 4 个字节，对于 IPv6 地址则为 16 个字节。存储状态在 32 位平台上始终占用 32 或 64 个字节，在 64 位平台上占用 64 个字节。一兆字节的区域可以保持大约 32000 个 32 字节的状态或大约 16000 个 64 字节的状态。如果区域存储耗尽，服务器会将错误返回给所有其余的请求。

### limit_zone

|\-|说明|
|------:|------|
|**语法**|**limit_zone** `name $variable size`;|
|**默认**|——|
|**上下文**|http|

该指令在 1.1.8 版本中已过时，并在 1.7.6 版本中被删除。请使用等效 [limit_conn_zone](#limit_conn_zone) 指令代替：

> `limit_conn_zone $variable zone=name:size;`

## 原文档

[http://nginx.org/en/docs/http/ngx_http_limit_conn_module.html](http://nginx.org/en/docs/http/ngx_http_limit_conn_module.html)