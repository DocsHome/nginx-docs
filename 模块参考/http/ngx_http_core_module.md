# ngx_http_core_module

- [指令](#directives)
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
- [内嵌变量](#embedded_variables)

<a id="directives"></a>

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

### limit_rate 

|\-|说明|
|:------|:------|
|**语法**|**limit_rate** `rate`; |
|**默认**|limit_rate 0;|
|**上下文**|http、server、location、location 中的 if|

限制客户端的响应传输速率。`rate` 以字节/秒为单位。零值将禁用速率限制。限制设置是针对每个请求，因此如果客户端同时打开两个连接，则整体速率将是指定限制的两倍。

也可以在 `$limit_rate` 变量中设置速率限制。根据某些条件来限制速率可能会有用：

```nginx
server {

    if ($slow) {
        set $limit_rate 4k;
    }

    ...
}
```

也可以在代理服务器响应的 **X-Accel-Limit-Rate** 头字段中设置速率限制。可以使用 [proxy_ignore_headers](ngx_http_proxy_module.md#proxy_ignore_headers)、[fastcgi_ignore_headers](ngx_http_fastcgi_module.md#fastcgi_ignore_headers)、[uwsgi_ignore_headers](ngx_http_uwsgi_module.md#uwsgi_ignore_headers) 和 [scgi_ignore_headers](ngx_http_scgi_module.md#scgi_ignore_headers) 指令禁用此功能。

### lingering_time 

|\-|说明|
|:------|:------|
|**语法**|**lingering_time** `time`; |
|**默认**|lingering_time 30s;|
|**上下文**|http、server、location|

当 [lingering_close](ngx_http_core_module.md#lingering_close) 生效时，该指令指定 nginx 处理（读取和忽略）来自客户端的额外数据的最长时间。之后，连接将被关闭，即使还有更多的数据。

### lingering_timeout 

|\-|说明|
|:------|:------|
|**语法**|**lingering_timeout** `time`; |
|**默认**|lingering_timeout 5s;|
|**上下文**|http、server、location|

当 [lingering_close](ngx_http_core_module.md#lingering_close) 生效时，该指令指定更多的客户端数据到达的最长等待时间。如果在此期间未收到数据，则关闭连接。否则，读取和忽略数据，nginx 再次开始等待更多的数据。**wait-read-ignore** 循环被重复，但不再由 [lingering_time](#lingering_time) 指令指定。

### listen 

|\-|说明|
|:------|:------|
|**语法**|**listen** `address[:port] [default_server] [ssl] [http2 \| spdy] [proxy_protocol] [setfib=number] [fastopen=number] [backlog=number] [rcvbuf=size] [sndbuf=size] [accept_filter=filter] [deferred] [bind] [ipv6only=on\|off] [reuseport] [so_keepalive=on\|off\|[keepidle]:[keepintvl]:[keepcnt]]`; <br /> **listen** `port [default_server] [ssl] [http2 \| spdy] [proxy_protocol] [setfib=number] [fastopen=number] [backlog=number] [rcvbuf=size] [sndbuf=size] [accept_filter=filter] [deferred] [bind] [ipv6only=on\|off] [reuseport] [so_keepalive=on\|off\|[keepidle]:[keepintvl]:[keepcnt]]`; <br/> **listen** `unix:path [default_server] [ssl] [http2 \| spdy] [proxy_protocol] [backlog=number] [rcvbuf=size] [sndbuf=size] [accept_filter=filter] [deferred] [bind] [so_keepalive=on\|off\|[keepidle]:[keepintvl]:[keepcnt]]`; |
|**默认**|listen *:80 \| *:8000;|
|**上下文**|server|

设置 IP 的 `address` （地址）和 `port` （端口），或服务器接受请求的 UNIX 域套接字的 `path` （路径）。可以同时指定 `addres` （地址）和 `port` （端口），也可以只指定 `address` （地址）或 `port` （端口）。`address` 也可以是主机名，例如：

```nginx
listen 127.0.0.1:8000;
listen 127.0.0.1;
listen 8000;
listen *:8000;
listen localhost:8000;
```
IPv6 地址（0.7.36）在方括号中指定：

```nginx
listen [::]:8000;
listen [::1];
```
UNIX 域套接字（0.8.21）用 `unix:` 前缀指定：

```nginx
listen unix:/var/run/nginx.sock;
```

如果只指定 `address`，则使用 80 端口。

如果指令不存在，那么如果 nginx 是以超级用户权限运行，则使用 `*:80`，否则使用 `*:8000`。

`default_server` 参数（如果存在）将使得服务器成为指定 `address:port` 对的默认服务器。如果没有指令有 `default_server` 参数，那么具有 `address:port` 对的第一个服务器将是该对的默认服务器。

> 在 0.8.21 之前的版本中，此参数简单地命名为 `default`。

`ssl` 参数（0.7.14）允许指定该端口上接受的所有连接都应该工作在 SSL 模式。这样可以为处理 HTTP 和 HTTPS 请求的服务器提供更紧凑的[配置](介绍/配置HTTPS服务器.md#single_http_https_server)。

`http2` 参数（1.9.5）配置端口接受 [HTTP/2](ngx_http_v2_module.md) 连接。通常，为了能够工作，还应该指定 `ssl` 参数，但也可以将 nginx 配置为接受没有 SSL 的 HTTP/2 连接。

`spdy` 参数（1.3.15 — 1.9.4）允许在此端口上接受 [SPDY](ngx_http_spdy_module.md) 连接。通常，为了能够工作，还应该指定 `ssl` 参数，但也可以将 nginx 配置为接受没有 SSL 的 SPDY 连接。

`proxy_protocol` 参数（1.5.12）允许指定此端口上接受的所有连接都应使用 [PROXY 协议](http://www.haproxy.org/download/1.5/doc/proxy-protocol.txt)。

`listen` 指令可以有特定于套接字相关系统调用的几个附加参数。这些参数可以在任何 `listen` 指令中指定，但对于给定的 `address:port` 只能使用一次。

> 在 0.8.21 之前的版本中，它们只能在 `listen` 指令中与默认参数一起指定。

- `setfib=number`

    此参数（0.8.44）设置相关联的路由表，监听套接字的 FIB（`SO_SETFIB` 选项）。目前只适用于 FreeBSD。
- `fastopen=number`

    为侦听套接字启用 **[TCP Fast Open](http://en.wikipedia.org/wiki/TCP_Fast_Open)** （1.5.8），并限制尚未完成三次握手的连接队列的最大长度。

    > 不要启用此功能，除非服务器可以一次处理接收多个[相同的 SYN 包的数据](https://tools.ietf.org/html/rfc7413#section-6.1)。
- `backlog=number`

    在 `listen()` 调用中设置限制挂起连接队列的最大长度的`backlog` 参数。默认情况下，FreeBSD、DragonFly BSD 和 macOS 上的 `backlog` 设置为 -1，在其他平台上设置为 511。
- `rcvbuf=size`

    设置侦听套接字的接收缓冲区大小（`SO_RCVBUF` 选项）。
- `sndbuf=size`

    设置侦听套接字的发送缓冲区大小（`SO_SNDBUF` 选项）。
- `accept_filter=filter`

    为侦听套接字设置接受过滤器（`SO_ACCEPTFILTER` 选项）的名称，该套接字将传入的连接在传递给 `accept()` 之前进行过滤。这只适用于 FreeBSD 和 NetBSD 5.0+。可设置值[dataready](http://man.freebsd.org/accf_data) 或 [httpready](http://man.freebsd.org/accf_http)。
- `deferred`
    
    指示在 Linux 上使用延迟 `accept()`（`TCP_DEFER_ACCEPT` 套接字选项）。
- `bind`

    指示为给定的 `address:port` 对单独进行 `bind()` 调用。这是有用的，因为如果有多个有相同端口但不同地址的 `listen` 指令，并且其中一个 `listen` 指令监听给定端口（`*:port`）的所有地址，则 nginx 将 `bind()` 应用到`*:port`。应该注意的是，在这种情况下将会进行 `getsockname()` 系统调用，以确定接受该连接的地址。如果使用 `setfib`、`backlog`、`rcvbuf`、`sndbuf`、`accept_filter`、`deferred`、`ipv6only` 或 `so_keepalive` 参数，那么对于给定的 `address:port` 对将始终进行单独的 `bind()` 调用。
- `ipv6only=ON|OFF`
    
    此参数（0.7.42）确定（通过 `IPV6_V6ONLY` 套接字选项）一个监听通配符地址 `[::]` 的 IPv6 套接字是否仅接受 IPv6 连接或 IPv6 和 IPv4 连接。此参数默认为开启。它只能在启动时设置一次。

    > 在 1.3.4 版本之前，如果省略该参数，则操作系统的设置将对于套接字产生影响。
- `reuseport`

    此参数（1.9.1）指示为每个工作进程创建一个单独的监听套接字（使用 `SO_REUSEPORT` 套接字选项），允许内核在工作进程之间分配传入的连接。目前只适用于 Linux 3.9+ 和 DragonFly BSD。

    > 不当地使用此选项可能会带来安全[隐患](http://man7.org/linux/man-pages/man7/socket.7.html)。
- `SO_KEEPALIVE=ON|OFF|[keepidle]:[keepintvl]:[keepcnt]`

    此参数（1.1.11）配置监听套接字的 **TCP keepalive** 行为。如果省略此参数，则操作系统的设置将对套接字产生影响。如果设置为 `on`，则套接字将打开 `SO_KEEPALIVE` 选项。如果设置为 `off`，则 `SO_KEEPALIVE` 选项将被关闭。一些操作系统支持在每个套接字上使用 `TCP_KEEPIDLE`、`TCP_KEEPINTVL` 和 `TCP_KEEPCNT` 套接字选项来设置 TCP keepalive 参数。在这样的系统上（目前为 Linux 2.4+、NetBSD 5+ 和 FreeBSD 9.0-STABLE），可以使用 `keepidle`、`keepintvl`和 `keepcnt` 参数进行配置。可以省略一个或两个参数，在这种情况下，相应套接字选项的系统默认设置将生效。例如，

    ```nginx
    SO_KEEPALIVE=30m::10
    ```

    将空闲超时（`TCP_KEEPIDLE`）设置为 30 分钟，将探测间隔（`TCP_KEEPINTVL`）设置为系统默认值，并将探测数量（`TCP_KEEPCNT`）设置为 10 个探测。

示例：

```nginx
listen 127.0.0.1 default_server accept_filter=dataready backlog=1024;
```
### location

|\-|说明|
|:------|:------|
|**语法**|**location** `[ = \| ~ \| ~* \| ^~ ] uri { ... }`; <br /> **location** `@name { ... }`; |
|**默认**|——|
|**上下文**|server、location|

根据请求 URI 设置配置。

在解码以 `％XX` 形式编码的文本，解析对相对路径组件 `.` 和`..` 的引用并且将两个或更多个相邻斜线[压缩](#merge_slashes)成单斜线之后，对规范化的 URI 执行匹配。

location 可以由前缀字符串定义，也可以由正则表达式定义。正则表达式前面使用`~*`修正符（用于不区分大小写的匹配）或 `~` 修正符（用于区分大小写的匹配）指定。要查找匹配给定请求的 location，nginx 首先检查使用前缀字符串（前缀 location）定义的 location。期间，前缀最长的 location 被匹配选中并记住。然后按照它们在配置文件中出现的顺序检查正则表达式。正则表达式的搜索将在第一次匹配时终止，并使用相应的配置。如果找不到正则表达式的匹配，则使用先前记住的前缀 location 的配置。

location 块可以嵌套，除了下面提到的一些例外。

对于不区分大小写的操作系统，如 macOS 和 Cygwin，与前缀字符串匹配忽略大小写（0.7.7）。但是，比较仅限于一个字节的区域设置。

正则表达式可以包含捕获（0.7.40），之后可以在其他指令中使用。

如果最长匹配的前缀 location 具有 `^~` 修正符，则不检查正则表达式。

另外，使用 `=` 修正符可以使 URI 和 location 的匹配精确。如果找到完全匹配，则搜索结束。例如，如果 `/` 请求频繁，那么定义 `location=/` 会加快这些请求的处理速度，因为搜索在第一次比较之后会立即终止。这样的 location 不能包含嵌套 location。

> 从 0.7.1 到 0.8.41 版本，如果请求与没有 `=` 和 `^~` 修正符的前缀 location 匹配，则搜索也会终止，并且不再检查正则表达式。

下面举一个例子来说明：

```nginx
location = / {
    [ configuration A ]
}

location / {
    [ configuration B ]
}

location /documents/ {
    [ configuration C ]
}

location ^~ /images/ {
    [ configuration D ]
}

location ~* \.(gif|jpg|jpeg)$ {
    [ configuration E ]
}
```

`/` 请求将与配置 A 匹配，`/index.html` 请求将匹配配置 B，`/documents/document.html` 请求将匹配配置 C，`/images/1.gif` 请求将匹配配置 D，`/documents/1.jpg` 请求将匹配配置 E。

`@` 前缀定义了一个命名 location。这样的 location 不用于常规的请求处理，而是用于请求重定向。它们不能嵌套，也不能包含嵌套的 location。

如果某个 location 由以斜杠字符结尾的前缀字符串定义，并且请求由 [proxy_pass](ngx_http_proxy_module.md#proxy_pass)、[fastcgi_pass](ngx_http_fastcgi_module.md#fastcgi_pass)、[uwsgi_pass](ngx_http_uwsgi_module.md#uwsgi_pass)、[scgi_pass](ngx_http_scgi_module.md#scgi_pass) 或 [memcached_pa​​ss](ngx_http_memcached_module.md#memcached_pass) 中的一个进行处理，则会执行特殊处理。为了响应 URI 为该字符串的请求，但没有以斜杠结尾，带有 301 代码的永久重定向将返回所请求的 URI，并附上斜线。如果不需要，可以像以下这样定义 URI 和 location 的精确匹配：

```nginx
location /user/ {
    proxy_pass http://user.example.com;
}

location = /user {
    proxy_pass http://login.example.com;
}
```

### log_not_found

|\-|说明|
|:------|:------|
|**语法**|**log_not_found** `on \| off`; |
|**默认**|log_not_found on;|
|**上下文**|http、server、location|

启用或禁用将文件未找到错误记录到 [error_log](#error_log) 中。

### log_subrequest

|\-|说明|
|:------|:------|
|**语法**|**log_subrequest** `on \| off`; |
|**默认**|log_subrequest off;|
|**上下文**|http、server、location|

启用或禁用将子请求记录到 [access_log](ngx_http_log_module.md#access_log) 中。

### max_ranges

|\-|说明|
|:------|:------|
|**语法**|**merge_slashes** `number`; |
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 1.1.2 版本中出现|

限制 byte-range 请求中允许的最大范围数。如果没有指定字节范围，则处理超出限制的请求。 默认情况下，范围的数量不受限制。零值将完全禁用 byte-range 支持。

### merge_slashes

|\-|说明|
|:------|:------|
|**语法**|**merge_slashes** `on \| off`; |
|**默认**|merge_slashes on;|
|**上下文**|http、server|

启用或禁用将 URI 中两个或多个相邻斜线压缩为单斜线。

请注意，压缩对于正确匹配前缀字符串和正则表达式的 location 非常重要。没有它，将不匹配 `//scripts/one.php` 请求：

```nginx
location /scripts/ {
    ...
}
```

并可能被作为一个静态文件处理。因此它需要被转换成 `/scripts/one.php`。

因为 base64 在内部使用 `/` 字符，所以如果 URI 包含 base64 编码的名称，则可能需要关闭压缩。但是，出于安全考虑，最好不要关闭压缩。

如果该指令是在 [server](#server) 级别指定的，则仅在 server 是默认 server 时才使用该指令。指定的值也适用于监听相同地址和端口的所有虚拟服务器。

### msie_padding

|\-|说明|
|:------|:------|
|**语法**|**msie_padding** `on \| off`; |
|**默认**|msie_padding on;|
|**上下文**|http、server、location|

启用或禁用向状态超过 400 的 MSIE 客户端响应添加注释以将响应大小增加到 512 字节。

### msie_refresh

|\-|说明|
|:------|:------|
|**语法**|**msie_refresh** `on \| off`; |
|**默认**|msie_refresh off;|
|**上下文**|http、server、location|

启用或禁用发布刷新替代 MSIE 客户端重定向。

### open_file_cache

|\-|说明|
|:------|:------|
|**语法**|**open_file_cache** `off`; <br /> **open_file_cache** `max=N [inactive=time]`;|
|**默认**|open_file_cache off;|
|**上下文**|http、server、location|

配置一个缓存，可以存储：

- 打开文件描述符、大小和修改时间
- 有关目录是否存在信息
- 文件查找错误，如**找不到文件**、**没有读取权限**等

> 应该通过 [open_file_cache_errors](#open_file_cache_errors) 指令分别启用缓存错误。

该指令有以下参数：

- `max`

    设置缓存中元素的最大数量。在缓存溢出时，最近最少使用的（LRU）元素将被移除
- `inactive`

    定义一个时间，在这个时间之后，元素在缓存中将被删除，默认是 60 秒
- `off`
    
    禁用缓存

示例：

```nginx
open_file_cache          max=1000 inactive=20s;
open_file_cache_valid    30s;
open_file_cache_min_uses 2;
open_file_cache_errors   on;
```

### open_file_cache_errors

|\-|说明|
|:------|:------|
|**语法**|**open_file_cache_errors** `off` \| `on`;|
|**默认**|open_file_cache_errors off;|
|**上下文**|http、server、location|

通过 [open_file_cache](#open_file_cache) 启用或禁用文件查找错误缓存。

### open_file_cache_min_uses

|\-|说明|
|:------|:------|
|**语法**|**open_file_cache_min_uses** `number`;|
|**默认**|open_file_cache_min_uses 1;|
|**上下文**|http、server、location|

设置由 [open_file_cache](#open_file_cache) 指令的 `inactive` 参数配置的时间段内文件访问的最小 `number` （次数），这是文件描述符在缓存中保持打开状态所必需的。

### open_file_cache_valid

|\-|说明|
|:------|:------|
|**语法**|**open_file_cache_valid** `time`;|
|**默认**|open_file_cache_valid 60s;|
|**上下文**|http、server、location|

设置 [open_file_cache](#open_file_cache) 元素应该验证的时间。

### output_buffers

|\-|说明|
|:------|:------|
|**语法**|**output_buffers** `number size`;|
|**默认**|output_buffers 2 32k;|
|**上下文**|http、server、location|

设置从磁盘读取响应缓冲区的 `number` （数量）和 `size` （大小）。

> 在 1.9.5 版本之前，默认值是 `1 32k`。

### port_in_redirect

|\-|说明|
|:------|:------|
|**语法**|**port_in_redirect** `on` \| `off`;|
|**默认**|port_in_redirect on;|
|**上下文**|http、server、location|

启用或禁用指定由 nginx 发出的[绝对](#absolute_redirect)重定向中的端口。

> 在重定向中使用的主服务器名称由 [server_name_in_redirect](#server_name_in_redirect) 指令控制。

### postpone_output

|\-|说明|
|:------|:------|
|**语法**|**postpone_output** `size`;|
|**默认**|postpone_output 1460;|
|**上下文**|http、server、location|

如果指定的话，客户端数据的传输将被推迟，直到 nginx 至少有 `size` 字节的数据要发送。零值将禁止延迟数据传输。

### read_ahead

|\-|说明|
|:------|:------|
|**语法**|**read_ahead** `sizef`;|
|**默认**|read_ahead 0;|
|**上下文**|http、server、location|

设置使用文件时内核的预读数量。

在 Linux 上，使用 `posix_fadvise`（`0, 0, 0, POSIX_FADV_SEQUENTIAL`）系统调用，因此 `size` 参数将被忽略。

在 FreeBSD 上，使用自 FreeBSD 9.0-CURRENT 后支持的 `fcntl`（`O_READAHEAD, size`）系统调用。FreeBSD 7 需要[打补丁](http://sysoev.ru/freebsd/patch.readahead.txt)。

### recursive_error_pages

|\-|说明|
|:------|:------|
|**语法**|**recursive_error_pages** `on` \| `off`;|
|**默认**|reset_timedout_connection off;|
|**上下文**|http、server、location|

启用或禁用使用 [error_page](#error_page) 指令执行多个重定向。这种重定向的数量是[有限](#internal)的。

### request_pool_size

|\-|说明|
|:------|:------|
|**语法**|**request_pool_size** `size`;|
|**默认**|request_pool_size 4k;|
|**上下文**|http、server|

允许精确调整每个请求的内存分配。该指令对性能影响最小，一般不应该使用。

### reset_timedout_connection

|\-|说明|
|:------|:------|
|**语法**|**reset_timedout_connection** `on` \| `off`;|
|**默认**|reset_timedout_connection off;|
|**上下文**|http、server、location|

启用或禁用重置超时连接。重置过程如下。在关闭一个套接字之前，`SO_LINGER` 选项超时值被设置为 0。当套接字关闭时，TCP RST 被发送到客户端，并且释放该套接字占用的所有内存。这有助于避免长时间持有一个缓冲区已经被填充 FIN_WAIT1 状态的已关闭套接字。

应该注意，超时的 keep-alive 连接被正常关闭。

### resolver

|\-|说明|
|:------|:------|
|**语法**|**resolver** `address ... [valid=time] [ipv6=on|off]`;|
|**默认**|——|
|**上下文**|http、server、location|

将用于解析 upstream 服务器名称的名称服务器配置进指定的地址，例如：

```nginx
resolver 127.0.0.1 [:: 1]:5353;
```

地址可以指定为域名或 IP 地址，也可以指定一个可选的端口（1.3.1，1.2.2）。如果没有指定端口，则使用端口 53。名称服务器以轮询方式查询。

> 在 1.1.7 版本之前，只能配置一个名称服务器。从 1.3.1 和 1.2.2 版本开始，支持使用 IPv6 地址来指定名称服务器。

默认情况下，nginx 将在解析时查找 IPv4 和 IPv6 地址。如果不想查找 IPv6 地址，则可以指定 `ipv6=off` 参数。

> 从 1.5.8 版本开始，支持将名称解析为 IPv6 地址。

默认情况下，nginx 使用响应的 TTL 值缓存回复。可选的 `valid` 参数可以覆盖它：

```nginx
resolver 127.0.0.1 [:: 1]:5353 valid=30s;
```

> 在 1.1.9 版本之前，缓存时间是不能调整的，nginx 总是缓存 5 分钟的回复。

> 为了防止 DNS 欺骗，建议在安全的可信任本地网络中配置 DNS 服务器。

### satisfy

|\-|说明|
|:------|:------|
|**语法**|**satisfy** `all` \| `any`;|
|**默认**|satisfy all;|
|**上下文**|http、server、location|

如果所有（全部）或至少一个（任意一个） [ngx_http_access_module](ngx_http_access_module.md)、[ngx_http_auth_basic_module](ngx_http_auth_basic_module.md)、[ngx_http_auth_request_module](ngx_http_auth_request_module.md) 或 [ngx_http_auth_jwt_module](ngx_http_auth_jwt_module.md) 模块允许访问，则允许访问。

示例：

```nginx
location / {
    satisfy any;

    allow 192.168.1.0/32;
    deny  all;

    auth_basic           "closed site";
    auth_basic_user_file conf/htpasswd;
}
```

### send_lowat

|\-|说明|
|:------|:------|
|**语法**|**send_lowat** `size`;|
|**默认**|send_lowat 0;|
|**上下文**|http、server、location|

如果指令设置为非零值，nginx 将尝试通过使用 [kqueue](http://nginx.org/en/docs/events.html#kqueue) 方法的 `NOTE_LOWAT` 标志或`SO_SNDLOWAT` 套接字选项来最小化客户端套接字上的发送操作数。在这两种情况下都使用到了指定的 `size`。

该指令在 Linux、Solaris 和 Windows 上被忽略。

### send_timeout

|\-|说明|
|:------|:------|
|**语法**|**send_timeout** `time`;|
|**默认**|send_timeout 60s;|
|**上下文**|http、server、location|

设置向客户端发送响应的超时时间。超时设置只限定在两次连续的写入操作之间，而不是用于整个响应的传输。如果客户端在此时间内没有收到任何内容，则连接将被关闭。

### sendfile

|\-|说明|
|:------|:------|
|**语法**|**sendfile** `on` \| `off`;|
|**默认**|sendfile off;|
|**上下文**|http、server、location、location 中的 if|

启用或禁用 `sendfile()`。

从 nginx 0.8.12 和 FreeBSD 5.2.1 开始，可以用 [aio](#aio) 来为 `sendfile()` 预加载数据：

```nginx
location /video/ {
    sendfile       on;
    tcp_nopush     on;
    aio            on;
}
```

在此配置中，使用 `SF_NODISKIO` 标志调用 `sendfile()`，使其不会阻塞磁盘 I/O，而是以报告数据不在内存中的方式代替。然后 nginx 通过读取一个字节来启动异步数据加载。在第一次读取时，FreeBSD 内核会将文件的第一个 128K 字节加载到内存中，但是下一次读取只能以 16K 块加载数据。可以使用 [read_ahead](#read_ahead) 指令进行修改。

> 在 1.7.11 版本之前，可以使用 `aio sendfile` 来启用预加载。

### sendfile_max_chunk 

|\-|说明|
|:------|:------|
|**语法**|**sendfile_max_chunk ** `size`;|
|**默认**|sendfile_max_chunk 0;|
|**上下文**|http、server、location|

设置为非零值时，可限制单个 `sendfile()` 调用时传输的数据量。如果没有限制，一个快速连接可能会完全占用工作进程。

### server  

|\-|说明|
|:------|:------|
|**语法**|**server** `{ ... }`;|
|**默认**|——|
|**上下文**|http|

设置虚拟服务器的配置。基于 IP（基于 IP 地址）和基于名称（基于 `Host` 请求头字段）的虚拟服务器之间没有明确的界限。相反，[listen](#listen) 指令描述应接受服务器连接的所有地址和端口，[server_name](#server_name) 指令列出所有服务器名称。[如何处理请求](http://nginx.org/en/docs/http/request_processing.html)文档中提供了配置示例。

### server_name  

|\-|说明|
|:------|:------|
|**语法**|**server_name** `name ...`;|
|**默认**|server_name "";|
|**上下文**|server|

设置虚拟服务器名称，例如：

```nginx
server {
    server_name example.com www.example.com;
}
```

第一个名字将成为主服务器名称。

服务器名称可以包含一个星号（`*`）以代替名称的第一部分或最后一部分：

```nginx
server {
    server_name example.com *.example.com www.example.*;
}
```

这样的名称被称为通配符名称。

上面提到的前两个名字可以合并成一个：

```nginx
server {
    server_name .example.com;
}
```

也可以在服务器名称中使用正则表达式，在名称前面加上波浪号（`〜`）：

```nginx
server {
    server_name www.example.com ~^www\d+\.example\.com$;
}
```

正则表达式可以包含之后用于其他指令的捕获（0.7.40）：

```nginx
server {
    server_name ~^(www\.)?(.+)$;

    location / {
        root /sites/$2;
    }
}

server {
    server_name _;

    location / {
        root /sites/default;
    }
}
```

在正则表达式中命名捕获创建变量（0.8.25），之后可在其他指令中使用：

```nginx
server {
    server_name ~^(www\.)?(?<domain>.+)$;

    location / {
        root /sites/$domain;
    }
}

server {
    server_name _;

    location / {
        root /sites/default;
    }
}
```

如果指令参数设置为 `$hostname`（0.9.4），则将替换为机器的主机名。

也可以指定一个空的服务器名称（0.7.11）：

```nginx
server {
    server_name www.example.com "";
}
```

它允许这个服务器对给定的 address:port 对处理没有 `Host` 头的请求，而不是默认的服务器。这是默认设置。

> 在 0.8.48 之前，默认使用机器的主机名。

在按名称搜索虚拟服务器的过程中，如果名称与多个指定变体相匹配（例如，通配符名称和正则表达式匹配），将按照以下优先顺序选择第一个匹配变体：

1. 确切的名字
2. 以星号开头的最长通配符名称，例如 `*.example.com`
3. 以星号结尾的最长通配符名称，例如 `mail.*`
4. 第一个匹配的正则表达式（按照配置文件中的出现顺序）

服务器名称的详细描述在单独的[服务器名称](http://nginx.org/en/docs/http/server_names.html)文档中提供。

### server_name_in_redirect   

|\-|说明|
|:------|:------|
|**语法**|**server_name** `on` \| `off`;|
|**默认**|server_name_in_redirect off;|
|**上下文**|http、server、location|

启用或禁用在由 nginx 发出的 [absolute](#absolute_redirect) 指令中使用由 [server_name](#server_name) 指令指定的主服务器名称。当禁用主服务器名称时，将使用 `Host` 请求头字段中的名称。如果此字段不存在，则使用服务器的 IP 地址。

重定向中使用端口由 [port_in_redirect](#port_in_redirect) 指令控制。

### server_names_hash_bucket_size    

|\-|说明|
|:------|:------|
|**语法**|**server_names_hash_bucket_size** `size`;|
|**默认**|server_names_hash_bucket_size 32|64|128;|
|**上下文**|http|

设置服务器名称哈希表的存储桶大小。默认值取决于处理器缓存行的大小。设置哈希表的细节在单独的[文档](http://nginx.org/en/docs/hash.html)中提供。

### server_names_hash_max_size    

|\-|说明|
|:------|:------|
|**语法**|**server_names_hash_max_size** `size`;|
|**默认**|server_names_hash_max_size 512;|
|**上下文**|http|

设置服务器名称哈希表的最大大小。设置哈希表的细节在单独的[文档]((http://nginx.org/en/docs/hash.html))中提供。

### server_tokens    

|\-|说明|
|:------|:------|
|**语法**|**server_tokens** `on` \| `off` \| `build` \| `string`;|
|**默认**|server_tokens on;|
|**上下文**|http、server、location|

在错误页面和 `Server` 响应头字段中启用或禁用发送 nginx 版本。

`build` 参数（1.11.10）能够发送构建名称以及 nginx 版本。

此外，作为我们的[商业订阅](http://nginx.com/products/?_ga=2.14041591.1300915338.1513355851-1890203964.1497190280)的一部分，从1.9.13 版本开始，可以使用带有变量的字符串显式设置错误页面上的签名和 `Server` 响应头字段值。指定空字符串将禁用 `Server` 字段的发送。

### tcp_nodelay    

|\-|说明|
|:------|:------|
|**语法**|**tcp_nodelay** `on` \| `off`;|
|**默认**|tcp_nodelay on;|
|**上下文**|http、server、location|

启用或禁用 `TCP_NODELAY` 选项的使用。该选项仅在连接转换到 keep-alive 状态时启用。

### tcp_nopush    

|\-|说明|
|:------|:------|
|**语法**|**tcp_nopush** `on` \| `off`;|
|**默认**|tcp_nopush off;|
|**上下文**|http、server、location|

启用或禁用在 FreeBSD 上使用 `TCP_NOPUSH` 套接字选项或在 Linux 上使用 `TCP_CORK` 套接字选项。这些选项只有在使用 [sendfile](#sendfile) 时才能使用。启用该选项将允许：

- 在 Linux 和 FreeBSD 4 上，在同一包中可发送响应头和文件开头。
- 以完整包的方式发送一个文件

### try_files

|\-|说明|
|:------|:------|
|**语法**|**try_files** `file ... uri`; <br /> **try_files** `file ... =code`;|
|**默认**|——|
|**上下文**|server、location|

以指定顺序检查文件是否存在，并使用第一个找到的文件进行请求处理。处理将在当前上下文中执行。指向文件的路径根据 [root](#root) 和 [alias](#alias) 指令从 `file` 参数构造。可以通过在名称末尾指定斜线来检查目录是否存在，例如，`$URI/`。如果找不到任何文件，则内部重定向将指向最后一个参数中指定的 `uri`。例如：

```nginx
location /images/ {
    try_files $uri /images/default.gif;
}

location = /images/default.gif {
    expires 30s;
}
```

最后一个参数也可以指向一个命名的 location ，如以下示例。从 0.7.51 版本开始，最后一个参数也可以是一个 `code`：

```nginx
location / {
    try_files $uri $uri/index.html $uri.html =404;
}
```

代理 Mongrel 示例：

```nginx
location / {
    try_files /system/maintenance.html
              $uri $uri/index.html $uri.html
              @mongrel;
}

location @mongrel {
    proxy_pass http://mongrel;
}
```

Drupal/FastCGI 示例：

```nginx
location / {
    try_files $uri $uri/ @drupal;
}

location ~ \.php$ {
    try_files $uri @drupal;

    fastcgi_pass ...;

    fastcgi_param SCRIPT_FILENAME /path/to$fastcgi_script_name;
    fastcgi_param SCRIPT_NAME     $fastcgi_script_name;
    fastcgi_param QUERY_STRING    $args;

    ... other fastcgi_param's
}

location @drupal {
    fastcgi_pass ...;

    fastcgi_param SCRIPT_FILENAME /path/to/index.php;
    fastcgi_param SCRIPT_NAME     /index.php;
    fastcgi_param QUERY_STRING    q=$uri&$args;

    ... other fastcgi_param's
}
```

在以下示例中

```nginx
location / {
    try_files $uri $uri/ @drupal;
}
```

try_files 指令相当于

```nginx
location / {
    error_page 404 = @drupal;
    log_not_found off;
}
```

还有一个示例

```nginx
location ~ \.php$ {
    try_files $uri @drupal;

    fastcgi_pass ...;

    fastcgi_param SCRIPT_FILENAME /path/to$fastcgi_script_name;

    ...
}
```

在将请求传递给 FastCGI 服务器之前，try_files 将检查 PHP 文件是否存在。

Wordpress 与 Joomla 示例：

```nginx
location / {
    try_files $uri $uri/ @wordpress;
}

location ~ \.php$ {
    try_files $uri @wordpress;

    fastcgi_pass ...;

    fastcgi_param SCRIPT_FILENAME /path/to$fastcgi_script_name;
    ... other fastcgi_param's
}

location @wordpress {
    fastcgi_pass ...;

    fastcgi_param SCRIPT_FILENAME /path/to/index.php;
    ... other fastcgi_param's
}
```

### types_hash_bucket_size

|\-|说明|
|:------|:------|
|**语法**|**types_hash_bucket_size** `size`;|
|**默认**|types_hash_bucket_size 64;|
|**上下文**|http、server、location|

设置类型哈希表桶大小。设置哈希表的细节在单独的[文档](http://nginx.org/en/docs/hash.html)中有提供。

> 在版 1.5.13 本之前，默认值取决于处理器缓存行的大小。

### types_hash_max_size

|\-|说明|
|:------|:------|
|**语法**|**types_hash_max_size** `size`;|
|**默认**|types_hash_max_size 1024;|
|**上下文**|http、server、location|

设置类型哈希表的最大大小。设置哈希表的细节在单独的[文档](http://nginx.org/en/docs/hash.html)中有提供。

### underscores_in_headers

|\-|说明|
|:------|:------|
|**语法**|**underscores_in_headers** `on` \| `off`;|
|**默认**|underscores_in_headers off;|
|**上下文**|http、server|

启用或禁用在客户端请求头字段中使用下划线。当禁用下划线时，名称中包含下划线的请求头字段将被标记为无效，并受制于 [ignore_invalid_headers](#ignore_invalid_headers) 指令。

如果该指令是在 [server](#server) 级别指定，则仅在 server 是默认 server 时才使用该指令。指定的值也适用于监听相同地址和端口的所有虚拟服务器。

### variables_hash_bucket_size

|\-|说明|
|:------|:------|
|**语法**|**variables_hash_bucket_size** `size`;|
|**默认**|variables_hash_bucket_size size;|
|**上下文**|http|

设置变量哈希表桶大小。设置哈希表的细节在单独的[文档](http://nginx.org/en/docs/hash.html)中有提供。

### variables_hash_max_size 

|\-|说明|
|:------|:------|
|**语法**|**variables_hash_max_size** `size`;|
|**默认**|variables_hash_max_size  1024;|
|**上下文**|http|

设置变量哈哈希表的最大大小。设置哈希表的细节在单独的[文档](http://nginx.org/en/docs/hash.html)中有提供。

> 在 1.5.13 版本之前，默认值是 512。

<a id="embedded_variables"></a>

## 内嵌变量

`ngx_http_core_module` 模块支持嵌入式变量名称与 Apache 服务器变量匹配。首先，这些是出现在客户端请求头字段的变量，例如 `$http_user_agent`、`$http_cookie` 等等。还有其他变量：

- `$arg_name`

    请求行中的 `name` 参数

- `$args`

    请求行中的参数

- `$binary_remote_addr`

    客户端地址以二进制形式表示，值的长度对于 IPv4 地址总是 4 个字节，对于 IPv6 地址总是 16 个字节
- `$body_bytes_sent`

    发送到客户端的字节数，不包括响应头。此变量与 `mod_log_config` Apache 模块的 `％B` 参数兼容

- `$bytes_sent`

    发送到客户端的字节数（1.3.8、1.2.5）

- $connection

    连接序列号（1.3.8、1.2.5）

- `$connection_requests`

    当前通过连接请求的请求数（1.3.8、1.2.5）

- `$connect_length`

    `Content-Length` 请求头字段

- `$content_type`

    `Content-Type` 请求头字段

- `$cookie_name`

    名称为 `name` 的 cookie

- `$document_root`

    根目录或别名指令的当前请求的值

- `$document_uri`
    
    与 `$uri` 相同

- `$host`

    按照以下优先顺序：来自请求行的主机名，来自 `Host` 请求头字段的主机名，或与请求匹配的服务器名

- `$hostname`

    主机名

- `$http_name`

    任意请求头字段,变量名称的最后一部分是将字段名称转换为小写，并用破折号替换为下划线

- `$https`

    如果连接以 SSL 模式运行，则为 `on`，否则为空字符串

- `$is_args`

    如果请求行有参数则为 `?`，否则为空字符串

- `$limit_rate`

    设置这个变量可以实现响应速率限制，见 [limit_rate](#limit_rate)

- `$msec`

    当前时间以毫秒为单位（1.3.9、1.2.6）

- `$nginx_version`

    nginx 版本

- `$pid`

    工作进程的 PID

- `$pipe`

    如果请求是管道模式则为 `p`，否则为 `.`（1.3.12、1.2.7）

- `$proxy_protocol_addr`

    来自 PROXY 协议头的客户端地址，否则为空字符串（1.5.12）
    
    要在 [listen](#listen) 指令中设置 `proxy_protocol` 参数，必须先启用 PROXY 协议。

- `$proxy_protocol_port`  

    PROXY 协议头中的客户端口，否则为空字符串（1.11.0）

    要在 [listen](#listen) 指令中设置 `proxy_protocol` 参数，必须先启用 PROXY 协议。

- `$query_string`

    与 `$args` 相同

- `$realpath_root`

    与当前请求的 [root](#root) 或 [alias](#alias) 指令值相对应的绝对路径名，所有符号链接都将解析为实际路径

- `$remote_addr`

    客户端地址

- `$remote_port`

    客户端端口

- `$remote_user`

    基本身份验证提供的用户名

- `$request`

    完整的原始请求行

- `$request_body`

    请求正文

    当请求正文被读取到[内存缓冲区](#client_body_buffer_size)时，变量的值在由[proxy_pass](gx_http_proxy_module.md#proxy_pass)、[fastcgi_pass](ngx_http_fastcgi_module.md#fastcgi_pass)、[uwsgi_pass](ngx_http_uwsgi_module.md#uwsgi_pass) 和 [scgi_pass](ngx_http_scgi_module.md#scgi_pass) 指令处理的 location 中可用。

- `$request_body_file`

    带有请求正文的临时文件的名称

    在处理结束时，文件需要被删除。想始终将请求主体写入文件中，需要启用 [client_body_in_file_only](#client_body_in_file_only)。当临时文件的名称在代理请求中或在向 FastCGI/uwsgi/SCGI 服务器的请求中传递时，应该分别通过 [proxy_pass_request_body off](ngx_http_proxy_module.md#proxy_pass_request_body)、[fastcgi_pass_request_body off](ngx_http_fastcgi_module.md#fastcgi_pass_request_body)、[uwsgi_pass_request_body off](ngx_http_uwsgi_module.md#uwsgi_pass_request_body) 或 [scgi_pass_request_body off](ngx_http_scgi_module.md#scgi_pass_request_body) 指令禁用传递请求正文。

- `$request_completion`

    如果请求已经完成，则返回 `OK`，否则返回空字符串

- `$request_filename`

    当前请求的文件路径，基于 [root](#root) 或 [alias](#alias) 指令以及请求 URI

- `$request_id`

    由 16 个随机字节生成的唯一请求标识符，以十六进制表示（1.11.0）

- `$request_length`

    请求长度（包括请求行、头部和请求体）（1.3.12、1.2.7）

- `$request_method`

    请求方法，通常为 `GET` 或 `POST`

- `$request_time`

    请求处理时间以毫秒为单位（1.3.9、1.2.6）。自客户端读取第一个字节的时间起

- `$request_uri`

    完整的原始请求 URI（带参数）

- `$scheme`

    请求模式，`http` 或 `https`

- `$sent_http_name`

    任意响应头字段。变量名称的最后一部分是将字段名称转换为小写，并用破折号替换为下划线

- `$sent_trailer_name`

    响应结束时发送的任意字段（1.13.2）。变量名称的最后一部分是将字段名称转换为小写，并用破折号替换为下划线

- `$server_addr`

    接受请求的服务器地址

    通常需要一个系统调用来计算这个变量的值。为了避免系统调用，[listen](#listen) 指令必须指定地址并使用 `bind` 参数。

- `$server_name`

    接受请求的服务器名称

- `$server_port`

    接受请求的服务器端口

- `$server_protocol`

    请求协议，通常为 `HTTP/1.0`、`HTTP/1.1` 或 [HTTP/2.0](ngx_http_v2_module.md)

- `$status`

    响应状态（1.3.2、1.2.2）

- `$tcpinfo_rtt`、`$tcpinfo_rttvar`、`$tcpinfo_snd_cwnd`、`$tcpinfo_rcv_space`

    有关客户端 TCP 连接的信息。在支持 `TCP_INFO` 套接字选项的系统上可用

- `$time_iso8601`

    本地时间采用 ISO 8601 标准格式（1.3.12、1.2.7）

- `$time_local`

    通用日志格式（Common Log Format）中的本地时间（1.3.12、1.2.7）

- `$uri`

    [规范化](#location)过的当前请求 URI

    `$uri` 的值可能在请求期间会改变

## 原文档
[http://nginx.org/en/docs/http/ngx_http_core_module.html](http://nginx.org/en/docs/http/ngx_http_core_module.html)
