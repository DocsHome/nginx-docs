# ngx_http_perl_module

- [指令](#directives)
    - [proxy_bind](#proxy_bind)
    - [proxy_buffer_size](#proxy_buffer_size)
    - [proxy_buffering](#proxy_buffering)
    - [proxy_buffers](#proxy_buffers)
    - [proxy_busy_buffers_size](#proxy_busy_buffers_size)
    - [proxy_cache](#proxy_cache)
    - [proxy_cache_background_update](#proxy_cache_background_update)
    - [proxy_cache_bypass](#proxy_cache_bypass)
    - [proxy_cache_convert_head](#proxy_cache_convert_head)
    - [proxy_cache_key](#proxy_cache_key)
    - [proxy_cache_lock](#proxy_cache_lock)
    - [proxy_cache_lock_age](#proxy_cache_lock_age)
    - [proxy_cache_lock_timeout](#proxy_cache_lock_timeout)
    - [proxy_cache_max_range_offset](#proxy_cache_max_range_offset)
    - [proxy_cache_methods](#proxy_cache_methods)
    - [proxy_cache_min_uses](#proxy_cache_min_uses)
    - [proxy_cache_path](#proxy_cache_path)
    - [proxy_cache_purge](#proxy_cache_purge)
    - [proxy_cache_revalidate](#proxy_cache_revalidate)
    - [proxy_cache_use_stale](#proxy_cache_use_stale)
    - [proxy_cache_valid](#proxy_cache_valid)
    - [proxy_connect_timeout](#proxy_connect_timeout)
    - [proxy_cookie_domain](#proxy_cookie_domain)
    - [proxy_cookie_path](#proxy_cookie_path)
    - [proxy_force_ranges](#proxy_force_ranges)
    - [proxy_headers_hash_bucket_size](#proxy_headers_hash_bucket_size)
    - [proxy_headers_hash_max_size](#proxy_headers_hash_max_size)
    - [proxy_hide_header](#proxy_hide_header)
    - [proxy_http_version](#proxy_http_version)
    - [proxy_ignore_client_abort](#proxy_ignore_client_abort)
    - [proxy_ignore_headers](#proxy_ignore_headers)
    - [proxy_intercept_errors](#proxy_intercept_errors)
    - [proxy_limit_rate](#proxy_limit_rate)
    - [proxy_max_temp_file_size](#proxy_max_temp_file_size)
    - [proxy_method](#proxy_method)
    - [proxy_next_upstream](#proxy_next_upstream)
    - [proxy_next_upstream_timeout](#proxy_next_upstream_timeout)
    - [proxy_next_upstream_tries](#proxy_next_upstream_tries)
    - [proxy_no_cache](#proxy_no_cache)
    - [proxy_pass](#proxy_pass)
    - [proxy_pass_header](#proxy_pass_header)
    - [proxy_pass_request_body](#proxy_pass_request_body)
    - [proxy_pass_request_headers](#proxy_pass_request_headers)
    - [proxy_read_timeout](#proxy_read_timeout)
    - [proxy_redirect](#proxy_redirect)
    - [proxy_request_buffering](#proxy_request_buffering)
    - [proxy_send_lowat](#proxy_send_lowat)
    - [proxy_send_timeout](#proxy_send_timeout)
    - [proxy_set_body](#proxy_set_body)
    - [proxy_set_header](#proxy_set_header)
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
    - [proxy_store](#proxy_store)
    - [proxy_store_access](#proxy_store_access)
    - [proxy_temp_file_write_size](#proxy_temp_file_write_size)
    - [proxy_temp_path](#proxy_temp_path)
- [内嵌变量](#embedded_variables)

`ngx_http_proxy_module` 模块允许将请求传递给另一台服务器。

<a id="example_configuration"></a>

## 示例配置

```nginx
location / {
    proxy_pass       http://localhost:8000;
    proxy_set_header Host      $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

<a id="directives"></a>

## 指令

### proxy_bind

|\-|说明|
|------:|------|
|**语法**|**proxy_bind** `address [transparent]` &#124; `off`;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 0.8.22 版本中出现|

连接到一个指定了本地 IP 地址和可选端口（1.11.2）的代理服务器。参数值可以包含变量（1.3.12）。特殊值 `off` （1.3.12）取消从上层配置级别继承的 `proxy_bind` 指令的作用，其允许系统自动分配本地 IP 地址和端口。

`transparent` 参数（1.11.0）允许出站从非本地 IP 地址到代理服务器的连接（例如，来自客户端的真实 IP 地址）：

```nginx
proxy_bind $remote_addr transparent;
```

为了使这个参数起作用，通常需要以[超级用户](../核心模块.md#user)权限运行 nginx worker 进程。在 Linux 上，不需要指定 `transparent` 参数（1.13.8），工作进程会继承 master 进程的 `CAP_NET_RAW` 功能。此外，还要配置内核路由表来拦截来自代理服务器的网络流量。

### proxy_buffer_size

|\-|说明|
|------:|------|
|**语法**|**proxy_buffer_size** `size`;|
|**默认**|proxy_buffer_size 4k&#124;8k;|
|**上下文**|http、server、location|

设置用于读取从代理服务器收到的第一部分响应的缓冲区大小（`size`）。这部分通常包含一个小的响应头。默认情况下，缓冲区大小等于一个内存页。4K 或 8K，因平台而异。但是，它可以设置得更小。

### proxy_buffering

|\-|说明|
|------:|------|
|**语法**|**proxy_buffering** `on` &#124; `off`;|
|**默认**|proxy_buffering on;|
|**上下文**|http、server、location|

启用或禁用来自代理服务器的响应缓冲。

当启用缓冲时，nginx 会尽可能快地收到接收来自代理服务器的响应，并将其保存到由 [proxy_buffer_size](#proxy_buffer_size) 和 [proxy_buffers](#proxy_buffers) 指令设置的缓冲区中。如果内存放不下整个响应，响应的一部分可以保存到磁盘上的[临时文件](#proxy_temp_path)中。写入临时文件由 [proxy_max_temp_file_size ](#proxy_max_temp_file_size) 和 [proxy_temp_file_write_size](#proxy_temp_file_write_size) 指令控制。

当缓冲被禁用时，nginx 在收到响应时立即同步传递给客户端，不会尝试从代理服务器读取整个响应。nginx 一次可以从服务器接收的最大数据量由 [proxy_buffer_size](#proxy_buffer_size) 指令设置。

通过在 `X-Accel-Buffering` 响应头字段中通过 `yes` 或 `no` 也可以启用或禁用缓冲。可以使用 [proxy_ignore_headers](#proxy_ignore_headers) 指令禁用此功能。

### proxy_buffers

|\-|说明|
|------:|------|
|**语法**|**proxy_buffers** `number size`;|
|**默认**|proxy_buffers 8 4k&#124;8k;|
|**上下文**|http、server、location|

设置单个连接从代理服务器读取响应的缓冲区的 `number` （数量）和 `size` （大小）。默认情况下，缓冲区大小等于一个内存页。为 4K 或 8K，因平台而异。

### proxy_busy_buffers_size

|\-|说明|
|------:|------|
|**语法**|**proxy_busy_buffers_size** `size`;|
|**默认**|proxy_buffer_size 8k&#124;16k;|
|**上下文**|http、server、location|

当启用代理服务器响应[缓冲](#proxy_buffering)时，限制缓冲区的总大小（`size`）在当响应尚未被完全读取时可向客户端发送响应。同时，其余的缓冲区可以用来读取响应，如果需要的话，缓冲部分响应到临时文件中。默认情况下，`size` 受 [proxy_buffer_size](#proxy_buffer_size) 和 [proxy_buffers](#proxy_buffers) 指令设置的两个缓冲区的大小限制。

### proxy_cache

|\-|说明|
|------:|------|
|**语法**|**proxy_cache** `zone` &#124; `off`;|
|**默认**|proxy_cache off;|
|**上下文**|http、server、location|

定义用于缓存的共享内存区域。同一个区域可以在几个地方使用。参数值可以包含变量（1.7.9）。`off` 参数将禁用从上级配置级别继承的缓存配置。

### proxy_cache_background_update

|\-|说明|
|------:|------|
|**语法**|**proxy_cache_background_update** `on` &#124; `off`;|
|**默认**|proxy_cache_background_update off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.11.10 版本中出现|

允许启动后台子请求来更新过期的缓存项，而过时的缓存响应则返回给客户端。请注意，有必要在更新时[允许](#proxy_cache_use_stale_updating)使用陈旧的缓存响应。

### proxy_cache_bypass

|\-|说明|
|------:|------|
|**语法**|**proxy_cache_bypass** `string ...`;|
|**默认**|——|
|**上下文**|http、server、location|

定义不从缓存中获取响应的条件。如果字符串参数中有一个值不为空且不等于 `0`，则不会从缓存中获取响应：

```nginx
proxy_cache_bypass $cookie_nocache $arg_nocache$arg_comment;
proxy_cache_bypass $http_pragma    $http_authorization;
```

可以与 [proxy_no_cache](#proxy_no_cache) 指令一起使用。

### proxy_cache_convert_head

|\-|说明|
|------:|------|
|**语法**|**proxy_cache_convert_head** `on` &#124; `off`;|
|**默认**|proxy_cache_convert_head on;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.9.7 版本中出现|

启用或禁用将 **HEAD** 方法转换为 **GET** 进行缓存。禁用转换时，应将[缓存键](#proxy_cache_key)配置为包含 `$request_method`。

### proxy_cache_key

|\-|说明|
|------:|------|
|**语法**|**proxy_cache_key** `string`;|
|**默认**|proxy_cache_key $scheme$proxy_host$request_uri;|
|**上下文**|http、server、location|

为缓存定义一个 key，例如：

```nginx
proxy_cache_key "$host$request_uri $cookie_user";
```

默认情况下，指令的值与字符串相近：

```nginx
proxy_cache_key $scheme$proxy_host$uri$is_args$args;
```

**待续……**

## 原文档
[http://nginx.org/en/docs/http/ngx_http_proxy_module.html](http://nginx.org/en/docs/http/ngx_http_proxy_module.html)