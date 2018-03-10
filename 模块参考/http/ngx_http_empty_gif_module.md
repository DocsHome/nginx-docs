# ngx_http_empty_gif_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [empty_gif](#empty_gif)

`ngx_http_empty_gif_module` 模块发送单像素透明 GIF。

<a id="example_configuration"></a>

## 示例配置

```nginx
location = /_.gif {
    empty_gif;
}
```

<a id="directives"></a>

## 指令

### empty_gif

|\-|说明|
|------:|------|
|**语法**|**empty_gif**;|
|**默认**|——|
|**上下文**|location|

开启针对 `location` 的模块处理。

## 原文档
[http://nginx.org/en/docs/http/ngx_http_empty_gif_module.html](http://nginx.org/en/docs/http/ngx_http_empty_gif_module.html)