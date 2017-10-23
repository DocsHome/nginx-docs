# ngx_http_core_module

- 指令
    - [absolute_redirect](#absolute_redirect)
    - [aio](#aio)
    - [aio_write](#aio_write)
    - [alias](#alias)
    - [chunked_transfer_encoding](#chunked_transfer_encoding)
    - [client_body_buffer_size](#client_body_buffer_size)
    - [client_body_in_file_only](#client_body_in_file_only)
    - [client_body_in_single_buffer](#client_body_in_single_buffer)
    - [client_body_temp_path](#client_body_temp_path)
    - [client_body_timeout](#client_body_timeout)
    - [client_header_buffer_size](#client_header_buffer_size)
    - [client_header_timeout](#client_header_timeout)
    - [client_max_body_size](#client_max_body_size)
    - [connection_pool_size](#connection_pool_size)
    - [default_type](#default_type)
    - [directio](#directio)
    - [directio_alignment](#directio_alignment)
    - [disable_symlinks](#disable_symlinks)
    - [error_page](#error_page)
    - [etag](#etag)
    - [http](#http)
    - [if_modified_since](#if_modified_since)
    - [ignore_invalid_headers](#ignore_invalid_headers)
    - [internal](#internal)
    - [keepalive_disable](#keepalive_disable)
    - [keepalive_requests](#keepalive_requests)
    - [keepalive_timeout](#keepalive_timeout)
    - [large_client_header_buffers](#large_client_header_buffers)
    - [limit_except](#limit_except)
    - [limit_rate](#limit_rate)
    - [limit_rate_after](#limit_rate_after)
    - [lingering_close](#lingering_close)
    - [lingering_time](#lingering_time)
    - [lingering_timeout](#lingering_timeout)
    - [listen](#listen)
    - [location](#location)
    - [log_not_found](#log_not_found)
    - [log_subrequest](#log_subrequest)
    - [max_ranges](#max_ranges)
    - [merge_slashes](#merge_slashes)
    - [msie_padding](#msie_padding)
    - [msie_refresh](#msie_refresh)
    - [open_file_cache](#open_file_cache)
    - [open_file_cache_errors](#open_file_cache_errors)
    - [open_file_cache_min_uses](#open_file_cache_min_uses)
    - [open_file_cache_valid](#open_file_cache_valid)
    - [output_buffers](#output_buffers)
    - [port_in_redirect](#port_in_redirect)
    - [postpone_output](#postpone_output)
    - [read_ahead](#read_ahead)
    - [recursive_error_pages](#recursive_error_pages)
    - [request_pool_size](#request_pool_size)
    - [reset_timedout_connection](#reset_timedout_connection)
    - [resolver](#resolver)
    - [resolver_timeout](#resolver_timeout)
    - [root](#root)
    - [satisfy](#satisfy)
    - [send_lowat](#send_lowat)
    - [send_timeout](#send_timeout)
    - [sendfile](#sendfile)
    - [sendfile_max_chunk](#sendfile_max_chunk)
    - [server](#server)
    - [server_name](#server_name)
    - [server_name_in_redirect](#server_name_in_redirect)
    - [server_names_hash_bucket_size](#server_names_hash_bucket_size)
    - [server_names_hash_max_size](#server_names_hash_max_size)
    - [server_tokens](#server_tokens)
    - [tcp_nodelay](#tcp_nodelay)
    - [tcp_nopush](#tcp_nopush)
    - [try_files](#try_files)
    - [types](#types)
    - [types_hash_bucket_size](#types_hash_bucket_size)
    - [types_hash_max_size](#types_hash_max_size)
    - [underscores_in_headers](#underscores_in_headers)
    - [variables_hash_bucket_size](#variables_hash_bucket_size)
    - [variables_hash_max_size](#variables_hash_max_size)
- 内嵌变量

## 指令

### absolute_redirect

|\-|说明|
|:------|:------|
|**语法**|**absolute_redirect** `on` &#124; `off`;|
|**默认**|absolute_redirect on;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.11.8 版本中出现|

如果禁用，nginx 发出的重定向将是相对的。

另请参阅 [server_name_in_redirect](#server_name_in_redirect) 和 [port_in_redirect](#port_in_redirect) 指令。

### aio

|\-|说明|
|:------|:------|
|**语法**|**aio** `on` &#124; `off` &#124; `threads[=pool]`;|
|**默认**|aio off;|
|**上下文**|http、server、location|
|**提示**|该指令在 0.8.11 版本中出现|

启用或禁用在 FreeBSD 和 Linux 上使用异步文件 I/O（AIO）：

```nginx
location /video/ {
    aio            on;
    output_buffers 1 64k;
}
```

在 FreeBSD 上，AIO 从 FreeBSD 4.3 开始可用。在 FreeBSD 11.0 之前，可以将 AIO 静态链接到内核中：

```nginx
options VFS_AIO
```

或作为一个内核可加载模块动态加载：

```nginx
kldload aio
```

在 Linux 上，AIO 从内核版本为 2.6.22 开始可用。此外，有必要启用 [directio](#directio)，否则读取将被阻塞：

```nginx
location /video/ {
    aio            on;
    directio       512;
    output_buffers 1 128k;
}
```
在 Linux 上，[directio](#directio) 只能用于读取 512 字节边界对齐的块（或 XFS 4K）。文件未对齐的末端以阻塞模式读取。对于字节范围请求和不是从文件开头开始的 FLV 请求也是如此：在文件的开头和结尾读取未对齐的数据将被阻塞。

当在 Linux 上启用 AIO 和 [sendfile](#sendfile) 时，AIO 用于大于或等于 [directio](#directio) 指令指定大小的文件，而 [sendfile](#sendfile) 用于较小的文件（禁用 [directio](#directio) 时也是如此）。

```nginx
location /video/ {
    sendfile       on;
    aio            on;
    directio       8m;
}
```

最后，可以使用多线程（1.7.11）读取和[发送](#sendfile)文件，不会阻塞工作进程：

```nginx
location /video/ {
    sendfile       on;
    aio            threads;
}
```

读取和发送文件操作被卸载到指定[池](#thread_pool)中的线程。如果省略池名称，则使用名称为 `default` 的池。池名也可以用变量设置：

```nginx
aio threads=pool$disk;
```

默认情况下，多线程是禁用状态，它应该使用 `--with-threads` 配置参数启用。目前，多线程仅与 [epoll](http://nginx.org/en/docs/events.html#epoll)、[kqueue](http://nginx.org/en/docs/events.html#kqueue) 和 [eventport](http://nginx.org/en/docs/events.html#eventport) 方式兼容。仅在 Linux 上支持多线程发送文件。

另请参见 [sendfile](#sendfile) 指令。

### aio_write

|\-|说明|
|:------|:------|
|**语法**|**aio_write** `on` &#124; `off`;|
|**默认**|aio_write off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.9.13 版本中出现|

如果启用 [aio](#aio)，则指定是否写入文件。目前，这仅在使用 aio 线程时有效，并且仅限于将从代理服务器接收的数据写入临时文件。

### alias

|\-|说明|
|:------|:------|
|**语法**|**alias** `path`;|
|**默认**|——|
|**上下文**|location|

定义指定 location 的替换。例如，使用以下配置

```nginx
location /i/ {
    alias /data/w3/images/;
}
```

`/i/top.gif` 的请求，将发送 `/data/w3/images/top.gif` 文件。

`path` 值可以包含变量，除 `$document_root` 和 `$realpath_root` 外。

如果在使用正则表达式定义的 location 内使用了别名，那么这种正则表达式应该包含捕获，并且别名应该引用这些捕获（0.7.40），例如：

```nginx
location ~ ^/users/(.+\.(?:gif|jpe?g|png))$ {
    alias /data/w3/images/$1;
}
```

当 location 与指令值的最后一部分匹配时：

```nginx
location /images/ {
    alias /data/w3/images/;
}
```

更好的方式是使用 [root](#root) 指令：

```nginx
location /images/ {
    root /data/w3;
}
```

### chunked_transfer_encoding

|\-|说明|
|:------|:------|
|**语法**|**chunked_transfer_encoding** `on` &#124; `off`;|
|**默认**|chunked_transfer_encoding on;|
|**上下文**|http、server、location|

允许在 HTTP/1.1 中禁用分块传输编码。在使用的软件未能支持分块编码时它可能会派上用场。

### client_body_buffer_size

|\-|说明|
|:------|:------|
|**语法**|**client_body_buffer_size** `size`;|
|**默认**|client_body_buffer_size 8k|16k;|
|**上下文**|http、server、location|

设置读取客户端请求体的缓冲区大小。如果请求体大于缓冲区，则整个体或仅将其部分写入[临时文件](#client_body_temp_path)。默认情况下，缓冲区大小等于两个内存页。在 x86、其他 32 位平台和 x86-64 上是 8K。在其他 64 位平台上通常为 16K。

### client_body_in_file_only

|\-|说明|
|:------|:------|
|**语法**|**client_body_in_file_only** `on` &#124; `clean` &#124; `off`;|
|**默认**|client_body_in_file_only off;|
|**上下文**|http、server、location|

确定 nginx 是否应将整个客户端请求体保存到文件中。可以在调试期间或使用 `$request_body_file` 变量或模块 [ngx_http_perl_module](ngx_http_perl_module.md) 的 [$r->request_body_file](ngx_http_perl_module.md#methods) 方法时使用此指令。

当设置为 `on` 值时，临时文件在请求处理后不会被删除。

值 `clean` 会将请求处理后剩下的临时文件删除。

### client_body_in_single_buffer

|\-|说明|
|:------|:------|
|**语法**|**client_body_in_single_buffer** `on` &#124; `off`;|
|**默认**|client_body_in_single_buffer off;|
|**上下文**|http、server、location|

确定 nginx 是否应将整个客户端请求体保存在单个缓冲区中。在使用 `$request_body` 变量时，建议使用该指令，用来保存涉及的复制操作次数。

### client_body_temp_path

|\-|说明|
|:------|:------|
|**语法**|**client_body_temp_path** `path [level1 [level2 [level3]]]`;|
|**默认**|client_body_temp_path client_body_temp;|
|**上下文**|http、server、location|

定义用于存储持有客户端请求主体的临时文件的目录。最多可以在指定目录下使用三级子目录层次结构。例如以下配置

```nginx
client_body_temp_path /spool/nginx/client_temp 1 2;
```

临时文件的路径可以如下：

```nginx
/spool/nginx/client_temp/7/45/00000123457
```

### client_body_timeout

|\-|说明|
|:------|:------|
|**语法**|**client_body_timeout** `time`;|
|**默认**|client_body_timeout 60s;|
|**上下文**|http、server、location|

定义读取客户端请求正文的超时时间。超时设置仅是在两个连续读操作之间的时间间隔，而不是整个请求体的传输过程。如果客户端在此时间内没有发送任何内容，则会将 408（请求超时）错误返回给客户端。

### client_header_buffer_size

|\-|说明|
|:------|:------|
|**语法**|**client_header_buffer_size** `size`;|
|**默认**|client_header_buffer_size 1k;|
|**上下文**|http、server|

设置读取客户端请求头的缓冲区大小。对于大多数请求，1K 字节的缓冲区就足够了。但是，如果请求中包含长 cookie，或者来自 WAP 客户端，则可能 1K 是不适用的。如果请求行或请求头域不适合此缓冲区，则会分配由 [large_client_header_buffers](#large_client_header_buffers) 指令配置的较大缓冲区。

### client_header_timeout

|\-|说明|
|:------|:------|
|**语法**|**client_header_timeout** `time`;|
|**默认**|client_header_timeout 60s;|
|**上下文**|http、server|

定义读取客户端请求头的超时时间。如果客户端在这段时间内没有传输整个报头，则将 408（请求超时）错误返回给客户端。

### client_max_body_size

|\-|说明|
|:------|:------|
|**语法**|**client_header_timeout** `size`;|
|**默认**|client_max_body_size 1m;|
|**上下文**|http、server、location|

在 **Content-Length** 请求头域中指定客户端请求体的最大允许大小。如果请求的大小超过配置值，则将 413 （请求实体过大）错误返回给客户端。请注意，浏览器无法正确显示此错误。将  `size` 设置为 0 将禁用检查客户端请求正文大小。

### connection_pool_size

|\-|说明|
|:------|:------|
|**语法**|**connection_pool_size** `size`;|
|**默认**|connection_pool_size 256|512;|
|**上下文**|http、server|

允许精确调整每个连接的内存分配。该指令对性能影响最小，一般不建议使用。默认情况下，32 位平台上的大小为 256 字节，64 位平台上为 512 字节。

> 在 1.9.8 版本之前，所有平台上的默认值都为 256。

### default_type

|\-|说明|
|:------|:------|
|**语法**|**default_type** `mime-type`;|
|**默认**|default_type text/plain;|
|**上下文**|http、server、location|

定义响应的默认 MIME 类型。可以使用 [types](#types) 指令对 MIME 类型的文件扩展名进行映射。

### directio

|\-|说明|
|:------|:------|
|**语法**|**directio** `size` \| `off`;|
|**默认**|directio off;|
|**上下文**|http、server、location|

开启当读取大于或等于指定大小的文件时，使用 `O_DIRECT` 标志（FreeBSD、Linux）、`F_NOCACHE` 标志（macOS）或 `directio()` 函数（Solaris）。该指令自动禁用（0.7.15）给定请求使用的 [sendfile](#sendfile)。它可以用于服务大文件：

```nginx
directio 4m;
```

或当 Linux 上使用 [aio](#aio) 时。

**待续……**

## 原文档
[http://nginx.org/en/docs/http/ngx_http_core_module.html](http://nginx.org/en/docs/http/ngx_http_core_module.html)
