# ngx_http_memcached_module

- [指令](#directives)
    - [memcached_bind](#memcached_bind)
    - [memcached_buffer_size](#memcached_buffer_size)
    - [memcached_connect_timeout](#memcached_connect_timeout)
    - [memcached_force_ranges](#memcached_force_ranges)
    - [memcached_gzip_flag](#memcached_gzip_flag)
    - [memcached_next_upstream](#memcached_next_upstream)
    - [memcached_next_upstream_timeout](#memcached_next_upstream_timeout)
    - [memcached_next_upstream_tries](#memcached_next_upstream_tries)
    - [memcached_pass](#memcached_pass)
    - [memcached_read_timeout](#memcached_read_timeout)
    - [memcached_send_timeout](#memcached_send_timeout)
- [内嵌变量](#embedded_variables)

`ngx_http_memcached_module` 模块用于从 memcached 服务器上获取响应。key 设置在 `$memcached_key` 变量中。应通过 nginx 之外的方式提前将响应放入 memcached。

<a id="example_configuration"></a>

## 示例配置

```nginx
server {
    location / {
        set            $memcached_key "$uri?$args";
        memcached_pass host:11211;
        error_page     404 502 504 = @fallback;
    }

    location @fallback {
        proxy_pass     http://backend;
    }
}
```

<a id="directives"></a>

## 指令

### memcached_bind

|\-|说明|
|------:|------|
|**语法**|**memcached_bind** `address [transparent ]` &#124; `off`;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 0.8.22 版本中出现|

连接到一个指定了本地 IP 地址和可选端口（1.11.2）的 memcached 服务器。参数值可以包含变量（1.3.12）。特殊值 `off` （1.3.12）取消从上层配置级别继承的 `memcached_bind` 指令的作用，其允许系统自动分配本地 IP 地址和端口。

`transparent` 参数（1.11.0）允许出站从非本地 IP 地址到 memcached 服务器的连接（例如，来自客户端的真实 IP 地址）：

```nginx
memcached_bind $remote_addr transparent;
```

为了使这个参数起作用，通常需要以[超级用户](../核心模块.md#user)权限运行 nginx worker 进程。在 Linux 上，不需要指定 `transparent` 参数，工作进程会继承 master 进程的 `CAP_NET_RAW` 功能。此外，还要配置内核路由表来拦截来自 memcached 服务器的网络流量。

### memcached_buffer_size

|\-|说明|
|------:|------|
|**语法**|**memcached_buffer_size** `size`;|
|**默认**|memcached_buffer_size 4k&#124;8k|
|**上下文**|http、server、location|

设置用于读取从 memcached 服务器收到的响应的缓冲区的大小（`size`）。一旦收到响应，响应便会同步传送给客户端。

### memcached_connect_timeout

|\-|说明|
|------:|------|
|**语法**|**memcached_connect_timeout** `time`;|
|**默认**|memcached_connect_timeout 60s|
|**上下文**|http、server、location|

定义与 memcached 服务器建立连接的超时时间。需要说明的是，超时通常不能超过 75 秒。

### memcached_force_ranges

|\-|说明|
|------:|------|
|**语法**|**memcached_force_ranges** `on` &#124; `off`;|
|**默认**|memcached_force_ranges off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.7 版本中出现|

无论响应中的 **Accept-Ranges** 字段如何，都对来自 memcached 服务器的缓存和未缓存的响应启用 byte-range 支持。

### memcached_gzip_flag

|\-|说明|
|------:|------|
|**语法**|**memcached_gzip_flag** `flag`;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 1.3.6 版本中出现|

启用对 memcached 服务器响应中的 `flag` 存在测试，并在 flag 设置时将 **Content-Encoding** 响应头字段设置为 **gzip**。

### memcached_next_upstream

|\-|说明|
|------:|------|
|**语法**|**memcached_next_upstream** `error` &#124; `timeout` &#124; `invalid_response` &#124; `not_found` &#124; `off ...`;|
|**默认**|memcached_next_upstream error timeout;|
|**上下文**|http、server、location|

指定在哪些情况下请求应传递给下一台服务器：

- `error`

    在与服务器建立连接、传递请求或读取响应头时发生错误

- `timeout`

    在与服务器建立连接、传递请求或读取响应头时发生超时

- `invalid_response`

    服务器返回空或无效的响应

- `not_found`

    在服务器上未找到响应

- `off`

    禁用将请求传递给下一个服务器。

我们应该记住，只有在没有任何内容发送给客户端的情况下，才能将请求传递给下一个服务器。也就是说，如果在响应传输过程中发生错误或超时，修复这样的错误是不可能的。

该指令还定义了与服务器进行通信的[失败尝试](ngx_http_upstream_module.md#max_fails)。`error`、`timeout` 和 `invalid_response` 的情况始终被视为失败尝试，即使它们没有在指令中指定。`not_found` 的情况永远不会被视为失败尝试。

将请求传递给下一个服务器可能受到[尝试次数](#grpc_next_upstream_tries)和[时间](#grpc_next_upstream_timeout)的限制。

### memcached_next_upstream_tries

|\-|说明|
|------:|------|
|**语法**|**memcached_next_upstream_tries** `number`;|
|**默认**|memcached_next_upstream_tries 0;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.5 版本中出现|

限制尝试将请求传递到[下一个服务器](#grpc_next_upstream)的次数。`0` 值表示关闭此限制。

### memcached_pass

|\-|说明|
|------:|------|
|**语法**|**memcached_pass** `address`;|
|**默认**|——|
|**上下文**|http、location 中 if|

设置 memcached 服务器地址。该地址可以指定为域名或 IP 地址以及端口：

```nginx
memcached_pass localhost:11211;
```

或使用 UNIX 域套接字路径：

```nginx
memcached_pass unix:/tmp/memcached.socket;
```

如果域名解析为多个地址，则这些地址将以循环方式使用。另外，地址可以被指定为[服务器组](ngx_http_upstream_module.md)。

### memcached_read_timeout

|\-|说明|
|------:|------|
|**语法**|**memcached_read_timeout** `time`;|
|**默认**|memcached_read_timeout 60s;|
|**上下文**|http、server、location|
memcached
定义从 gRPC 服务器读取响应的超时时间。超时间隔只在两次连续的读操作之间，而不是整个响应的传输过程。如果 memcached 服务器在此时间内没有发送任何内容，则连接关闭。

### memcached_send_timeout

|\-|说明|
|------:|------|
|**语法**|**memcached_send_timeout** `time`;|
|**默认**|memcached_send_timeout 60s;|
|**上下文**|http、server、location|

设置将请求传输到 memcached 服务器的超时时间。超时间隔只在两次连续写入操作之间，而不是整个请求的传输过程。如果 memcached 服务器在此时间内没有收到任何内容，则连接将关闭。

<a id="embedded_variables"></a>

## 内嵌变量

- `$memcached_key`

    定义从 memcached 服务器获取响应的密钥

## 原文档
[http://nginx.org/en/docs/http/ngx_http_memcached_module.html](http://nginx.org/en/docs/http/ngx_http_memcached_module.html)