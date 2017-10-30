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

或当在 Linux 上使用 [aio](#aio) 时。

### directio_alignment

|\-|说明|
|:------|:------|
|**语法**|**directio_alignment** `size`;|
|**默认**|directio_alignment 512;|
|**上下文**|http、server、location|
|**提示**|该指令在 0.8.11 版本中出现|

设置 [directio](#directio) 的对齐方式。在大多数情况下，512 字节的对齐就足够了。但是，在 Linux 下使用 XFS 时，需要增加到 4K。

### disable_symlinks

|\-|说明|
|:------|:------|
|**语法**|**disable_symlinks** `off`; <br/> **disable_symlinks on** \| `if_not_owner [from=part]`; |
|**默认**|disable_symlinks off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.1.15 版本中出现|

确定打开文件时应如何处理符号链接：

- `off`

    允许路径名中的符号链接的，不执行检查。这是默认行为。
- `on`

    如果路径名存在是符号链接的组件，则拒绝对文件的访问。

- `if_not_owner`

    如果路径名存在是符号链接的组件，并且链接指向的链接和对象为不同所有者，则拒绝访问文件。

- `from=part`
    
    当检查符号链接（参数 `on` 和 `if_not_owner`）时，通常会检查路径名的所有组件。可以通过另外指定 `from=part` 参数来避免检查路径名的初始部分中的符号链接。在这种情况下，只能从指定的初始部分后面的路径名组件检查符号链接。如果该值不是检查的路径名的初始部分，则会检查整个路径名，相当于没有指定此参数。如果该值与整个文件名匹配，则不会检查符号链接。参数值可以包含变量。

例如：

```nginx
disable_symlinks on from=$document_root;
```

此指令仅适用于具有 `openat()` 和 `fstatat()` 接口的系统。这样的系统包括现代版本的FreeBSD、Linux 和 Solaris。

参数 `on` 和 `if_not_owner` 增加了处理开销。

> 在不支持打开目录仅用于搜索的系统上，要使用这些参数，需要 worker 进程对所有正在检查的目录具有读取权限。

> [ngx_http_autoindex_module](ngx_http_autoindex_module.md)、[ngx_http_random_index_module](ngx_http_random_index_module.md) 和 [ngx_http_dav_module](ngx_http_dav_module.md) 模块目前忽略此指令。

### error_page

|\-|说明|
|:------|:------|
|**语法**|**error_page** `code ... [=[response]] uri`; |
|**默认**|——|
|**上下文**|http、server、location、location 中的 if|

定义针对指定错误显示的 URI。`uri` 值可以包含变量。

例如：

```nginx
error_page 404             /404.html;
error_page 500 502 503 504 /50x.html;
```

这会导致客户端请求方法更改为 `GET`，内部重定向到指定的 `uri`（除 `GET` 和 `HEAD` 之外的所有方法）。

此外，可以使用 `=response` 语法将修改响应代码，例如：

```nginx
error_page 404 =200 /empty.gif;
```

如果错误响应是由代理服务器或 FastCGI/uwsgi/SCGI 服务器处理，并且服务器可能返回不同的响应代码（例如，200、302、401 或 404），则可以使用其返回的代码进行响应：

```nginx
error_page 404 = /404.php;
```

如果在内部重定向时不需要更改 URI 和方法，则可以将错误处理传递给一个命名了的 location：

```nginx
location / {
    error_page 404 = @fallback;
}

location @fallback {
    proxy_pass http://backend;
}
```

> 如果 `uri` 处理导致发生错误，最后发生错误的状态代码将返回给客户端。

也可以使用 URL 重定向进行错误处理：

```nginx
error_page 403      http://example.com/forbidden.html;
error_page 404 =301 http://example.com/notfound.html;
```

在这种情况下，默认将响应代码 302 返回给客户端。它只能是重定向状态代码其中之一（301、302、303、307 和 308）。

> 在 1.1.16 和 1.0.13 版本之前，代码 307 没有被视为重定向。

> 直到 1.13.0 版本，代码 308 才被视为重定向。

当且仅当没有在当前级别上定义 error_page 指令时，指令才从上一级继承这些特性。

### etag

|\-|说明|
|:------|:------|
|**语法**|**etag** `on` \| `off`; |
|**默认**|etag on;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.3.3 版本中出现|

启用或禁用自动生成静态资源 **ETag** 响应头字段。

### http

|\-|说明|
|:------|:------|
|**语法**|**http** `{ ... }`; |
|**默认**|——|
|**上下文**|main|

提供指定 HTTP server 指令的配置文件上下文。

### if_modified_since

|\-|说明|
|:------|:------|
|**语法**|**if_modified_since** `off` \| `exact` \| `before`; |
|**默认**|if_modified_since exact;|
|**上下文**|http、server、location|
|**提示**|该指令在 0.7.24 版本中出现|

指定如何将响应的修改时间与 **If-Modified-Since** 请求头字段中的时间进行比较：

- `off`

    忽略 **If-Modified-Since** 请求头字段（0.7.34）
- `exact`
    
    完全匹配
- `before`

    响应的修改时间小于或等于 **If-Modified-Since** 请求头字段中的时间

### ignore_invalid_headers

|\-|说明|
|:------|:------|
|**语法**|**ignore_invalid_headers** `on` \| `off`; |
|**默认**|ignore_invalid_headers on;|
|**上下文**|http、server|

控制是否应忽略具有无效名称的头字段。有效名称由英文字母、数字、连字符或下划线组成（由 [underscores_in_headers](#underscores_in_headers) 指令控制）。

如果在 [server](#server) 级别指定了该指令，则其值仅在 server 为默认 server 时使用。指定的值也适用于监听相同地址和端口的所有虚拟服务器。

### internal

|\-|说明|
|:------|:------|
|**语法**|**internal**; |
|**默认**|——|
|**上下文**|location|

指定给定的 location 只能用于内部请求。对于外部请求，返回客户端错误 404（未找到）。内部请求如下：

- 请求由 [error_page](#error_page)、[index](#index)、[random_index](#random_index) 和 [try_files](#try_files) 指令重定向
- 来 upstream server 的 **X-Accel-Redirect** 响应头字段重定向的请求
- 由 [ngx_http_ssi_module](ngx_http_ssi_module.md) 模块的 `include virtual` 命令、[ngx_http_addition_module](ngx_http_addition_module.md) 模块指令和 [auth_request](ngx_http_auth_request_module.md#auth_request) 和 [mirror](ngx_http_mirror_module.md#mirror) 指令组成的子请求
- 由 [rewrite](ngx_http_rewrite_module.md#rewrite) 指令更改的请求

示例：

```nginx
error_page 404 /404.html;

location /404.html {
    internal;
}
```

> 每个请求限制 10 个内部重定向，以防止不正确配置引发的请求处理死循环。如果达到此限制，则返回错误 500（内部服务器错误）。在这种情况下，可以在错误日志中看到 `rewrite or internal redirection cycle` 消息。

### keepalive_disable

|\-|说明|
|:------|:------|
|**语法**|**keepalive_disable** `none` \| `browser ...`; |
|**默认**|keepalive_disable msie6;|
|**上下文**|http、server、location|

禁用与行为异常的浏览器保持连接。`browser` 参数指定哪些浏览器将受到影响。一旦接收到 POST 请求，值 `msie6` 将禁用与旧版本 MSIE 保持连接。值 `safari` 禁用与 macOS 和类似 MacOS 的操作系统上的 Safari 和 Safari 浏览器保持连接。值 `none` 启用与所有浏览器保持连接。

> 在 1.1.18 版本之前，值 `safari` 匹配所有操作系统上的所有 Safari 和类 Safari 浏览器，并且默认情况下，禁用与它们保持连接。

### keepalive_requests

|\-|说明|
|:------|:------|
|**语法**|**keepalive_requests** `number`; |
|**默认**|keepalive_requests 100;|
|**上下文**|http、server、location|
|**提示**|该指令在 0.8.0 版本中出现|

设置通过一个保持活动（keep-alive）连接可以提供的最大请求数。在发出的请求达到最大数量后，连接将被关闭。

### keepalive_timeout 

|\-|说明|
|:------|:------|
|**语法**|**keepalive_timeout** `timeout` `[header_timeout]`; |
|**默认**|keepalive_timeout 75s;|
|**上下文**|http、server、location|

第一个参数设置一个超时时间，keep-alive 客户端连接将在服务端保持打开状态。零值将禁用  keep-alive 客户端连接。可选的第二个参数在 **Keep-Alive: timeout=`time`** 响应头域中设置一个值。两个参数可能不同。

Mozilla 和 Konqueror 会识别 **Keep-Alive: timeout=`time` 头字段。MSIE 在大约在 60 秒钟内自行关闭 keep-alive 连接。

### large_client_header_buffers 

|\-|说明|
|:------|:------|
|**语法**|**large_client_header_buffers** `number size`; |
|**默认**|arge_client_header_buffers 4 8k;|
|**上下文**|http、server|

设置用于读取大客户端请求头的缓冲区的最大 `number`（数量）和 `size`（大小）。请求行不能超过一个缓冲区的大小，否则将返回 414（请求 URI 太长）错误给客户端。请求头字段也不能超过一个缓冲区的大小，否则将返回 400（错误请求）错误给客户端。缓冲区只能按需分配。默认情况下，缓冲区大小等于 8K 字节。如果在请求处理结束之后，连接被转换为 keep-alive 状态，这些缓冲区将被释放。

### limit_except 

|\-|说明|
|:------|:------|
|**语法**|**limit_except** `method ... { ... }`; |
|**默认**|——|
|**上下文**|location|

限制给定的 location 内允许的 HTTP 方法。`method` 参数可以是以下之一：`GET`、`HEAD`、`POST`、`PUT`、`DELETE`、`MKCOL`、`COPY`、`MOVE`、`OPTIONS`、`PROPFIND`、`PROPPATCH`、`LOCK`、`UNLOCK` 或 `PATCH`。允许 `GET` 方法也将使得 `HEAD`方法被允许。可以使用 [ngx_http_access_module](ngx_http_access_module.md) 和 [ngx_http_auth_basic_module](ngx_http_auth_basic_module.md) 模块指令来限制对其他方法的访问：

```nginx
limit_except GET {
    allow 192.168.1.0/32;
    deny  all;
}
```

请注意，这将限制访问除 `GET` 和 `HEAD` 之外的所有方法。

**待续……**

## 原文档
[http://nginx.org/en/docs/http/ngx_http_core_module.html](http://nginx.org/en/docs/http/ngx_http_core_module.html)
