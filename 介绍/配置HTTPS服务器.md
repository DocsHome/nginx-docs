# 配置 HTTPS 服务器

要配置 HTTPS 服务器，必须在 [server](http://nginx.org/en/docs/http/ngx_http_core_module.html#server) 块中的 [监听套接字](http://nginx.org/en/docs/http/ngx_http_core_module.html#listen) 上启用 `ssl` 参数，并且指定[服务器证书](http://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_certificate) 和 [私钥文件](http://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_certificate_key) 的位置：

```nginx
server {
    listen              443 ssl;
    server_name         www.example.com;
    ssl_certificate     www.example.com.crt;
    ssl_certificate_key www.example.com.key;
    ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers         HIGH:!aNULL:!MD5;
    ...
}
```

<!-- more -->

服务器证书是一个公共实体。它被发送到每个连接到服务器的客户端。私钥是一个安全实体，存储在一个访问受限的文件中，但是它对 nginx 的主进程必须是可读的。私钥也可以存储在与证书相同的文件中：
```nginx
ssl_certificate     www.example.com.cert;
ssl_certificate_key www.example.com.cert;
```

这种情况下，文件的访问也应该被限制。虽然证书和密钥存储在一个文件中，但只有证书能被发送给客户端。

可以使用 [ssl_protocols](http://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_protocols) 和 [ssl_ciphers](http://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_ciphers) 指令来限制连接，使其仅包括 SSL/TLS 的版本和密码。默认情况下，nginx 使用版本为 `ssl_protocols TLSv1 TLSv1.1 TLSv1.2`，密码为 `ssl_ciphers HIGH:!aNULL:!MD5`，因此通常不需要配置它们。请注意，这些指令的默认值已经被 [更改](#兼容性) 多次。

## HTTPS 服务器优化
SSL 操作会消耗额外的 CPU 资源。在多处理器系统上，应该运行多个 [工作进程（worker process）](http://nginx.org/en/docs/ngx_core_module.html#worker_processes)，不得少于可用 CPU 核心的数量。大多数 CPU 密集型操作是发生在 SSL 握手时。有两种方法可以最大程度地减少每个客户端执行这些操作的次数。首先，启用 [keepalive](http://nginx.org/en/docs/http/ngx_http_core_module.html#keepalive_timeout) 连接，通过一个连接来发送多个请求，第二个是复用 SSL 会话参数，避免相同的和后续的连接发生 SSL 握手。会话存储在工作进程间共享的 SSL 会话缓存中，由 [ssl_session_cache](http://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_session_cache) 指令配置。1MB 缓存包含约 4000 个会话。默认缓存超时时间为 5 分钟，可以用 [ssl_session_timeout](http://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_session_timeout) 指令来增加。以下是一个优化具有 10MB 共享会话缓存的多核系统的配置示例：

```nginx
worker_processes auto;

http {
    ssl_session_cache   shared:SSL:10m;
    ssl_session_timeout 10m;

    server {
        listen              443 ssl;
        server_name         www.example.com;
        keepalive_timeout   70;

        ssl_certificate     www.example.com.crt;
        ssl_certificate_key www.example.com.key;
        ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers         HIGH:!aNULL:!MD5;
        ...
```

## SSL 证书链
某些浏览器可能会不承认由知名证书颁发机构签发的证书，而其他浏览器可能会接受该证书。之所以发生这种情况，是因为颁发机构已经在特定浏览器分发了一个中间证书，该证书不存在于知名可信证书颁发机构的证书库中。在这种情况下，权威机构提供了一系列链式证书，这些证书应该与已签名的服务器证书相连。服务器证书必须出现在组合文件中的链式证书之前：

```
$ cat www.example.com.crt bundle.crt > www.example.com.chained.crt
```

在 [ssl_certificate](http://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_certificate) 指令中使用生成的文件：

```nginx
server {
    listen              443 ssl;
    server_name         www.example.com;
    ssl_certificate     www.example.com.chained.crt;
    ssl_certificate_key www.example.com.key;
    ...
}
```

如果服务器证书与捆绑的链式证书的相连顺序错误，nginx 将无法启动并显示错误消息：

```bash
SSL_CTX_use_PrivateKey_file(" ... /www.example.com.key") failed
   (SSL: error:0B080074:x509 certificate routines:
    X509_check_private_key:key values mismatch)
```

因为 nginx 已尝试使用私钥和捆绑的第一个证书而不是服务器证书。

浏览器通常会存储他们收到的中间证书，这些证书由受信任的机构签名，因此积极使用这些存储证书的浏览器可能已经具有所需的中间证书，不会发生不承认没有链接捆绑发送的证书的情况。可以使用 openssl 命令行工具来确保服务器发送完整的证书链，例如：

```bash
$ openssl s_client -connect www.godaddy.com:443
...
Certificate chain
 0 s:/C=US/ST=Arizona/L=Scottsdale/1.3.6.1.4.1.311.60.2.1.3=US
     /1.3.6.1.4.1.311.60.2.1.2=AZ/O=GoDaddy.com, Inc
     /OU=MIS Department/CN=www.GoDaddy.com
     /serialNumber=0796928-7/2.5.4.15=V1.0, Clause 5.(b)
   i:/C=US/ST=Arizona/L=Scottsdale/O=GoDaddy.com, Inc.
     /OU=http://certificates.godaddy.com/repository
     /CN=Go Daddy Secure Certification Authority
     /serialNumber=07969287
 1 s:/C=US/ST=Arizona/L=Scottsdale/O=GoDaddy.com, Inc.
     /OU=http://certificates.godaddy.com/repository
     /CN=Go Daddy Secure Certification Authority
     /serialNumber=07969287
   i:/C=US/O=The Go Daddy Group, Inc.
     /OU=Go Daddy Class 2 Certification Authority
 2 s:/C=US/O=The Go Daddy Group, Inc.
     /OU=Go Daddy Class 2 Certification Authority
   i:/L=ValiCert Validation Network/O=ValiCert, Inc.
     /OU=ValiCert Class 2 Policy Validation Authority
     /CN=http://www.valicert.com//emailAddress=info@valicert.com
...
```

在本示例中，www.GoDaddy.com 服务器证书 ＃0 的主体（“s”）由发行机构（“i”）签名，发行机构本身是证书 ＃1 的主体，是由知名发行机构 ValiCert, Inc. 签署的证书 ＃2 的主体，其证书存储在浏览器的内置证书库中。

如果没有添加证书包（certificate bundle），将仅显示服务器证书 ＃0。

## HTTP/HTTPS 服务器
可以配置单个服务器来处理 HTTP 和 HTTPS 请求：

```nginx
server {
    listen              80;
    listen              443 ssl;
    server_name         www.example.com;
    ssl_certificate     www.example.com.crt;
    ssl_certificate_key www.example.com.key;
    ...
}
```

> 在 0.7.14 之前，无法为各个 socket 选择性地启用 SSL，如上所示。只能使用 [ssl](http://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl) 指令为整个服务器启用 SSL，从而无法设置单个 HTTP/HTTPS 服务器。可以通过添加 [listen](http://nginx.org/en/docs/http/ngx_http_core_module.html#listen) 指令的 ssl 参数来解决这个问题。因此，不建议在现在的版本中使用 [ssl](http://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl) 指令。

## 基于名称的 HTTPS 服务器
当配置两个或多个 HTTPS 服务器监听单个 IP 地址时，会出现一个常见问题：

```nginx
server {
    listen          443 ssl;
    server_name     www.example.com;
    ssl_certificate www.example.com.crt;
    ...
}

server {
    listen          443 ssl;
    server_name     www.example.org;
    ssl_certificate www.example.org.crt;
    ...
}
```

使用了此配置，浏览器会接收默认服务器的证书，即 www.example.com，而无视所请求的服务器名称。这是由 SSL 协议行为引起的。SSL连接在浏览器发送 HTTP 请求之前建立，nginx 并不知道请求的服务器名称。因此，它只能提供默认服务器的证书。

最古老、最强大的解决方法是为每个 HTTPS 服务器分配一个单独的 IP 地址：

```nginx
server {
    listen          192.168.1.1:443 ssl;
    server_name     www.example.com;
    ssl_certificate www.example.com.crt;
    ...
}

server {
    listen          192.168.1.2:443 ssl;
    server_name     www.example.org;
    ssl_certificate www.example.org.crt;
    ...
}
```

## 具有多个名称的 SSL 证书
虽然还有其他方法允许在多个 HTTPS 服务器之间共享一个 IP 地址。但他们都有自己的缺点。一种方法是在 SubjectAltName 证书字段中使用多个名称的证书，例如 `www.example.com` 和 `www.example.org`。但是，SubjectAltName 字段长度有限。

另一种方法是使用附带通配符名称的证书，例如 `*.example.org`。通配符证书保护指定域的所有子域，但只能在同一级别上。此证书能匹配 `www.example.org`，但与 `example.org` 和 `www.sub.example.org` 不匹配。当然，这两种方法也可以组合使用的。SubjectAltName 字段中的证书可能包含确切名称和通配符名称，例如 `example.org` 和 `*.example.org`。

最好是将证书文件与名称、私钥文件放置在 http 级配置，以便在所有服务器中继承其单个内存副本：

```nginx
ssl_certificate     common.crt;
ssl_certificate_key common.key;

server {
    listen          443 ssl;
    server_name     www.example.com;
    ...
}

server {
    listen          443 ssl;
    server_name     www.example.org;
    ...
```

## 服务器名称指示
在单个 IP 地址上运行多个 HTTPS 服务器的更通用的解决方案是 [TLS 服务器名称指示扩展](http://en.wikipedia.org/wiki/Server_Name_Indication)（SNI，RFC 6066），其允许浏览器在 SSL 握手期间传递所请求的服务器名称，因此，服务器将知道应该为此连接使用哪个证书。然而，SNI 对浏览器的支持是有限的。目前，它仅支持以下版本开始的浏览器：

- Opera 8.0
- MSIE 7.0（但仅在 Windows Vista 或更高版本）
- Firefox 2.0 和使用 Mozilla Platform rv:1.8.1 的其他浏览器
- Safari 3.2.1（支持 SNI 的 Windows 版本需要 Vista 或更高版本）
- Chrome（支持 SNI 的 Windows 版本需要 Vista 或更高版本）

> 只有域名可以在 SNI 中传递，然而，如果请求包含 IP 地址，某些浏览器可能会错误地将服务器的 IP 地址作为名称传递。不应该依靠这个。

要在 nginx 中使用 SNI，其必须支持构建后的 nginx 二进制的 OpenSSL 库以及在可在运行时动态链接的库。自 0.9.8f 版本起（OpenSSL），如果 OpenSSL 使用了配置选项 `--enable-tlsext` 构建，是支持 SNI 的。自 OpenSSL 0.9.8j 起，此选项是默认启用。如果 nginx 是用 SNI 支持构建的，那么当使用 `nginx -V` 命令时 ，nginx 会显示：

```bash
$ nginx -V
...
TLS SNI support enabled
...
```

但是，如果启用了 SNI 的 nginx 在没有 SNI 支持的情况下动态链接到 OpenSSL 库，那么 nginx 将会显示警告：

```bash
nginx was built with SNI support, however, now it is linked
dynamically to an OpenSSL library which has no tlsext support,
therefore SNI is not available
```

## 兼容性
- 从 0.8.21 和 0.7.62 起，SNI 支持状态通过 `-V `开关显示。
- 从 0.7.14 开始，支持 listen 指令的 ssl 参数。在 0.8.21 之前，只能与 `default` 参数一起指定。
- 从 0.5.23 起，支持 SNI。
- 从 0.5.6 起，支持共享 SSL 会话缓存。
- 1.9.1 及更高版本：默认 SSL 协议为 TLSv1、TLSv1.1 和 TLSv1.2（如果 OpenSSL 库支持）。
- 0.7.65、0.8.19 及更高版本：默认 SSL 协议为 SSLv3、TLSv1、TLSv1.1 和 TLSv1.2（如果 OpenSSL 库支持）。
- 0.7.64、0.8.18 及更早版本：默认 SSL 协议为 SSLv2、SSLv3 和 TLSv1。
- 1.0.5及更高版本：默认 SSL 密码为 `HIGH:!aNULL:!MD5`。
- 0.7.65、0.8.20 及更高版本：默认 SSL 密码为 `HIGH:!ADH:!MD5`。
- 0.8.19 版本：默认 SSL 密码为 `ALL:!ADH:RC4+RSA:+HIGH:+MEDIUM`。
- 0.7.64、0.8.18 及更早版本：默认SSL密码为 `ALL:!ADH:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP`。

由 **Igor Sysoev** 撰写，**Brian Mercer** 编辑

## 原文档

- [Configuring HTTPS servers](http://nginx.org/en/docs/http/configuring_https_servers.html)
