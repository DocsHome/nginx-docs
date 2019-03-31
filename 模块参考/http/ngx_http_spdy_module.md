# ngx_http_spdy_module

- [已知问题](#issues)
- [示例配置](#example_configuration)
- [指令](#directives)
    - [spdy_chunk_size](#spdy_chunk_size)
    - [spdy_headers_comp](#spdy_headers_comp)
- [内嵌变量](#embedded_variables)

**该模块已被 `1.9.5` 中的 [ngx_http_v2_module](http://nginx.org/en/docs/http/ngx_http_v2_module.html) 模块所取代。**

`ngx_http_spdy_module` 模块为 [SPDY](http://www.chromium.org/spdy/spdy-protocol) 提供实验性支持。目前，SPDY 协议[草案 3.1](http://www.chromium.org/spdy/spdy-protocol/spdy-protocol-draft3-1)已实施。

> 在 1.5.10 版之前，已实施 SPDY 协议[草案 2](http://www.chromium.org/spdy/spdy-protocol/spdy-protocol-draft2)。

默认情况下不构建此模块，可在构建 nginx 时使用 `--with-http_spdy_module` 配置参数启用它。

<a id="issues"></a>

## 已知问题

该模块处于实验阶段，请注意风险。

当前的 SPDY 协议实现不支持**服务器推送**。

在 1.5.9 之前的版本中，SPDY 连接中的响应无法做到[速率限制](ngx_http_core_module.md#limit_rate)。

无论 [proxy_request_buffering](ngx_http_proxy_module.md#proxy_request_buffering)、[fastcgi_request_buffering](ngx_http_fastcgi_module.md#fastcgi_request_buffering)、[uwsgi_request_buffering](ngx_http_uwsgi_module.md#uwsgi_request_buffering) 和 [scgi_request_buffering](ngx_http_scgi_module.md#scgi_request_buffering) 指令为何值，都无法禁用客户端请求体缓冲。

<a id="example_configuration"></a>

## 示例配置

```nginx
server {
    listen 443 ssl spdy;

    ssl_certificate server.crt;
    ssl_certificate_key server.key;
    ...
}
```

> 请注意，为了在同一端口上同时接受 [HTTPS](ngx_http_ssl_module.md) 和 SPDY 连接，使用的 [OpenSSL](http://www.openssl.org/) 库应支持 **Next Protocol Negotiation** TLS 扩展，该扩展自 OpenSSL 1.0.1 版开始可用。

<a id="directives"></a>

## 指令

### spdy_chunk_size

|\-|说明|
|:------|:------|
|**语法**|**spdy_chunk_size** `size`;|
|**默认**|spdy_chunk_size 8k;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.5.9 版本中出现|

设置响应体[分块](http://www.chromium.org/spdy/spdy-protocol/spdy-protocol-draft2#TOC-Data-frames)的最大大小。值太低会导致更高的开销。由于 [HOL 阻塞](http://en.wikipedia.org/wiki/Head-of-line_blocking)，太高的值会破坏优先级。

### spdy_headers_comp

|\-|说明|
|:------|:------|
|**语法**|**spdy_headers_comp** `level`;|
|**默认**|spdy_headers_comp 0;|
|**上下文**|http、server|

设置响应头压缩级别（`level`），范围从 `1`（最快，压缩程度较低）到 `9`（最慢，压缩程度最佳）。特殊值 `0` 将关闭头压缩。

<a id="embedded_variables"></a>

## 内嵌变量

`ngx_http_spdy_module` 模块支持以下内嵌变量：

- `$spdy`

    SPDY 连接的 SPDY 协议版本，无则为空字符串

- `$spdy_request_priority`

    请求 SPDY 连接的优先级，无则为空字符串

## 原文档
[http://nginx.org/en/docs/http/ngx_http_spdy_module.html](http://nginx.org/en/docs/http/ngx_http_spdy_module.html)
