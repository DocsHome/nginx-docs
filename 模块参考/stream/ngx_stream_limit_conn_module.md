# ngx_stream_limit_conn_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [limit_conn](#limit_conn)
    - [limit_conn_log_level](#limit_conn_log_level)
    - [limit_conn_zone](#limit_conn_zone)

`ngx_stream_limit_conn_module` 模块（1.9.3）用于限制每个定义的 key 的连接数，特别是来自单个 IP 地址的连接数。

<a id="example_configuration"></a>

## 示例配置

```nginx
stream {
    limit_conn_zone $binary_remote_addr zone=addr:10m;

    ...

    server {

        ...

        limit_conn           addr 1;
        limit_conn_log_level error;
    }
}
```

<a id="directives"></a>

## 指令

### limit_conn

|\-|说明|
|------:|------|
|**语法**|**limit_conn** `zone number`;|
|**默认**|——|
|**上下文**|stream、server|

设置共享内存区域和给定 key 的最大允许连接数。超过此限制时，服务器将关闭连接。例如，以下指令：

```nginx
limit_conn_zone $binary_remote_addr zone=addr:10m;

server {
    ...
    limit_conn addr 1;
}
```

每次只允许一个 IP 地址一个连接。

如果指定了几个 `limit_conn` 指令，则将应用所有已配置的限制。

当且仅当当前级别没有 `limit_conn` 指令时，指令才从上级继承。

### limit_conn_log_level

|\-|说明|
|------:|------|
|**语法**|**limit_conn_log_level** `info` &#124; `notice` &#124; `warn` &#124; `error`;|
|**默认**|limit_conn_log_level error;|
|**上下文**|stream、server|

为服务器限制连接数设置日志记录级别。

### limit_conn_zone

|\-|说明|
|------:|------|
|**语法**|**limit_conn_zone** `key zone=name:size`;|
|**默认**|——|
|**上下文**|stream|

为指定的共享内存区域设置参数，该区域将保留各种 key 的状态。尤其是状态包括当前的连接数。`key` 可以包含文本、变量及其组合（1.11.2）。不计算 key 为空的连接。用法示例：

```nginx
limit_conn_zone $binary_remote_addr zone=addr:10m;
```

上述中，key 是一个 `$binary_remote_addr` 变量设置的客户端 IP 地址。`$binary_remote_addr` 的大小为 IPv4 地址的 4 个字节或 IPv6 地址的 16 个字节。存储状态在 32 位平台上总是占用 32 或 64 字节，在 64 位平台上占用 64 字节。一兆字节区域可以保留大约 32,000 个 32 字节状态或大约 16,000 个 64 字节状态。如果区域存储耗尽，服务器将关闭连接。

## 原文档
[http://nginx.org/en/docs/stream/ngx_stream_limit_conn_module.html](http://nginx.org/en/docs/stream/ngx_stream_limit_conn_module.html)