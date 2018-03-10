# ngx_mail_pop3_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [pop3_auth](#pop3_auth)
    - [pop3_capabilities](#pop3_capabilities)

<a id="directives"></a>

## 指令

### pop3_auth 

|\-|说明|
|------:|------|
|**语法**|**pop3_auth** `method ...`;|
|**默认**|pop3_auth plain;|
|**上下文**|mail、server|

为 POP3 客户端设置允许的认证方法。支持的方法有：

- `plain`
    
    [USER/PASS](https://tools.ietf.org/html/rfc1939)、[AUTH PLAIN](https://tools.ietf.org/html/rfc4616)、[AUTH LOGIN](https://tools.ietf.org/html/draft-murchison-sasl-login-00)。不可能禁用这些方法。
- `apop`

    [APOP](https://tools.ietf.org/html/rfc1939)。为了使此方法正常工作，密码不能加密存储。
- `cram-md5`

    [AUTH CRAM-MD5](https://tools.ietf.org/html/rfc2195)。为了使此方法正常工作，密码不能加密存储。

- `external`
    
    [AUTH EXTERNAL](https://tools.ietf.org/html/rfc4422)（1.11.6）。

### pop3_capabilities

|\-|说明|
|------:|------|
|**语法**|**pop3_capabilities** `extension ...`;|
|**默认**|pop3_capabilities TOP USER UIDL;|
|**上下文**|mail、server|

设置响应 `CAPA` 命令传送给客户端的 [POP3 协议](https://tools.ietf.org/html/rfc2449) 扩展列表。根据 [starttls](ngx_mail_ssl_module.md#starttls) 指令值，[pop3_auth](#pop3_auth) 指令（[SASL](https://tools.ietf.org/html/rfc2449) 扩展）和 [STLS](https://tools.ietf.org/html/rfc2595) 中指定的认证方法将自动添加到此列表。

指定客户端代理的 POP3 后端支持的扩展（当 nginx 透明地代理到后端的客户端连接，如果这些扩展与认证后使用的命令相关），则是有意义的。

## 原文档
[http://nginx.org/en/docs/mail/ngx_mail_pop3_module.html](http://nginx.org/en/docs/mail/ngx_mail_pop3_module.html)