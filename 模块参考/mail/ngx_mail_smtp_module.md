# ngx_mail_smtp_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [ngx_mail_smtp_module](#ngx_mail_smtp_module)
    - [smtp_capabilities](#smtp_capabilities)

<a id="directives"></a>

## 指令

### smtp_auth 

|\-|说明|
|------:|------|
|**语法**|**smtp_auth** `method ...`;|
|**默认**|smtp_auth login plain;|
|**上下文**|mail、server|

为 SMTP 客户端设置 [SASL 认证](https://tools.ietf.org/html/rfc2554) 的允许方法。支持的方法有：

- `login`

    [AUTH LOGIN](https://tools.ietf.org/html/draft-murchison-sasl-login-00)
- `plain`
    
    [AUTH PLAIN](https://tools.ietf.org/html/rfc4616)
- `cram-md5`

    [AUTH CRAM-MD5](https://tools.ietf.org/html/rfc2195)。为了使此方法正常工作，密码不加密存储。
- `external`
    
    [AUTH EXTERNAL](https://tools.ietf.org/html/rfc4422)（1.11.6）。
- `none`
    
    不需要验证

### smtp_capabilities

|\-|说明|
|------:|------|
|**语法**|**smtp_capabilities** `extension ...`;|
|**默认**|——|
|**上下文**|mail、server|

设置传送给客户端响应 `EHLO` 命令的 SMTP 协议扩展列表。根据 [starttls](ngx_mail_ssl_module.md#starttls) 指令值，[smtp_auth](ngx_mail_smtp_module.md#smtp_auth) 指令和 [STARTTLS](https://tools.ietf.org/html/rfc3207) 中指定的认证方法将自动添加到此列表中。

指定被代理客户端的 MTA 支持扩展是有意义的（当 nginx 透明地将客户端连接代理到后端，如果这些扩展与认证后使用的命令相关）。

目前的标准扩展名单已发布在 [www.iana.org](http://www.iana.org/assignments/mail-parameters)。

## 原文档
[http://nginx.org/en/docs/mail/ngx_mail_smtp_module.html](http://nginx.org/en/docs/mail/ngx_mail_smtp_module.html)