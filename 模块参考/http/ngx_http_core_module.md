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
|------:|------|
|**语法**|**absolute_redirect** `on` \| `off`;|
|**默认**|absolute_redirect on;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.11.8 版本中出现|

如果禁用，nginx 发出的重定向将是相对的。

另请参阅 [server_name_in_redirect](#server_name_in_redirect) 和 [port_in_redirect](#port_in_redirect) 指令。

### aio

|\-|说明|
|------:|------|
|**语法**|**aio** `on` \| `off` \| `threads[=pool]`;|
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
|------:|------|
|**语法**|**aio_write** `on` \| `off`;|
|**默认**|aio_write off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.9.13 版本中出现|

如果启用 [aio](#aio)，则指定是否写入文件。目前，这仅在使用 aio 线程时有效，并且仅限于将从代理服务器接收的数据写入临时文件。

**待续……**

## 原文档
[http://nginx.org/en/docs/http/ngx_http_core_module.html](http://nginx.org/en/docs/http/ngx_http_core_module.html)