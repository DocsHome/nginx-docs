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

ngx_http_gzip_module模块是一个使用“gzip”方法压缩响应的过滤器。 这通常有助于将传输数据的大小减少一半甚至更多。

<a id="example_configuration"></a>

## 示例配置

```nginx
gzip            on;
gzip_min_length 1000;
gzip_proxied    expired no-cache no-store private auth;
gzip_types      text/plain application/xml;
```

$ gzip_ratio变量可用于记录实现的压缩比率。

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

**待续……**

## 原文档

[http://nginx.org/en/docs/http/ngx_http_gzip_module.html](http://nginx.org/en/docs/http/ngx_http_gzip_module.html)