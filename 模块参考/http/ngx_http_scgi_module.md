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

设置缓存的路径和其他参数。缓存数据存储在文件中。缓存的文件名是由 [cache_key](#scgi_cache_key) 经过 MD5 函数处理生成。`levels` 参数定义缓存的层次级别：从 1 到 3，每个级别接受值为 1 或 2。例如，在以下配置中

```nginx
scgi_cache_path /data/nginx/cache levels=1:2 keys_zone=one:10m;
```

缓存的文件名如下所示：

```
/data/nginx/cache/c/29/b7f54b2df7773722d382f4809d65029c
```

首先将被缓存的响应写入临时文件，然后重命名该文件。从 0.8.9 版本开始，临时文件和缓存可以放在不同的文件系统上。但是，请注意，在这种情况下，文件将跨两个文件系统进行复制，而不是简单的重命名操作。因此，建议对于任何指定位置，缓存和保存临时文件的目录都放在同一文件系统上。临时文件目录根据 `use_temp_path` 参数（1.7.10）而设置。如果省略此参数或将其设置为 `on`，则将使用 [scgi_temp_path](#scgi_temp_path) 指令为指定位置设置的目录。如果该值设置为 `off`，则临时文件将直接放入缓存目录中。

此外，所有活跃的 key 和有关数据的信息都存储在共享内存区域中，其名称和大小由 `keys_zone` 参数配置。一兆字节区域可以存储大约 8000 个 key。

> 作为[商业订阅](http://nginx.com/products/?_ga=2.219368921.1549177115.1554004850-896013220.1554004850)的一部分，共享存储器区域还存储扩展的缓存[信息](ngx_http_api_module.md#http_caches_)，因此，需要为相同数量的 key 指定更大的区域大小。例如，一兆字节区域可以存储大约 4000 个 key。

在 `inactive` 参数指定的时间内未访问的缓存数据将从缓存中删除，不管其新旧程度如何。默认情况下，`inactive` 设置为 10 分钟。

特殊的**缓存管理器**进程监视 `max_size` 参数设置的最大缓存大小。超过此大小时，它会删除最近最少使用的数据。在 `manager_files`、`manager_threshold` 和 `manager_sleep` 参数（1.11.5）配置的迭代中删除数据。在一次迭代期间，不会删除超过 `manager_files` 项（默认情况下为 100）。一次迭代的持续时间受 `manager_threshold` 参数限制（默认为 200 毫秒）。在迭代之间，间隔时间由 `manager_sleep` 参数（默认为 50 毫秒）控制。

启动一分钟后，激活特殊的**缓存加载程序**（cache loader）进程。它将有关存储在文件系统上的先前缓存数据的信息加载到缓存区。加载也是在迭代中完成的。在一次迭代期间，不会加载超过 `loader_files` 项（默认情况下为 100）。此外，一次迭代的持续时间受 `loader_threshold` 参数限制（默认为 200 毫秒）。在迭代之间，由 `loader_sleep` 参数（默认为 50 毫秒）控制间隔时间。

此外，以下参数作为[商业订阅](http://nginx.com/products/?_ga=2.185224425.1549177115.1554004850-896013220.1554004850)的一部分提供：

- `purger=on|off`

    指示缓存清除程序是否从磁盘删除与[通配 key](#scgi_cache_purge) 匹配的缓存项（1.7.12）。将参数设置为 `on`（默认为 `off`）将激活清除程序进程，该进程将永久迭代所有缓存条目并删除与通配 key 匹配的条目。

- `purger_files=number`

    设置一次迭代中将扫描的条目数量（1.7.12）。默认情况下，`purger_files` 设置为 10。

- `purger_threshold=number`

    设置一次迭代的持续时间（1.7.12）。默认情况下，`purger_threshold` 设置为 50 毫秒。

- `purger_sleep=number`

    设置迭代间的间隔时间（1.7.12）。默认情况下，`purger_sleep` 设置为 50 毫秒。

> 在 1.7.3、1.7.7 和 1.11.10 版本中，缓存头格式已更改。升级到较新的 nginx 版本后，以前缓存的响应将被视为无效。

### scgi_cache_purge

|\-|说明|
|:------|:------|
|**语法**|**scgi_cache_purge** `string ...`;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 1.5.7 版本中出现|

定义将请求视为缓存清除请求的条件。如果字符串参数包含一个值不为空且不等于 `0`，则移除有相应[缓存 key](#scgi_cache_key) 的缓存项。通过返回 204（无内容）响应来指示成功操作结果。

如果清除请求的缓存 key 以星号（`*`）结尾，则将从缓存中删除与通配 key 匹配的所有缓存项。但是，这些项将保留在磁盘上，直到它们视为[非活动](#scgi_cache_path)状态而被删除，或由缓存清除程序（1.7.12）处理，或者客户端尝试访问它们。

配置示例：

```nginx
scgi_cache_path /data/nginx/cache keys_zone=cache_zone:10m;

map $request_method $purge_method {
    PURGE   1;
    default 0;
}

server {
    ...
    location / {
        scgi_pass        backend;
        scgi_cache       cache_zone;
        scgi_cache_key   $uri;
        scgi_cache_purge $purge_method;
    }
}
```

> 此功能是我们[商业订阅](http://nginx.com/products/?_ga=2.156509307.1549177115.1554004850-896013220.1554004850)的一部分。

### scgi_cache_revalidate

|\-|说明|
|:------|:------|
|**语法**|**scgi_cache_revalidate** `on` &#124; `off`;|
|**默认**|scgi_cache_revalidate off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.5.7 版本中出现|

对带有 **If-Modified-Since** 和 **If-None-Match** 头字段的条件请求启用过期缓存项重新验证。

### scgi_cache_use_stale

|\-|说明|
|:------|:------|
|**语法**|**scgi_cache_use_stale** `error \| timeout \| invalid_header \| updating \| http_500 \| http_503 \| http_403 \| http_404 \| http_429 \| off ...`;|
|**默认**|scgi_cache_use_stale off;|
|**上下文**|http、server、location|

确定在与 SCGI 服务器通信期间发生错误时可以使用过时的缓存响应的情况。该指令的参数与 [scgi_next_upstream](#scgi_next_upstream) 指令的参数匹配。

`error` 参数在无法选择处理请求的 SCGI 服务器的情况下还允许使用过时的缓存响应。

此外，如果当前正在更新，则 `updating` 参数允许使用过时的缓存响应。这允许在更新缓存数据时尽量减少 SCGI 服务器的访问次数。

在响应变为失效后，也可以在响应头中直接启用使用过时的缓存响应指定的秒数（1.11.10）。这比使用指令参数的优先级低。

- **Cache-Control** 头字段的 **[stale-while-revalidate](https://tools.ietf.org/html/rfc5861#section-3)**扩展允许使用陈旧的缓存响应（如果当前正在更新）。
- **Cache-Control** 头字段的 **[stale-if-error](https://tools.ietf.org/html/rfc5861#section-4)**扩展允许在出现错误时使用陈旧的缓存响应。

要在填充新缓存元素时最大化减少 SCGI 服务器的访问次数，可以使用 [scgi_cache_lock](#scgi_cache_lock) 指令。

### scgi_cache_valid

|\-|说明|
|:------|:------|
|**语法**|**scgi_cache_valid** `[code ...] time`;|
|**默认**|——|
|**上下文**|http、server、location|

设置不同响应码的缓存时间。例如，以下指令

```nginx
scgi_cache_valid 200 302 10m;
scgi_cache_valid 404      1m;
```

为响应码为 200 和 302 的响应设置 10 分钟的缓存，为代码 404 的响应设置 1 分钟。

如果仅指定了缓存时间

```nginx
scgi_cache_valid 5m;
```

然后只缓存 200、301 和 302 响应。

此外，可以指定 `any` 参数来缓存任何响应：

```nginx
scgi_cache_valid 200 302 10m;
scgi_cache_valid 301      1h;
scgi_cache_valid any      1m;
```

也可以直接在响应头中设置缓存的参数。这比使用该指令设置缓存时间的优先级更高。

- **X-Accel-Expires** 头字段是以秒为单位设置响应的缓存时间。零值禁用响应的缓存。如果值以 `@` 前缀开头，则设置自 Epoch 以来的绝对时间（以秒为单位），响应可以缓存。
- 如果头不包括 **X-Accel-Expires** 字段，则可以在头字段 **Expires** 或 **Cache-Control** 中设置缓存的参数。
- 如果头包含 **Set-Cookie** 字段，则不会缓存此类响应。
- 如果头包含有特殊值 `*` 的 **Vary** 字段，则不会缓存此类响应（1.7.7）。如果头包含具有另一个值的 **Vary**字段，则将考虑相应的请求头字段来缓存这样的响应（1.7.7）。

可以使用 [scgi_ignore_headers](#scgi_ignore_headers) 指令禁用这些响应头字段中的一个或多个的处理。

### scgi_connect_timeout

|\-|说明|
|:------|:------|
|**语法**|**scgi_connect_timeout** `time`;|
|**默认**|scgi_connect_timeout 60s;|
|**上下文**|http、server、location|

定义与 SCGI 服务器建立连接的超时时间。需要注意此超时通常不会超过 75 秒。

### scgi_force_ranges

|\-|说明|
|:------|:------|
|**语法**|**scgi_force_ranges** `on` &#124; `off`;|
|**默认**|scgi_force_ranges off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.7 版本中出现|

无论这些响应中的 **Accept-Ranges** 字段如何，都为 SCGI 服务器的缓存和未缓存响应启用字节范围支持。

### scgi_hide_header

|\-|说明|
|:------|:------|
|**语法**|**scgi_hide_header** `field`;|
|**默认**|——|
|**上下文**|http、server、location|

默认情况下，nginx 不会将 SCGI 务器的响应中的头字段 **Status** 和 **X-Accel-...** 传递给客户端。[scgi_hide_header](#scgi_pass_header) 指令设置了不会传递的其他字段。相反，如果需要允许传递字段，则可以使用 [scgi_pass_header](#scgi_pass_header) 指令。

### scgi_ignore_client_abort

|\-|说明|
|:------|:------|
|**语法**|**scgi_ignore_client_abort** `on` &#124; `off`;|
|**默认**|scgi_ignore_client_abort off;|
|**上下文**|http、server、location|

确定客户端在不等待响应的情况下关闭连接时是否应关闭与 SCGI 服务器的连接。

### scgi_ignore_headers

|\-|说明|
|:------|:------|
|**语法**|**scgi_ignore_headers** `field ...`;|
|**默认**|——|
|**上下文**|http、server、location|

禁用从 SCGI 服务器处理某些响应头字段。可以忽略以下字段：**X-Accel-Redirect**、**X-Accel-Expires**、**X-Accel-Limit-Rate**（1.1.6）、**X-Accel-Buffering**（1.1.6）、**X-Accel-Charset**（1.1.6）、**Expires**、**Cache-Control**、**Set-Cookie**（0.8.44）和 **Vary**（1.7.7）。

如果未禁用，则处理这些头字段会影响以下：

- **X-Accel-Expires**、**Expires**、**Cache-Control**、**Set-Cookie** 和 **Vary** 设置响应[缓存](#scgi_cache_valid)的参数
- **X-Accel-Redirect** 执行[内部重定向](ngx_http_core_module.md#internal)到指定的 URI
- **X-Accel-Limit-Rate** 设置向客户端传输响应的[速率限制](ngx_http_core_module.md#limit_rate)
- **X-Accel-Buffering** 启用或禁用[缓冲](#scgi_buffering)响应
- **X-Accel-Charset** 设置了所需的响应[字符集](ngx_http_charset_module.md#charset)

### scgi_intercept_errors

|\-|说明|
|:------|:------|
|**语法**|**scgi_intercept_errors** `on` &#124; `off`;|
|**默认**|scgi_intercept_errors off;|
|**上下文**|http、server、location|

确定响应码大于或等于 300 的 SCGI 服务器响应是应该传递给客户端还是被拦截并重定向到 nginx 以便使用 [error_page](ngx_http_core_module.md#error_page) 指令进行处理。

### scgi_limit_rate

|\-|说明|
|:------|:------|
|**语法**|**scgi_limit_rate** `rate`;|
|**默认**|scgi_limit_rate 0;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.7 版本中出现|

限制从 SCGI 服务器读取响应的速度。`rate` 以每秒字节数指定。零值禁用速率限制。根据请求设置限制，因此如果 nginx 同时打开两个到 SCGI 服务器的连接，则总速率将是指定限制的两倍。仅当启用了来自 SCGI 服务器的响应[缓冲](ngx_http_scgi_module.#scgi_buffering)时，该限制才有效。

### scgi_max_temp_file_size

|\-|说明|
|:------|:------|
|**语法**|**scgi_max_temp_file_size** `size`;|
|**默认**|scgi_max_temp_file_size 1024m;|
|**上下文**|http、server、location|

当启用来自 SCGI 服务器的响应缓冲，并且整个响应不适合 [scgi_buffer_size](#scgi_buffer_size) 和 [scgi_buffers](#scgi_buffers) 指令设置的缓冲区时，响应的一部分可以保存到临时文件中。该指令设置临时文件的最大大小（`size`）。一次写入临时文件的数据大小由 [scgi_temp_file_write_size](#scgi_temp_file_write_size) 指令设置。

零值禁用缓冲对临时文件的响应。

> 此限制不适用于被缓存或存储在磁盘上的响应。

### scgi_next_upstream

|\-|说明|
|:------|:------|
|**语法**|**scgi_next_upstream** `sierror \| timeout \| invalid_header \| http_500 \| http_503 \| http_403 \| http_404 \| http_429 \| non_idempotent \| off ...`;|
|**默认**|scgi_next_upstream error timeout;|
|**上下文**|http、server、location|

指定应将请求传递到下一个服务器的场景：

- `error`

    与服务器建立连接，向其传递请求或读取响应头时发生错误

- `timeout`

    在与服务器建立连接，向其传递请求或读取响应头时发生超时

- `invalid_header`

    服务器返回空的或无效的响应

- `http_500`

    服务器返回状态码为 500 的响应

- `http_503`

    服务器返回状态码为 503 的响应

- `http_403`

    服务器返回状态码为 403 的响应

- `http_404`

    服务器返回状态码为 404 的响应

- `http_429`

    服务器返回状态码为 429 的响应（1.11.13）

- `non_idempotent`

    通常，如果请求已发送到上游服务器，则使用非幂等方法（`POST`、`LOCK`、`PATCH`）的请求不会传递给下一个服务器（1.9.13），启用此选项显式允许重试此类请求

- `off`

    禁用将请求传递给下一个服务器

应该记住，只有在尚未向客户端发送任何内容的情况下才能将请求传递给下一个服务器。也就是说，如果在传输响应的过程中发生错误或超时，则无法修复此问题。

该指令还定义了与服务器通信的[失败尝试](ngx_http_upstream_module.md#max_fails)。`error`、`timeout` 和 `invalid_header` 的情况始终被视为失败尝试，即使它们未在指令中指定。`http_500`、`http_503` 和 `http_429` 的情况仅在指令中指定时才被视为失败尝试。`http_403` 和 `http_404` 的情况从未被视为失败尝试。

将请求传递到下一个服务器可能会受到[尝试次数](#scgi_next_upstream_tries)和[时间](#scgi_next_upstream_timeout)的限制。

### scgi_next_upstream_timeout

|\-|说明|
|:------|:------|
|**语法**|**scgi_next_upstream_timeout** `time`;|
|**默认**|scgi_next_upstream_timeout 0;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.5 版本中出现|

限制请求可以传递到[下一个服务器](#scgi_next_upstream)的时间。`0` 值关闭此限制。

### scgi_next_upstream_tries

|\-|说明|
|:------|:------|
|**语法**|**scgi_next_upstream_tries** `number`;|
|**默认**|scgi_next_upstream_tries 0;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.5 版本中出现|

限制将请求传递到[下一个服务器](#scgi_next_upstream)的可能尝试次数。`0` 值关闭此限制。

### scgi_no_cache

|\-|说明|
|:------|:------|
|**语法**|**scgi_no_cache** `string ...`;|
|**默认**|——|
|**上下文**|http、server、location|

定义不将响应保存到缓存的条件。如果字符串参数有一个值不为空且不等于 `0`，则不会保存响应：

```nginx
scgi_no_cache $cookie_nocache $arg_nocache$arg_comment;
scgi_no_cache $http_pragma    $http_authorization;
```

可以与 [scgi_cache_bypass](#scgi_cache_bypass) 指令一起使用。

### scgi_param

|\-|说明|
|:------|:------|
|**语法**|**scgi_param** `parameter value [if_not_empty]`;|
|**默认**|——|
|**上下文**|http、server、location|

设置一个应传递给 SCGI 服务器的 `parameter`。`value` 可以包含文本、变量及其组合。当且仅当在当前级别上没有定义 `scgi_param` 指令时，这些指令才从先前级别继承。

应将[标准 CGI 环境变量](https://tools.ietf.org/html/rfc3875#section-4.1)作为 SCGI 头提供，请参阅分发中提供的 `scgi_params` 文件：

```nginx
location / {
    include scgi_params;
    ...
}
```

如果使用 `if_not_empty`（1.1.11）指定了该指令，那么只有当它的值不为空时，这个参数才会传递给服务器：

```nginx
scgi_param HTTPS $https if_not_empty;
```

### scgi_pass

|\-|说明|
|:------|:------|
|**语法**|**scgi_pass** `address`;|
|**默认**|——|
|**上下文**|location、location 中的 if|

设置 SCGI 服务器的地址。地址可以指定为域名或 IP 地址以及端口：

```nginx
scgi_pass localhost:9000;
```

或者作为 UNIX 域套接字路径：

```nginx
scgi_pass unix:/tmp/scgi.socket;
```

如果域名解析为多个地址，则所有这些地址都以轮训方式使用。此外，可以将地址指定为[服务器组](ngx_http_upstream_module.md)。

参数值可以包含变量。在这种情况下，如果将地址指定为域名，则在所描述的[服务器组](ngx_http_upstream_module.md)中搜索名称，如果未找到，则使用[解析器](ngx_http_core_module.md#resolver)确定。

### scgi_pass_header

|\-|说明|
|:------|:------|
|**语法**|**scgi_pass_header** `field`;|
|**默认**|——|
|**上下文**|http、server、location|

允许将[其他禁用](#scgi_hide_header)的头字段从 SCGI 服务器传递到客户端。

### scgi_pass_request_body

|\-|说明|
|:------|:------|
|**语法**|**scgi_pass_request_body** `on` &#124; `off`;|
|**默认**|scgi_pass_request_body on;|
|**上下文**|http、server、location|

指示是否将原始请求正文传递给 SCGI 服务器。另请参见 [scgi_pass_request_headers](#scgi_pass_request_headers) 指令。

### scgi_pass_request_headers

|\-|说明|
|:------|:------|
|**语法**|**scgi_pass_request_headers** `on` &#124; `off`;|
|**默认**|scgi_pass_request_headers on;|
|**上下文**|http、server、location|

指明原始请求的头字段是否传递给 SCGI 服务器。另请参见 [scgi_pass_request_body](#scgi_pass_request_body) 指令。

### scgi_read_timeout

|\-|说明|
|:------|:------|
|**语法**|**scgi_read_timeout** `time`;|
|**默认**|scgi_read_timeout 60s|
|**上下文**|http、server、location|

设置从 SCGI 服务器读取一个响应的超时时间。超时时间仅针对两个连续的读操作，而不是整个响应传输。如果 SCGI 服务器在此时间内未传输任何内容，则会关闭连接。

### scgi_socket_keepalive

|\-|说明|
|:------|:------|
|**语法**|**scgi_socket_keepalive** `on` &#124; `off`;|
|**默认**|scgi_socket_keepalive off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.15.6 版本中出现|

配置与 SCGI 服务器的传出连接的 **TCP keepalive** 行为。默认情况下，操作系统的设置对套接字有效。如果指令设置为值 `on`，则为套接字打开 `SO_KEEPALIVE` 套接字选项。

### scgi_store

|\-|说明|
|:------|:------|
|**语法**|**scgi_store** `on` &#124; `off` &#124; `string`;|
|**默认**|scgi_store off;|
|**上下文**|http、server、location|

允许将文件保存到磁盘。`on` 参数使用与 [alias](ngx_http_core_module.md#alias) 或 [root](ngx_http_core_module.md#root) 指令对应的路径保存文件。`off` 参数禁用文件保存。此外，可以使用带变量的字符串显式设置文件名：

```nginx
scgi_store /data/www$original_uri;
```

根据接收的 **Last-Modified** 响应头字段设置文件的修改时间。首先将响应写入临时文件，然后重命名该文件。从 0.8.9 版本开始，临时文件和持久化存储可以放在不同的文件系统上。但是，请注意，在这种情况下，文件将跨两个文件系统进行复制，而不是简单的重命名操作。因此，建议对于任何指定位置，由 [scgi_temp_path](#scgi_temp_path) 指令设置的保存文件和保存临时文件的目录都放在同一文件系统上。

该指令可用于创建静态不可更改文件的本地副本，例如：

```nginx
location /images/ {
    root              /data/www;
    error_page        404 = /fetch$uri;
}

location /fetch/ {
    internal;

    scgi_pass         backend:9000;
    ...

    scgi_store        on;
    scgi_store_access user:rw group:rw all:r;
    scgi_temp_path    /data/temp;

    alias             /data/www/;
}
```

### scgi_store_access

|\-|说明|
|:------|:------|
|**语法**|**scgi_store_access** `users:permissions ...`;|
|**默认**|scgi_store_access user:rw;|
|**上下文**|http、server、location|

为新创建的文件和目录设置访问权限，例如：

```nginx
scgi_store_access user:rw group:rw all:r;
```

如果指定了 `group` 或 `all` 访问权限，则可以省略 `user` 权限：

```nginx
scgi_store_access group:rw all:r;
```

### scgi_temp_file_write_size

|\-|说明|
|:------|:------|
|**语法**|**scgi_temp_file_write_size** `size`;|
|**默认**|scgi_temp_file_write_size 8k&#124;16k|
|**上下文**|http、server、location|

当启用从 SCGI 服务器到临时文件的响应缓冲时，限制一次写入临时文件的数据大小（`size`）。默认情况下，`size` 由 [scgi_buffer_size](#scgi_buffer_size ) 和 [scgi_buffers](#scgi_buffers) 指令设置的两个缓冲区限制。临时文件的最大大小由 [scgi_max_temp_file_size](#scgi_max_temp_file_size) 指令设置。

### scgi_temp_path

|\-|说明|
|:------|:------|
|**语法**|**scgi_temp_path** `path [level1 [level2 [level3]]]`;|
|**默认**|scgi_temp_path scgi_temp|
|**上下文**|http、server、location|

定义一个用于存储临时文件的目录，其中包含从 SCGI 服务器接收的数据。在指定目录下最多可以使用三级子目录结构。例如以下配置：

```nginx
scgi_temp_path /spool/nginx/scgi_temp 1 2;
```

临时文件可能如下所示：

```nginx
/spool/nginx/scgi_temp/7/45/00000123457
```

另请参见 [scgi_cache_path](#scgi_cache_path) 指令的 `use_temp_path` 参数。

## 原文档

- [http://nginx.org/en/docs/http/ngx_http_scgi_module.html](http://nginx.org/en/docs/http/ngx_http_scgi_module.html)
