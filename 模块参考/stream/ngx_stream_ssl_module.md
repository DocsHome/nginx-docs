# ngx_stream_ssl_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [ssl_certificate](#ssl_certificate)
    - [ssl_certificate_key](#ssl_certificate_key)
    - [ssl_ciphers](#ssl_ciphers)
    - [ssl_client_certificate](#ssl_client_certificate)
    - [ssl_crl](#ssl_crl)
    - [ssl_dhparam](#ssl_dhparam)
    - [ssl_ecdh_curve](#ssl_ecdh_curve)
    - [ssl_handshake_timeout](#ssl_handshake_timeout)
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
- [内置变量](#embedded_variables)

`ngx_stream_ssl_module` 模块（1.9.0）为流代理服务器使用 SSL/TLS 协议提供必要的支持。默认不构建此模块，可在构建时使用 `--with-stream_ssl_module` 配置参数启用。

<a id="example_configuration"></a>

## 示例配置

为了减少处理器负载，建议

- 将 [work 进程](../核心功能.md#worker_processes)数设置为与处理器核心数相同
- 启用[共享](#ssl_session_cache_shared)会话缓存
- 禁用[内置](#ssl_session_cache_builtin)的会话缓存
- 可以延长会话[生命周期](#ssl_session_timeout)（默认为 5 分钟）

```nginx
worker_processes auto;

stream {

    ...

    server {
        listen              12345 ssl;

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

### ssl_certificate

|\-|说明|
|------:|------|
|**语法**|**ssl_certificate** `file`;|
|**默认**|——|
|**上下文**|stream、server|

为给定服务器指定一个 PEM 格式的证书文件。如果除主证书之外还要指定中间证书，则应按以下顺序在同一文件中指定它们：首先是主证书，然后是中间证书。PEM 格式的密钥可以放在同一文件中。

从 1.11.0 版本开始，可以重复使用指令以加载不同类型的证书，例如 RSA 和 ECDSA：

```nginx
server {
    listen              12345 ssl;

    ssl_certificate     example.com.rsa.crt;
    ssl_certificate_key example.com.rsa.key;

    ssl_certificate     example.com.ecdsa.crt;
    ssl_certificate_key example.com.ecdsa.key;

    ...
}
```

> 仅 OpenSSL 1.0.2 或更高版本支持不同证书的独立证书链。对于较旧的版本，只能使用一个证书链。

从 1.15.9 版本开始，使用 OpenSSL 1.0.2 或更高版本时，可以在文件名中使用变量：

```nginx
ssl_certificate     $ssl_server_name.crt;
ssl_certificate_key $ssl_server_name.key;
```

请注意，使用变量意味着每次 SSL 握手都会加载证书，可能会对性能产生负面影响。

可以指定值 `data:$variable` 代替 `file`（1.15.10），nginx 将从变量加载证书，无需通过文件加载。请注意，不正确使用此语法可能会带来安全隐患，例如将密钥数据写入[错误日志](../核心功能.md#error_log)。

### ssl_certificate_key

|\-|说明|
|------:|------|
|**语法**|**ssl_certificate_key** `file`;|
|**默认**|——|
|**上下文**|stream、server|

指定一个保存有指定服务器密钥的 PEM 文件。

可以指定值 `engine:name:id` 来代替 `file`，nginx 将从 OpenSSL 引擎名为 `name` 中加载 ID 为 `id` 的密钥。

可以指定值 `data:$variable` 来代替 `file`（1.15.10），无需使用中间文件即可从变量直接加载密钥。请注意，不正确使用此语法可能会带来安全隐患，例如将密钥数据写入[错误日志](../核心功能.md#error_log)。

从 1.15.9 版本开始，使用 OpenSSL 1.0.2 或更高版本时，可以在文件名中使用变量。

### ssl_ciphers

|\-|说明|
|------:|------|
|**语法**|**ssl_ciphers** `ciphers`;|
|**默认**|ssl_ciphers HIGH:!aNULL:!MD5;|
|**上下文**|stream、server|

指定启用的密码算法。仅限 OpenSSL 库支持的算法，例如：

```nginx
ssl_ciphers ALL:!aNULL:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP;
```

可以使用 `openssl ciphers` 命令查看完整 openssl 支持的密码算法列表。

### ssl_client_certificate

|\-|说明|
|------:|------|
|**语法**|**ssl_client_certificate** `file`;|
|**默认**|——|
|**上下文**|stream、server|
|**提示**|该指令在 1.11.8 版本中出现|

指定一个用于[验证](#ssl_verify_client)客户端证书的可信 CA 证书 PEM 文件。

证书列表将发送给客户端。如果不希望这样做，可以使用 [ssl_trusted_certificate](#ssl_trusted_certificate) 指令修改配置。

### ssl_crl

|\-|说明|
|------:|------|
|**语法**|**ssl_crl** `file`;|
|**默认**|——|
|**上下文**|stream、server|
|**提示**|该指令在 1.11.8 版本中出现|

指定一个 PEM 格式的吊销证书（CRL）文件，用于[验证](#ssl_verify_client)客户端证书。

### ssl_dhparam

|\-|说明|
|------:|------|
|**语法**|**ssl_dhparam**;|
|**默认**|——|
|**上下文**|stream、server|

指定一个存储有 DHE 密码的 DH 参数的文件。

默认情况下，未设置任何参数，因此不会使用 DHE 密码。

> 在 1.11.0 版本之前，默认情况下使用内置参数。

### ssl_ecdh_curve

|\-|说明|
|------:|------|
|**语法**|**ssl_ecdh_curve** `curve`;|
|**默认**|ssl_ecdh_curve auto|
|**上下文**|stream、server|

为 ECDHE 密码指定一个椭圆曲线（`curve`）。

使用 OpenSSL 1.0.2 或更高版本时，可以指定多条椭圆曲线（1.11.0），例如：

```nginx
ssl_ecdh_curve prime256v1:secp384r1;
```

当使用 OpenSSL 1.0.2 或更高版本或带有较旧版本的 `prime256v1` 时，特殊值 `auto`（1.11.0）指示 nginx 使用内置在 OpenSSL 库中的椭圆曲线。

> 在 1.11.0 版本之前，默认使用 `prime256v1` 椭圆曲线。

### ssl_handshake_timeout

|\-|说明|
|------:|------|
|**语法**|**ssl_handshake_timeout** `time`;|
|**默认**|ssl_handshake_timeout 60s;|
|**上下文**|stream、server|

指定 SSL 握手完成的超时时间。

### ssl_password_file

|\-|说明|
|------:|------|
|**语法**|**ssl_password_file** `file`;|
|**默认**|——|
|**上下文**|stream、server|

指定一个存储有[密钥](#ssl_certificate_key)口令的文件，每个口令独占一行。加载密钥时依次尝试使用这些口令。

示例：

```nginx
stream {
    ssl_password_file /etc/keys/global.pass;
    ...

    server {
        listen 127.0.0.1:12345;
        ssl_certificate_key /etc/keys/first.key;
    }

    server {
        listen 127.0.0.1:12346;

        # named pipe can also be used instead of a file
        ssl_password_file /etc/keys/fifo;
        ssl_certificate_key /etc/keys/second.key;
    }
}
```

### ssl_prefer_server_ciphers

|\-|说明|
|------:|------|
|**语法**|**ssl_prefer_server_ciphers** `on` &#124; `off`;|
|**默认**|rssl_prefer_server_ciphers off;|
|**上下文**|stream、server|

指定当使用 SSLv3 和 TLS 协议时，服务器密码算法应优先于客户端密码算法。

### ssl_protocols

|\-|说明|
|------:|------|
|**语法**|**ssl_protocols** `[SSLv2] [SSLv3] [TLSv1] [TLSv1.1] [TLSv1.2] [TLSv1.3]`;|
|**默认**|rssl_protocols TLSv1 TLSv1.1 TLSv1.2;|
|**上下文**|stream、server|

启用指定的协议。

> `TLSv1.1` 和 `TLSv1.2` 参数仅在使用 OpenSSL 1.0.1 或更高版本时有效。

> `TLSv1.3` 参数（1.13.0）仅在使用通过 TLSv1.3 支持构建的 OpenSSL 1.1.1 时有效。

### ssl_session_cache

|\-|说明|
|------:|------|
|**语法**|**ssl_session_cache** `off` &#124; `none` &#124; `[builtin[:size]] [shared:name:size]`;|
|**默认**|ssl_session_cache none;|
|**上下文**|stream、server|

设置存储会话参数的缓存的类型和大小。缓存可以是以下任何一种：

- `off`

    严格禁止使用会话缓存：nginx 明确告知客户端不得重复使用会话

- `none`

    禁止使用会话缓存：nginx 告诉客户端会话可以被重用，但实际上并没有在缓存中存储会话参数

- `builtin`

    内置 OpenSSL 的缓存；仅由一个 worker 进程使用。缓存大小在会话中指定。如果未提供大小，则等于 20480 个会话。使用内置缓存可能导致内存碎片。

- `shared`

    所有 worker 进程之间共享的缓存。缓存大小以字节为单位，一兆字节可以存储大约 4000 个会话。每个共享缓存都有一个名称。有相同名称的缓存可以在多个服务器中使用。

可以同时使用两种缓存类型，例如：

```nginx
ssl_session_cache builtin:1000 shared:SSL:10m;
```

但关闭内置缓存仅使用共享缓存会更有效率。

### ssl_session_ticket_key

|\-|说明|
|------:|------|
|**语法**|**ssl_session_ticket_key** `file`;|
|**默认**|——|
|**上下文**|stream、server|

设置一个存有用于加密和解密 TLS 会话票证的密钥文件。如果必须在多个服务器之间共享同一密钥，则该指令是必需的。默认情况下，使用随机生成的密钥。

如果指定了多个密钥，则仅第一个密钥用于加密 TLS 会话票证。也可以配置键轮转，例如：

```nginx
ssl_session_ticket_key current.key;
ssl_session_ticket_key previous.key;
```

该文件必须包含 80 或 48 个字节的随机数，可以使用以下命令创建：

```
openssl rand 80> ticket.key
```

根据文件大小，使用 AES256（针对 80 字节的密钥，1.11.8）或 AES128（针对 48 字节的密钥）进行加密。

### ssl_session_tickets

|\-|说明|
|------:|------|
|**语法**|**ssl_session_tickets** `on` &#124; `off`;|
|**默认**|rssl_session_tickets on;|
|**上下文**|stream、server|

通过 [TLS 会话票证](https://tools.ietf.org/html/rfc5077)启用或禁用会话恢复。

### ssl_session_timeout

|\-|说明|
|------:|------|
|**语法**|**ssl_session_timeout** `time`;|
|**默认**|ssl_session_timeout 5m;|
|**上下文**|stream、server|

指定一个客户端可以重用会话参数的时间时长。

### ssl_trusted_certificate

|\-|说明|
|------:|------|
|**语法**|**ssl_trusted_certificate** `file`;|
|**默认**|——|
|**上下文**|stream、server|
|**提示**|该指令在 1.11.8 版本中出现|

指定一个用于[验证](#ssl_verify_client)客户端证书的可信 CA 证书 PEM 文件。

与 [ssl_client_certificate](#ssl_client_certificate) 设置的证书相反，这些证书的列表不会发送给客户端。

### ssl_verify_client

|\-|说明|
|------:|------|
|**语法**|**ssl_verify_client** `on` &#124; `off` &#124; `optional` &#124; `optional_no_ca`;|
|**默认**|ssl_verify_client off;|
|**上下文**|stream、server|
|**提示**|该指令在 1.11.8 版本中出现|

启用客户端证书的验证。验证结果存储在 [$ssl_client_verify](#var_ssl_client_verify) 变量中。如果在验证客户端证书期间发生错误，或者客户端未提供所需的证书，则连接将关闭。

`optional` 参数请求客户端证书，当证书存在时对其进行验证。

`optional_no_ca` 参数请求客户端证书，但不需要由可信 CA 证书对其进行签名。这用于在 nginx 外部的服务执行实际证书验证的情况下使用。可以通过 [$ssl_client_cert](#var_ssl_client_cert) 变量访问证书的内容。

### ssl_verify_depth

|\-|说明|
|------:|------|
|**语法**|**ssl_verify_depth** `number`;|
|**默认**|ssl_verify_depth 1;|
|**上下文**|stream、server|
|**提示**|该指令在 1.11.8 版本中出现|

设置客户端证书链的验证深度。

<a id="embedded_variables"></a>

## 内置变量

自 1.11.2 版本起，`ngx_stream_ssl_module` 模块支持以下变量：

- `$ssl_cipher`

    返回用于已建立的 SSL 连接使用的密码算法的名称

- `$ssl_ciphers`

    返回客户端支持的密码算法列表（1.11.7）。已知密码算法按名称列出，未知密码算法以十六进制显示，例如：

    ```
    AES128-SHA:AES256-SHA:0x00ff
    ```

    > 仅当使用 OpenSSL 1.0.2 或更高版本时，才完全支持该变量。对于较旧的版本，该变量仅适用于新会话，并且仅列出已知密码算法。

- `$ssl_client_cert`

    以 PEM 格式返回建立已建立的 SSL 连接的客户端证书，除第一行外，每行均以制表符开头（1.11.8）

- `$ssl_client_fingerprint`

    返回已建立的 SSL 连接的客户端证书的 SHA1 指纹（1.11.8）

- `$ssl_client_i_dn`

    为建立的 SSL 连接返回客户端证书的 [RFC 2253](https://tools.ietf.org/html/rfc2253) **issuer DN** 字符串（1.11.8）

- `$ssl_client_raw_cert`

    以 PEM 格式返回已建立的 SSL 连接的客户端证书（1.11.8）

- `$ssl_client_s_dn`

    返回已建立的 SSL 连接的客户端证书的 [RFC 2253](https://tools.ietf.org/html/rfc2253) **subject DN** 字符串（1.11.8）

- `$ssl_client_serial`

    返回已建立的 SSL 连接的客户端证书的序列号（1.11.8）

- `$ssl_client_v_end`

    返回客户证书的截止日期（1.11.8）

- `$ssl_client_v_remain`

    返回客户端证书距离过期剩余的有效天数（1.11.8）

- `$ssl_client_v_start`

    返回客户端证书的开始日期（1.11.8）

- `$ssl_client_verify`

    如果没有证书，则返回客户端证书验证的结果（1.11.8）：`SUCCESS`、`FAILED:reason` 和 `NONE`

- `$ssl_curves`

    返回客户端支持的椭圆曲线列表（1.11.7）。已知椭圆曲线按名称列出，未知曲线以十六进制显示，例如：

    ```
    0x001d:prime256v1:secp521r1:secp384r1
    ```

    > 仅当使用 OpenSSL 1.0.2 或更高版本时才支持该变量。在旧版本中，变量值将为空字符串。

    > 该变量仅适用于新会话。

- `$ssl_protocol`

    返回已建立的 SSL 连接的协议

- `$ssl_server_name`

    返回通过 [SNI](http://en.wikipedia.org/wiki/Server_Name_Indication) 请求的服务器名称

- `$ssl_session_id`

    返回已建立的 SSL 连接的会话标识符

- `$ssl_session_reused`

    如果 SSL 会话被复用，则返回 `r`，否则返回 `.`


## 原文档

[http://nginx.org/en/docs/stream/ngx_stream_ssl_module.html](http://nginx.org/en/docs/stream/ngx_stream_ssl_module.html)