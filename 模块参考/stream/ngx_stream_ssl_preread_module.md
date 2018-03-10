# ngx_stream_ssl_preread_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [ssl_preread](#ssl_preread)
- [内嵌变量](#embedded_variables)

`ngx_stream_ssl_preread_module` 模块（1.11.5）允许从 [ClientHello](ClientHello) 消息中提取信息，而不会终止 SSL/TLS，例如提取通过 [SNI](https://tools.ietf.org/html/rfc6066#section-3) 请求的服务器名称。默认情况下不构建此模块，您可以在构建时使用 `--with-stream_ssl_preread_module` 配置参数启用此模块。

<a id="example_configuration"></a>

## 示例配置

```nginx
map $ssl_preread_server_name $name {
    backend.example.com      backend;
    default                  backend2;
}

upstream backend {
    server 192.168.0.1:12345;
    server 192.168.0.2:12345;
}

upstream backend2 {
    server 192.168.0.3:12345;
    server 192.168.0.4:12345;
}

server {
    listen      12346;
    proxy_pass  $name;
    ssl_preread on;
}
```

<a id="directives"></a>

## 指令

### google_perftools_profiles

|\-|说明|
|------:|------|
|**语法**|**ssl_preread** `on` \| `off`;|
|**默认**|ssl_preread off;|
|**上下文**|stream、server|

启用在[预读阶段](stream_processing.md#preread_phase) 从 ClientHello 消息中提取信息。

<a id="embedded_variables"></a>

## 内嵌变量

- `$ssl_preread_server_name`
    
    返回通过 SNI 请求的服务器名称

## 原文档
[http://nginx.org/en/docs/ngx_google_perftools_module.html](http://nginx.org/en/docs/ngx_google_perftools_module.html)