#   - [grpc_bind](#grpc_bind)
  ngx_http_grpc_module

- [指令](#directives)
    - [grpc_buffer_size](#grpc_buffer_size)
    - [grpc_connect_timeout](#grpc_connect_timeout)
    - [grpc_hide_header](#grpc_hide_header)
    - [grpc_ignore_headers](#grpc_ignore_headers)
    - [grpc_intercept_errors](#grpc_intercept_errors)
    - [grpc_next_upstream](#grpc_next_upstream)
    - [grpc_next_upstream_timeout](#grpc_next_upstream_timeout)
    - [grpc_next_upstream_tries](#grpc_next_upstream_tries)
    - [grpc_pass](#grpc_pass)
    - [grpc_pass_header](#grpc_pass_header)
    - [grpc_read_timeout](#grpc_read_timeout)
    - [grpc_send_timeout](#grpc_send_timeout)
    - [grpc_set_header](#grpc_set_header)
    - [grpc_ssl_certificate](#grpc_ssl_certificate)
    - [grpc_ssl_certificate_key](#grpc_ssl_certificate_key)
    - [grpc_ssl_ciphers](#grpc_ssl_ciphers)
    - [grpc_ssl_crl](#grpc_ssl_crl)
    - [grpc_ssl_name](#grpc_ssl_name)
    - [grpc_ssl_password_file](#grpc_ssl_password_file)
    - [grpc_ssl_server_name](#grpc_ssl_server_name)
    - [grpc_ssl_session_reuse](#grpc_ssl_session_reuse)
    - [grpc_ssl_protocols](#grpc_ssl_protocols)
    - [grpc_ssl_trusted_certificate](#grpc_ssl_trusted_certificate)
    - [grpc_ssl_verify](#grpc_ssl_verify)
    - [grpc_ssl_verify_depth](#grpc_ssl_verify_depth)

`ngx_http_grpc_module` 模块允许将请求传递给 gRPC 服务器（1.13.10）。该模块需要 [ngx_http_v2_module](ngx_http_v2_module.md) 模块的支持。

<a id="example_configuration"></a>

## 示例配置

```nginx
server {
    listen 9000 http2;

    location / {
        grpc_pass 127.0.0.1:9000;
    }
}
```

<a id="directives"></a>

## 指令

### grpc_bind

|\-|说明|
|------:|------|
|**语法**|**map** `address [transparent ]` &#124; `off`;|
|**默认**|——|
|**上下文**|http、server、location|

连接到一个指定了本地 IP 地址和可选端口的 gRPC 服务器。参数值可以包含变量。特殊值 `off` 取消从上层配置级别继承的 `grpc_bind` 指令的作用，其允许系统自动分配本地 IP 地址和端口。

`transparent` 参数允许出站从非本地 IP 地址到 gRPC 服务器的连接（例如，来自客户端的真实 IP 地址）：

```nginx
grpc_bind $remote_addr transparent;
```

为了使这个参数起作用，通常需要以[超级用户](../核心模块.md#user)权限运行 nginx worker 进程。在 Linux 上，不需要指定 `transparent` 参数，工作进程会继承 master 进程的 `CAP_NET_RAW` 功能。此外，还要配置内核路由表来拦截来自 gRPC 服务器的网络流量。

### grpc_buffer_size

|\-|说明|
|------:|------|
|**语法**|**grpc_buffer_size** `size`;|
|**默认**|grpc_buffer_size 4k&#124;8k;|
|**上下文**|http、server、location|

设置用于读取从 gRPC 服务器收到的响应的缓冲区的大小（`size`）。一旦收到响应，响应便会同步传送给客户端。

### grpc_connect_timeout

|\-|说明|
|------:|------|
|**语法**|**grpc_connect_timeout** `time`;|
|**默认**|grpc_connect_timeout 60s;|
|**上下文**|http、server、location|

定义与 gRPC 服务器建立连接的超时时间。需要说明的是，超时通常不能超过 75 秒。

### grpc_hide_header

|\-|说明|
|------:|------|
|**语法**|**grpc_hide_header** `field`;|
|**默认**|——|
|**上下文**|http、server、location|

默认情况下，nginx 不会将 gRPC 服务器响应中的头字段 `Date`、`Server` 和 `X-Accel-...` 传送给客户端。`grpc_hide_header` 指令设置了不会被传送的附加字段。相反，如果需要允许传送字段，则可以使用 [grpc_pass_header](#grpc_pass_header) 指令设置。

### grpc_ignore_headers

|\-|说明|
|------:|------|
|**语法**|**grpc_ignore_headers** `field ...`;|
|**默认**|——|
|**上下文**|http、server、location|

禁用处理来自 gRPC 服务器的某些响应头字段。以下字段可以忽略：`X-Accel-Redirect` 和 `X-Accel-Charset`。

如果未禁用，处理这些头字段将产生以下作用：

- `X-Accel-Redirect` 执行[内部重定](../核心模块.md#internal)向到指定的 URI
- `X-Accel-Charset` 设置所需的响应[字符集](ngx_http_charset_module.md#charset)

### grpc_intercept_errors

|\-|说明|
|------:|------|
|**语法**|**grpc_intercept_errors** `on` &#124; `off`;|
|**默认**|grpc_intercept_errors off;|
|**上下文**|http、server、location|

确定状态码大于或等于 300 的 gRPC 服务器响应是应该传送给客户端还是拦截并重定向到 nginx 使用 [error_page](../核心模块.md#error_page) 指令进行处理。

### grpc_next_upstream

|\-|说明|
|------:|------|
|**语法**|**grpc_next_upstream** `error` &#124; `timeout` &#124; `invalid_header` &#124; `http_500` &#124; `http_502` &#124; `http_503` &#124; `http_504` &#124; `http_403` &#124; `http_404` &#124; `http_429` &#124; `non_idempotent` &#124; `off ...`;|
|**默认**|grpc_next_upstream error timeout;|
|**上下文**|http、server、location|

指定在哪些情况下请求应传递给下一个服务器：

- `error`

    在与服务器建立连接、传递请求或读取响应头时发生错误

- `timeout`

    在与服务器建立连接、传递请求或读取响应头时发生超时

- `invalid_header`

    服务器返回了空的或无效的响应

- `http_500`

    服务器返回状态码为 500 的响应

- `http_502`

    服务器返回状态码为 502 的响应

- `http_503`

    服务器返回状态码为 503 的响应

- `http_504`

    服务器返回状态码为 504 的响应

- `http_403`

    服务器返回状态码为 403 的响应

- `http_404`

    服务器返回状态码为 404 的响应

- `http_429`

    服务器返回状态码为 429 的响应

- `non_idempotent`

    通常，如果请求已发送到上游服务器，请求方法为非幂等（POST、LOCK、PATCH）的请求是不会传送到下一个服务器，使这个选项将明确允许重试这样的请求

- `off`

    禁止将请求传递给下一个服务器

我们应该记住，只有在没有任何内容发送给客户端的情况下，才能将请求传递给下一个服务器。也就是说，如果在响应传输过程中发生错误或超时，修复这样的错误是不可能的。

该指令还定义了与服务器进行通信的[失败尝试](ngx_http_upstream_module.md#max_fails)。`error`、`timeout` 和 `invalid_header` 的情况总是被认为是失败尝试，即使它们没有在指令中指定。只有在指令中指定了 `http_500`、`http_502`、`http_503`、`http_504` 和 `http_429` 的情况下，才会将其视为失败尝试。`http_403` 和 `http_404` 的情况永远不会被视为失败尝试。

将请求传递给下一个服务器可能受到[尝试次数](#grpc_next_upstream_tries)和[时间](#grpc_next_upstream_timeout)的限制。

### grpc_next_upstream_timeout

|\-|说明|
|------:|------|
|**语法**|**grpc_next_upstream_timeout** `time`;|
|**默认**|grpc_next_upstream_timeout 0;|
|**上下文**|http、server、location|

限制请求可以传递到[下一个服务器](#grpc_next_upstream)的时间。`0` 值表示关闭此限制。

### grpc_next_upstream_tries

|\-|说明|
|------:|------|
|**语法**|**grpc_next_upstream_tries** `number`;|
|**默认**|grpc_next_upstream_tries 0;|
|**上下文**|http、server、location|

限制尝试将请求传递到[下一个服务器](#grpc_next_upstream)的次数。`0` 值表示关闭此限制。

### grpc_pass

|\-|说明|
|------:|------|
|**语法**|**grpc_pass** `address`;|
|**默认**|——|
|**上下文**|location、location 中的 if|

设置 gRPC 服务器地址。该地址可以指定为域名或 IP 地址以及端口：

```nginx
grpc_pass localhost:9000;
```
或使用 UNIX 域套接字路径：

```nginx
grpc_pass unix:/tmp/grpc.socket;
```

或使用 `grpc://` scheme：

```nginx
grpc_pass grpc://127.0.0.1:9000;
```

要 gRPC 配合 SSL，应该使用 `grpcs://` scheme：

```nginx
grpc_pass grpcs://127.0.0.1:443;
```

如果域名解析为多个地址，则这些地址将以循环方式使用。另外，地址可以被指定为[服务器组](ngx_http_upstream_module.md)。

### grpc_pass_header

|\-|说明|
|------:|------|
|**语法**|**grpc_pass_header** `field`;|
|**默认**|——|
|**上下文**|http、server、location|

允许从 gRPC 服务器向客户端传递忽略的头字段。

### grpc_read_timeout

|\-|说明|
|------:|------|
|**语法**|**grpc_read_timeout** `time`;|
|**默认**|grpc_read_timeout 60s;|
|**上下文**|http、server、location|

定义从 gRPC 服务器读取响应的超时时间。超时间隔只在两次连续的读操作之间，而不是整个响应的传输过程。如果 gRPC 服务器在此时间内没有发送任何内容，则连接关闭。

### grpc_send_timeout

|\-|说明|
|------:|------|
|**语法**|**grpc_send_timeout** `time`;|
|**默认**|grpc_send_timeout 60s;|
|**上下文**|http、server、location|

设置向 gRPC 服务器发送请求的超时时间。超时间隔只在两次连续写入操作之间，而不是整个请求的传输过程。如果 gRPC 服务器在此时间内没有收到任何内容，则连接将关闭。

### grpc_set_header

|\-|说明|
|------:|------|
|**语法**|**grpc_set_header** `field value`;|
|**默认**|grpc_set_header Content-Length $content_length;|
|**上下文**|http、server、location|

允许重新定义或附加字段到[传递](#grpc_pass_request_headers)给 gRPC 服务器的请求头。该值可以包含文本、变量及其组合。当且仅当在当前级别上没有定义 `grpc_set_header` 指令时，这些指令才从上一级继承。

如果头字段的值是一个空字符串，那么这个字段将不会被传递给 gRPC 服务器：

```nginx
grpc_set_header Accept-Encoding "";
```

### grpc_ssl_certificate

|\-|说明|
|------:|------|
|**语法**|**grpc_ssl_certificate** `file`;|
|**默认**|——|
|**上下文**|http、server、location|

指定一个带有 PEM 格式证书的文件（`file`），用于向 gRPC SSL 服务器进行身份验证。

### grpc_ssl_certificate_key

|\-|说明|
|------:|------|
|**语法**|**grpc_ssl_certificate_key** `file`;|
|**默认**|——|
|**上下文**|http、server、location|

指定一个文件（`file`），其包含 PEM 格式的密钥，用于对 gRPC SSL 服务器进行身份验证。

可以指定值 `engine:name:id` 来代替 `file`，其从 OpenSSL 引擎 `name` 加载具有指定 `id` 的密钥。

### grpc_ssl_ciphers

|\-|说明|
|------:|------|
|**语法**|**grpc_ssl_ciphers** `ciphers`;|
|**默认**|grpc_ssl_ciphers DEFAULT;|
|**上下文**|http、server、location|

指定对 gRPC SSL 服务器的请求启用的密码。密码格式能被 OpenSSL 库所支持。

完整的列表详情可以使用 `openssl ciphers` 命令查看。

### grpc_ssl_crl

|\-|说明|
|------:|------|
|**语法**|**grpc_ssl_crl** `file`;|
|**默认**|——|
|**上下文**|http、server、location|

指定一个带有 PEM 格式的撤销证书（CRL）的文件（`file`），用于[验证](#grpc_ssl_verify) gRPC SSL 服务器的证书。

### grpc_ssl_name

|\-|说明|
|------:|------|
|**语法**|**grpc_ssl_name** `name`;|
|**默认**|grpc_ssl_name host from grpc_pass;|
|**上下文**|http、server、location|

允许重写用于[验证](#grpc_ssl_verify) gRPC SSL 服务器的证书并在与 gRPC SSL 服务器建立连接时[通过 SNI 传递](#grpc_ssl_server_name)的服务器名称。

默认情况下，使用 [grpc_pass](#grpc_pass) 的主机部分。

### grpc_ssl_password_file

|\-|说明|
|------:|------|
|**语法**|**grpc_ssl_password_file** `file`;|
|**默认**|——|
|**上下文**|http、server、location|

指定一个密码为密钥的文件，[每个密码](#grpc_ssl_certificate_key)在单独的行上指定。加载密钥时会依次尝试每个密码。

### grpc_ssl_server_name

|\-|说明|
|------:|------|
|**语法**|**grpc_ssl_server_name** `on` &#124; `off`;|
|**默认**|grpc_ssl_server_name off;|
|**上下文**|http、server、location|

在建立与 gRPC SSL 服务器的连接时，启用或禁用通过 [TLS 服务器名称指示扩展](http://en.wikipedia.org/wiki/Server_Name_Indication)（SNI，RFC 6066）传送服务器名称。

### grpc_ssl_session_reuse

|\-|说明|
|------:|------|
|**语法**|**grpc_ssl_session_reuse** `on` &#124; `off`;|
|**默认**|grpc_ssl_session_reuse on;|
|**上下文**|http、server、location|

确定在使用 gRPC 服务器时是否可以重用 SSL 会话。如果错误 `SSL3_GET_FINISHED:digest check fialed` 出现在日志中，尝试禁用会话重用。

### grpc_ssl_protocols

|\-|说明|
|------:|------|
|**语法**|**grpc_ssl_protocols** `[SSLv2] [SSLv3] [TLSv1] [TLSv1.1] [TLSv1.2] [TLSv1.3]`;|
|**默认**|grpc_ssl_protocols TLSv1 TLSv1.1 TLSv1.2;|
|**上下文**|http、server、location|

对 gRPC SSL 服务器的请求启用指定的协议。

### grpc_ssl_trusted_certificate

|\-|说明|
|------:|------|
|**语法**|**grpc_ssl_trusted_certificate** `file`;|
|**默认**|——|
|**上下文**|http、server、location|

指定一个带有 PEM 格式的可信 CA 证书的文件，用于[验证](#grpc_ssl_verify) gRPC SSL 服务器的证书。

### grpc_ssl_verify

|\-|说明|
|------:|------|
|**语法**|**grpc_ssl_verify** `on` &#124; `off`;|
|**默认**|grpc_ssl_verify off;|
|**上下文**|http、server、location|

启用或禁用验证 gRPC SSL 服务器证书。

### grpc_ssl_verify_depth

|\-|说明|
|------:|------|
|**语法**|**grpc_ssl_verify_depth** `number`;|
|**默认**|grpc_ssl_verify_depth 1;|
|**上下文**|http、server、location|

设置 gRPC SSL 服务器证书链中的验证深度。

## 原文档

[http://nginx.org/en/docs/http/ngx_http_grpc_module.html](http://nginx.org/en/docs/http/ngx_http_grpc_module.html)