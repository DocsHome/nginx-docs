# ngx_http_slice_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [slice](#slice)
- [内嵌变量](#embedded_variables)

`ngx_http_slice_module` 模块（1.9.8）是一个过滤器，它将请求拆分为子请求，每个子请求都返回一定范围的响应。该过滤器针对大响应缓存更加有效。

默认情况下不构建此模块，可在构建 nginx 时使用 `--with-http_slice_module` 配置参数启用。

<a id="example_configuration"></a>

## 示例配置

```nginx
location / {
    slice             1m;
    proxy_cache       cache;
    proxy_cache_key   $uri$is_args$args$slice_range;
    proxy_set_header  Range $slice_range;
    proxy_cache_valid 200 206 1h;
    proxy_pass        http://localhost:8000;
}
```

在此示例中，响应被拆分为 1M 大小的可缓存切片。

<a id="directives"></a>

## 指令

### slice

|\-|说明|
|:------|:------|
|**语法**|**slice** `size`;|
|**默认**|slice 0;|
|**上下文**|http、server、location|

设置切片的 `size`（大小）。零值禁止将响应拆分为切片。请注意，值太低可能会导致内存使用过多并打开大量文件。

为了使子请求返回所需的范围，`$slice_range` 变量应作为 Range 请求头字段[传递](ngx_http_proxy_module.md#proxy_set_header)给代理服务器。如果启用了缓存，则应将 `$slice_range` 添加到[缓存键](ngx_http_proxy_module.md#proxy_cache_key)，并启用 206 状态代码的响应缓存。

<a id="embedded_variables"></a>

## 内嵌变量

`ngx_http_slice_module` 模块支持以下内嵌变量：

- `$slice_range`

    [HTTP 字节范围](https://tools.ietf.org/html/rfc7233#section-2.1)格式的当前切片范围，例如：`bytes=0-1048575`。
    
## 原文档
[http://nginx.org/en/docs/http/ngx_http_slice_module.html](http://nginx.org/en/docs/http/ngx_http_slice_module.html)
