# ngx_stream_realip_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [set_real_ip_from](#set_real_ip_from)
- [内嵌变量](#embedded_variables)

`ngx_stream_realip_module` 模块用于将客户端地址和端口更改为 PROXY 协议头（1.11.4）中发送。必须先在 `listen` 指令中设置 [proxy_protocol](ngx_stream_core_module.md#proxy_protocol) 参数才能启用 PROXY 协议。

该模块不是默认构建的，您可以在构建时使用 `--with-stream_realip_module` 配置参数启用。

<a id="example_configuration"></a>

## 示例配置

```nginx
listen 12345 proxy_protocol;

set_real_ip_from  192.168.1.0/24;
set_real_ip_from  192.168.2.1;
set_real_ip_from  2001:0db8::/32;
```

<a id="directives"></a>

## 指令

### set_real_ip_from

|\-|说明|
|------:|------|
|**语法**|**set_real_ip_from** `address` \| `CIDR` \| `unix:`;|
|**默认**|——|
|**上下文**|stream、server|

定义已知可发送正确替换地址的受信任地址。如果指定了特殊值 `unix:`，则所有 UNIX 域套接字将被信任。

<a id="embedded_variables"></a>

## 内嵌变量

- `$realip_remote_addr`

    保留原始客户端地址
- `$realip_remote_port`

    保留原始的客户端端口

## 原文档
[http://nginx.org/en/docs/stream/ngx_stream_realip_module.html](http://nginx.org/en/docs/stream/ngx_stream_realip_module.html)