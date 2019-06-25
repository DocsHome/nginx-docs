# ngx_http_ssi_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [ssl](#ssl)
    - [ssl_buffer_size](#ssl_buffer_size)
    - [ssl_certificate](#ssl_certificate)
    - [ssl_certificate_key](#ssl_certificate_key)
    - [ssl_ciphers](#ssl_ciphers)
    - [ssl_client_certificate](#ssl_client_certificate)
    - [ssl_crl](#ssl_crl)
    - [ssl_dhparam](#ssl_dhparam)
    - [ssl_early_data](#ssl_early_data)
    - [ssl_ecdh_curve](#ssl_ecdh_curve)
    - [ssl_password_file](#ssl_password_file)
    - [ssl_prefer_server_ciphers](#ssl_prefer_server_ciphers)
    - [ssl_protocols](#ssl_protocols)
    - [ssl_session_cache](#ssl_session_cache)
    - [ssl_session_ticket_key](#ssl_session_ticket_key)
    - [ssl_session_tickets](#ssl_session_tickets)
    - [ssl_session_timeout](#ssl_session_timeout)
    - [ssl_stapling](#ssl_stapling)
    - [ssl_stapling_file](#ssl_stapling_file)
    - [ssl_stapling_responder](#ssl_stapling_responder)
    - [ssl_stapling_verify](#ssl_stapling_verify)
    - [ssl_trusted_certificate](#ssl_trusted_certificate)
    - [ssl_verify_client](#ssl_verify_client)
    - [ssl_verify_depth](#ssl_verify_depth)
- [错误处理](#errors)
- [内嵌变量](#embedded_variables)

`ngx_http_ssl_module` 模块为 HTTPS 提供必要的支持。

默认不构建此模块，在构建时可使用 `--with-http_ssl_module` 配置参数启用。

> 该模块依赖 [OpenSSL](http://www.openssl.org/) 库。

<a id="example_configuration"></a>

## 示例配置

为减少 CPU 的负载，建议

- 设置 worker 进程数等于 CPU 核心数
- 启用 [keep-alive](ngx_http_core_module.md#keepalive_timeout) 连接
- 启用[共享](ngx_http_ssl_module.md#ssl_session_cache_shared)会话缓存
- 禁用[内置](ngx_http_ssl_module.md#ssl_session_cache_builtin)会话缓存
- 可增长会话[生命周期](ngx_http_ssl_module.md#ssl_session_timeout)（默认为 5 分钟）

```nginx
worker_processes auto;

http {

    ...

    server {
        listen              443 ssl;
        keepalive_timeout   70;

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
|**默认**|ssi off;|
|**上下文**|http、server|

该指令在 1.15.0 版本中已过时。应使用 [listen](ngx_http_core_module.md#listen) 指令的 `ssl` 参数设置。

### ssl_buffer_size

|\-|说明|
|:------|:------|
|**语法**|**ssl_buffer_size** `size`;|
|**默认**|ssl_buffer_size 16k;|
|**上下文**|http、server|
|**提示**|该指令在 1.5.9 版本中出现|

设置发送数据的缓冲区大小。

缓冲区默认大小为 16k，对应发送大响应时的最小开销。要将首字节时间（TTFB，Time To First Byte）减到最小，设置较小的值可能会有不错的效果，如：

```
ssl_buffer_size 4k;
```

### ssl_certificate

|\-|说明|
|:------|:------|
|**语法**|**ssl_certificate** `file`;|
|**默认**|——|
|**上下文**|http、server|

指定一个有给定虚拟服务器的 PEM 证书文件（`file`）。如果除了主证书之外还要指定中级证书，则应按以下顺序在同一文件中指定它们：首先是主证书，然后是中级证书。PEM 格式的密钥可以放在同一文件中。

从 1.11.0 版本开始，可以多次指定此指令以加载不同类型的证书，例如，RSA 和 ECDSA：

```nginx
server {
    listen              443 ssl;
    server_name         example.com;

    ssl_certificate     example.com.rsa.crt;
    ssl_certificate_key example.com.rsa.key;

    ssl_certificate     example.com.ecdsa.crt;
    ssl_certificate_key example.com.ecdsa.key;

    ...
}
```

> 只有 OpenSSL 1.0.2 或更高版本才支持不同证书的独立[证书链](../../介绍/配置HTTPS服务器.md#chains)。对于旧版本，只能使用一个证书链。

从 1.15.9 版本开始，使用 OpenSSL 1.0.2 或更高版本时，可在 `file` 文件名中使用变量：

```nginx
ssl_certificate     $ssl_server_name.crt;
ssl_certificate_key $ssl_server_name.key;
```

请注意，使用变量意味着每次 SSL 握手都会加载证书，这可能会对性能产生负面影响。

可以指定值 `data:$variable` 来代替 `file`（1.15.10），证书将从变量中加载而不使用中间文件。请注意，不恰当地使用此语法可能会产生安全隐患，例如将密钥数据写入[错误日志](../核心功能.md#error_log)。

记住，由于 HTTPS 协议对最大互操作性的限制，虚拟服务器应[监听不同的 IP 地址](configuring_https_servers.md#name_based_https_servers)。

### ssl_certificate_key

|\-|说明|
|:------|:------|
|**语法**|**ssl_certificate_key** `file`;|
|**默认**|——|
|**上下文**|http、server|

指定有给定虚拟服务器的 PEM 密钥文件。

可以指定值 `engine:name:id` 来代替是 `file`（1.7.9），从 OpenSSL 引擎 `name` 加载有指定 `id` 的密钥。

可以指定值 `data:$variable` 替代 `file`（1.15.10），将从变量加载密钥而不使用中间文件。请注意，不恰当地使用此语法可能会产生安全隐患，例如将密钥数据写入[错误日志](../核心功能.md#error_log)。

从 1.15.9 版本开始，使用 OpenSSL 1.0.2 或更高版本时，可在 `file` 文件名中使用变量。

### ssl_ciphers

|\-|说明|
|:------|:------|
|**语法**|**ssl_ciphers** `ciphers`;|
|**默认**|ssl_ciphers HIGH:!aNULL:!MD5;|
|**上下文**|http、server|

指定启用的密码。密码以 OpenSSL 库支持的格式指定，例如：

```
ssl_ciphers ALL:!aNULL:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP;
```

可以使用 `openssl ciphers` 命令查看完整列表。

> 以前版本的 nginx 默认使用了[不同](../../介绍/配置HTTPS服务器.md#compatibility)的密码。

### ssl_client_certificate

|\-|说明|
|:------|:------|
|**语法**|**ssl_client_certificate** `file`;|
|**默认**|——|
|**上下文**|http、server|

如果启用了 [ssl_stapling](#ssl_stapling)，则指定一个有可信 CA 的 PEM 证书文件，该证书用于[验证](#ssl_verify_client)客户端证书和 OCSP 响应。

证书列表将被发送到客户端。如果不需要，可以使用 [ssl_trusted_certificate](#ssl_trusted_certificate) 指令设置。

### ssl_crl

|\-|说明|
|:------|:------|
|**语法**|**ssl_crl** `file`;|
|**默认**|——|
|**上下文**|http、server|
|**提示**|该指令在 0.8.7 版本中出现|

指定 PEM 格式的已吊销证书（CRL）文件（`file`），用于[验证](#ssl_verify_client)客户端证书。

### ssl_dhparam

|\-|说明|
|:------|:------|
|**语法**|**ssl_dhparam** `file`;|
|**默认**|——|
|**上下文**|http、server|
|**提示**|该指令在 0.7.2 版本中出现|

为 DHE 密码指定 DH 参数文件。

默认不设置任何参数，因此不会使用 DHE 密码。

> 在 1.11.0 版之前，默认使用内置参数。

### ssl_early_data

|\-|说明|
|:------|:------|
|**语法**|**ssl_early_data** `on` &#124; `off`;|
|**默认**|ssl_early_data off;|
|**上下文**|http、server|
|**提示**|该指令在 1.15.3 版本中出现|

启用或禁用 TLS 1.3 [Early data](https://tools.ietf.org/html/rfc8446#section-2.3)。

> 带有 Early data 的请求将受到[重放攻击](https://tools.ietf.org/html/rfc8470)。为了防止应用层受到此类攻击，应使用 [$ssl_early_data](#var_ssl_early_data) 变量避免。

```
proxy_set_header Early-Data $ssl_early_data;
```

> BoringSSL、OpenSSL 1.1.1 或更高版本（1.15.4）支持该指令。

### ssl_ecdh_curve

|\-|说明|
|:------|:------|
|**语法**|**ssl_ecdh_curve** `curve`;|
|**默认**|ssl_ecdh_curve auto;|
|**上下文**|http、server|
|**提示**|该指令在 1.1.0 和 1.0.6 版本中出现|

指定 ECDHE 密码的 `curve`。

使用 OpenSSL 1.0.2 或更高版本时，可以指定多个 curve（1.11.0），例如：

```
ssl_ecdh_curve prime256v1:secp384r1;
```

特殊值 `auto`（1.11.0）指示 nginx 在使用 OpenSSL 1.0.2 或更高版本时使用内置在 OpenSSL 库中的列表，或者使用旧版本的 prime256v1。

在 1.11.0 版本之前，默认使用 `prime256v1` curve。

### ssl_password_file

|\-|说明|
|:------|:------|
|**语法**|**ssl_password_file** `file`;|
|**默认**|——|
|**上下文**|http、server|
|**提示**|该指令在 1.7.3 版本中出现|

指定一个有[密钥](#ssl_certificate_key)的文件（`file`），每个密码按行指定。在加载密钥时依次尝试。

例：

```nginx
http {
    ssl_password_file /etc/keys/global.pass;
    ...

    server {
        server_name www1.example.com;
        ssl_certificate_key /etc/keys/first.key;
    }

    server {
        server_name www2.example.com;

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
|**上下文**|http、server|

指定在使用 SSLv3 和 TLS 协议时，服务器密码应优先于客户端密码。

### ssl_protocols

|\-|说明|
|:------|:------|
|**语法**|**ssl_protocols** `[SSLv2] [SSLv3] [TLSv1] [TLSv1.1] [TLSv1.2] [TLSv1.3]`;|
|**默认**|ssl_protocols TLSv1 TLSv1.1 TLSv1.2;|
|**上下文**|http、server|

启用指定的协议。

> TLSv1.1 和 TLSv1.2 参数（1.1.13、1.0.12）仅在使用 OpenSSL 1.0.1 或更高版本时有效。

> 仅当使用 TLSv1.3 支持构建的 OpenSSL 1.1.1 时，TLSv1.3 参数（1.13.0）才有效。

### ssl_session_cache

|\-|说明|
|:------|:------|
|**语法**|**ssl_session_cache** `off \| none \| [builtin[:size]] [shared:name:size]`;|
|**默认**|ssl_session_cache none;|
|**上下文**|http、server|

设置存储会话参数的缓存的类型和大小。缓存可以是以下任何类型：

- `off`

    完全禁止使用会话缓存：nginx 明确告诉客户端会话可能不会被重用。

- `none`

    轻度禁止使用会话缓存：nginx 告诉客户端会话可以重用，但实际上并不会将会话参数存储在缓存中。

- `builtin`

    一个用 OpenSSL 构建的缓存，仅由一个 worker 进程使用。缓存大小在会话中指定。如果未指定大小，则默认为 20480 个会话。使用内置缓存可能会导致内存碎片。

- `shared`

    所有 worker 进程之间共享的缓存。缓存大小以字节为单位指定，一兆字节可以存储大约 4000 个会话。每个共享缓存都应有一个任意的名称。可以在多个虚拟服务器中使用有相同名称的缓存。

两种缓存类型可以同时使用，例如：

```
ssl_session_cache builtin:1000 shared:SSL:10m;
```

但只使用没有内置缓存的共享缓存会更好。

### ssl_session_ticket_key

|\-|说明|
|:------|:------|
|**语法**|**ssl_session_ticket_key** `file`;|
|**默认**|——|
|**上下文**|http、server|
|**提示**|该指令在 1.5.7 版本中出现|

设置一个用于加密和解密 TLS 会话 ticket 的密钥文件。如果必须在多个服务器之间共享相同的密钥，则该指令是必需的。默认情况下，使用随机生成的密钥。

如果指定了多个密钥，则仅使用第一个密钥来加密 TLS 会话 ticket。允许配置秘钥轮转，例如：

```nginx
ssl_session_ticket_key current.key;
ssl_session_ticket_key previous.key;
```

该文件必须包含 80 或 48 个字节的随机数，可以使用以下命令创建：

```
openssl rand 80 > ticket.key
```

根据文件大小，AES256（对于 80 字节密钥，1.11.8）或 AES128（对于 48 字节密钥）用于加密。

### ssl_session_tickets

|\-|说明|
|:------|:------|
|**语法**|**ssl_session_tickets** `on` &#124; `off`;|
|**默认**|ssl_session_tickets on;|
|**上下文**|http、server|
|**提示**|该指令在 1.5.9 版本中出现|

通过 [TLS 会话 ticket](https://tools.ietf.org/html/rfc5077) 启用或禁用会话重用。

### ssl_session_timeout

|\-|说明|
|:------|:------|
|**语法**|**ssl_session_timeout** `time`;|
|**默认**|ssl_session_timeout 5m;|
|**上下文**|http、server|

指定客户端可以重用会话参数的时间。

### ssl_stapling

|\-|说明|
|:------|:------|
|**语法**|**ssl_stapling** `on` &#124; `off`;|
|**默认**|ssl_stapling off;|
|**上下文**|http、server|
|**提示**|该指令在 1.3.7 版本中出现|

启用或禁用服务器 OCSP stapling：

```nginx
ssl_stapling on;
resolver 192.0.2.1;
```

要使 OCSP stapling 起作用，应知道服务器证书颁发者的证书。如果 [ssl_certificate](#ssl_certificate) 文件不包含中级证书，则服务器证书颁发者的证书应存在于 [ssl_trusted_certificate](#ssl_trusted_certificate) 文件中。

要解析 OCSP 响应器主机名，还应指定 [resolver](ngx_http_core_module.md#resolver) 指令。

### ssl_stapling_file

|\-|说明|
|:------|:------|
|**语法**|**ssl_stapling_file** `file`;|
|**默认**|——|
|**上下文**|http、server|
|**提示**|该指令在 1.3.7 版本中出现|

设置后，将从指定的文件中获取 OCSP stapling 响应，而不是查询服务器证书中指定的 OCSP 响应器。

该文件应为 DER 格式，由 `openssl ocsp` 命令生成。

### ssl_stapling_responder

|\-|说明|
|:------|:------|
|**语法**|**ssl_stapling_responder** `url`;|
|**默认**|——|
|**上下文**|http、server|
|**提示**|该指令在 1.3.7 版本中出现|

覆盖 [`Authority Information Access`](https://tools.ietf.org/html/rfc5280#section-4.2.2.1) 证书扩展中指定的 OCSP 响应器的 URL。

仅支持 `http://` OCSP 响应器（responder）：

```nginx
ssl_stapling_responder http://ocsp.example.com/;
```

### ssl_stapling_verify

|\-|说明|
|:------|:------|
|**语法**|**ssl_stapling_verify** `on` &#124; `off`;|
|**默认**|ssl_stapling_verify off;|
|**上下文**|http、server|
|**提示**|该指令在 1.3.7 版本中出现|

启用或禁用服务器对 OCSP 响应的验证。

要使验证生效，应使用 [ssl_trusted_certificate](#ssl_trusted_certificate) 指令将服务器证书颁发者的证书、根证书和所有中级证书配置为受信任。

### ssl_trusted_certificate

|\-|说明|
|:------|:------|
|**语法**|**ssl_trusted_certificate** `file`;|
|**默认**|——|
|**上下文**|http、server|
|**提示**|该指令在 1.3.7 版本中出现|

如果启用了 [ssl_stapling](#ssl_stapling)，则指定一个 PEM 格式的可信 CA 证书文件，该证书用于验证客户端证书和 OCSP 响应。

与 [ssl_client_certificate](#ssl_client_certificate) 设置的证书不同，这些证书的列表不会发送给客户端。

### ssl_verify_client

|\-|说明|
|:------|:------|
|**语法**|**ssl_verify_client** `on` &#124; `off` &#124; `optional` &#124; `optional_no_ca`;|
|**默认**|ssl_stapling_verify off;|
|**上下文**|http、server|

启用客户端证书验证。验证结果存储在 [`$ssl_client_verify`](#var_ssl_client_verify) 变量中。

`optional` 参数（0.8.7+）请求客户端证书，并在证书存在时验证。

`optional_no_ca` 参数（1.3.8、1.2.5）请求客户端证书，但不要求它由受信任的 CA 证书签名。这适用于 nginx 外部服务执行实际证书验证的情况。可以通过 [$ssl_client_cert](#var_ssl_client_cert) 变量访问证书内容。

### ssl_verify_depth

|\-|说明|
|:------|:------|
|**语法**|**ssl_verify_depth** `number`;|
|**默认**|ssl_verify_depth 1;|
|**上下文**|http、server|

设置客户端证书链的验证深度。

## 错误处理

<a id="errors"></a>

ngx_http_ssl_module 模块支持几个非标准错误代码，可以使用 [error_page](ngx_http_core_module.md#error_page) 指令来重定向：

- `495`

    客户端证书验证期间发生错误

- `496`

    客户未提交所需证书

- `497`

    已将常规请求发送到 HTTPS 端口

在完全解析请求并且变量（例如 `$request_uri`、`$uri`、`$args` 和其他变量）可用之后，就会发生重定向。

<a id="embedded_variables"></a>

## 内嵌变量

`ngx_http_ssl_module` 模块支持以下嵌入变量：

- `$ssl_cipher`

    返回用于一个已建立的 SSL 连接的密码字符串

- `$ssl_ciphers`

    返回客户端支持的密码列表（1.11.7）。已知密码按名称列出，未知则以十六进制显示，例如：

    ```
    AES128-SHA:AES256-SHA:0x00ff
    ```
    
    仅在使用 OpenSSL 1.0.2 或更高版本时才完全支持该变量。对于旧版本，该变量仅适用于新会话，仅列出已知密码。

- `$ssl_client_escaped_cert`

    以 PEM 格式（urlencoded）返回已建立 SSL 连接的客户端证书（1.13.5）

- `$ssl_client_cert`

    为已建立的 SSL 连接返回 PEM 格式的客户端证书。除了第一行，前面的每一行都带有制表符。这适用于 [proxy_set_header](ngx_http_proxy_module.md#proxy_set_header) 指令。

    > 不推荐使用该变量，应该使用 `$ssl_client_escaped_cert` 变量。

- `$ssl_client_fingerprint`

    返回已建立 SSL 连接的客户端证书的 SHA1 指纹（1.7.1）

- `$ssl_client_i_dn`

    根据 RFC 2253（1.11.6），为已建立的 SSL 连接返回客户端证书的 `issuer DN` 字符串;

- `$ssl_client_i_dn_legacy`

    返回已建立的 SSL 连接的客户端证书的 `issuer DN` 字符串。

    > 在 1.11.6 版之前，变量名称为 `$ssl_client_i_dn`。

- `$ssl_client_raw_cert`

    返回已建立 SSL 连接的 PEM 格式的客户端证书

- `$ssl_client_s_dn`

    根据 RFC 2253（1.11.6），为已建立的 SSL 连接返回客户端证书的 `subject DN` 字符串

- `$ssl_client_s_dn_legacy`

    返回已建立 SSL 连接的客户端证书的 `subject DN `字符串

    > 在 1.11.6 版之前，变量名称为 `$ssl_client_s_dn`。

- `$ssl_client_serial`

    返回已建立的 SSL 连接的客户端证书的序列号

- `$ssl_client_v_end`

    返回客户端证书的结束日期（1.11.7）

- `$ssl_client_v_remain`

    返回客户端证书到期前的天数（1.11.7）

- `$ssl_client_v_start`

    返回客户端证书的开始日期（1.11.7）

- `$ssl_client_verify`

    返回客户端证书验证的结果：`SUCCESS`、`FAILED:reason`，如果证书不存在则返回 `NONE`。

    > 在 1.11.7 版之前，`FAILED` 结果不包含原因字符串

- `$ssl_curves`

    返回客户端支持的 curve 列表（1.11.7）。已知 curve 按名称列出，未知以十六进制显示，例如：

    ```
    0x001d:prime256v1:secp521r1:secp384r1
    ```

    > 仅在使用 OpenSSL 1.0.2 或更高版本时才支持该变量。对于旧版本，变量值将为空字符串。

    > 该变量仅适用于新会话。

- `$ssl_early_data`

    如果使用 TLS 1.3 [Early data](#ssl_early_data) 并且握手未完成则返回 `"1"`，否则返回 `""`（1.15.3）。

- `$ssl_protocol`

    返回已建立的 SSL 连接的协议

- `$ssl_server_name`

    返回通过 SNI（1.7.0）请求的服务器名称

- `$ssl_session_id`

    返回已建立的 SSL 连接的会话标识

- `$ssl_session_reused`

    如果重用 SSL 会话则返回 `"r"`，否则返回 `"."`（1.5.11）。

## 原文档

- [http://nginx.org/en/docs/http/ngx_http_ssl_module.html](http://nginx.org/en/docs/http/ngx_http_ssl_module.html)
