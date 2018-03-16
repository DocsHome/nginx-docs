# ngx_http_fastcgi_module

- [指令](#directives)
    - [fastcgi_bind](#fastcgi_bind)
    - [fastcgi_buffer_size](#fastcgi_buffer_size)
    - [fastcgi_buffering](#fastcgi_buffering)
    - [fastcgi_buffers](#fastcgi_buffers)
    - [fastcgi_busy_buffers_size](#fastcgi_busy_buffers_size)
    - [fastcgi_cache](#fastcgi_cache)
    - [fastcgi_cache_background_update](#fastcgi_cache_background_update)
    - [fastcgi_cache_bypass](#fastcgi_cache_bypass)
    - [fastcgi_cache_key](#fastcgi_cache_key)
    - [fastcgi_cache_lock](#fastcgi_cache_lock)
    - [fastcgi_cache_lock_age](#fastcgi_cache_lock_age)
    - [fastcgi_cache_lock_timeout](#fastcgi_cache_lock_timeout)
    - [fastcgi_cache_max_range_offset](#fastcgi_cache_max_range_offset)
    - [fastcgi_cache_methods](#fastcgi_cache_methods)
    - [fastcgi_cache_min_uses](#fastcgi_cache_min_uses)
    - [fastcgi_cache_path](#fastcgi_cache_path)
    - [fastcgi_cache_purge](#fastcgi_cache_purge)
    - [fastcgi_cache_revalidate](#fastcgi_cache_revalidate)
    - [fastcgi_cache_use_stale](#fastcgi_cache_use_stale)
    - [fastcgi_cache_valid](#fastcgi_cache_valid)
    - [fastcgi_catch_stderr](#fastcgi_catch_stderr)
    - [fastcgi_connect_timeout](#fastcgi_connect_timeout)
    - [fastcgi_force_ranges](#fastcgi_force_ranges)
    - [fastcgi_hide_header](#fastcgi_hide_header)
    - [fastcgi_ignore_client_abort](#fastcgi_ignore_client_abort)
    - [fastcgi_ignore_headers](#fastcgi_ignore_headers)
    - [fastcgi_index](#fastcgi_index)
    - [fastcgi_intercept_errors](#fastcgi_intercept_errors)
    - [fastcgi_keep_conn](#fastcgi_keep_conn)
    - [fastcgi_limit_rate](#fastcgi_limit_rate)
    - [fastcgi_max_temp_file_size](#fastcgi_max_temp_file_size)
    - [fastcgi_next_upstream](#fastcgi_next_upstream)
    - [fastcgi_next_upstream_timeout](#fastcgi_next_upstream_timeout)
    - [fastcgi_next_upstream_tries](#fastcgi_next_upstream_tries)
    - [fastcgi_no_cache](#fastcgi_no_cache)
    - [fastcgi_param](#fastcgi_param)
    - [fastcgi_pass](#fastcgi_pass)
    - [fastcgi_pass_header](#fastcgi_pass_header)
    - [fastcgi_pass_request_body](#fastcgi_pass_request_body)
    - [fastcgi_pass_request_headers](#fastcgi_pass_request_headers)
    - [fastcgi_read_timeout](#fastcgi_read_timeout)
    - [fastcgi_request_buffering](#fastcgi_request_buffering)
    - [fastcgi_send_lowat](#fastcgi_send_lowat)
    - [fastcgi_send_timeout](#fastcgi_send_timeout)
    - [fastcgi_split_path_info](#fastcgi_split_path_info)
    - [fastcgi_store](#fastcgi_store)
    - [fastcgi_store_access](#fastcgi_store_access)
    - [fastcgi_temp_file_write_size](#fastcgi_temp_file_write_size)
    - [fastcgi_temp_path](#fastcgi_temp_path)
- [传参到 FastCGI 服务器](#parameters)
- [内嵌变量](#embedded_variables)

`ngx_http_fastcgi_module` 模块允许将请求传递给 FastCGI 服务器。

<a id="example_configuration"></a>

## 示例配置

```nginx
location / {
    fastcgi_pass  localhost:9000;
    fastcgi_index index.php;

    fastcgi_param SCRIPT_FILENAME /home/www/scripts/php$fastcgi_script_name;
    fastcgi_param QUERY_STRING    $query_string;
    fastcgi_param REQUEST_METHOD  $request_method;
    fastcgi_param CONTENT_TYPE    $content_type;
    fastcgi_param CONTENT_LENGTH  $content_length;
}
```

<a id="directives"></a>

## 指令

### fastcgi_bind

|\-|说明|
|------:|------|
|**语法**|**fastcgi_bind** `address [transparent]` &#124; `off`;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 0.8.22 版本中出现|

通过一个可选的端口（1.11.2）从指定的本地 IP 地址发出到 FastCGI 服务器的传出连接。参数值可以包含变量（1.3.12）。特殊值 `off`（1.3.12）取消从上层配置级别继承到的 `fastcgi_bind` 指令作用，这允许系统自动分配本地 IP 地址和端口。

`transparent` 参数（1.11.0）允许从非本地 IP 地址（例如来自客户端的真实 IP 地址）的到 FastCGI 服务器的传出连接：

```nginx
fastcgi_bind $remote_addr transparent;
```

为了使这个参数起作用，有必要以超级用户权限运行 nginx 工作进程，并配置内核路由来拦截来自 FastCGI 服务器的网络流量。

### fastcgi_buffer_size

|\-|说明|
|------:|------|
|**语法**|**fastcgi_buffer_size** `size`;|
|**默认**|fastcgi_buffer_size 4k&#124;8k;|
|**上下文**|http、server、location|

设置读取 FastCGI 服务器收到的响应的第一部分的缓冲区的 `size`（大小）。该部分通常包含一个小的响应头。默认情况下，缓冲区大小等于一个内存页。为 4K 或 8K，因平台而异。但是，它可以设置得更小。

### fastcgi_buffering

|\-|说明|
|------:|------|
|**语法**|**fastcgi_buffering** `on` &#124; `off`;|
|**默认**|fastcgi_buffering on;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.5.6 版本中出现|

启用或禁用来自 FastCGI 服务器的响应缓冲。

当启用缓冲时，nginx 会尽可能快地收到接收来自 FastCGI 服务器的响应，并将其保存到由 [fastcgi_buffer_size](#fastcgi_buffer_size) 和 [fastcgi_buffers](#fastcgi_buffers) 指令设置的缓冲区中。如果内存放不下整个响应，响应的一部分可以保存到磁盘上的[临时文件](#fastcgi_temp_path)中。写入临时文件由 [fastcgi_max_temp_file_size ](#fastcgi_max_temp_file_size) 和 [fastcgi_temp_file_write_size](#fastcgi_temp_file_write_size) 指令控制。

当缓冲被禁用时，nginx 在收到响应时立即同步传递给客户端，不会尝试从 FastCGI 服务器读取整个响应。nginx 一次可以从服务器接收的最大数据量由 [fastcgi_buffer_size](#fastcgi_buffer_size) 指令设置。

通过在 `X-Accel-Buffering` 响应头字段中通过 `yes` 或 `no` 也可以启用或禁用缓冲。可以使用 [fastcgi_ignore_headers](#fastcgi_ignore_headers) 指令禁用此功能。

### fastcgi_buffes 

|\-|说明|
|------:|------|
|**语法**|**fastcgi_buffes** `number size`;|
|**默认**|fastcgi_buffers 8 4k&#124;8k;|
|**上下文**|http、server、location|

设置单个连接从 FastCGI 服务器读取响应的缓冲区的 `number` （数量）和 `size` （大小）。默认情况下，缓冲区大小等于一个内存页。为 4K 或 8K，因平台而异。

### fastcgi_busy_buffers_size

|\-|说明|
|------:|------|
|**语法**|**fastcgi_busy_buffers_size** `size`;|
|**默认**|fastcgi_busy_buffers_size 8k&#124;16k;|
|**上下文**|http、server、location|

当启用 FastCGI 服务器响应[缓冲](#fastcgi_buffering)时，限制缓冲区的总大小（`size`）在当响应尚未被完全读取时可向客户端发送响应。同时，其余的缓冲区可以用来读取响应，如果需要的话，缓冲部分响应到临时文件中。默认情况下，`size` 受 [fastcgi_buffer_size](#fastcgi_buffer_size) 和 [fastcgi_buffers](#fastcgi_buffers) 指令设置的两个缓冲区的大小限制。

### fastcgi_cache

|\-|说明|
|------:|------|
|**语法**|**fastcgi_cache** `zone` &#124; `off`;|
|**默认**|fastcgi_cache off;|
|**上下文**|http、server、location|

定义用于缓存的共享内存区域。同一个区域可以在几个地方使用。参数值可以包含变量（1.7.9）。`off` 参数将禁用从上级配置级别继承的缓存配置。

### fastcgi_cache_background_update

|\-|说明|
|------:|------|
|**语法**|**fastcgi_cache_background_update** `on` &#124; `off`;|
|**默认**|fastcgi_cache_background_update off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.11.10. 版本中出现|

允许启动后台子请求来更新过期的缓存项，而过时的缓存响应则返回给客户端。请注意，有必要在更新时[允许](#fastcgi_cache_use_stale_updating)使用陈旧的缓存响应。

### fastcgi_cache_bypass

|\-|说明|
|------:|------|
|**语法**|**fastcgi_cache_bypass** `string ...`;|
|**默认**|——|
|**上下文**|http、server、location|

定义不从缓存中获取响应的条件。如果字符串参数中有一个值不为空且不等于 `0`，则不会从缓存中获取响应：

```nginx
fastcgi_cache_bypass $cookie_nocache $arg_nocache$arg_comment;
fastcgi_cache_bypass $http_pragma    $http_authorization;
```

可以和 [fastcgi_no_cache](#fastcgi_no_cache) 指令一起使用。

### fastcgi_cache_key

|\-|说明|
|------:|------|
|**语法**|**fastcgi_cache_key** `string`;|
|**默认**|——|
|**上下文**|http、server、location|

为缓存定义一个 key，例如：

```nginx
fastcgi_cache_key localhost:9000$request_uri;
```

### fastcgi_cache_lock

|\-|说明|
|------:|------|
|**语法**|**fastcgi_cache_lock** `on` &#124; `off`;|
|**默认**|fastcgi_cache_lock off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.1.12 版本中出现|

当启用时，同一时间只允许一个请求通过将请求传递给 FastCGI 服务器来填充 [fastcgi_cache_key](#fastcgi_cache_key) 指令标识的新缓存元素。同一缓存元素的其他请求将等待响应出现在缓存中，或等待此元素的缓存锁释放，直到 [fastcgi_cache_lock_timeout](#fastcgi_cache_lock_timeout) 指令设置的时间。

### fastcgi_cache_lock_age

|\-|说明|
|------:|------|
|**语法**|**fastcgi_cache_lock_age** `time`;|
|**默认**|fastcgi_cache_lock_age 5s;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.8 版本中出现|

如果传递给 FastCGI 服务器的最后一个请求填充新缓存元素没能在指定的 `time` 内完成，则可能会有其他另一个请求被传递给 FastCGI 服务器。

### fastcgi_cache_lock_timeout

|\-|说明|
|------:|------|
|**语法**|**fastcgi_cache_lock_timeout** `time`;|
|**默认**|fastcgi_cache_lock_timeout 5s;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.1.12 版本中出现|

设置 [fastcgi_cache_lock](#fastcgi_cache_lock_timeout) 的超时时间。当时间到期时，请求将被传递给 FastCGI 服务器，但是，响应不会被缓存。

> 在 1.7.8 之前，响应可以被缓存。

### fastcgi_cache_max_range_offset

|\-|说明|
|------:|------|
|**语法**|**fastcgi_cache_max_range_offset** `number`;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 1.11.6 版本中出现|

为 byte-range 请求设置字节偏移量。如果 range 超出 `number`（偏移量），range 请求将被传递给 FastCGI 服务器，并且不会缓存响应。

### fastcgi_cache_methods

|\-|说明|
|------:|------|
|**语法**|**fastcgi_cache_methods** `GET` &#124; `HEAD` &#124; `POST ...`;|
|**默认**|fastcgi_cache_methods GET HEAD;|
|**上下文**|http、server、location|
|**提示**|该指令在 0.7.59 版本中出现|

如果此指令中存在当前客户端请求方法，那么响应将被缓存。虽然 `GET` 和 `HEAD` 方法总是在该列表中，但我们还是建议您明确指定它们。另请参阅 [fastcgi_no_cache](#fastcgi_no_cache) 指令。

### fastcgi_cache_min_uses

|\-|说明|
|------:|------|
|**语法**|**fastcgi_cache_min_uses** `number`;|
|**默认**|fastcgi_cache_min_uses 1;|
|**上下文**|http、server、location|

设置指定数量（`number`）请求后响应将被缓存。

### fastcgi_cache_path

|\-|说明|
|------:|------|
|**语法**|**fastcgi_cache_path** `path [levels=levels] [use_temp_path=on&#124;off] keys_zone=name:size [inactive=time] [max_size=size] [manager_files=number] [manager_sleep=time] [manager_threshold=time] [loader_files=number] [loader_sleep=time] [loader_threshold=time] [purger=on&#124;off] [purger_files=number] [purger_sleep=time] [purger_threshold=time]`;|
|**默认**|——|
|**上下文**|http|

设置缓存的路径和其他参数。缓存数据存储在文件中。缓存中的 key 和文件名是代理 URL 经过 MD5 函数处理后得到的值。`levels` 参数定义缓存的层次结构级别：范围从 `1` 到 `3`，每个级别可接受值为 `1` 或 `2`。例如，在以下配置中

```nginx
fastcgi_cache_path /data/nginx/cache levels=1:2 keys_zone=one:10m;
```

缓存中的文件名如下所示：

```
/data/nginx/cache/c/29/b7f54b2df7773722d382f4809d65029c
```

首先将缓存的响应写入临时文件，然后重命名该文件。从 0.8.9 版本开始，临时文件和缓存可以放在不同的文件系统上。但是，请注意，在这种情况下，文件复制将要跨两个文件系统，而不是简单的重命名操作。因此建议，对于任何给定的位置，缓存和保存临时文件的目录都应该放在同一个文件系统上。临时文件的目录根据 `use_temp_path` 参数（1.7.10）设置。如果忽略此参数或将其设置为 `on`，则将使用由 [fastcgi_temp_path](#fastcgi_temp_path) 指令设置的目录。如果该值设置为 `off`，临时文件将直接放在缓存目录中。

另外，所有活跃的 key 和有关数据的信息都存储在共享内存区中，其名称和大小由 `keys_zone` 参数配置。一个兆字节的区域可以存储大约 8 千个 key。

> 作为[商业订阅](http://nginx.com/products/?_ga=2.129891407.2132667164.1520648382-1859001452.1520648382)的一部分，共享内存区还存储其他缓存[信息](ngx_http_api_module.md#http_caches_)，因此，需要为相同数量的 key区域大小。例如，一个兆字节区域可以存储大约 4 千个 key。

在 `inactive` 参数指定的时间内未被访问的缓存数据将从缓存中删除。默认情况下，`inactive` 设置为 10 分钟。

“缓存管理器”（cache manager）进程监视的最大缓存大小由 `max_size` 参数设置。当超过此大小时，它将删除最近最少使用的数据。数据在由 `manager_files`、`manager_threshold` 和 `manager_sleep` 参数（1.11.5）配置下进行迭代删除。在一次迭代中，不会超过 `manager_files` 项被删除（默认为 100）。一次迭代的持续时间受到 `manager_threshold` 参数（默认为 200 毫秒）的限制。在每次迭代之间存在间隔时间，由 `manager_sleep` 参数（默认为 50 毫秒）配置。

开始后一分钟，“缓存加载器”（cache loader）进程被激活。它将先前存储在文件系统中的缓存数据的有关信息加载到缓存区中。加载也是在迭代中完成。在每一次迭代中，不会加载 `loader_files` 个项（默认情况下为 100）。此外，每一次迭代的持续时间受到 `loader_threshold` 参数的限制（默认情况下为 200 毫秒）。在迭代之间存在间隔时间，由 `loader_sleep` 参数（默认为 50 毫秒）配置。

此外，以下参数作为我们[商业订阅](http://nginx.com/products/?_ga=2.57597673.2132667164.1520648382-1859001452.1520648382)的一部分：

- `purger=on|off`
    指明缓存清除程序（1.7.12）是否将与[通配符键](#fastcgi_cache_purge)匹配的缓存条目从磁盘中删除。将该参数设置为 `on`（默认为 `off`）将激活“缓存清除器”（cache purger）进程，该进程不断遍历所有缓存条目并删除与通配符匹配的条目。

- `purger_files=number`
    设置在一次迭代期间将要扫描的条目数量（1.7.12）。默认情况下，`purger_files` 设置为 10。

- `purger_threshold=number`
    设置一次迭代的持续时间（1.7.12）。默认情况下，`purger_threshold` 设置为 50 毫秒。

- `purger_sleep=number`
    在迭代之间设置暂停时间（1.7.12）。默认情况下，`purger_sleep` 设置为 50 毫秒。

> 在 1.7.3、1.7.7 和 1.11.10 版本中，缓存头格式发生了更改。升级到更新的 nginx 版本后，以前缓存的响应将视为无效。

### fastcgi_cache_purge

|\-|说明|
|------:|------|
|**语法**|**fastcgi_cache_purge** `string ...`;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 1.5.7 版本中出现|

定义将请求视为缓存清除请求的条件。如果 string 参数中至少有一个不为空的值并且不等于“0”，则带有相应[缓存键](#fastcgi_cache_key)的缓存条目将被删除。通过返回 204（无内容）响应来表示操作成功。

如果清除请求的[缓存键](#fastcgi_cache_key)以星号（`*`）结尾，则将匹配通配符键的所有缓存条目从缓存中删除。但是，这些条目仍然保留在磁盘上，直到它们因为[不活跃](#fastcgi_cache_path)而被删除或被[缓存清除程序](#purger)（1.7.12）处理，或者客户端尝试访问它们。

配置示例：

```nginx
fastcgi_cache_path /data/nginx/cache keys_zone=cache_zone:10m;

map $request_method $purge_method {
    PURGE   1;
    default 0;
}

server {
    ...
    location / {
        fastcgi_pass        backend;
        fastcgi_cache       cache_zone;
        fastcgi_cache_key   $uri;
        fastcgi_cache_purge $purge_method;
    }
}
```

> 该功能可作为我们[商业订阅](http://nginx.com/products/?_ga=2.96459743.2132667164.1520648382-1859001452.1520648382)的一部分。

### fastcgi_cache_revalidate

|\-|说明|
|------:|------|
|**语法**|**fastcgi_cache_purge** `on` &#124; `off`;|
|**默认**|fastcgi_cache_revalidate off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.5.7 版本中出现|

开启使用带有 `If-Modified-Since` 和 `If-None-Match` 头字段的条件请求对过期缓存项进行重新验证。

### fastcgi_cache_use_stale

|\-|说明|
|------:|------|
|**语法**|**fastcgi_cache_use_stale** `error` &#124; `timeout` &#124; `invalid_header` &#124; `updating` &#124; `http_500` &#124; `http_503` &#124; `http_403` &#124; `http_404` &#124; `http_429` &#124; `off ...`;|
|**默认**|fastcgi_cache_use_stale off;|
|**上下文**|http、server、location|

当在与 FastCGI 服务器通信期间发生错误时可以使用陈旧的缓存响应。该指令的参数与 [fastcgi_next_upstream](#fastcgi_next_upstream) 指令的参数相匹配。

如果无法选择使用 FastCGI 服务器处理请求，则 `error` 参数还允许使用陈旧的缓存响应。

此外，如果它当前正在更新，`updating` 参数允许使用陈旧的缓存响应。这样可以在更新缓存数据时最大限度地减少对 FastCGI 服务器的访问次数。

也可以在响应头中直接启用在响应变为陈旧的指定秒数后使用陈旧的缓存响应（1.11.10）。这比使用指令参数的优先级低。

- `Cache-Control` 头字段的 [`stale-while-revalidate`](https://tools.ietf.org/html/rfc5861#section-3) 扩展允许使用陈旧的缓存响应当它正在更新。
- `Cache-Control` 头字段的 [`stale-if-error`](https://tools.ietf.org/html/rfc5861#section-4) 扩展允许在发生错误时使用陈旧的缓存响应。

为了最大限度地减少填充新缓存元素时对 FastCGI 服务器的访问次数，可以使用 [fastcgi_cache_lock](#fastcgi_cache_lock) 指令。

### fastcgi_cache_valid

|\-|说明|
|------:|------|
|**语法**|**fastcgi_cache_valid** `[code ...] time`;|
|**默认**|——|
|**上下文**|http、server、location|

为不同的响应码设置缓存时间。例如：

```nginx
fastcgi_cache_valid 200 302 10m;
fastcgi_cache_valid 404      1m;
```

对响应码为 200 和 302 的响应设置 10 分钟缓存，对响应码为 404 的响应设置为 1 分钟。

如果只指定缓存时间（`time`）：

```nginx
fastcgi_cache_valid 5m;
```

那么只缓存 200 、301 和 302 响应。

另外，可以指定 `any` 参数来缓存任何响应：

```nginx
fastcgi_cache_valid 200 302 10m;
fastcgi_cache_valid 301      1h;
fastcgi_cache_valid any      1m;
```

缓存参数也可以直接在响应头中设置。这比使用指令设置缓存时间具有更高的优先级。

- `X-Accel-Expires` 头字段以秒为单位设置响应的缓存时间。零值会禁用响应缓存。如果该值以 `@` 前缀开头，则它会设置自 Epoch 以来的绝对时间（以秒为单位），最多可以缓存该时间段内的响应。
- 如果头中不包含 `X-Accel-Expires` 字段，则可以在头字段 `Expires` 或 `Cache-Control` 中设置缓存参数。
- 如果头中包含 `Set-Cookie` 字段，则不会缓存此类响应。
- 如果头中包含具有特殊值 `*` 的 `Vary` 字段，则这种响应不会被缓存（1.7.7）。如果头中包含带有另一个值的 `Vary` 字段，考虑到相应的请求头字段（1.7.7），这样的响应将被缓存。

使用 [fastcgi_ignore_headers](#fastcgi_ignore_headers) 指令可以禁用一个或多个响应头字段的处理。

### fastcgi_catch_stderr

|\-|说明|
|------:|------|
|**语法**|**fastcgi_catch_stderr** `string`;|
|**默认**|——|
|**上下文**|http、server、location|

设置一个字符串，用于在从 FastCGI 服务器接收到的响应的错误流中搜索匹配。如果找到该字符串，则认为 FastCGI 服务器返回[无效响应](#fastcgi_next_upstream)。此时将启用 nginx 中的应用程序错误处理，例如：

```nginx
location /php {
    fastcgi_pass backend:9000;
    ...
    fastcgi_catch_stderr "PHP Fatal error";
    fastcgi_next_upstream error timeout invalid_header;
}
```

### fastcgi_connect_timeout

|\-|说明|
|------:|------|
|**语法**|**fastcgi_connect_timeout** `time`;|
|**默认**|fastcgi_connect_timeout 60s;|
|**上下文**|http、server、location|

设置与 FastCGI 服务器建立连接的超时时间。需要注意的是，这个超时通常不能超过 75 秒。

### fastcgi_force_ranges

|\-|说明|
|------:|------|
|**语法**|**fastcgi_force_ranges** `on` &#124; `off`;|
|**默认**|fastcgi_force_ranges off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.7 版本中出现|

启用来自 FastCGI 服务器的缓存和未缓存响应的 byte-range 支持，忽略响应中的 `Accept-Ranges` 头字段。

### fastcgi_hide_header

|\-|说明|
|------:|------|
|**语法**|**fastcgi_hide_header** `field`;|
|**默认**|——|
|**上下文**|http、server、location|

默认情况下，nginx 不会将 FastCGI 服务器响应中的头字段 `Status` 和 `X-Accel-...` 传递给客户端。`fastcgi_hide_header` 指令设置不会被传递的附加字段。但是，如果需要允许传递字段，则可以使用 [fastcgi_pass_header](#fastcgi_pass_header) 指令。

### fastcgi_ignore_client_abort

|\-|说明|
|------:|------|
|**语法**|**fastcgi_ignore_client_abort** `on` &#124; `off`;|
|**默认**|fastcgi_ignore_client_abort off;|
|**上下文**|http、server、location|

确定当客户端关闭连接而不等待响应时是否关闭与 FastCGI 服务器的连接。

### fastcgi_ignore_headers

|\-|说明|
|------:|------|
|**语法**|**fastcgi_ignore_headers** `field ...`;|
|**默认**|——|
|**上下文**|http、server、location|

禁止处理来自 FastCGI 服务器的某些响应头字段。以下字段将被忽略：`X-Accel-Redirect`、`X-Accel-Expires`、`X-Accel-Limit-Rate`（1.1.6）、`X-Accel-Buffering`（1.1.6）、`X-Accel-Charset`（1.1.6）、`Expires`、`Cache-Control`、`Set-Cookie`（0.8.44）和 `Vary`（1.7.7）。

如果未禁用，则处理这些头字段产生以下效果：

- `X-Accel-Expires`、`Expires`、`Cache-Control`、`Set-Cookie` 和 `Vary` 设置响应[缓存](#fastcgi_cache_valid)的参数
- `X-Accel-Redirect` 执行[内部重定向](#internal)到指定的 URI
- `X-Accel-Limit-Rate` 设置响应的传送[速率限制](#limit_rate)回客户端
- `X-Accel-Buffering` 启用或禁用[缓冲](#fastcgi_buffering)响应
- `X-Accel-Charset` 设置所需的响应[字符集](ngx_http_charset_module.md#charset)

### fastcgi_index

|\-|说明|
|------:|------|
|**语法**|**fastcgi_index** `name`;|
|**默认**|——|
|**上下文**|http、server、location|

在 `$fastcgi_script_name` 变量的值中设置一个文件名，该文件名追加到 URL 后面并以一个斜杠结尾。例如以下设置

```nginx
fastcgi_index index.php;
fastcgi_param SCRIPT_FILENAME /home/www/scripts/php$fastcgi_script_name;
```

和 `/page.php` 请求，`SCRIPT_FILENAME` 参数将等于 `/home/www/scripts/php/page.php`，并且 `/` 请求将等于 `/home/www/scripts/php/index.php`。

### fastcgi_intercept_errors

|\-|说明|
|------:|------|
|**语法**|**fastcgi_intercept_errors** `on` &#124; `off`;|
|**默认**|fastcgi_intercept_errors off;|
|**上下文**|http、server、location|

确定当 FastCGI 服务器响应码大于或等于 300 时是否应传递给客户端，或者拦截并重定向到 nginx 以便使用 [error_page](ngx_http_core_module.md#error_page) 指令进行处理。

### fastcgi_keep_conn

|\-|说明|
|------:|------|
|**语法**|**fastcgi_keep_conn** `on` &#124; `off`;|
|**默认**|fastcgi_keep_conn off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.1.4 版本中出现|

默认情况下，FastCGI 服务器将在发送响应后立即关闭连接。但是，如果当此指令设置为 `on` 值，则 nginx 将指示 FastCGI 服务器保持连接处于打开状态。这对保持 FastCGI 服务器连接 [keepalive](ngx_http_upstream_module.md#keepalive) 尤为重要。

### fastcgi_limit_rate

|\-|说明|
|------:|------|
|**语法**|**fastcgi_limit_rate** `rate`;|
|**默认**|fastcgi_limit_rate 0;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.7 版本中出现|

限制读取 FastCGI 服务器响应的速度。`rate` 以每秒字节数为单位。零值则禁用速率限制。该限制是针对每个请求设置的，因此如果 nginx 同时打开两个连接到 FastCFI 服务器的连接，则整体速率将是指定限制的两倍。该限制仅在启用[缓冲](#fastcgi_buffering)来自 FastCGI 服务器的响应时才起作用。

### fastcgi_max_temp_file_size

|\-|说明|
|------:|------|
|**语法**|**fastcgi_max_temp_file_size** `size`;|
|**默认**|fastcgi_max_temp_file_size 1024m;|
|**上下文**|http、server、location|

当启用[缓冲](#fastcgi_buffering)来自 FastCGI 服务器的响应时并且整个响应不适合由 {fastcgi_buffer_size](#fastcgi_buffer_size)  和 [fastcgi_buffers](#fastcgi_buffers) 指令设置的缓冲时，响应的一部分可以保存到临时文件中。该指令用于设置临时文件的最大大小（`size`）。一次写入临时文件的数据大小由 [fastcgi_temp_file_write_size](#fastcgi_temp_file_write_size) 指令设置。

零值将禁用临时文件响应缓冲。

> 此限制不适用于将要[缓存](#fastcgi_cache)或[存储](#fastcgi_store)在磁盘上的响应。

### fastcgi_next_upstream

|\-|说明|
|------:|------|
|**语法**|**fastcgi_next_upstream** `error` &#124; `timeout` &#124; `invalid_header` &#124; `http_500` &#124; `http_503` &#124; `http_403` &#124; `http_404` &#124; `http_429` &#124; `non_idempotent` &#124; `off ...`；|
|**默认**|fastcgi_next_upstream error timeout;|
|**上下文**|http、server、location|

指定在哪些情况下请求应传递给下一台服务器：

- `erorr`

    在与服务器建立连接、传递请求或读取响应头时发生错误
    
- `timeout`

    在与服务器建立连接、传递请求或读取响应头时发生超时

- `invalid_header`

    服务器返回了空的或无效的响应

- `http_500`

    服务器返回 500 响应码

- `http_503`

    服务器返回 503 响应码

- `http_403`

    服务器返回 403 响应码

- `http_404`

    服务器返回 404 响应码

- `http_429`

    服务器返回 429 响应码（1.11.13）

- `non_idempotent`

    通常，如果请求已发送到上游服务器（1.9.13），则具有[非幂等](https://tools.ietf.org/html/rfc7231#section-4.2.2)方法（POST、LOCK、PATCH）的请求不会传递到下一个服务器，使这个选项明确允许重试这样的请求

- `off`

    禁用将请求传递给下一个服务器

我们应该记住，只有在没有任何内容发送给客户端的情况下，才能将请求传递给下一台服务器。也就是说，如果在响应传输过程中发生错误或超时，要修复是不可能的。

该指令还定义了与服务器进行通信的[不成功尝试](ngx_http_upstream_module.html#max_fails)。`erorr`、`timeout` 和 `invalid_header` 的情况总是被认为是不成功的尝试，即使它们没有在指令中指定。只有在指令中指定了 `http_500`、`http_503` 和 `http_429` 的情况下，它们才被视为不成功尝试。`http_403` 和 `http_404` 的情况永远不会被视为不成功尝试。

将请求传递给下一台服务器可能受到[尝试次数](#fastcgi_next_upstream_tries)和[时间](#fastcgi_next_upstream_timeout)的限制。

### fastcgi_next_upstream_timeout

|\-|说明|
|------:|------|
|**语法**|**fastcgi_next_upstream_timeout** `time`;|
|**默认**|fastcgi_next_upstream_timeout 0;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.5 版本中出现|

限制请求可以传递到[下一个服务器](#fastcgi_next_upstream)的时间。`0` 值关闭此限制。

### fastcgi_next_upstream_tries

|\-|说明|
|------:|------|
|**语法**|**fastcgi_next_upstream_tries** `number`;|
|**默认**|fastcgi_next_upstream_tries 0;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.5 版本中出现|

限制将请求传递到下一个服务器的[尝试次数](#fastcgi_next_upstream)。`0` 值关闭此限制。

### fastcgi_no_cache

|\-|说明|
|------:|------|
|**语法**|**fastcgi_no_cache** `string ...`;|
|**默认**|——|
|**上下文**|http、server、location|

定义响应不会保存到缓存中的条件。如果 `string` 参数中有一个值不为空且不等于 `0`，则不会保存响应：

```nginx
fastcgi_no_cache $cookie_nocache $arg_nocache$arg_comment;
fastcgi_no_cache $http_pragma    $http_authorization;
```

可以与 [fastcgi_cache_bypass](fastcgi_cache_bypass) 指令一起使用。

### fastcgi_param

|\-|说明|
|------:|------|
|**语法**|**fastcgi_param** `parameter value [if_not_empty]`;|
|**默认**|——|
|**上下文**|http、server、location|

设置应传递给 FastCGI 服务器的 `parameter` (参数)。该值可以包含文本、变量及其组合。当且仅当在当前级别上没有定义 [fastcgi_param](#fastcgi_param) 指令时，这些指令才从前一级继承。

以下示例展示了 PHP 的最小要求配置：

```nginx
fastcgi_param SCRIPT_FILENAME /home/www/scripts/php$fastcgi_script_name;
fastcgi_param QUERY_STRING    $query_string;
```

`SCRIPT_FILENAME` 参数在 PHP 中用于确定脚本名称，`QUERY_STRING` 参数用于传递请求参数。

对于处理 POST 请求的脚本，还需要以下三个参数：

```nginx
fastcgi_param REQUEST_METHOD  $request_method;
fastcgi_param CONTENT_TYPE    $content_type;
fastcgi_param CONTENT_LENGTH  $content_length;
```

如果 PHP 使用了 `--enable-force-cgi-redirect` 配置参数构建，则还应该使用值 `200` 传递 `REDIRECT_STATUS` 参数：

```nginx
fastcgi_param REDIRECT_STATUS 200;
```

如果该指令是通过 `if_not_empty`（1.1.11）指定的，那么只有当它的值不为空时，这个参数才会被传递给服务器：

```nginx
fastcgi_param HTTPS           $https if_not_empty;
```

### fastcgi_pass

|\-|说明|
|------:|------|
|**语法**|**fastcgi_pass** `address`;|
|**默认**|——|
|**上下文**|http、server、location|

设置 FastCGI 服务器的地址。该地址可以指定为域名或 IP 地址，以及端口：

```nginx
fastcgi_pass localhost:9000;
```

或者作为 UNIX 域套接字路径：

```nginx
fastcgi_pass unix:/tmp/fastcgi.socket;
```

如果域名解析为多个地址，则所有这些地址都将以循环方式使用。另外，地址可以被指定为[服务器组](ngx_http_upstream_module.md)。

参数值可以包含变量。在这种情况下，如果地址被指定为域名，则在所描述的[服务器组](ngx_http_upstream_module.md)中搜索名称，如果未找到，则使用[解析器](ngx_http_core_module.md#resolver)来确定。

### fastcgi_pass_header

|\-|说明|
|------:|------|
|**语法**|**fastcgi_pass_header** `field`;|
|**默认**|——|
|**上下文**|http、server、location|

允许从 FastCGI 服务器向客户端传递[隐藏禁用](#fastcgi_hide_header)的头字段。

### fastcgi_pass_request_body

|\-|说明|
|------:|------|
|**语法**|**fastcgi_pass_request_body** `on` &#124; `off`;|
|**默认**|fastcgi_pass_request_body on;|
|**上下文**|http、server、location|

指示是否将原始请求主体传递给 FastCGI 服务器。另请参阅 [fastcgi_pass_request_headers](#fastcgi_pass_request_body) 指令。

### fastcgi_pass_request_headers

|\-|说明|
|------:|------|
|**语法**|**fastcgi_pass_request_headers** `on` &#124; `off`;|
|**默认**|fastcgi_pass_request_headers on;|
|**上下文**|http、server、location|

指示原始请求的头字段是否传递给 FastCGI 服务器。另请参阅 [fastcgi_pass_request_body](#fastcgi_pass_request_body) 指令。

### fastcgi_read_timeout

|\-|说明|
|------:|------|
|**语法**|**fastcgi_read_timeout** `time`;|
|**默认**|fastcgi_read_timeout 60s;|
|**上下文**|http、server、location|

定义从 FastCGI 服务器读取响应的超时时间。超时设置在两次连续的读操作之间，而不是传输整个响应的过程。如果 FastCGI 服务器在此时间内没有发送任何内容，则连接将被关闭。

### fastcgi_request_buffering

|\-|说明|
|------:|------|
|**语法**|**fastcgi_request_buffering** `on` &#124; `off`;|
|**默认**|fastcgi_request_buffering on;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.11 版本中出现|

启用或禁用客户端请求体缓冲。

启用缓冲时，在将请求发送到 FastCGI 服务器之前，将从客户端[读](#client_body_buffer_size)取整个请求体。

当缓冲被禁用时，请求体在收到时立即发送到 FastCGI 服务器。在这种情况下，如果 nginx 已经开始发送请求体，则请求不能传递到[下一个服务器](#fastcgi_next_upstream)。

### fastcgi_send_lowat

|\-|说明|
|------:|------|
|**语法**|**fastcgi_send_lowat** `size`;|
|**默认**|fastcgi_send_lowat 0;|
|**上下文**|http、server、location|

如果指令设置为非零值，则 nginx 将尝试通过使用 [kqueue](../../介绍/连接处理方式.md#kqueue) 方式的 `NOTE_LOWAT` 标志或 `SO_SNDLOWAT` 套接字选项，以指定的 `size`（大小）来最小化传出连接到 FastCGI 服务器上的发送操作次数。

该指令在 Linux、Solaris 和 Windows 上被忽略。

### fastcgi_send_timeout

|\-|说明|
|------:|------|
|**语法**|**fastcgi_send_timeout** `time`;|
|**默认**|fastcgi_send_timeout 60s;|
|**上下文**|http、server、location|

设置向 FastCGI 服务器发送请求的超时时间。超时设置在两次连续写入操作之间，而不是传输整个请求的过程。如果 FastCGI 服务器在此时间内没有收到任何内容，则连接将关闭。

### fastcgi_split_path_info

|\-|说明|
|------:|------|
|**语法**|**fastcgi_split_path_info** `regex`;|
|**默认**|fastcgi_send_timeout 60s;|
|**上下文**|location|

定义一个捕获 `$fastcgi_path_info` 变量值的正则表达式。正则表达式应该有两个捕获：第一个为 `$fastcgi_script_name` 变量的值，第二个为 `$fastcgi_path_info` 变量的值。例如以下设置

```nginx
location ~ ^(.+\.php)(.*)$ {
    fastcgi_split_path_info       ^(.+\.php)(.*)$;
    fastcgi_param SCRIPT_FILENAME /path/to/php$fastcgi_script_name;
    fastcgi_param PATH_INFO       $fastcgi_path_info;
```

和 `/show.php/article/0001` 请求，`SCRIPT_FILENAME` 参数等于 `/path/to/php/show.php`，并且 `PATH_INFO` 参数等于 `/article/0001`。

### fastcgi_store

|\-|说明|
|------:|------|
|**语法**|**fastcgi_store** `on` &#124; `off` &#124; `string`;|
|**默认**|fastcgi_store off;|
|**上下文**|http、server、location|

启用将文件保存到磁盘。`on` 参数将文件保存为与指令 [alias](ngx_http_core_module.md#alias) 或 [root](ngx_http_core_module.md#root) 相对应的路径。`off` 参数禁用保存文件。另外，可以使用带变量的字符串显式设置文件名：

```nginx
fastcgi_store /data/www$original_uri;
```
文件的修改时间根据收到的 `Last-Modified` 响应头字段设置。首先将响应写入临时文件，然后重命名该文件。从 0.8.9 版本开始，临时文件和持久存储可以放在不同的文件系统上。但是，请注意，在这种情况下，文件将跨两个文件系统进行复制，而不是简单地进行重命名操作。因此建议，对于任何给定位置，保存的文件和由 [fastcgi_temp_path](#fastcgi_temp_path) 指令设置的保存临时文件的目录都放在同一个文件系统上。

该指令可用于创建静态不可更改文件的本地副本，例如：

```nginx
location /images/ {
    root                 /data/www;
    error_page           404 = /fetch$uri;
}

location /fetch/ {
    internal;

    fastcgi_pass         backend:9000;
    ...

    fastcgi_store        on;
    fastcgi_store_access user:rw group:rw all:r;
    fastcgi_temp_path    /data/temp;

    alias                /data/www/;
}
```

### fastcgi_store_access

|\-|说明|
|------:|------|
|**语法**|**fastcgi_store_access** `users:permissions ...`;|
|**默认**|fastcgi_store_access user:rw;|
|**上下文**|http、server、location|

为新创建的文件和目录设置访问权限，例如：

```nginx
fastcgi_store_access user:rw group:rw all:r;
```

如果指定了任何组或所有访问权限，则可以省略用户权限

```nginx
fastcgi_store_access group:rw all:r;
```

### fastcgi_temp_file_write_size

|\-|说明|
|------:|------|
|**语法**|**fastcgi_temp_file_write_size** `size`;|
|**默认**|fastcgi_temp_file_write_size 8k|16k;|
|**上下文**|http、server、location|

设置当开启缓冲 FastCGI 服务器响应到临时文件时，限制写入临时文件的数据 `size`（大小）。默认情况下，大小受 [fastcgi_buffer_size](#fastcgi_buffer_size) 和 [fastcgi_buffers](#fastcgi_buffers) 指令设置的两个缓冲区限制。临时文件的最大大小由 [fastcgi_max_temp_file_size](#fastcgi_max_temp_file_size) 指令设置。

### fastcgi_temp_path

|\-|说明|
|------:|------|
|**语法**|**fastcgi_temp_path** `path [level1 [level2 [level3]]]`;|
|**默认**|astcgi_temp_path fastcgi_temp;|
|**上下文**|http、server、location|

定义一个目录，用于存储从 FastCGI 服务器接收到的数据的临时文件。指定目录下最多可有三级子目录。例如以下配置

```nginx
fastcgi_temp_path /spool/nginx/fastcgi_temp 1 2;
```

临时文件如下所示：

```nginx
/spool/nginx/fastcgi_temp/7/45/00000123457
```

另请参见 [fastcgi_cache_path](#fastcgi_cache_path) 指令的 `use_temp_path` 参数。

<a id="parameters"></a>

## 传参到 FastCGI 服务器

HTTP 请求头字段作为参数传递给 FastCGI 服务器。在作为 FastCGI 服务器运行的应用程序和脚本中，这些参数通常作为环境变量提供。例如，`User-Agent` 头字段作为 `HTTP_USER_AGENT` 参数传递。除 HTTP 请求头字段外，还可以使用 [fastcgi_param](#fastcgi_param) 指令传递任意参数。

<a id="embedded_variables"></a>

## 内嵌变量

`ngx_http_fastcgi_module` 模块支持在 [fastcgi_param](#fastcgi_param) 指令设置参数时使用内嵌变量：

- `$fastcgi_script_name`

    请求 URI，或者如果 URI 以斜杠结尾，则请求 URI 的索引文件名称由 [fastcgi_index](#fastcgi_index) 指令配置。该变量可用于设置 `SCRIPT_FILENAME` 和 `PATH_TRANSLATED` 参数，以确定 PHP 中的脚本名称。例如，对 `/info/` 请求的指令设置

    ```nginx
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME /home/www/scripts/php$fastcgi_script_name;
    ```

    `SCRIPT_FILENAME` 参数等于 `/home/www/scripts/php/info/index.php`。

    使用 [fastcgi_split_path_info](#fastcgi_split_path_info) 指令时，`$fastcgi_script_name` 变量等于指令设置的第一个捕获值。

- `$fastcgi_path_info`

    由 [fastcgi_split_path_info](#fastcgi_split_path_info) 指令设置的第二个捕获值。这个变量可以用来设置 `PATH_INFO` 参数。

## 原文档

[http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html](http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html)