# ngx_http_flv_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [flv](#flv)

ngx_http_flv_module模块为Flash视频（FLV）文件提供伪流服务器端支持。

它通过发送返回从请求的字节偏移开始的文件的内容和前缀的FLV标题来处理请求URI查询字符串中的起始参数的请求。

该模块不是默认构建的，它应该使用--with-http_flv_module配置参数启用。

<a id="example_configuration"></a>

## 示例配置

```nginx
location ~ \.flv$ {
    flv;
}
```

<a id="directives"></a>

## 指令

### flv

|\-|说明|
|------:|------|
|**语法**|**flv**;|
|**默认**|——|
|**上下文**|location|

开启针对 `location` 的模块处理。

## 原文档
[http://nginx.org/en/docs/http/ngx_http_flv_module.html](http://nginx.org/en/docs/http/ngx_http_flv_module.html)