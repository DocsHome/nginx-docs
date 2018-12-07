# ngx_stream_access_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [allow](#allow)
    - [deny](#deny)

`ngx_stream_access_module` 模块（1.9.2）允许对某些客户端地址限制访问。

<a id="example_configuration"></a>

## 示例配置

```nginx
server {
    ...
    deny  192.168.1.1;
    allow 192.168.1.0/24;
    allow 10.1.1.0/16;
    allow 2001:0db8::/32;
    deny  all;
}
```

按顺序检查规则，直到找到第一个匹配项。在此示例中，仅允许 IPv4 网络 `10.1.1.0/16` 和 `192.168.1.0/24`（不包括地址 `192.168.1.1`）和 IPv6 网络`2001:0db8::/32` 进行访问。

<a id="directives"></a>

## 指令

### allow

|\-|说明|
|------:|------|
|**语法**|**allow** `address` &#124; `CIDR` &#124; `unix:` &#124; `all`;|
|**默认**|——|
|**上下文**|stream、server|

允许指定的网络或地址访问。如果指定了值 `unix:`，则允许访问所有 UNIX 域套接字。

### deny

|\-|说明|
|------:|------|
|**语法**|**deny** `address` &#124; `CIDR` &#124; `unix:` &#124; `all`;|
|**默认**|——|
|**上下文**|stream、server|

拒绝指定的网络或地址访问。如果指定了值 `unix:`，则拒绝所有 UNIX 域套接字的访问。

## 原文档
[http://nginx.org/en/docs/stream/ngx_stream_access_module.html](http://nginx.org/en/docs/stream/ngx_stream_access_module.html)