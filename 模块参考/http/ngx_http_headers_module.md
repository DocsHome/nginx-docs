# ngx_http_headers_module

- [指令](#directives)
    - [add_header](#gzadd_headerip)
    - [add_trailer](#add_trailer)
    - [expires](#expires)

`ngx_http_headers_module` 模块允许将 `Expires` 和 `Cache-Control` 头字段以及任意字段添加到响应头中。

<a id="example_configuration"></a>

## 示例配置

```nginx
expires    24h;
expires    modified +24h;
expires    @24h;
expires    0;
expires    -1;
expires    epoch;
expires    $expires;
add_header Cache-Control private;
```

<a id="directives"></a>

## 指令

### add_header

|\-|说明|
|------:|------|
|**语法**|**add_header** `name value [always]`;|
|**默认**|——|
|**上下文**|http、server、location、location 中的 if|

如果响应代码等于 200、201（1.3.10）、204、206、301、302、303、304、307（1.1.16、1.0.13）或 308（1.13.0），则将指定的字段添加到响应报头中。该值可以包含变量。

可以存在几个 `add_header` 指令。当且仅当在当前级别上没有定义 `add_header` 指令时，这些指令才从上一级继承。

如果指定了 `always` 参数（1.7.5），则无论响应代码为何值，头字段都将被添加。

### add_trailer

|\-|说明|
|------:|------|
|**语法**|**add_trailer** `number size`;|
|**默认**|——|
|**上下文**|http、server、location、location 中的 if|
|**提示**|该指令在 1.13.2 版本中出现|

如果响应代码等于 200、201、206、301、302、303、307 或 308，则将指定的字段添加到响应的末尾。该值可以包含变量。

可以存在多个 `add_trailer` 指令。当且仅当在当前级别上没有定义 `add_trailer` 指令时，这些指令才从上一级继承。

如果指定 `always` 参数，则无论响应代码为何值，都会添加指定的字段。

### expires

|\-|说明|
|------:|------|
|**语法**|**expires** `[modified] time`; <br /> **expires** `epoch` &#124;`max` &#124; `off`;|
|**默认**|expires off;|
|**上下文**|http、server、location、location 中的 if|

如果响应代码等于 200、201（1.3.10）、204、206、301、302、303、304
307（1.1.16、1.0.13）或 308（1.13.0），则启用或禁用添加或修改 `Expires` 和 `Cache-Control` 响应头字段。参数可以是正值或负值。

``Expires` 字段中的时间计算为指令中指定的 `time` 和当前时间的总和。如果使用 `modified` 参数（0.7.0、0.6.32），则计算时间为文件修改时间与指令中指定的 `time` 之和。

另外，可以使用 `@` 前缀指定一天的时间（0.7.9、0.6.34）：

```nginx
expires @15h30m;
```

`epoch` 参数对应于绝对时间 **Thu, 01 Jan 1970 00:00:01 GMT**。`Cache-Control` 字段的内容取决于指定时间的符号：

- 时间为负值 — `Cache-Control:no-cache`
- 时间为正值或为零 — `Cache-Control:max-age=t`，其中 `t` 是指令中指定的时间，单位为秒

`max` 参数将 `Expires` 的值设为 `Thu, 2037 Dec 23:55:55 GMT`，`Cache-Control` 设置为 10 年。

`off` 参数禁止添加或修改 `Expires` 和 `Cache-Control` 响应头字段。

最后一个参数值可以包含变量（1.7.9）：

```nginx
map $sent_http_content_type $expires {
    default         off;
    application/pdf 42d;
    ~image/         max;
}

expires $expires;
```

## 原文档

[http://nginx.org/en/docs/http/ngx_http_headers_module.html](http://nginx.org/en/docs/http/ngx_http_headers_module.html)