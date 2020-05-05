# ngx_mail_ssl_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [ssl](#ssl)
    - [ssl_certificate](#ssl_certificate)
    - [ssl_certificate_key](#ssl_certificate_key)
    - [ssl_ciphers](#ssl_ciphers)
    - [ssl_client_certificate](#ssl_client_certificate)
    - [ssl_crl](#ssl_crl)
    - [ssl_dhparam](#ssl_dhparam)
    - [ssl_ecdh_curve](#ssl_ecdh_curve)
    - [ssl_password_file](#ssl_password_file)
    - [ssl_prefer_server_ciphers](#ssl_prefer_server_ciphers)
    - [ssl_protocols](#ssl_protocols)
    - [ssl_session_cache](#ssl_session_cache)
    - [ssl_session_ticket_key](#ssl_session_ticket_key)
    - [ssl_session_tickets](#ssl_session_tickets)
    - [ssl_session_timeout](#ssl_session_timeout)
    - [ssl_trusted_certificate](#ssl_trusted_certificate)
    - [ssl_verify_client](#ssl_verify_client)
    - [ssl_verify_depth](#ssl_verify_depth)
    - [starttls](#starttls)

`ngx_mail_ssl_module` 模块可让邮件代理服务器支持 SSL/TLS 协议。

默认情况下不构建此模块，可在构建时使用 `--with-mail_ssl_module` 配置参数启用它。

> 该模块依赖 [OpenSSL](http://www.openssl.org/) 库。

<a id="example_configuration"></a>

## 示例配置

为了减轻处理器负载，建议：

- 将 [worker 进程](../核心功能.md#worker_processes)数设置为与处理器数量相等
- 启用[共享](#ssl_session_cache_shared)会话缓存
- 禁用[内置](#ssl_session_cache_builtin)的会话缓存
- 可以延长会话的[生命周期](#ssl_session_timeout)（默认为 5 分钟）

```nginx
worker_processes auto;

mail {

    ...

    server {
        listen              993 ssl;

        ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers         AES128-SHA:AES256-SHA:RC4-SHA:DES-CBC3-SHA:RC4-MD5;
        ssl_certificate     /usr/local/nginx/conf/cert.pem;
        ssl_certificate_key /usr/local/nginx/conf/cert.key;
        ssl_session_cache   shared:SSL:10m;
        ssl_session_timeout 10m;

        ...
    }
```

<a id="directives"></a>

## 指令

### ssl

|\-|说明|
|:------|:------|
|**语法**|**ssl** `on` &#124; `off`;|
|**默认**|ssl off;|
|**上下文**|mail、server|

该指令在 1.15.0 版本中已废弃，请改用 [listen](./ngx_mail_core_module.md#listen) 指令的 `ssl` 参数。

### ssl_certificate

|\-|说明|
|:------|:------|
|**语法**|**ssl_certificate** `file`;|
|**默认**|——|
|**上下文**|mail、server|

为给定服务器指定一个 PEM 格式的证书文件（`file`）。如果除主证书之外还要指定中间证书，则应在同一文件中按以下顺序指定它们：首先是主证书，然后是中间证书。PEM 格式的密钥可以放在同一文件中。

从 1.11.0 版开始，可以多次声明该指令来加载不同类型的证书，例如 RSA 和 ECDSA：

```nginx
server {
    listen              993 ssl;

    ssl_certificate     example.com.rsa.crt;
    ssl_certificate_key example.com.rsa.key;

    ssl_certificate     example.com.ecdsa.crt;
    ssl_certificate_key example.com.ecdsa.key;

    ...
}
```

> 仅 OpenSSL 1.0.2 或更高版本支持不同证书的独立证书链。对于较旧的版本，只能使用一个证书链。

可以指定 `data:certificate` 值来代替 `file`（1.15.10），无需使用文件即可加载证书。请注意，错误使用此语法可能会带来安全隐患，例如将密钥数据写入[错误日志](../核心功能.md#error_log)。

### ssl_certificate_key

|\-|说明|
|:------|:------|
|**语法**|**ssl_certificate_key** `file`;|
|**默认**|——|
|**上下文**|mail、server|

给服务器指定一个 PEM 格式的密钥文件（`file`）。

可以指定 `engine:name:id` 来代替 `file`（1.7.9），Nginx 将从名称为 `name` 的 OpenSSL 引擎中中加载 id 为 `id` 的密钥。

可以指定 `data:key` 值来代替 `file`（1.15.10），无需使用文件就可以加载密钥。请注意，错误使用此语法可能会带来安全隐患，例如将密钥数据写入[错误日志](../核心功能.md#error_log)。

### ssl_ciphers

|\-|说明|
|:------|:------|
|**语法**|**ssl_ciphers** `ciphers`|
|**默认**|ssl_ciphers HIGH:!aNULL:!MD5;|
|**上下文**|mail、server|

指定启用的加密算法。仅可指定 OpenSSL 库支持的算法，例如：

```
ssl_ciphers ALL:!aNULL:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP;
```

> 可以使用 `openssl ciphers` 命令查看完整列表。

默认情况下，早期版本的 nginx 使用了[不同](../../介绍/配置HTTPS服务器.md#compatibility)的加密算法。

### ssl_client_certificate

|\-|说明|
|:------|:------|
|**语法**|**ssl_client_certificate** `file`;|
|**默认**|——|
|**上下文**|mail、server|
|**提示**|该指令在 1.7.11 版本中出现|

指定一个 PEM 格式的受信任 CA 证书文件，用于[验证](#ssl_verify_client)客户端证书。

证书列表将发送给客户端。如果不希望这样做，则可以使用 [ssl_trusted_certificate ](#ssl_trusted_certificate) 指令配置。

### ssl_crl

|\-|说明|
|:------|:------|
|**语法**|**ssl_crl** `file`;|
|**默认**|——|
|**上下文**|mail、server|
|**提示**|该指令在 1.7.11 版本中出现|

指定一个 PEM 格式的吊销证书（CRL）文件，用于[验证](#ssl_verify_client)客户端证书。

### ssl_dhparam

|\-|说明|
|:------|:------|
|**语法**|**ssl_dhparam** `file`;|
|**默认**|——|
|**上下文**|mail、server|
|**提示**|该指令在 0.7.2 版本中出现|

指定一个带有 DHE 密码的 DH 参数的文件（`file`）。

默认情况下，不设置任何参数，因此不使用 DHE 密码。

> 在 1.11.0 版之前，默认情况下使用内置参数。

### ssl_ecdh_curve

|\-|说明|
|:------|:------|
|**语法**|**ssl_ecdh_curve** `curve`;|
|**默认**|ssl_ecdh_curve auto;|
|**上下文**|mail、server|
|**提示**|该指令在 1.1.0 和 1.0.6 版本中出现|

为 ECDHE 算法指定一个椭圆曲线方案（`curve`）。

使用 OpenSSL 1.0.2 或更高版本时，可以指定多个曲线（1.11.0），例如：

```nginx
ssl_ecdh_curve prime256v1:secp384r1;
```

当使用 OpenSSL 1.0.2 或更高版本或带有较旧版本的 `prime256v1` 时，特殊值 `auto`（1.11.0）指示 nginx 使用内置在 OpenSSL 库中的列表。

> 在 1.11.0 版之前，默认使用 `prime256v1` 曲线。

### ssl_password_file

|\-|说明|
|:------|:------|
|**语法**|**ssl_password_file** `file`;|
|**默认**|——|
|**上下文**|mail、server|
|**提示**|该指令在 1.7.3 版本中出现|

指定一个保存有[密钥](#ssl_certificate_key)密码的文件，每个密码独占一行。 加载密钥时依次尝试使用这些密码。

例：

```nginx
mail {
    ssl_password_file /etc/keys/global.pass;
    ...

    server {
        server_name mail1.example.com;
        ssl_certificate_key /etc/keys/first.key;
    }

    server {
        server_name mail2.example.com;

        # named pipe can also be used instead of a file
        ssl_password_file /etc/keys/fifo;
        ssl_certificate_key /etc/keys/second.key;
    }
}
```

### ssl_prefer_server_ciphers

|\-|说明|
|:------|:------|
|**语法**|**ssl_prefer_server_ciphers** `on` &#124; `off`;|
|**默认**|ssl_prefer_server_ciphers off;|
|**上下文**|mail、server|

指定当使用 SSLv3 和 TLS 协议时，服务器加密算法应优先于客户端加密算法。

### ssl_protocols

|\-|说明|
|:------|:------|
|**语法**|**ssl** `[SSLv2] [SSLv3] [TLSv1] [TLSv1.1] [TLSv1.2] [TLSv1.3]`;|
|**默认**|sssl_protocols TLSv1 TLSv1.1 TLSv1.2;|
|**上下文**|mail、server|

启用指定的协议。

> `TLSv1.1` 和 `TLSv1.2` 参数（1.1.13、1.0.12）仅在使用 OpenSSL 1.0.1 或更高版本时有效。

> `TLSv1.3` 参数（1.13.0）仅在 OpenSSL 1.1.1 构建时使用了 TLSv1.3 支持有效。


### ssl_session_cache

|\-|说明|
|:------|:------|
|**语法**|**ssl_session_cache** `on` &#124; `none` &#124; `[builtin[:size]] [shared:name:size]`;|
|**默认**|ssl_session_cache none;|
|**上下文**|mail、server|

设置存储会话参数的缓存的类型和大小。缓存可以是以下任何类型：

- `off`

    严格禁止使用会话缓存：nginx 明确告知客户端禁止重复使用会话。

- `none`

    禁止使用会话缓存：nginx 告诉客户端会话可以重用，但实际上并没有在缓存中存储会话参数。

- `builtin`

    内置的 OpenSSL 缓存，仅由一个 worker 进程使用。缓存大小在会话中指定。如果未指定大小，则默认为 20480 个会话。使用内置缓存可能导致内存碎片。

- `shared`

    所有 worker 进程之间共享的缓存。缓存大小以字节为单位，一兆字节可以存储大约 4000 个会话。每个共享缓存都有一个任意的名称。相同名称的缓存可以在多个服务器中使用。

两种缓存类型可以同时使用，例如：

```nginx
ssl_session_cache builtin:1000 shared:SSL:10m;
```

但仅使用共享缓存而不使用内置缓存，效率会更高。

### ssl_session_ticket_key

|\-|说明|
|:------|:------|
|**语法**|**ssl_session_ticket_key** `file`;|
|**默认**|——|
|**上下文**|mail、server|
|**提示**|该指令在 1.5.7 版本中出现|

设置一个带有用于加密和解密 TLS 会话票证的密钥文件。如果必须在多个服务器之间共享同一密钥，则该指令是必需的。默认情况下，使用随机生成的密钥。

如果指定了多个密钥，仅第一个密钥被用于加密 TLS 会话票证。可配置 key 轮转，例如：

```nginx
ssl_session_ticket_key current.key;
ssl_session_ticket_key previous.key;
```

该文件（`file`）必须包含 80 或 48 个字节的随机数据，可以使用以下命令创建：

```
openssl rand 80> ticket.key
```

根据文件大小，使用 AES256（针对 80 字节的 key，1.11.8）或 AES128（针对 48 字节的 key）进行加密。

### ssl_session_tickets

|\-|说明|
|:------|:------|
|**语法**|**ssl_session_tickets** `on` &#124; `off`;|
|**默认**|ssl_session_tickets on;|
|**上下文**|mail、server|
|**提示**|该指令在 1.5.9 版本中出现|

通过 [TLS 会话票证](https://tools.ietf.org/html/rfc5077)启用或禁用会话复用。

### ssl_session_timeout

|\-|说明|
|:------|:------|
|**语法**|**ssl_session_timeout** `time`;|
|**默认**|ssl_session_timeout 5m;|
|**上下文**|mail、server|

指定客户端可以重用会话参数的时间。

### ssl_trusted_certificate

|\-|说明|
|:------|:------|
|**语法**|**ssl_trusted_certificate** `file`;|
|**默认**|——|
|**上下文**|mail、server|
|**提示**|该指令在 1.7.11 版本中出现|

指定一个带有用于[验证](#ssl_verify_client)客户端证书的 PEM 格式的受信任 CA 证书文件。

与 [ssl_client_certificate](#ssl_client_certificate) 设置的证书相反，这些证书的列表不会发送给客户端。

### ssl_verify_client

|\-|说明|
|:------|:------|
|**语法**|**ssl_verify_client** `on` &#124; `none` &#124; `optional` &#124; `optional_no_ca`;|
|**默认**|ssl_verify_client off;|
|**上下文**|mail、server|
|**提示**|该指令在 1.7.11 版本中出现|

启用客户端证书的验证。验证结果在[身份验证](ngx_mail_auth_http_module.md#auth_http)请求的 **Auth-SSL-Verify** 头中传递。

`optional` 参数请求客户端证书并验证该证书是否存在。

`optional_no_ca` 参数请求客户端证书，但不需要由受信任的 CA 证书对其进行签名，适合在 nginx 外部的服务执行实际证书验证的情况下使用。通过[发送](ngx_mail_auth_http_module.md#auth_http_pass_client_cert)到身份验证服务器的请求可以访问证书的内容。

### ssl_verify_depth

|\-|说明|
|:------|:------|
|**语法**|**ssl_verify_depth** `number`;|
|**默认**|ssl_verify_depth 1;|
|**上下文**|mail、server|
|**提示**|该指令在 1.7.11 版本中出现|

设置客户端证书链的验证深度。

### starttls

|\-|说明|
|:------|:------|
|**语法**|**starttls** `on` &#124; `off` &#124; `only`;|
|**默认**|starttls off;|
|**上下文**|mail、server|

- `on`

    允许对 POP3 使用 `STLS` 命令，对 IMAP 和 SMTP 使用 `STARTTLS` 命令

- `off`

    拒绝使用 `STLS` 和 `STARTTLS` 命令

- `only`

    要求初步的 TLS 转换

## 原文档

- [http://nginx.org/en/docs/mail/ngx_mail_ssl_module.html](http://nginx.org/en/docs/mail/ngx_mail_ssl_module.html)
