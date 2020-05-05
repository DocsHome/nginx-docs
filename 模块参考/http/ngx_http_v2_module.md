# ngx_http_v2_module

- [已知问题](#issues)
- [示例配置](#example_configuration)
- [指令](#directives)
    - [http2_body_preread_size](#http2_body_preread_size)
    - [http2_chunk_size](#http2_chunk_size)
    - [http2_idle_timeout](#http2_idle_timeout)
    - [http2_max_concurrent_pushes](#http2_max_concurrent_pushes)
    - [http2_max_concurrent_streams](#http2_max_concurrent_streams)
    - [http2_max_field_size](#http2_max_field_size)
    - [http2_max_header_size](#http2_max_header_size)
    - [http2_max_requests](#http2_max_requests)
    - [http2_push](#http2_push)
    - [http2_push_preload](#http2_push_preload)
    - [http2_recv_buffer_size](#http2_recv_buffer_size)
    - [http2_recv_timeout](#http2_recv_timeout)
- [内嵌变量](#embedded_variables)

`ngx_http_v2_module` 模块（1.9.5）提供对 [HTTP/2](https://tools.ietf.org/html/rfc7540) 的支持并取代了 [ngx_http_spdy_module](ngx_http_spdy_module.md) 模块。

默认不构建此模块，可使用 `--with-http_v2_module` 配置参数启用。

<a id="issues"></a>

## 已知问题

在 1.9.14 版本之前，无论 [proxy_request_buffering](ngx_http_proxy_module.md#proxy_request_buffering)、[fastcgi_request_buffering](ngx_http_fastcgi_module.md#fastcgi_request_buffering)、[uwsgi_request_buffering](ngx_http_uwsgi_module.md#uwsgi_request_buffering) 和 [scgi_request_buffering](ngx_http_scgi_module.md#scgi_request_buffering) 指令值如何设置，都无法禁用客户端请求体缓冲。

<a id="example_configuration"></a>

## 示例配置

```nginx
server {
    listen 443 ssl http2;

    ssl_certificate server.crt;
    ssl_certificate_key server.key;
}
```

请注意，通过 TLS 接受 HTTP/2 连接需要「应用层协议协商」（Application-Layer Protocol Negotiation，ALPN）TLS 扩展支持，该支持仅在 [OpenSSL](http://www.openssl.org/) 1.0.2 版本之后可用。使用「次协议协商」（Next Protocol Negotiation，NPN）TLS 扩展（自 OpenSSL 1.0.1 版本起可用）不能保证生效。

另外，如果 [ssl_prefer_server_ciphers](ngx_http_ssl_module.md#ssl_prefer_server_ciphers) 指令设置为 `on` 值，则应将密码配置为符合 [RFC 7540 中的附录 A 黑名单](https://tools.ietf.org/html/rfc7540#appendix-A) 并由客户端支持。

<a id="directives"></a>

## 指令

### http2_body_preread_size

|\-|说明|
|:------|:------|
|**语法**|**http2_body_preread_size** `size`;|
|**默认**|http2_body_preread_size 64k;|
|**上下文**|http、server|
|**提示**|该指令在 1.11.0 版本中出现|

设置在开始处理之前可能被保存的请求体中的每个请求的缓冲区大小（`size`）。

### http2_chunk_size

|\-|说明|
|:------|:------|
|**语法**|**http2_chunk_size** `size`;|
|**默认**|http2_chunk_size 8k;|
|**上下文**|http、server、location|

设置响应体切片的最大大小（`size`）。值太低会导致更高的开销。由于 [HOL 阻塞](http://en.wikipedia.org/wiki/Head-of-line_blocking)，过高的值会破坏优先级。

### http2_idle_timeout

|\-|说明|
|:------|:------|
|**语法**|**http2_idle_timeout** `time`;|
|**默认**|http2_idle_timeout 3m;|
|**上下文**|http、server|

设置连接关闭后的不活动超时时间。

### http2_max_concurrent_pushes

|\-|说明|
|:------|:------|
|**语法**|**http2_max_concurrent_pushes** `number`;|
|**默认**|http2_max_concurrent_pushes 10;|
|**上下文**|http、server|
|**提示**|该指令在 1.13.9 版本中出现|

限制一个连接的最大并发[推送](#http2_push)请求数。

### http2_max_concurrent_streams

|\-|说明|
|:------|:------|
|**语法**|**http2_max_concurrent_streams** `number`;|
|**默认**|http2_max_concurrent_streams 128;|
|**上下文**|http、server|

设置一个连接的最大并发 HTTP/2 流数量。

### http2_max_field_size

|\-|说明|
|:------|:------|
|**语法**|**http2_max_field_size** `size`;|
|**默认**|http2_max_field_size 4k;|
|**上下文**|http、server|

限制 [HPACK](https://tools.ietf.org/html/rfc7541) 压缩的请求头字段的最大大小（`size`）。该限制同样适用于字段名和值。请注意，如果使用了霍夫曼编码，则解压缩后的字段名和值字符串的实际大小可能会更大。对于大多数请求，默认限制应该足够。

### http2_max_header_size

|\-|说明|
|:------|:------|
|**语法**|**http2_max_header_size** `size`;|
|**默认**|http2_max_header_size 16k;|
|**上下文**|http、server|

限制 [HPACK](https://tools.ietf.org/html/rfc7541) 解压缩后整个请求头列表的最大大小（`size`）。对于大多数请求，默认限制应该足够。

### http2_max_requests

|\-|说明|
|:------|:------|
|**语法**|**http2_max_requests** `number`;|
|**默认**|http2_max_requests 1000;|
|**上下文**|http、server|
|**提示**|该指令在 1.11.6 版本中出现|

设置可以通过一个 HTTP/2 连接提供服务的最大请求数量（`number`）（包括[推送](#http2_push)请求），之后下一个客户端请求将导致连接关闭以及需要建立新连接。

要释放每个连接的内存分配，必须定期关闭连接。因此，设置过多的最大请求数可能会导致内存使用过多，因此不建议这样做。

### http2_push

|\-|说明|
|:------|:------|
|**语法**|**http2_push** `uri` &#124; `off`;|
|**默认**|http2_push off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.13.9 版本中出现|

抢先向指定的 `uri` 发送（[推送](https://tools.ietf.org/html/rfc7540#section-8.2)）请求以及对原始请求响应。仅处理有绝对路径的相对 URI，例如：

```nginx
http2_push /static/css/main.css;
```

`uri` 值可以包含变量。

可以在同一配置级别上指定几个 `http2_push` 指令。`off` 参数取消从其他配置级别继承的 `http2_push` 指令的作用。

### http2_push_preload

|\-|说明|
|:------|:------|
|**语法**|**http2_push_preload** `on` &#124; `off`;|
|**默认**|http2_push_preload off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.13.9 版本中出现|

启用将 **Link** 响应头字段中指定的[预加载链接](https://www.w3.org/TR/preload/#server-push-http-2)自动转换为[推送](https://tools.ietf.org/html/rfc7540#section-8.2)请求的功能。

### http2_recv_buffer_size

|\-|说明|
|:------|:------|
|**语法**|**http2_recv_buffer_size** `size`;|
|**默认**|http2_recv_buffer_size 256k;|
|**上下文**|http|

设置每个[工作进程](../核心功能.md#worker_processes)输入缓冲区的大小（`size`）。

### http2_recv_timeout

|\-|说明|
|:------|:------|
|**语法**|**http2_recv_timeout** `time`;|
|**默认**|http2_recv_timeout 30s;|
|**上下文**|http、server|

设置超时时间以从客户端获得更多数据，然后关闭连接。

<a id="embedded_variables"></a>

## 内嵌变量

`ngx_http_userid_module` 模块支持以下内嵌变量：

- `$http2`

    协商的协议标识符：`h2` 用于 TLS HTTP/2，`h2c` 用于在明文 TCP HTTP/2，否则为空字符串。

## 原文档

- [http://nginx.org/en/docs/http/ngx_http_v2_module.html](http://nginx.org/en/docs/http/ngx_http_v2_module.html)
