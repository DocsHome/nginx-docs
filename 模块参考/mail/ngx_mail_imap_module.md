# ngx_mail_imap_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [imap_auth](#imap_auth)
    - [imap_capabilities](#imap_capabilities)
    - [imap_client_buffer](#imap_client_buffer)

<a id="directives"></a>

## 指令

### imap_auth 

|\-|说明|
|------:|------|
|**语法**|**imap_auth** `method ...`;|
|**默认**|imap_auth plain;|
|**上下文**|mail、server|

为 IMAP 客户端设置允许的认证方法。支持的方法有：

- `login`

    [AUTH=LOGIN](https://tools.ietf.org/html/draft-murchison-sasl-login-00)
- `plain`

    [AUTH=PLAIN](https://tools.ietf.org/html/rfc4616)
- `cram-md5`

    [AUTH=CRAM-MD5](https://tools.ietf.org/html/rfc2195)。为了使此方法正常工作，密码不能加密存储。

- `external`
    
    [AUTH EXTERNAL](https://tools.ietf.org/html/rfc4422)（1.11.6）。

### imap_capabilities

|\-|说明|
|------:|------|
|**语法**|**imap_capabilities** `extension ...`;|
|**默认**|imap_capabilities IMAP4 IMAP4rev1 UIDPLUS;|
|**上下文**|mail、server|

设置响应 `CAPABILITY` 命令传递给客户端的 [IMAP 协议](https://tools.ietf.org/html/rfc3501) 扩展列表。根据 [starttls](ngx_mail_ssl_module.md#starttls) 指令值，[imap_auth](#imap_auth) 指令和 [STARTTLS](https://tools.ietf.org/html/rfc2595) 中指定的认证方法将自动添加到此列表中。

指定被代理客户端的 IMAP 后端支持的扩展（当 nginx 透明地代理到后端的客户端连接，如果这些扩展与认证后使用的命令相关），则是有意义的。

目前的标准扩展名单已发布在 [www.iana.org](http://www.iana.org/assignments/imap4-capabilities)。

### imap_client_buffer

|\-|说明|
|------:|------|
|**语法**|**imap_client_buffer** `size`;|
|**默认**|imap_client_buffer 4k&#124;8k;|
|**上下文**|mail、server|

设置 IMAP 命令读取缓冲区大小。默认情况下，缓冲区大小等于一个内存页面。4K 或 8K，取决于平台。

## 原文档
[http://nginx.org/en/docs/mail/ngx_mail_imap_module.html](http://nginx.org/en/docs/mail/ngx_mail_imap_module.html)