# ngx_http_uwsgi_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [uwsgi_bind](#uwsgi_bind)
    - [uwsgi_buffer_size](#uwsgi_buffer_size)
    - [uwsgi_buffering](#uwsgi_buffering)
    - [uwsgi_buffers](#uwsgi_buffers)
    - [uwsgi_busy_buffers_size](#uwsgi_busy_buffers_size)
    - [uwsgi_cache](#uwsgi_cache)
    - [uwsgi_cache_background_update](#uwsgi_cache_background_update)
    - [uwsgi_cache_bypass](#uwsgi_cache_bypass)
    - [uwsgi_cache_key](#uwsgi_cache_key)
    - [uwsgi_cache_lock](#uwsgi_cache_lock)
    - [uwsgi_cache_lock_age](#uwsgi_cache_lock_age)
    - [uwsgi_cache_lock_timeout](#uwsgi_cache_lock_timeout)
    - [uwsgi_cache_max_range_offset](#uwsgi_cache_max_range_offset)
    - [uwsgi_cache_methods](#uwsgi_cache_methods)
    - [uwsgi_cache_min_uses](#uwsgi_cache_min_uses)
    - [uwsgi_cache_path](#uwsgi_cache_path)
    - [uwsgi_cache_purge](#uwsgi_cache_purge)
    - [uwsgi_cache_revalidate](#uwsgi_cache_revalidate)
    - [uwsgi_cache_use_stale](#uwsgi_cache_use_stale)
    - [uwsgi_cache_valid](#uwsgi_cache_valid)
    - [uwsgi_connect_timeout](#uwsgi_connect_timeout)
    - [uwsgi_force_ranges](#uwsgi_force_ranges)
    - [uwsgi_hide_header](#uwsgi_hide_header)
    - [uwsgi_ignore_client_abort](#uwsgi_ignore_client_abort)
    - [uwsgi_ignore_headers](#uwsgi_ignore_headers)
    - [uwsgi_intercept_errors](#uwsgi_intercept_errors)
    - [uwsgi_limit_rate](#uwsgi_limit_rate)
    - [uwsgi_max_temp_file_size](#uwsgi_max_temp_file_size)
    - [uwsgi_modifier1](#uwsgi_modifier1)
    - [uwsgi_modifier2](#uwsgi_modifier2)
    - [uwsgi_next_upstream](#uwsgi_next_upstream)
    - [uwsgi_next_upstream_timeout](#uwsgi_next_upstream_timeout)
    - [uwsgi_next_upstream_tries](#uwsgi_next_upstream_tries)
    - [uwsgi_no_cache](#uwsgi_no_cache)
    - [uwsgi_param](#uwsgi_param)
    - [uwsgi_pass](#uwsgi_pass)
    - [uwsgi_pass_header](#uwsgi_pass_header)
    - [uwsgi_pass_request_body](#uwsgi_pass_request_body)
    - [uwsgi_pass_request_headers](#uwsgi_pass_request_headers)
    - [uwsgi_read_timeout](#uwsgi_read_timeout)
    - [uwsgi_request_buffering](#uwsgi_request_buffering)
    - [uwsgi_send_timeout](#uwsgi_send_timeout)
    - [uwsgi_socket_keepalive](#uwsgi_socket_keepalive)
    - [uwsgi_ssl_certificate](#uwsgi_ssl_certificate)
    - [uwsgi_ssl_certificate_key](#uwsgi_ssl_certificate_key)
    - [uwsgi_ssl_ciphers](#uwsgi_ssl_ciphers)
    - [uwsgi_ssl_crl](#uwsgi_ssl_crl)
    - [uwsgi_ssl_name](#uwsgi_ssl_name)
    - [uwsgi_ssl_password_file](#uwsgi_ssl_password_file)
    - [uwsgi_ssl_protocols](#uwsgi_ssl_protocols)
    - [uwsgi_ssl_server_name](#uwsgi_ssl_server_name)
    - [uwsgi_ssl_session_reuse](#uwsgi_ssl_session_reuse)
    - [uwsgi_ssl_trusted_certificate](#uwsgi_ssl_trusted_certificate)
    - [uwsgi_ssl_verify](#uwsgi_ssl_verify)
    - [uwsgi_ssl_verify_depth](#uwsgi_ssl_verify_depth)
    - [uwsgi_store](#uwsgi_store)
    - [uwsgi_store_access](#uwsgi_store_access)
    - [uwsgi_temp_file_write_size](#uwsgi_temp_file_write_size)
    - [uwsgi_temp_path](#uwsgi_temp_path)

`ngx_http_uwsgi_module` 模块允许将请求传递到 uwsgi 服务器。

<a id="example_configuration"></a>

## 示例配置

```nginx
location / {
    include    uwsgi_params;
    uwsgi_pass localhost:9000;
}
```

<a id="directives"></a>

## 指令

### uwsgi_bind

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_bind** `address [transparent]` &#124; `off`;|
|**默认**|——|
|**上下文**|http、server、location|

使到 uwsgi 服务器的传出连接源自有一个可选端口（1.11.2）的指定本地 IP 地址。参数值可以包含变量（1.3.12）。特殊值 `off`（1.3.12）取消从先前的配置级别继承的 `uwsgi_bind` 指令的作用，这使系统可以自动分配本地 IP 地址和端口。

`transparent` 参数（1.11.0）允许到 uwsgi 服务器的传出连接来自非本地 IP 地址，例如，来自客户端的真实 IP 地址：

```nginx
uwsgi_bind $remote_addr transparent;
```

为了使该参数起作用，通常必须使用[超级用户](../核心功能.md#user)特权运行 nginx 工作进程。在 Linux 上不需要这样做（1.13.8），就像指定了 `transparent` 参数一样，工作进程从主进程继承 `CAP_NET_RAW` 功能。还必须配置内核路由表以拦截来自 uwsgi 服务器的网络流量。

### uwsgi_buffer_size

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_buffer_size** `size`;|
|**默认**|uwsgi_buffer_size 4k&#124;8k;|
|**上下文**|http、server、location|

设置用于读取从 uwsgi 服务器接收到的响应的第一部分的缓冲区的大小（`size`）。这部分通常包含一个小的响应头。默认情况下，缓冲区大小等于一个内存页。根据平台的不同，它可以是 4K 或 8K。但是，它可以更小。

### uwsgi_buffering

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_buffering** `on` &#124; `off`;|
|**默认**|uwsgi_buffering on;|
|**上下文**|http、server、location|

启用或禁用来自 uwsgi 服务器的响应缓冲。

启用缓冲后，nginx 会尽快从 uwsgi 服务器收到响应，并将其保存到 [uwsgi_buffer_size](#uwsgi_buffer_size) 和 [uwsgi_buffers](#uwsgi_buffers) 指令设置的缓冲区中。如果整个响应都无法容纳到内存中，则可以将一部分响应保存到磁盘上的临时文件中。写入临时文件由 [uwsgi_max_temp_file_size](#uwsgi_max_temp_file_size) 和 [uwsgi_temp_file_write_size](#uwsgi_temp_file_write_size) 指令控制。

禁用缓冲后，一旦收到响应就立即同步传递到客户端。nginx 不会尝试从 uwsgi 服务器读取整个响应。nginx 一次可以从服务器接收的最大数据大小由 [uwsgi_buffer_size](#uwsgi_buffer_size) 指令设置。

也可以通过在 `X-Accel-Buffering` 响应头字段中传递 `yes` 或 `no` 来启用或禁用缓冲。可以使用 [uwsgi_ignore_headers](#uwsgi_ignore_headers) 指令禁用此功能。

### uwsgi_buffers

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_buffers** `number size`;|
|**默认**|uwsgi_buffers 8 4k&#124;8k;|
|**上下文**|http、server、location|

为单个连接设置用于从 uwsgi 服务器读取响应的缓冲区的数量和大小。默认情况下，缓冲区大小等于一个内存页。根据平台的不同，它可以是 4K 或 8K。

### uwsgi_busy_buffers_size

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_busy_buffers_size** `size`;|
|**默认**|uwsgi_busy_buffers_size 8k&#124;16k;|
|**上下文**|http、server、location|

当启用来自 uwsgi 服务器的响应[缓冲](#uwsgi_buffering)后，将限制在尚未完全读取响应时正忙于向客户端发送响应的缓冲区的总大小。同时，其余的缓冲区可用于读取响应，并在需要时将响应的一部分缓冲到临时文件中。默认情况下，大小受 [uwsgi_buffer_size](#uwsgi_buffer_size) 和 [uwsgi_buffers](#uwsgi_buffers) 指令设置的两个缓冲区的大小限制。

### uwsgi_cache

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_cache** `on` &#124; `off`;|
|**默认**|uwsgi_cache off;|
|**上下文**|http、server、location|

定义用于缓存的共享内存区域。同一区域可以在多个地方使用。参数值可以包含变量（1.7.9）。`off` 参数禁用从先前配置级别继承的缓存配置。

### uwsgi_cache_background_update

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_cache_background_update** `on` &#124; `off`;|
|**默认**|uwsgi_cache_background_update off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.11.10 版本中出现|

允许启动后台子请求以更新过期的缓存项，同时将陈旧的缓存响应返回给客户端。请注意，有必要在更新时[允许](#uwsgi_cache_use_stale_updating)使用过期的缓存响应。

### uwsgi_cache_bypass

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_cache_bypass** `string ...`;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 1.11.10 版本中出现|

定义不从缓存获取响应的条件。如果字符串参数中有一个值不为空且不等于 `0`，则不会从缓存中获取响应：

```nginx
uwsgi_cache_bypass $cookie_nocache $arg_nocache$arg_comment;
uwsgi_cache_bypass $http_pragma    $http_authorization;
```

可以与 [uwsgi_no_cache](#uwsgi_no_cache) 指令一起使用。

### uwsgi_cache_key

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_cache_key** `string`;|
|**默认**|——|
|**上下文**|http、server、location|

定义用于缓存的 key，例如

```nginx
uwsgi_cache_key localhost:9000$request_uri;
```

### uwsgi_cache_lock

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_cache_lock** `on` &#124; `off`;|
|**默认**|uwsgi_cache_lock off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.1.12 版本中出现|

启用后，一次仅允许一个请求通过将请求传递给 uwsgi 服务器来填充根据 [uwsgi_cache_key](#uwsgi_cache_key) 指令标识的新缓存元素。在 [uwsgi_cache_lock_timeout](#uwsgi_cache_lock_timeout) 指令设置的时间之前，同一缓存元素的其他请求将等待响应出现在缓存中，或者等待缓存锁定释放该元素。

### uwsgi_cache_lock_age

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_cache_lock_age** `time`;|
|**默认**|uwsgi_cache_lock_age 5s;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.8 版本中出现|

如果最后一次传递给 uwsgi 服务器用于填充新缓存元素的请求在指定时间（`time`）内未完成，则可能再有一个请求传递给 uwsgi 服务器。

### uwsgi_cache_lock_timeout

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_cache_lock_timeout** `time`;|
|**默认**|uwsgi_cache_lock_timeout 5s;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.1.12 版本中出现|

为 [uwsgi_cache_lock](#uwsgi_cache_lock) 设置超时时间。时间到时，请求将被传递到 uwsgi 服务器，但响应将不会被缓存。

> 在 1.7.8 版本之前，可以缓存响应。

### uwsgi_cache_max_range_offset

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_cache_max_range_offset** `number`;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 1.11.6 版本中出现|

设置字节范围（byte-range）请求的字节偏移量。如果范围超出偏移量，则范围请求将传递到 uwsgi 服务器，并且不会缓存响应。

### uwsgi_cache_methods

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_cache_methods** `GET` &#124; `HEAD` &#124; `POST ...`;|
|**默认**|uwsgi_cache_methods GET HEAD;|
|**上下文**|http、server、location|

如果此指令中列出了客户端的请求方法，则将缓存响应。建议显式指定 `GET` 和 `HEAD` 方法，虽然它们始终添加在列表中。另请参见 [uwsgi_no_cache](#uwsgi_no_cache) 指令。

### uwsgi_cache_min_uses

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_cache_min_uses** `number`;|
|**默认**|uwsgi_cache_min_uses 1;|
|**上下文**|http、server、location|

设置请求数（`number`），之后将缓存响应。

### uwsgi_cache_path

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_cache_path** `path [levels=levels] [use_temp_path=on\|off] keys_zone=name:size [inactive=time] [max_size=size] [manager_files=number] [manager_sleep=time] [manager_threshold=time] [loader_files=number] [loader_sleep=time] [loader_threshold=time] [purger=on\|off] [purger_files=number] [purger_sleep=time] [purger_threshold=time]`;|
|**默认**|——|
|**上下文**|http|

设置缓存的路径和其他参数。缓存数据存储在文件中。缓存中的文件名是将[缓存 key](#uwsgi_cache_key) 经过 MD5 计算后得到。`levels` 参数定义缓存的层次结构级别：从 1 到 3，每个级别接受值 1 或 2。例如，在以下配置中

```nginx
uwsgi_cache_path /data/nginx/cache levels=1:2 keys_zone=one:10m;
```

缓存中的文件名如下所示：

```
/data/nginx/cache/c/29/b7f54b2df7773722d382f4809d65029c
```

首先将缓存的响应写入临时文件，然后重命名该文件。从 0.8.9 版本开始，临时文件和缓存可以放在不同的文件系统上。但请注意，在这种情况下，文件跨越了两个文件系统复制，而不是简单的重命名操作。因此，建议对于任何给定位置，将缓存和临时文件保存目录都放在同一文件系统上。基于 `use_temp_path` 参数（1.7.10）设置临时文件的目录，如果省略此参数或将其设置为 `on` 值，则将使用 [uwsgi_temp_path](#uwsgi_temp_path) 指令指定的目录。如果将该值设置为 `off`，则临时文件将直接放置在缓存目录中。

此外，所有活跃的 key 和有关数据的信息都存储在共享存储区中，该存储区的 `name` 和 `size` 由 `keys_zone` 参数配置。一个 1 兆字节的区域可以存储大约 8000 个 key。

> 作为[商业订阅](http://nginx.com/products/?_ga=2.150468402.507616449.1577517222-1105498734.1571247330)部分，共享内存区域还存储缓存扩展信息，因此，需要为相同数量的 key 指定更大的区域大小。例如，一个 1MB 的区域可以存储大约 4000 个 key。

在 `inactive` 参数指定的时间内未访问的缓存数据，无论其新鲜度如何，都将从缓存中删除。默认情况下，`inactive` 设置为 10 分钟。

特殊的「缓存管理器」（cache manager）进程监视的最大缓存大小由 `max_size` 参数设置。当超过此大小时，它将删除最近最少使用的数据。在由 `manager_files`、`manager_threshold` 和 `manager_sleep` 参数（1.11.5）配置的迭代中删除数据。在一次迭代中，最多删除 `manager_files` 项（默认为 100）。一次迭代的持续时间受 `manager_threshold` 参数限制（默认情况下为 200 毫秒）。在迭代之间，将执行由 `manager_sleep` 参数配置的间隔时间（默认情况下为 50 毫秒）。

启动后一分钟，「缓存加载器」（cache loader）进程被激活。它将有关存储在文件系统上的先前缓存数据的信息加载到缓存区域中。加载也以迭代方式完成。在一次迭代中，最多加载 `loader_files` 项（默认情况下为 100）。此外，一次迭代的持续时间受 `loader_threshold` 参数限制（默认为 200 毫秒）。在迭代之间，将执行由 `loader_sleep` 参数配置的暂停时间（默认为 50 毫秒）。

此外，以下参数作为我们的[商业订购部分](http://nginx.com/products/?_ga=2.138998711.507616449.1577517222-1105498734.1571247330)：

- `purger=on|off`

    指示是否由缓存清除器（1.7.12）从磁盘上删除与通配符匹配的缓存条目。将参数设置为 `on`（默认为 `off`）将激活「缓存清除器」进程，该过程将永久性地遍历所有缓存条目，并删除与通配符匹配的条目。

- `purger_files=number`

    设置一次迭代（1.7.12）期间要扫描的条目数。默认情况下，`purger_files` 设置为 10。

- `purger_threshold=number`

    设置一次迭代的持续时间（1.7.12）。默认情况下，`purger_threshold` 设置为 50 毫秒。

- `purger_sleep=number`

设置迭代之间的暂停时间（1.7.12）。默认情况下，`purger_sleep` 设置为 50 毫秒。

> 在 1.7.3、1.7.7 和 1.11.10 版本中，缓存头格式已更改。升级到较新的 nginx 版本后，以前缓存的响应将被视为无效。

### uwsgi_cache_purge

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_cache_purge** `string ...`;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 1.5.7 版本中出现|

定义将请求视为缓存清除请求的条件。如果字符串参数中有一个值不为空且不等于 `0`，则将删除有相应缓存键的缓存条目。返回 204（No Content）响应指示成功操作的结果。

如果清除请求的缓存键以星号（`*`）结尾，则所有与通配符匹配的缓存条目都将从缓存中删除。但是，这些条目将保留在磁盘上，直到因不活跃而将其删除或由缓存清除程序（1.7.12）处理或客户端尝试访问它们为止。

配置示例：

```nginx
uwsgi_cache_path /data/nginx/cache keys_zone=cache_zone:10m;

map $request_method $purge_method {
    PURGE   1;
    default 0;
}

server {
    ...
    location / {
        uwsgi_pass        backend;
        uwsgi_cache       cache_zone;
        uwsgi_cache_key   $uri;
        uwsgi_cache_purge $purge_method;
    }
}
```

> 此功能是我们的[商业订阅](http://nginx.com/products/?_ga=2.115863554.507616449.1577517222-1105498734.1571247330)的一部分内容。

### uwsgi_cache_revalidate

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_cache_revalidate** `on` &#124; `off`;|
|**默认**|uwsgi_cache_revalidate off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.5.7 版本中出现|

启用使用带有 `If-Modified-Since` 和 `If-None-Match` 头字段的条件请求重新验证过期缓存项。

### uwsgi_cache_use_stale

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_cache_use_stale** `uwsgi_cache_use_stale error \| timeout \| invalid_header \| updating \| http_500 \| http_503 \| http_403 \| http_404 \| http_429 \| off ...`;|
|**默认**|uwsgi_cache_use_stale off;|
|**上下文**|http、server、location|

确定在与 uwsgi 服务器通信期间发生错误时在什么情况下可以使用过时的缓存响应。该指令的参数与 [uwsgi_next_upstream](#uwsgi_next_upstream) 指令的参数匹配。

如果无法选择 uwsgi 服务器来处理请求，则 `error` 参数还允许使用过时的缓存响应。

此外，如果当前正在更新 `updating` 参数，则允许使用过时的缓存响应。这样可以在更新缓存的数据时最大程度地减少对 uwsgi 服务器的访问次数。

在响应过时（1.11.10）之后，还可以在响应头中直接启用使用过时的缓存响应并指定的秒数。与使用指令参数相比，它的优先级较低。

- 如果 `Cache-Control` 头字段的 [stale-while-revalidate](https://tools.ietf.org/html/rfc5861#section-3) 扩展当前正在更新，则允许使用过时的缓存响应。
- `Cache-Control` 头字段的 [stale-if-error](https://tools.ietf.org/html/rfc5861#section-4) 扩展允许在发生错误的情况下使用过期缓存的响应。

为了在填充新的缓存元素时最大程度地减少对 uwsgi 服务器的访问次数，可以使用 [uwsgi_cache_lock](#uwsgi_cache_lock) 指令。

### uwsgi_cache_valid

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_cache_valid** `[code ...] time`;|
|**默认**|——|
|**上下文**|http、server、location|

设置不同响应状态码的缓存时间。例如以下指令：

```nginx
uwsgi_cache_valid 200 302 10m;
uwsgi_cache_valid 404      1m;
```

为状态码为 200 和 302 的响应设置 10 分钟的缓存时长，为状态码为 404 的响应设置 1 分钟缓存时长。

如果仅指定缓存时间：

```nginx
uwsgi_cache_valid 5m;
```

那么仅缓存状态码为 200、301 和 302 的响应。

另外，可以指定 `any` 参数来缓存任何响应：

```nginx
uwsgi_cache_valid 200 302 10m;
uwsgi_cache_valid 301      1h;
uwsgi_cache_valid any      1m;
```

缓存参数也可以直接在响应头中设置。这比使用指令设置缓存时间具有更高的优先级。

- `X-Accel-Expires` 头字段以秒为单位设置响应的缓存时间。零值禁用缓存响应。如果该值以 `@` 前缀开头，则它设置自 Epoch 以来的绝对时间（以秒为单位），直到此时间为止，响应都可以被缓存。
- 如果头不包括 `X-Accel-Expires` 字段，则可以在头字段 `Expires` 或 `Cache-Control` 中设置缓存参数。
- 如果头中包含 `Set-Cookie` 字段，则不会缓存此类响应。
- 如果头包含带有特殊值 `*` 的 `Vary` 字段，则不会缓存此类响应（1.7.7）。如果头包含带有另一个值的 `Vary` 字段，则将考虑使用该请求头字段（1.7.7）来缓存此类响应。

可以使用 [uwsgi_ignore_headers](#uwsgi_ignore_headers) 指令禁用对这些响应头字段中的一个或多个的处理。

### uwsgi_connect_timeout

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_connect_timeout** `time`;|
|**默认**|uwsgi_connect_timeout 60s;|
|**上下文**|http、server、location|

定义用于与 uwsgi 服务器建立连接的超时时间。请注意，此超时时间通常不能超过 75 秒。

### uwsgi_force_ranges

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_force_ranges** `on` &#124; `off`;|
|**默认**|uwsgi_force_ranges off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.7 版本中出现|

对来自 uwsgi 服务器的缓存和未缓存响应均启用字节范围（byte-range）支持，忽略这些响应中的 `Accept-Ranges` 字段。

### uwsgi_hide_header

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_hide_header** `field`;|
|**默认**|——|
|**上下文**|http、server、location|

默认情况下，nginx 不会将 uwsgi 服务器的响应中的头字段 `Status` 和 `X-Accel-...` 传递给客户端。`uwsgi_hide_header` 指令设置了不会传递的其他字段。相反，如果需要允许传递字段，则可以使用 [uwsgi_pass_header](#uwsgi_pass_header) 指令。

### uwsgi_ignore_client_abort

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_ignore_client_abort** `on` &#124; `off`;|
|**默认**|uwsgi_ignore_client_abort off;|
|**上下文**|http、server、location|

确定在客户端不等待响应就关闭连接时是否应关闭与 uwsgi 服务器的连接。

### uwsgi_ignore_headers

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_ignore_headers** `field ...`;|
|**默认**|——|
|**上下文**|http、server、location|

禁用来自 uwsgi 服务器的某些响应标头字段的处理。可以忽略以下字段：`X-Accel-Redirect`、`X-Accel-Expires`、`X-Accel-Limit-Rate`（1.1.6）、`X-Accel-Buffering`（1.1.6） 、`X-Accel-Charset`（1.1.6）、`Expires`、`Cache-Control`、`Set-Cookie`（0.8.44）和 `Vary`（1.7.7）。

如果未禁用，则处理这些头字段会做以下处理：

- `X-Accel-Expires`、`Expires`、`Cache-Control`、`Set-Cookie` 和 `Vary` 设置响应缓存的参数
- `X-Accel-Redirect` 执行内部重定向到指定的 URI
- `X-Accel-Limit-Rate` 设置将响应传输到客户端的速率限制
- `X-Accel-Buffering` 启用或禁用响应的缓冲
- `X-Accel-Charset` 设置响应的所需字符集

### uwsgi_intercept_errors

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_intercept_errors** `on` &#124; `off`;|
|**默认**|uwsgi_intercept_errors off;|
|**上下文**|http、server、location|

确定是否应将有大于或等于 300 的状态码的 uwsgi 服务器响应传递给客户端，或者应将其拦截并重定向到 nginx 以使用 [error_page](ngx_http_core_module.md#error_page) 指令进行处理。

### uwsgi_limit_rate

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_limit_rate** `rate`;|
|**默认**|uwsgi_limit_rate 0;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.7 版本中出现|

限制从 uwsgi 服务器读取响应的速度。该速率以每秒字节数指定。零值禁用速率限制。该限制是按请求设置的，因此，如果 nginx 同时打开两个与 uwsgi 服务器的连接，则总速率将是指定限制的两倍。仅当启用了来自 uwsgi 服务器的响应[缓冲](#uwsgi_buffering)时，此限制才有效。

### uwsgi_max_temp_file_size

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_max_temp_file_size** `size`;|
|**默认**|uwsgi_max_temp_file_size 1024m;|
|**上下文**|http、server、location|

如果启用了来自 uwsgi 服务器的响应[缓冲](#uwsgi_buffering)，并且整个响应不适合 [uwsgi_buffer_size](#uwsgi_buffer_size) 和 [uwsgi_buffers](#uwsgi_buffers) 指令设置的缓冲区，则可以将一部分响应保存到临时文件中。该指令设置临时文件的最大大小。一次写入临时文件的数据大小由 [uwsgi_temp_file_write_size](#uwsgi_temp_file_write_size) 指令设置。

零值禁用对临时文件的响应缓冲。

> 此限制不适用于将被[缓存](#uwsgi_cache)或[存储](#uwsgi_store)在磁盘上的响应。

### uwsgi_modifier1

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_modifier1** `number`;|
|**默认**|uwsgi_modifier1 0;|
|**上下文**|http、server、location|

设置 [uwsgi 数据包头](http://uwsgi-docs.readthedocs.org/en/latest/Protocol.html#uwsgi-packet-header)中的 `modify1` 字段的值。

### uwsgi_modifier2

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_modifier2** `number`;|
|**默认**|uwsgi_modifier2 0;|
|**上下文**|http、server、location|

设置 [uwsgi 数据包头](http://uwsgi-docs.readthedocs.org/en/latest/Protocol.html#uwsgi-packet-header)中的 `modify2` 字段的值。

### uwsgi_next_upstream

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_next_upstream** `error \| timeout \| invalid_header \| http_500 \| http_503 \| http_403 \| http_404 \| http_429 \| non_idempotent \| off ...`;|
|**默认**|uwsgi_next_upstream error timeout;|
|**上下文**|http、server、location|

指定在哪种情况下将请求传递到下一个服务器：

- `error`

    与服务器建立连接，向服务器传递请求或读取响应头时发生错误

- `timeout`

    与服务器建立连接，向服务器传递请求或读取响应标头时发生超时

- `invalid_header`

    服务器返回了空的或无效的响应

- `http_500`

    服务器返回状态码为 500 的响应

- `http_503`

    服务器返回响应，状态码为 503

- `http_403`

    服务器返回响应，状态码为 403

- `http_404`

    服务器返回了状态码为 404 的响应

- `http_429`

    服务器返回响应，状态码为 429（1.11.13）

- `non_idempotent`

    通常，如果请求已发送到上游服务器，则[非等幂](https://tools.ietf.org/html/rfc7231#section-4.2.2)方法（`POST`、`LOCK`、`PATCH`）的请求不会传递到下一服务器（1.9.13）；明确启用此选项将允许重试此类请求

- `off`

    禁止将请求传递到下一个服务器

应该记住的是，只有在还没有任何内容发送给客户端的情况下，才有可能将请求传递给下一台服务器。即，如果在响应的传输过程中发生错误或超时，则无法解决该问题。

该指令还定义了与服务器通信的一个[失败尝试](ngx_http_upstream_module.md#max_fails)。`error`、`timeout` 和 `invalid_header` 的情况始终被认为是失败尝试，即使未在指令中指定它们也是如此。仅当在指令中指定了 `http_500`、`http_503` 和 `http_429` 的情况时，它们才被认为是失败尝试。永远不会将 `http_403` 和 `http_404` 的情况视为失败尝试。

将请求传递到下一台服务器可能受到[尝试次数](#uwsgi_next_upstream_tries)和[时间](#uwsgi_next_upstream_timeout)的限制。

### uwsgi_next_upstream_timeout

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_next_upstream_timeout** `time`;|
|**默认**|uwsgi_next_upstream_timeout 0;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.5 版本中出现|

限制将请求传递到[下一个服务器]((#uwsgi_next_upstream))的超时时间。`0` 值关闭此限制。

### uwsgi_next_upstream_tries

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_next_upstream_tries** `number`;|
|**默认**|uwsgi_next_upstream_tries 0;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.5 版本中出现|

限制将请求传递到[下一个服务器](#uwsgi_next_upstream)的可能尝试次数。`0` 值关闭此限制。

### uwsgi_no_cache

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_no_cache** `string ...`;|
|**默认**|——|
|**上下文**|http、server、location|

定义不将响应保存到缓存的条件。如果字符串参数中存在一个值不为空且不等于 `0`，则将不保存响应：

```nginx
uwsgi_no_cache $cookie_nocache $arg_nocache$arg_comment;
uwsgi_no_cache $http_pragma    $http_authorization;
```

可以与 [uwsgi_cache_bypass](#uwsgi_cache_bypass) 指令一起使用。

### uwsgi_param

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_param** `parameter value [if_not_empty]`;|
|**默认**|——|
|**上下文**|http、server、location|

设置一个应该传递给 uwsgi 服务器的参数（`parameter`）。该值可以包含文本、变量及其组合。当且仅当当前级别上没有定义 uwsgi_param 指令时，这些指令才从上一级继承。

标准 [CGI 环境变量](https://tools.ietf.org/html/rfc3875#section-4.1)应作为 uwsgi 头提供，请参阅发行版中提供的 `uwsgi_params` 文件：

```nginx
location / {
    include uwsgi_params;
    ...
}
```

如果使用 `if_not_empty`（1.1.11）指定了指令，则仅当其值不为空时，此类参数才会传递给服务器：

```nginx
uwsgi_param HTTPS $https if_not_empty;
```

### uwsgi_pass

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_pass** `[protocol://]address`;|
|**默认**|——|
|**上下文**|http、server、location|

设置 uwsgi 服务器的协议和地址。`protocol` 可以指定 `uwsgi` 或 `suwsgi`（安全的 uwsgi，基于 SSL 的 uwsgi）。地址（`address`）可以指定为域名或 IP 地址以及端口：

```nginx
uwsgi_pass localhost:9000;
uwsgi_pass uwsgi://localhost:9000;
uwsgi_pass suwsgi://[2001:db8::1]:9090;
```

或为 UNIX 域套接字路径：

```nginx
uwsgi_pass unix:/tmp/uwsgi.socket;
```

如果一个域名解析为多个地址，则所有这些地址都将以轮询方式使用。另外，可以将地址指定为一个[服务器组](ngx_http_upstream_module.md)。

参数值可以包含变量。在这种情况下，如果将地址指定为域名，则在描述的[服务器组](ngx_http_upstream_module.md)中搜索该名称，如果找不到，则使用[解析器](ngx_http_core_module.md#resolver)确定该名称。

> 从 1.5.8 版本开始支持安全的 uwsgi 协议。

### uwsgi_pass_header

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_pass_header** `field`;|
|**默认**|——|
|**上下文**|http、server、location|

允许将[原本已禁用](#uwsgi_hide_header)的头字段从 uwsgi 服务器传递到客户端。

### uwsgi_pass_request_body

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_pass_request_body** `on` &#124; `off`;|
|**默认**|uwsgi_pass_request_body on;|
|**上下文**|http、server、location|

指示是否将原始请求体传递到 uwsgi 服务器。另请参见 [uwsgi_pass_request_headers](#uwsgi_pass_request_headers) 指令。

### uwsgi_pass_request_headers

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_pass_request_headers** `on` &#124; `off`;|
|**默认**|uwsgi_pass_request_headers on;|
|**上下文**|http、server、location|

指示是否将原始请求的头字段传递到 uwsgi 服务器。另请参见 [uwsgi_pass_request_body](#uwsgi_pass_request_body) 指令。

### uwsgi_read_timeout

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_read_timeout** `time`;|
|**默认**|uwsgi_read_timeout 60s;|
|**上下文**|http、server、location|

为从 uwsgi 服务器读取响应定义一个超时时间。超时时间仅在两次连续的读取操作之间计算，而不是整个传输响应。如果 uwsgi 服务器在此时间内未传输任何内容，则连接已关闭。

### uwsgi_request_buffering

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_request_buffering** `on` &#124; `off`;|
|**默认**|uwsgi_request_buffering on;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.11 版本中出现|

启用或禁用客户端请求体缓冲。

启用缓冲后，在将请求发送到 uwsgi 服务器之前，将从客户端[读](#client_body_buffer_size)取整个请求体。

禁用缓冲后，请求体将在收到请求后立即发送到 uwsgi 服务器。在这种情况下，如果 ngin 已经开始发送请求体，则该请求无法传递到[下一个服务器](#uwsgi_next_upstream)。

当使用 HTTP/1.1 分块传输编码发送原始请求正文时，无论指令值如何，都将对请求正文进行缓冲。

### uwsgi_send_timeout

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_send_timeout** `time`;|
|**默认**|uwsgi_send_timeout 60s;|
|**上下文**|http、server、location|

设置将请求传输到 uwsgi 服务器的超时时间。超时时间仅在两个连续的写操作之间计算，而不是整个请求的传输。如果 uwsgi 服务器在此时间内未收到任何信息，则连接已关闭。

### uwsgi_socket_keepalive

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_socket_keepalive** `on` &#124; `off`;|
|**默认**|uwsgi_socket_keepalive off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.15.6 版本中出现|

为与 uwsgi 服务器的传出连接配置 **TCP keepalive** 行为。默认情况下，操作系统的设置对套接字有效。如果指令设置为 `on` 值，则将为套接字打开 `SO_KEEPALIVE` 套接字选项。

### uwsgi_ssl_certificate

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_ssl_certificate** `file`;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.8 版本中出现|

指定一个PEM 格式的证书文件，用于对受保护的 uwsgi 服务器进行身份验证。

### uwsgi_ssl_certificate_key

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_ssl_certificate_key** `file`;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.8 版本中出现|

指定一个PEM 格式的密钥文件，用于对受保护的 uwsgi 服务器进行身份验证。

可以指定值 `engine:name:id` 来代替文件（`file`）（1.7.9），该文件从 OpenSSL 引擎名称（`name`）中加载有指定 ID 的密钥。

### uwsgi_ssl_ciphers

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_ssl_ciphers** `ciphers`;|
|**默认**|uwsgi_ssl_ciphers DEFAULT;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.5.8 版本中出现|

为对受保护的 uwsgi 服务器的请求指定启用密码。密码以 OpenSSL 库可以理解的格式指定。

可以使用 `openssl ciphers` 命令查看完整列表。

### uwsgi_ssl_crl

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_ssl_crl** `file`;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.0 版本中出现|

指定一个 PEM 格式带有吊销证书（CRL）的文件，用于[验证](#uwsgi_ssl_verify)受保护的 uwsgi 服务器的证书。

### uwsgi_ssl_name

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_ssl_name** `name`;|
|**默认**|uwsgi_ssl_name host from uwsgi_pass;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.0 版本中出现|

允许覆盖用于[验证](#uwsgi_ssl_verify)受保护的 uwsgi 服务器的证书的服务器名称，并在与受保护的 uwsgi 服务器建立连接时[通过 SNI 传递](#uwsgi_ssl_server_name)。

默认情况下，使用 [uwsgi_pass](#uwsgi_pass) 的主机部分。

### uwsgi_ssl_password_file

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_ssl_password_file** `file`;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.8 版本中出现|

指定一个带有[密钥](#uwsgi_ssl_certificate_key)的文件，每个口令在单独的行上指定。加载密钥时依次尝试。

### uwsgi_ssl_protocols

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_ssl_protocols** `[SSLv2] [SSLv3] [TLSv1] [TLSv1.1] [TLSv1.2] [TLSv1.3]`;|
|**默认**|uwsgi_ssl_protocols TLSv1 TLSv1.1 TLSv1.2;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.5.8 版本中出现|

当请求一个受保护的 uwsgi 服务器时，启用指定协议。

### uwsgi_ssl_server_name

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_ssl_server_name** `on` &#124; `off`;|
|**默认**|uwsgi_ssl_server_name off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.0 版本中出现|

与受保护的 uwsgi 服务器建立连接时，启用或禁用通过 [TLS 服务器名称指示扩展（SNI，RFC 6066）传递服务器名称](http://en.wikipedia.org/wiki/Server_Name_Indication)。

### uwsgi_ssl_session_reuse

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_ssl_session_reuse** `on` &#124; `off`;|
|**默认**|uwsgi_ssl_session_reuse on;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.5.8 版本中出现|

确定在使用受保护的 uwsgi 服务器时是否可以重用 SSL 会话。如果日志中出现错误 `SSL3_GET_FINISHED:digest check failed`，请尝试禁用会话重用。

### uwsgi_ssl_trusted_certificate

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_ssl_trusted_certificate** `file`;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.0 版本中出现|

指定一个 PEM 格式的受信任 CA 证书文件（`file`），该证书用于[验证](#uwsgi_ssl_verify)受保护的 uwsgi 服务器的证书。

### uwsgi_ssl_verify

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_ssl_verify** `on` &#124; `off`;|
|**默认**|uwsgi_ssl_verify off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.0 版本中出现|

启用或禁用对受保护的 uwsgi 服务器证书的验证。

### uwsgi_ssl_verify_depth

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_ssl_verify_depth** `number`;|
|**默认**|uwsgi_ssl_verify_depth 1;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.0 版本中出现|

在受保护的 uwsgi 服务器证书链中设置验证深度。

### uwsgi_store

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_store** `on` &#124; `off` &#124; `string`;|
|**默认**|uwsgi_store off;|
|**上下文**|http、server、location|

允许将文件保存到磁盘。`on` 参数保存文件的路径相对于 [alias](../核心功能.md#alias) 或 [root](../核心功能.md#root) 指令。`off` 参数禁用文件保存。另外，可以使用带有变量的字符串来显式设置文件名：

```nginx
uwsgi_store /data/www$original_uri;
```

根据收到的 **Last-Modified** 响应头字段设置文件的修改时间。首先将响应写入临时文件，然后重命名该文件。从 0.8.9 版本开始，可以将临时文件和持久存储放在不同的文件系统上。但请注意，在这种情况下，文件需要跨两个文件系统复制，而不是简单的重命名操作。因此，建议将 [uwsgi_temp_path](#uwsgi_temp_path) 指令设置的文件保存目录和临时文件保存目录放在同一文件系统上。

该指令可用于创建静态不可更改文件的本地副本，例如：

```nginx
location /images/ {
    root               /data/www;
    error_page         404 = /fetch$uri;
}

location /fetch/ {
    internal;

    uwsgi_pass         backend:9000;
    ...

    uwsgi_store        on;
    uwsgi_store_access user:rw group:rw all:r;
    uwsgi_temp_path    /data/temp;

    alias              /data/www/;
}
```

### uwsgi_store_access

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_store_access** `users:permissions ...`;|
|**默认**|uwsgi_store_access user:rw;|
|**上下文**|http、server、location|

设置新创建的文件和目录的访问权限，例如：

```nginx
uwsgi_store_access user:rw group:rw all:r;
```

如果指定了任何 `group` 或 `all` 访问权限，则可以忽略 `user` 权限：

```nginx
uwsgi_store_access group:rw all:r;
```

### uwsgi_temp_file_write_size

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_temp_file_write_size** `size`;|
|**默认**|uwsgi_temp_file_write_size 8k&#124;16k;|
|**上下文**|http、server、location|

当启用从 uwsgi 服务器到临时文件的响应缓冲时，限制一次写入临时文件的数据大小（`size`）。默认情况下，大小受 [uwsgi_buffer_size](#uwsgi_buffer_size) 和 [uwsgi_buffers](#uwsgi_buffers) 指令设置的两个缓冲区的限制。临时文件的最大大小由 [uwsgi_max_temp_file_size](#uwsgi_max_temp_file_size) 指令设置。

### uwsgi_temp_path

|\-|说明|
|:------|:------|
|**语法**|**uwsgi_temp_path** `path [level1 [level2 [level3]]]`;|
|**默认**|uwsgi_temp_path uwsgi_temp;|
|**上下文**|http、server、location|

定义一个目录，用于存储从 uwsgi 服务器接收到的数据的临时文件。在指定目录下最多可以使用三级子目录层次结构。例如以下配置：

```nginx
uwsgi_temp_path /spool/nginx/uwsgi_temp 1 2;
```

临时文件可能如下：

```
/spool/nginx/uwsgi_temp/7/45/00000123457
```

另请参见 [uwsgi_cache_path](#uwsgi_cache_path) 指令的 `use_temp_path` 参数。

## 原文档

- [http://nginx.org/en/docs/http/ngx_http_uwsgi_module.html](http://nginx.org/en/docs/http/ngx_http_uwsgi_module.html)
