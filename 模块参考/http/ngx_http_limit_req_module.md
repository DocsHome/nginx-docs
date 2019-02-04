# ngx_http_limit_req_module

- [指令](#directives)
    - [limit_req](#limit_req)
    - [limit_req_log_level](#limit_req_log_level)
    - [limit_req_status](#limit_req_status)
    - [limit_req_zone](#limit_req_zone)

`ngx_http_limit_req_module` 模块（0.7.21）用于限制每个已定义 key 的请求处理速率，特别是来自单个 IP 地址请求的处理速率。限制机制采用了 **leaky bucket** （漏桶算法）方法完成。

<a id="example_configuration"></a>

## 示例配置

```nginx
http {
    limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;

    ...

    server {

        ...

        location /search/ {
            limit_req zone=one burst=5;
        }
```

<a id="directives"></a>

## 指令

### limit_req

|\-|说明|
|------:|------|
|**语法**|**limit_req** `zone=name [burst=number] [nodelay]`;|
|**默认**|——|
|**上下文**|http、server、location|

设置共享内存区域和请求的最大突发大小。如果请求速率超过为某个区域配置的速率，则它们的处理会延迟，从而使请求以定义的速率处理。过多的请求被延迟，直到它们的数量超过最大突发大小，在这种情况下请求被终止并出现[错误](#limit_req_status)。 默认情况下，最大突发大小等于零。例如：

```nginx
limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;

server {
    location /search/ {
        limit_req zone=one burst=5;
    }
```

平均每秒不超过 1 个请求，并且突发不超过 5 个请求。

如果在限制期间延迟请求过多，则不需要使用参数 `nodelay`：

```nginx
limit_req zone=one burst=5 nodelay;
```

可以存在多个 `limit_req` 指令。例如，以下配置将限制来自单个 IP 地址请求的处理速率，同时限制虚拟服务器的请求处理速率：

```nginx
limit_req_zone $binary_remote_addr zone=perip:10m rate=1r/s;
limit_req_zone $server_name zone=perserver:10m rate=10r/s;

server {
    ...
    limit_req zone=perip burst=5 nodelay;
    limit_req zone=perserver burst=10;
}
```

当且仅当在当前级别上没有 `limit_req` 指令时，这些指令才从上一级继承。

### limit_req_log_level

|\-|说明|
|------:|------|
|**语法**|**limit_req_log_level** `info` &#124; `notice` &#124; `warn` &#124; `error`;|
|**默认**|limit_req_log_level error;|
|**上下文**|http、server、location|
|**提示**|该指令在 0.8.18 版本中出现|

当服务器由于速率超出而拒绝处理请求或延迟请求处理时，设置所需的日志记录级别。延误情况的记录等级比拒绝情况的记录低一些。例如，如果指定了 `limit_req_log_level notice`，则延迟情况将会在 `info` 级别记录。

### limit_req_status

|\-|说明|
|------:|------|
|**语法**|**limit_req_status** `code`;|
|**默认**|limit_req_status 503;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.3.15 版本中出现|

设置响应拒绝请求返回的状态码。

### limit_req_zone

|\-|说明|
|------:|------|
|**语法**|**limit_req_zone** `key zone=name:size rate=rate`;|
|**默认**|——|
|**上下文**|http|

为共享内存区域设置参数，该区域将保留各种键的状态。特别是，该状态包含当前的连接数。`key` 可以包含文本、变量及其组合。不包括有空键值的请求。

> 在 1.7.6 版本之前，一个 `key` 可能只包含一个变量。

用法示例：

```nginx
limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;
```

在这里，状态保持在 10 兆字节的区域 **one**，并且该区域的平均请求处理速率不能超过每秒 1 个请求。

客户端 IP 地址作为 key。请注意，不是 `$remote_addr`，而是使用 `$binary_remote_addr` 变量。`$binary_remote_addr` 变量的大小始终为 4 个字节，对于 IPv6 地址则为 16 个字节。存储状态在 32 位平台上始终占用 32 或 64 个字节，在 64 位平台上占用 64 个字节。一兆字节的区域可以保持大约 32000 个 32 字节的状态或大约 16000 个 64 字节的状态或大约 8000 个 128 字节的状态。

如果区域存储耗尽，最近最少使用的状态将被删除。即使在此之后无法创建新状态，该请求也会因[错误](#limit_req_status)而终止。

速率以每秒请求数（r/s）指定。如果需要每秒小于一个请求的速率，则按每分钟请求（r/m）指定。例如，每秒半请求是 30r/m。

## 原文档

[http://nginx.org/en/docs/http/ngx_http_limit_req_module.html](http://nginx.org/en/docs/http/ngx_http_limit_req_module.html)