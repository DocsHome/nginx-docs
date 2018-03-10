# ngx_http_autoindex_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [autoindex](#autoindex)
    - [autoindex_exact_size](#autoindex_exact_size)
    - [autoindex_format](#autoindex_format)
    - [autoindex_localtime](#autoindex_localtime)


`ngx_http_autoindex_module` 模块处理以斜线字符（`/`）结尾的请求并生成一个目录列表。当 [ngx_http_index_module](ngx_http_index_module.md) 模块找不到索引文件时，通常会将请求传递给 `ngx_http_autoindex_module` 模块。

<a id="example_configuration"></a>

## 示例配置
```nginx
location / {
    autoindex on;
}
```

<a id="directives"></a>

## 指令

### autoindex

|\-|说明|
|:------|:------|
|**语法**|**autoindex** `on` &#124; `off`;|
|**默认**|autoindex off;|
|**上下文**|http、server、location|

启用或禁用目录列表输出。

### autoindex_exact_size

|\-|说明|
|:------|:------|
|**语法**|**autoindex_exact_size** `on` &#124; `off`;|
|**默认**|autoindex_exact_size on;|
|**上下文**|http、server、location|

对于 HTML [格式](#autoindex_format)，指定是否应在目录列表中输出确切的文件大小，或者四舍五入到千字节、兆字节和千兆字节。

### autoindex_format

|\-|说明|
|:------|:------|
|**语法**|**autoindex_format** `html` &#124; `xml` &#124; `json` &#124; `jsonp`;|
|**默认**|autoindex_format html;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.9 版本中出现|

设置目录列表的格式。

当使用 JSONP 格式时，使用 `callback` 请求参数设置回调函数的名称。如果没有参数或为空值，则使用 JSON 格式。

XML 输出可以使用 [ngx_http_xslt_module](ngx_http_xslt_module.md) 模块进行转换。

### autoindex_localtime

|\-|说明|
|:------|:------|
|**语法**|**autoindex_localtime** `on` &#124; `off`;|
|**默认**|autoindex_localtime off;|
|**上下文**|http、server、location|

对于 HTML [格式](#autoindex_format)，指定目录列表中的时间是否应使用本地时区或 UTC 输出。

## 原文档
[http://nginx.org/en/docs/http/ngx_http_autoindex_module.html](http://nginx.org/en/docs/http/ngx_http_autoindex_module.html)
