# ngx_http_f4f_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [f4f](#f4f)
    - [f4f_buffer_size](#f4f_buffer_size)

`ngx_http_f4f_module` 模块为 Adobe HTTP 动态流（HDS）提供服务端支持。

该模块以 `/videoSeg1-Frag1` 形式处理 HTTP 动态流请求，使用 `videoSeg1.f4x` 索引文件从 `videoSeg1.f4f` 文件中提取所需的片段。该模块是 Apache 的 Adobe f4f 模块（HTTP Origin Module）的替代品。

它需要通过 Adobe 的 f4fpackager 进行预处理，有关详细信息，请参阅相关文档。

> 此模块作为我们[商业订阅](http://nginx.com/products/?_ga=2.62027116.1975223854.1508572582-1890203964.1497190280)的一部分。

<a id="example_configuration"></a>

## 示例配置

```nginx
location /video/ {
    f4f;
    ...
}
```

<a id="directives"></a>

## 指令

### f4f

|\-|说明|
|------:|------|
|**语法**|**f4f**;|
|**默认**|——|
|**上下文**|location|

开启针对 `location` 的模块处理。

### f4f_buffer_size

|\-|说明|
|------:|------|
|**语法**|**f4f4f_buffer_sizef** `size`;|
|**默认**|f4f_buffer_size 512k;|
|**上下文**|http、server、location|

设置用于读取 `.f4x` 索引文件的缓冲区的 `size` （大小）。

## 原文档
[http://nginx.org/en/docs/http/ngx_http_f4f_module.html](http://nginx.org/en/docs/http/ngx_http_f4f_module.html)