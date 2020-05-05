# ngx_mail_auth_http_module

- [指令](#directives)
    - [auth_http](#auth_http)
    - [auth_http_header](#auth_http_header)
    - [auth_http_pass_client_cert](#auth_http_pass_client_cert)
    - [auth_http_timeout](#auth_http_timeout)
- [协议](#protocol)

<a id="directives"></a>

## 指令

### auth_http

|\-|说明|
|:------|:------|
|**语法**|**auth_http** `URL`;|
|**默认**|——|
|**上下文**|mail、server|

设置 HTTP 认证服务器的 URL。协议描述[如下](#protocol)。

### auth_http_header

|\-|说明|
|:------|:------|
|**语法**|**auth_http_header** `header value`;|
|**默认**|——|
|**上下文**|mail、server|

将指定的头附加到发送到身份验证服务器的请求。该头可以用作共享密钥，以验证请求来自 nginx。例如：

```nginx
auth_http_header X-Auth-Key "secret_string";
```

### auth_http_pass_client_cert

|\-|说明|
|:------|:------|
|**语法**|**auth_http_pass_client_cert** `on` &#124; `off`;|
|**默认**|auth_http_pass_client_cert off;|
|**上下文**|mail、server|
|**提示**|该指令在 1.7.11 版本中出现|

将 **Auth-SSL-Cert** 头和 PEM 格式（已编码）的[客户端](./ngx_mail_ssl_module.md#ssl_verify_client)证书附加到发送到身份验证服务器的请求。

### auth_http_timeout

|\-|说明|
|:------|:------|
|**语法**|**auth_http_timeout** `time`|
|**默认**|auth_http_timeout 60s;|
|**上下文**|mail、server|

设置与认证服务器通信的超时时间。

<a id="protocol"></a>

## 协议

HTTP 协议用于与身份验证服务器进行通信。响应正文中的数据将被忽略，信息仅在头中传递。

请求和响应的示例：

请求：

```
GET /auth HTTP/1.0
Host: localhost
Auth-Method: plain # plain/apop/cram-md5/external
Auth-User: user
Auth-Pass: password
Auth-Protocol: imap # imap/pop3/smtp
Auth-Login-Attempt: 1
Client-IP: 192.0.2.42
Client-Host: client.example.org
```

好的响应：

```
HTTP/1.0 200 OK
Auth-Status: OK
Auth-Server: 198.51.100.1
Auth-Port: 143
```

坏的响应：

```
HTTP/1.0 200 OK
Auth-Status: Invalid login or password
Auth-Wait: 3
```

如果没有 **Auth-Wait** 头，则将返回错误并关闭连接。当前实现为每次身份验证尝试分配内存。仅在会话结束时才释放内存。因此，必须限制单个会话中无效身份验证尝试的次数 — 服务器必须在 10-20 次尝试后响应不带 **Auth-Wait** 头（尝试次数在 **Auth-Login-Attempt** 头中传递）。

使用 APOP 或 CRAM-MD5 时，请求-响应如下所示：

```
GET /auth HTTP/1.0
Host: localhost
Auth-Method: apop
Auth-User: user
Auth-Salt: <238188073.1163692009@mail.example.com>
Auth-Pass: auth_response
Auth-Protocol: imap
Auth-Login-Attempt: 1
Client-IP: 192.0.2.42
Client-Host: client.example.org
```

好的响应：

```
HTTP/1.0 200 OK
Auth-Status: OK
Auth-Server: 198.51.100.1
Auth-Port: 143
Auth-Pass: plain-text-pass
```

如果响应中存在 **Auth-User** 头，它将覆盖用于与后端进行身份验证的用户名。

对于 SMTP，响应还考虑了 **Auth-Error-Code** 头 — 如果存在，则在发生错误时用作响应代码。否则，将 535 5.7.0 代码添加到 **Auth-Status** 头中。

例如，如果从身份验证服务器收到以下响应：

```
HTTP/1.0 200 OK
Auth-Status: Temporary server problem, try again later
Auth-Error-Code: 451 4.3.0
Auth-Wait: 3
```

则 SMTP 客户端将收到错误

```
451 4.3.0 Temporary server problem, try again later
```

如果代理 SMTP 不需要身份验证，则请求将如下所示：

```
GET /auth HTTP/1.0
Host: localhost
Auth-Method: none
Auth-User:
Auth-Pass:
Auth-Protocol: smtp
Auth-Login-Attempt: 1
Client-IP: 192.0.2.42
Client-Host: client.example.org
Auth-SMTP-Helo: client.example.org
Auth-SMTP-From: MAIL FROM: <>
Auth-SMTP-To: RCPT TO: <postmaster@mail.example.com>
```

对于 SSL/TLS 客户端连接（1.7.11），添加了 **Auth-SSL** 头，并且 **Auth-SSL-Verify** 将包含客户端证书验证的结果（如果[启用](ngx_mail_ssl_module.md#ssl_verify_client)）：`SUCCESS`、`FAILED:reason` 和 `NONE`（如果不存在证书）。

> 在 1.11.7 版本之前，`FAILED` 结果不包含原因字符串。

存在客户端证书时，其详细信息将在以下请求头中传递：**Auth-SSL-Subject**、**Auth-SSL-Issuer**、**Auth-SSL-Serial** 和 **Auth-SSL-Fingerprint**。如果启用了 [auth_http_pass_client_cert](#auth_http_pass_client_cert)，则证书本身将在 **Auth-SSL-Cert** 头中传递。该请求将如下所示：

```
GET /auth HTTP/1.0
Host: localhost
Auth-Method: plain
Auth-User: user
Auth-Pass: password
Auth-Protocol: imap
Auth-Login-Attempt: 1
Client-IP: 192.0.2.42
Auth-SSL: on
Auth-SSL-Verify: SUCCESS
Auth-SSL-Subject: /CN=example.com
Auth-SSL-Issuer: /CN=example.com
Auth-SSL-Serial: C07AD56B846B5BFF
Auth-SSL-Fingerprint: 29d6a80a123d13355ed16b4b04605e29cb55a5ad
```

## 原文档

- [http://nginx.org/en/docs/mail/ngx_mail_auth_http_module.html](http://nginx.org/en/docs/mail/ngx_mail_auth_http_module.html)
