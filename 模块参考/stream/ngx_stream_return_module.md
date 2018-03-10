# ngx_stream_return_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [return](#return)

`ngx_stream_return_module` 模块（1.11.2）允许向客户端发送指定的值，然后关闭连接。

<a id="example_configuration"></a>

## 示例配置

```nginx
server {
    listen 12345;
    return $time_iso8601;
}
```

<a id="directives"></a>

## 指令

### return

|\-|说明|
|------:|------|
|**语法**|**return** `value`;|
|**默认**|——|
|**上下文**|server|

指定要发送给客户端的值。该值可以包含文本、变量及其组合。

## 原文档
[http://nginx.org/en/docs/stream/ngx_stream_return_module.html](http://nginx.org/en/docs/stream/ngx_stream_return_module.html)