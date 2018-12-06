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

### proxy_cache_lock

|\-|说明|
|------:|------|
|**语法**|**proxy_cache_key** `on` &#124; `off`;|
|**默认**|proxy_cache_lock off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.1.12 版本中出现|

启用后，通过将请求传递给代理服务器，一次只允许一个请求填充根据 [proxy_cache_key](#proxy_cache_key) 指令标识的新缓存元素。同一缓存元素的其他请求将等待响应出现在缓存中或缓存锁定以释放此元素，直到 [proxy_cache_lock_timeout](#proxy_cache_lock_timeout) 指令设置的时间。

### proxy_cache_lock_age

|\-|说明|
|------:|------|
|**语法**|**proxy_cache_lock_age** `time`;|
|**默认**|proxy_cache_lock_age 5s;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.8 版本中出现|

如果传递给代理服务器以填充新缓存元素的最后一个请求在指定时间（`time`）内没有完成，则可以将另一个请求传递给代理服务器。

### proxy_cache_lock_timeout

|\-|说明|
|------:|------|
|**语法**|**proxy_cache_lock_timeout** `time`;|
|**默认**|proxy_cache_lock_timeout 5s;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.1.12 版本中出现|

设置 [proxy_cache_lock](#proxy_cache_lock) 的超时。 当时间到期时，请求将被传递给代理服务器，但是，响应将不会被缓存。

> 在1.7.8之前，可以缓存响应。

### proxy_cache_max_range_offset

|\-|说明|
|------:|------|
|**语法**|**proxy_cache_max_range_offset** `number`;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 1.11.6 版本中出现|

设置字节范围请求的偏移量（以字节为单位）。 如果范围超出偏移量，则范围请求将传递到代理服务器，并且不会缓存响应。

### proxy_cache_methods

|\-|说明|
|------:|------|
|**语法**|**proxy_cache_methods** `GET` &#124; `HEAD` &#124; `POST ...`;|
|**默认**|proxy_cache_methods GET HEAD;|
|**上下文**|http、server、location|
|**提示**|该指令在 0.7.59 版本中出现|

如果此指令中列出了客户端请求方法，则将缓存响应。 “GET”和“HEAD”方法总是添加到列表中，但建议明确指定它们。 另请参见proxy_no_cache指令。

### proxy_cache_min_uses

|\-|说明|
|------:|------|
|**语法**|**proxy_cache_min_uses** `number`;|
|**默认**|proxy_cache_min_uses 1;|
|**上下文**|http、server、location|

设置将缓存响应的请求数。

### proxy_cache_path

|\-|说明|
|------:|------|
|**语法**|**proxy_cache_path** `path [levels=levels] [use_temp_path=on&#124;off] keys_zone=name:size [inactive=time] [max_size=size] [manager_files=number] [manager_sleep=time] [manager_threshold=time] [loader_files=number] [loader_sleep=time] [loader_threshold=time] [purger=on&#124;off] [purger_files=number] [purger_sleep=time] [purger_threshold=time]`;|
|**默认**|——|
|**上下文**|http|

设置缓存的路径和其他参数。 缓存数据存储在文件中。 缓存中的文件名是将MD5功能应用于缓存键的结果。 levels参数定义高速缓存的层次结构级别：从1到3，每个级别接受值1或2.例如，在以下配置中

```
proxy_cache_path /data/nginx/cache levels=1:2 keys_zone=one:10m;
```
缓存中的文件名如下所示：

```
/data/nginx/cache/c/29/b7f54b2df7773722d382f4809d65029c
```
首先将缓存的响应写入临时文件，然后重命名该文件。 从版本0.8.9开始，临时文件和缓存可以放在不同的文件系统上。 但是，请注意，在这种情况下，文件将跨两个文件系统复制，而不是廉价的重命名操作。 因此，建议对于任何给定位置，缓存和保存临时文件的目录都放在同一文件系统上。 临时文件的目录是根据use_temp_path参数（1.7.10）设置的。 如果省略此参数或将其设置为on，则将使用proxy_temp_path指令为给定位置设置的目录。 如果该值设置为off，则临时文件将直接放入缓存目录中。

此外，所有活动密钥和有关数据的信息都存储在共享内存区域中，其名称和大小由keys_zone参数配置。 一兆字节区域可以存储大约8000个密钥。

> 作为商业订阅的一部分，共享存储器区域还存储扩展的高速缓存信息，因此，需要为相同数量的密钥指定更大的区域大小。 例如，一兆字节区域可以存储大约4000个密钥。

在非活动参数指定的时间内未访问的缓存数据将从缓存中删除，无论其新鲜度如何。默认情况下，非活动设置为10分钟。

特殊的“缓存管理器”进程监视max_size参数设置的最大缓存大小。超过此大小时，它会删除最近最少使用的数据。在manager_files，manager_threshold和manager_sleep参数（1.11.5）配置的迭代中删除数据。在一次迭代期间，不会删除manager_files项（默认情况下为100）。一次迭代的持续时间受manager_threshold参数限制（默认情况下为200毫秒）。在迭代之间，由manager_sleep参数（默认为50毫秒）配置的暂停。

启动一分钟后，激活特殊的“缓存加载程序”进程。它将有关存储在文件系统中的先前缓存数据的信息加载到缓存区。加载也是在迭代中完成的。在一次迭代期间，加载的loader_files项目不超过（默认情况下为100）。此外，一次迭代的持续时间受loader_threshold参数限制（默认为200毫秒）。在迭代之间，由loader_sleep参数（默认为50毫秒）配置暂停。

此外，以下参数作为我们商业订阅的一部分提供：

- `purger=on|off`

    指示缓存清除程序是否将从磁盘中删除与通配符密钥匹配的缓存条目（1.7.12）。 将参数设置为on（默认为off）将激活“cache purger”进程，该进程将永久迭代所有缓存条目并删除与通配符键匹配的条目。

- `purger_files=number`

    设置在一次迭代（1.7.12）期间将扫描的项目数。 默认情况下，purger_files设置为10。

- `purger_threshold=number`

    设置一次迭代的持续时间（1.7.12）。 默认情况下，purger_threshold设置为50毫秒。

- `purger_sleep=number`

    设置迭代之间的暂停（1.7.12）。 默认情况下，purger_sleep设置为50毫秒。

    > 在版本1.7.3,1.7.7和1.11.10中，缓存头格式已更改。 升级到较新的nginx版本之前，缓存的响应将被视为无效。


### proxy_cache_purge

|\-|说明|
|------:|------|
|**语法**|**proxy_cache_purge** `string ...`;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 1.5.7 版本中出现|

定义将请求视为缓存清除请求的条件。 如果字符串参数的至少一个值不为空并且不等于“0”，则移除具有相应高速缓存键的高速缓存条目。 通过返回204（无内容）响应来指示成功操作的结果。

如果清除请求的缓存键以星号（“*”）结尾，则将从缓存中删除与通配符键匹配的所有缓存条目。 但是，这些条目将保留在磁盘上，直到它们被删除为不活动，或由缓存清除程序（1.7.12）处理，或者客户端尝试访问它们。

配置示例：

```nginx
proxy_cache_path /data/nginx/cache keys_zone=cache_zone:10m;

map $request_method $purge_method {
    PURGE   1;
    default 0;
}

server {
    ...
    location / {
        proxy_pass http://backend;
        proxy_cache cache_zone;
        proxy_cache_key $uri;
        proxy_cache_purge $purge_method;
    }
}
```

此功能作为我们商业订阅的一部分提供。

### proxy_cache_revalidate

|\-|说明|
|------:|------|
|**语法**|**proxy_cache_revalidate** `on` &#124; `off`;|
|**默认**|proxy_cache_revalidate off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.5.7 版本中出现|

使用具有“If-Modified-Since”和“If-None-Match”标头字段的条件请求启用过期缓存项的重新验证。

### proxy_cache_use_stale

|\-|说明|
|------:|------|
|**语法**|**proxy_cache_use_stale** `error` &#124; `timeout` &#124; `invalid_header` &#124; `updating` &#124; `http_500` &#124; `http_502` &#124; `http_503` &#124; `http_504` &#124; `http_403` &#124; `http_404` &#124; `http_429` &#124; `off ...`;|
|**默认**|proxy_cache_use_stale off;|
|**上下文**|http、server、location|

确定在与代理服务器通信期间可以在哪些情况下使用过时的缓存响应。 该指令的参数与proxy_next_upstream指令的参数匹配。

如果无法选择代理服务器来处理请求，则error参数还允许使用过时的缓存响应。

此外，如果当前正在更新，则更新参数允许使用过时的缓存响应。 这允许在更新缓存数据时最小化对代理服务器的访问次数。

在响应变为失效后，也可以在响应头中直接启用过时的缓存响应指定的秒数（1.11.10）。 这比使用指令参数的优先级低。

- “Cache-Control”头字段的“stale-while-revalidate”扩展允许使用陈旧的缓存响应（如果当前正在更新）。

- “Cache-Control”头字段的“stale-if-error”扩展允许在出现错误时使用陈旧的缓存响应。

要在填充新缓存元素时最小化对代理服务器的访问次数，可以使用proxy_cache_lock指令。

### proxy_cache_valid

|\-|说明|
|------:|------|
|**语法**|**proxy_cache_valid** `[code ...] time`;|
|**默认**|——|
|**上下文**|http、server、location|

设置不同响应代码的缓存时间。 例如，以下指令

```nginx
proxy_cache_valid 200 302 10m;
proxy_cache_valid 404      1m;
```

为代码为200和302的响应设置10分钟的缓存，为代码404的响应设置1分钟。

如果仅指定了缓存时间

```nginx
proxy_cache_valid 5m;
```

然后只缓存200,301和302个响应。

此外，可以指定any参数来缓存任何响应：

```nginx
proxy_cache_valid 200 302 10m;
proxy_cache_valid 301      1h;
proxy_cache_valid any      1m;
```

缓存的参数也可以直接在响应头中设置。 这比使用该指令设置缓存时间具有更高的优先级。

- “X-Accel-Expires”标题字段以秒为单位设置响应的缓存时间。 零值禁用响应的缓存。 如果值以@前缀开头，则设置自Epoch以来的绝对时间（以秒为单位），响应可以高速缓存。
- 如果标题不包括“X-Accel-Expires”字段，则可以在标题字段“Expires”或“Cache-Control”中设置高速缓存的参数。
- 如果标头包含“Set-Cookie”字段，则不会缓存此类响应。
- 如果标题包含具有特殊值“*”的“Vary”字段，则不会缓存此类响应（1.7.7）。 如果标题包含具有另一个值的“Vary”字段，则将考虑相应的请求标题字段来缓存这样的响应（1.7.7）。

可以使用proxy_ignore_headers指令禁用这些响应头字段中的一个或多个的处理。

### proxy_connect_timeout

|\-|说明|
|------:|------|
|**语法**|**proxy_connect_timeout** `time`;|
|**默认**|proxy_connect_timeout 60s;|
|**上下文**|http、server、location|

定义与代理服务器建立连接的超时。 应该注意，此超时通常不会超过75秒。

### proxy_cookie_path

|\-|说明|
|------:|------|
|**语法**|**proxy_cookie_path** `off`; <br/> **proxy_cookie_path** `path replacement`;|
|**默认**|proxy_cookie_path off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.1.15 版本中出现|

设置应在代理服务器响应的“Set-Cookie”标头字段的path属性中更改的文本。 假设代理服务器返回带有属性“path = / two / some / uri /”的“Set-Cookie”头字段。 指令

```nginx
proxy_cookie_path /two/ /;
```

将此属性重写为“path = / some / uri /”。

路径和替换字符串可以包含变量：

```nginx
proxy_cookie_path $uri /some$uri;
```

也可以使用正则表达式指定该指令。 在这种情况下，路径应该从用于区分大小写的匹配的“〜”符号开始，或者从用于区分大小写的匹配的“〜*”符号开始。 正则表达式可以包含命名和位置捕获，替换可以引用它们：

```nginx
proxy_cookie_path ~*^/user/([^/]+) /u/$1;
```

可能有几个proxy_cookie_path指令：

```nginx
proxy_cookie_path /one/ /;
proxy_cookie_path / /two/;
```

off参数取消所有proxy_cookie_path指令对当前级别的影响：

```nginx
proxy_cookie_path off;
proxy_cookie_path /two/ /;
proxy_cookie_path ~*^/user/([^/]+) /u/$1;
```

**待续……**

## 原文档
[http://nginx.org/en/docs/http/ngx_http_proxy_module.html](http://nginx.org/en/docs/http/ngx_http_proxy_module.html)