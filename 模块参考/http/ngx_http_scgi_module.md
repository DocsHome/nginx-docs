# ngx_http_scgi_module

- [配置示例](#example_configuration)
- [指令](#directives)
    - [scgi_bind](#scgi_bind)
    - [scgi_buffer_size](#scgi_buffer_size)
    - [scgi_buffering](#scgi_buffering)
    - [scgi_buffers](#scgi_buffers)
    - [scgi_busy_buffers_size](#scgi_busy_buffers_size)
    - [scgi_cache](#scgi_cache)
    - [scgi_cache_background_update](#scgi_cache_background_update)
    - [scgi_cache_bypass](#scgi_cache_bypass)
    - [scgi_cache_key](#scgi_cache_key)
    - [scgi_cache_lock](#scgi_cache_lock)
    - [scgi_cache_lock_age](#scgi_cache_lock_age)
    - [scgi_cache_lock_timeout](#scgi_cache_lock_timeout)
    - [scgi_cache_max_range_offset](#scgi_cache_max_range_offset)
    - [scgi_cache_methods](#scgi_cache_methods)
    - [scgi_cache_min_uses](#scgi_cache_min_uses)
    - [scgi_cache_path](#scgi_cache_path)
    - [scgi_cache_purge](#scgi_cache_purge)
    - [scgi_cache_revalidate](#scgi_cache_revalidate)
    - [scgi_cache_use_stale](#scgi_cache_use_stale)
    - [scgi_cache_valid](#scgi_cache_valid)
    - [scgi_connect_timeout](#scgi_connect_timeout)
    - [scgi_force_ranges](#scgi_force_ranges)
    - [scgi_hide_header](#scgi_hide_header)
    - [scgi_ignore_client_abort](#scgi_ignore_client_abort)
    - [scgi_ignore_headers](#scgi_ignore_headers)
    - [scgi_intercept_errors](#scgi_intercept_errors)
    - [scgi_limit_rate](#scgi_limit_rate)
    - [scgi_max_temp_file_size](#scgi_max_temp_file_size)
    - [scgi_next_upstream](#scgi_next_upstream)
    - [scgi_next_upstream_timeout](#scgi_next_upstream_timeout)
    - [scgi_next_upstream_tries](#scgi_next_upstream_tries)
    - [scgi_no_cache](#scgi_no_cache)
    - [scgi_param](#scgi_param)
    - [scgi_pass](#scgi_pass)
    - [scgi_pass_header](#scgi_pass_header)
    - [scgi_pass_request_body](#scgi_pass_request_body)
    - [scgi_pass_request_headers](#scgi_pass_request_headers)
    - [scgi_read_timeout](#scgi_read_timeout)
    - [scgi_request_buffering](#scgi_request_buffering)
    - [scgi_send_timeout](#scgi_send_timeout)
    - [scgi_socket_keepalive](#scgi_socket_keepalive)
    - [scgi_store](#scgi_store)
    - [scgi_store_access](#scgi_store_access)
    - [scgi_temp_file_write_size](#scgi_temp_file_write_size)
    - [scgi_temp_path](#scgi_temp_path)

`ngx_http_scgi_module` 模块允许将请求传递给 SCGI 服务器。

<a id="example_configuration"></a>

## 配置示例

```nginx
location / {
    include   scgi_params;
    scgi_pass localhost:9000;
}
```

<a id="directives"></a>

## 指令

### scgi_bind

|\-|说明|
|:------|:------|
|**语法**|**scgi_bind** `address [transparent] | off`;|
|**默认**|——|
|**上下文**|http、server、location|

使用可选端口（1.11.2）从指定的本地 IP 地址发出到 SCGI 服务器的传出连接。参数值可以包含变量（1.3.12）。特殊值 `off`（1.3.12）取消从先前配置级别继承的 `scgi_bind` 指令的作用，该指令允许系统自动分配本地 IP 地址和端口。

`transparent` 参数（1.11.0）允许到 SCGI 服务器的传出连接源自非本地 IP 地址，例如，来自一个客户端的真实 IP 地址：

```nginx
scgi_bind $remote_addr transparent;
```

为了使此参数起作用，通常需要使用[超级用户](../核心功能.md#user)权限运行 nginx worker 进程。在 Linux 上，不需要（1.13.8）像指定 `transparent` 参数一样，worker 进程从 master 进程继承 `CAP_NET_RAW` 功能。还需要配置内核路由表以拦截来自 SCGI 服务器的网络流量。

### scgi_buffer_size

|\-|说明|
|:------|:------|
|**语法**|**scgi_buffer_size** `size`;|
|**默认**|scgi_buffer_size 4k&#124;8k;|
|**上下文**|http、server、location|

设置用于读取从 SCGI 服务器接收的响应的第一部分的缓冲区的大小（`size`）。这部分通常包含一个小的响应头。默认情况下，缓冲区大小等于一个内存页，即 4K 或 8K，具体取决于平台。然而，它可以做得更小。

### scgi_buffering

|\-|说明|
|:------|:------|
|**语法**|**scgi_buffering** `on` &#124; `off`;|
|**默认**|scgi_buffering on;|
|**上下文**|http、server、location|

启用或禁用缓冲来自 SCGI 服务器的响应。

启用缓冲后，nginx 会尽快从 SCGI 服务器接收响应，并将其保存到 [scgi_buffer_size](#scgi_buffer_size) 和 [scgi_buffers](#scgi_buffers) 指令设置的缓冲区中。如果整个响应不适合放入内存，则可以将其中的一部分保存到磁盘上的临时文件中。写入临时文件由 [scgi_max_temp_file_size](#scgi_max_temp_file_size) 和 [scgi_temp_file_write_size](#scgi_temp_file_write_size) 指令控制。

禁用缓冲时，会在收到响应时立即同步传递给客户端。nginx 不会尝试从 SCGI 服务器读取整个响应。nginx 一次可以从服务器接收的数据的最大大小由 [scgi_buffer_size](#scgi_buffer_size) 指令设置。

也可以通过在 **X-Accel-Buffering** 响应头字段中传递 `yes` 或 `no` 来启用或禁用缓冲。可以使用 [scgi_ignore_headers](#scgi_ignore_headers) 指令禁用此功能。

### scgi_buffers

|\-|说明|
|:------|:------|
|**语法**|**scgi_buffers** `number size`;|
|**默认**|scgi_buffers 8 4k&#124;8k;|
|**上下文**|http、server、location|

设置用于从 SCGI 服务器读取响应的缓冲区的数量（`number`）和大小（`size`），适用于单个连接。默认情况下，缓冲区大小等于一个内存页，即 4K 或 8K，具体取决于平台。

### scgi_busy_buffers_size

|\-|说明|
|:------|:------|
|**语法**|**scgi_busy_buffers_size** `size`;|
|**默认**|scgi_busy_buffers_size 8k&#124;16k;|
|**上下文**|http、server、location|

当启用[缓冲](#scgi_buffering)来自 SCGI 服务器的响应时，限制在响应尚未完全读取时可能忙于向客户端发送响应的缓冲区的总大小（`size`）。同时，其余缓冲区可用于读取响应，如果需要，还可以缓冲部分响应临时文件。默认情况下，`size` 由 [scgi_buffer_size](#scgi_buffer_size) 和 [scgi_buffers](#scgi_buffers) 指令设置的两个缓冲区的大小限制。

### scgi_cache

|\-|说明|
|:------|:------|
|**语法**|**scgi_cache** `zone` &#124; `off`;|
|**默认**|scgi_cache off;|
|**上下文**|http、server、location|

定义一个用于缓存的共享内存区域。可以在多个地方使用相同的区域。参数值可以包含变量（1.7.9）。`off` 参数禁用从先前配置级别继承的缓存。

### scgi_cache_background_update

|\-|说明|
|:------|:------|
|**语法**|**scgi_cache_background_update** `on` &#124; `off`;|
|**默认**|scgi_cache_background_update off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.11.10 版本中出现|

允许启动一个后台子请求以更新过期的缓存项，同时将过时的缓存响应返回给客户端。请注意，在更新时必须[允许](#scgi_cache_use_stale_updating)使用陈旧的缓存响应。

### scgi_cache_bypass

|\-|说明|
|:------|:------|
|**语法**|**scgi_cache_bypass** `string ...`;|
|**默认**|——|
|**上下文**|http、server、location|

定义不从缓存中获取响应的条件。如果字符串参数中有一个值不为空且不等于 `0`，则不会从缓存中获取响应：

```nginx
scgi_cache_bypass $cookie_nocache $arg_nocache$arg_comment;
scgi_cache_bypass $http_pragma    $http_authorization;
```

可以与 [scgi_no_cache](#scgi_no_cache) 指令一起使用。

### scgi_cache_key

|\-|说明|
|:------|:------|
|**语法**|**scgi_cache_key** `string`;|
|**默认**|——|
|**上下文**|http、server、location|

定义一个用于缓存的 key：

```nginx
scgi_cache_key localhost:9000$request_uri;
```

### scgi_cache_lock

|\-|说明|
|:------|:------|
|**语法**|**scgi_cache_lock** `on` &#124; `off`;|
|**默认**|scgi_cache_lock off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.1.12 版本中出现|

启用后，在将请求传递给 SCGI 服务器，一次只允许一个请求填充根据 [scgi_cache_key](#scgi_cache_key) 指令标识的新缓存元素。同一缓存元素的其他请求将等待响应出现在缓存中或直到 [scgi_cache_lock_timeout](scgi_cache_lock_timeout) 指令设置的时间，缓存此元素的缓存锁释放。

### scgi_cache_lock_age

|\-|说明|
|:------|:------|
|**语法**|**scgi_cache_lock_age** `time`;|
|**默认**|scgi_cache_lock_age 5s;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.8 版本中出现|

如果传递给 SCGI 服务器以填充新缓存元素的最后一个请求在指定时间（`time`）内没有完成，则可以将另一个请求传递给 SCGI 服务器。

### scgi_cache_lock_timeout

|\-|说明|
|:------|:------|
|**语法**|**scgi_cache_lock_timeout** `time`;|
|**默认**|scgi_cache_lock_timeout 5s;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.1.12 版本中出现|

设置 [scgi_cache_lock](#scgi_cache_lock) 的超时时间。当时间到期时，请求将被传递给 SCGI 服务器，但响应将不会被缓存。

> 1.7.8 版本之前响应可以被缓存。

### scgi_cache_max_range_offset

|\-|说明|
|:------|:------|
|**语法**|**scgi_cache_max_range_offset** `number`;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 1.11.6 版本中出现|

设置一个字节范围（byte-range）请求的偏移量（以字节为单位）。如果范围超出偏移量，则范围请求将传递给 SCGI 服务器，并且不会缓存响应。

### scgi_cache_methods

|\-|说明|
|:------|:------|
|**语法**|**scgi_cache_methods** `GET \| HEAD \| POST ...`;|
|**默认**|scgi_cache_methods GET HEAD;|
|**上下文**|http、server、location|

如果此指令中列出了客户端请求方法，则将缓存响应。`GET` 和 `HEAD` 方法总是添加到列表中，但建议明确指定它们。另请参见 [scgi_no_cache](#scgi_no_cache) 指令。

### scgi_cache_min_uses

|\-|说明|
|:------|:------|
|**语法**|**scgi_cache_min_uses** `number`;|
|**默认**|scgi_cache_min_uses 1;|
|**上下文**|http、server、location|

设置缓存响应之前的请求数（`number`）。

### scgi_cache_path

|\-|说明|
|:------|:------|
|**语法**|**scgi_cache_path** `path [levels=levels] [use_temp_path=on\|off] keys_zone=name:size [inactive=time] [max_size=size] [manager_files=number] [manager_sleep=time] [manager_threshold=time] [loader_files=number] [loader_sleep=time] [loader_threshold=time] [purger=on\|off] [purger_files=number] [purger_sleep=time] [purger_threshold=time]`;|
|**默认**|——|
|**上下文**|http|

**待续……**



## 原文档

- [http://nginx.org/en/docs/http/ngx_http_scgi_module.html](http://nginx.org/en/docs/http/ngx_http_scgi_module.html)
