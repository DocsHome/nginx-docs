# ngx_http_gzip_module

- [指令](#directives)
    - [gzip](#gzip)
    - [gzip_buffers](#gzip_buffers)
    - [gzip_comp_level](#gzip_comp_level)
    - [gzip_disable](#gzip_disable)
    - [gzip_min_length](#gzip_min_length)
    - [gzip_http_version](#gzip_http_version)
    - [gzip_proxied](#gzip_proxied)
    - [gzip_types](#gzip_types)
    - [gzip_vary](#gzip_vary)
- [内嵌变量](#embedded_variables)

`ngx_http_gzip_module` 模块是一个使用了 **gzip** 方法压缩响应的过滤器。有助于将传输数据的大小减少一半甚至更多。

<a id="example_configuration"></a>

## 示例配置

```nginx
gzip            on;
gzip_min_length 1000;
gzip_proxied    expired no-cache no-store private auth;
gzip_types      text/plain application/xml;
```

`$gzip_ratio` 变量可用于记录实现的压缩比率。

<a id="directives"></a>

## 指令

### gzip

|\-|说明|
|------:|------|
|**语法**|**gzip** `on` &#124; `off`;|
|**默认**|gzip off;|
|**上下文**|http、server、location、location 中的 if|

启用或禁用响应的 gzip 压缩。

### gzip_buffers

|\-|说明|
|------:|------|
|**语法**|**gzip_buffers** `number size`;|
|**默认**|gzip_buffers 32 4k&#124;16 8k;|
|**上下文**|http、server、location|

设置用于压缩响应的缓冲区的数量（`number`）和大小（`size`）。默认情况下，缓冲区大小等于一个内存页（4K 或 8K，取决于平台）。

> 在 0.7.28 版本之前，默认使用 4 个 4K 或 8K 缓冲区。

### gzip_comp_level

|\-|说明|
|------:|------|
|**语法**|**gzip_comp_level** `level`;|
|**默认**|gzip_comp_level 1;|
|**上下文**|http、server、location|

设置响应的 gzip 压缩级别（`level`）。值的范围为 1 到 9。

### gzip_disable

|\-|说明|
|------:|------|
|**语法**|**gzip_disable** `regex ...`;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 0.6.23 版本中出现|

禁用对与任何指定正则表达式匹配的 `User-Agent` 头字段的请求响应做 gzip 处理。

特殊掩码 `msie6`（0.7.12）对应正则表达式 `MSIE [4-6]\.`，但效率更高。从 0.8.11 版本开始，`MSIE 6.0; ... SV1` 不包含在此掩码中。

### gzip_min_length

|\-|说明|
|------:|------|
|**语法**|**gzip_min_length** `length`;|
|**默认**|gzip_min_length 20;|
|**上下文**|http、server、location|

设置被压缩响应的最小长度。该长度仅由 `Content-Length` 响应头字段确定。

### gzip_http_version

|\-|说明|
|------:|------|
|**语法**|**gzip_http_version** `1.0` &#124; `1.1`;|
|**默认**|gzip_http_version 1.1;|
|**上下文**|http、server、location|

设置压缩响应一个请求所需的最小 HTTP 版本。

### gzip_proxied

|\-|说明|
|------:|------|
|**语法**|**gzip_proxied** `off` &#124; `expired` &#124; `no-cache` &#124; `no-store` &#124; `private` &#124; `no_last_modified` &#124; `no_etag` &#124; `auth` &#124; `any ...`;|
|**默认**|gzip_proxied off;|
|**上下文**|http、server、location|

根据请求和响应，启用或禁用针对代理请求的响应的 gzip。事实上请求被代理取决于 `Via` 请求头字段是否存在。该指令接受多个参数：

- `off`

    禁用所有代理请求压缩，忽略其他参数

- `expired`

    如果响应头包含 `Expires”` 字段并且其值为禁用缓存，则启用压缩

- `no-cache`

    如果响应头包含具有 `no-cache` 参数的 `Cache-Control` 字段，则启用压缩

- `no-store`

    如果响应头包含具有 `no-store` 参数的 `Cache-Control` 字段，则启用压缩

- `private`

    如果响应头包含带有 `private` 参数的 `Cache-Control` 字段，则启用压缩

- `no_last_modified`

    如果响应头不包含 `Last-Modified` 字段，则启用压缩

- `no_etag`

    如果响应头不包含 `ETag` 字段，则启用压缩

- `auth`

    如果请求头包含 `Authorization` 字段，则启用压缩

- `any`

    为所有代理请求启用压缩

### gzip_types

|\-|说明|
|------:|------|
|**语法**|**gzip_types** `mime-type ...`;|
|**默认**|gzip_types text/html;|
|**上下文**|http、server、location|

除了 `text/html` 之外，还可以针对指定的 MIME 类型启用 gzip 响应。特殊值 `*` 匹配任何 MIME 类型（0.8.29）。对 `text/html` 类型的响应始终启用压缩。

### gzip_vary

|\-|说明|
|------:|------|
|**语法**|**gzip_vary** `on` &#124; `off`;|
|**默认**|gzip_vary off;|
|**上下文**|http、server、location|

如果指令 [gzip](ngx_http_gzip_module.md#gzip)、[gzip_static](ngx_http_gzip_static_module.md#gzip_static) 或 [gunzip](ngx_http_gunzip_module.md#gunzip) 处于激活状态，则启用或禁用插入 `Vary:Accept-Encoding` 响应头字段。

<a id="embedded_variables"></a>

## 内嵌变量

- `$gzip_ratio`

    实现压缩比率，计算为原始压缩响应大小与压缩后响应大小之间的比率。

## 原文档
[http://nginx.org/en/docs/http/ngx_http_gzip_module.html](http://nginx.org/en/docs/http/ngx_http_gzip_module.html)