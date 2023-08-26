# QUIC 和 HTTP/3 支持

- [从源码构建](#从源码构建)
- [配置](#配置)
- [配置示例](#配置示例)
- [故障排除](#故障排除)

从1.25.0后，对 [QUIC](https://datatracker.ietf.org/doc/html/rfc9000) 和 [HTTP/3](https://datatracker.ietf.org/doc/html/rfc9114) 协议的支持可用。同时，1.25.0之后，QUIC 和 HTTP/3 支持在Linux二进制包 ([binary package](https://nginx.org/en/linux_packages.html))中可用。

> QUIC 和 HTTP/3 支持是实验性的，请谨慎使用。

## 从源码构建

使用`configure`命令配置构建。请参考[从源码构建 nginx ](../How-To/从源码构建nginx.md)以获得更多细节。

当配置nginx时，可以使用 [`--with-http_v3_module`](../How-To/从源码构建nginx.md#http_v3_module) 配置参数来启用 QUIC 和 HTTP/3。

构建nginx时建议使用支持 QUIC 的 SSL 库，例如 [BoringSSL](https://boringssl.googlesource.com/boringssl)，[LibreSSL](https://www.libressl.org/)，或者 [QuicTLS](https://github.com/quictls/openssl)。否则，将使用不支持[早期数据](../模块参考/http/ngx_http_ssl_module.md#ssl_early_data)的[OpenSSL](https://openssl.org/)兼容层。

使用以下命令为 nginx 配置 [BoringSSL](https://boringssl.googlesource.com/boringssl)：

```bash
./configure
    --with-debug
    --with-http_v3_module
    --with-cc-opt="-I../boringssl/include"
    --with-ld-opt="-L../boringssl/build/ssl
                   -L../boringssl/build/crypto"
```

或者，可以使用 [QuicTLS](https://github.com/quictls/openssl) 配置 nginx：

```bash
./configure
    --with-debug
    --with-http_v3_module
    --with-cc-opt="-I../quictls/build/include"
    --with-ld-opt="-L../quictls/build/lib"
```

或者，可以使用现代版本的 [LibreSSL](https://www.libressl.org/) 配置 nginx：

```bash
./configure
    --with-debug
    --with-http_v3_module
    --with-cc-opt="-I../libressl/build/include"
    --with-ld-opt="-L../libressl/build/lib"
```

配置完成后，使用 `make` 编译和安装 nginx。

## 配置

[ngx_http_core_module](../模块参考/http/ngx_http_core_module.md) 模块中的 `listen` 指令获得了一个新参数 [`quic`](../模块参考/http/ngx_http_core_module.md#quic)，它在指定端口上通过启用 HTTP/3 over QUIC。

除了 `quic` 参数外，还可以指定 [`reuseport`](../模块参考/http/ngx_http_core_module.md#reuseport) 参数，使其在多个工作线程中正常工作。

有关指令列表，请参阅 [ngx_http_v3_module](https://nginx.org/en/docs/http/ngx_http_v3_module.html)。

要[启用](https://nginx.org/en/docs/http/ngx_http_v3_module.html#quic_retry)地址验证：

```nginx
quic_retry on;
```

要[启用](../模块参考/http/ngx_http_ssl_module.md#ssl_early_data) 0-RTT：

```nginx
ssl_early_data on;
```

要[启用](https://nginx.org/en/docs/http/ngx_http_v3_module.html#quic_gso) GSO (Generic Segmentation Offloading)：

```nginx
quic_gso on;
```

为多个 token [设置](https://nginx.org/en/docs/http/ngx_http_v3_module.html#quic_host_key) host key：

```nginx
quic_host_key <filename>;
```

QUIC 需要 TLSv1.3 协议版本，该版本在 [`ssl_protocols`](../模块参考/http/ngx_http_ssl_module.md#ssl_protocols) 指令中默认启用。

默认情况下，[GSO Linux 特定优化](http://vger.kernel.org/lpc_net2018_talks/willemdebruijn-lpc2018-udpgso-paper-DRAFT-1.pdf)处于禁用状态。如果相应的网络接口配置为支持 GSO，请启用它。

## 配置示例

```nginx
http {
    log_format quic '$remote_addr - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent" "$http3"';

    access_log logs/access.log quic;

    server {
        # for better compatibility it's recommended
        # to use the same port for quic and https
        listen 8443 quic reuseport;
        listen 8443 ssl;

        ssl_certificate     certs/example.com.crt;
        ssl_certificate_key certs/example.com.key;

        location / {
            # required for browsers to direct them to quic port
            add_header Alt-Svc 'h3=":8443"; ma=86400';
        }
    }
}
```

## 故障排除

一些可能有助于识别问题的提示：

- 确保 nginx 是使用正确的 SSL 库构建的。
- 确保 nginx 在运行时使用正确的 SSL 库（`nginx -V` 显示当前使用的内容）。
- 确保客户端实际通过 QUIC 发送请求。建议从简单的控制台客户端（如 [ngtcp2](https://nghttp2.org/ngtcp2)）开始，以确保服务器配置正确，然后再尝试使用可能对证书非常挑剔的真实浏览器。
- 使用[调试支持](../介绍/调试日志.md)构建nginx并检查调试日志。它应包含有关连接及其失败原因的所有详细信息。所有相关消息都包含“`quic`”前缀，可以轻松过滤掉。
- 为了进行更深入的调查，可以使用以下宏启用其他调试：`NGX_QUIC_DEBUG_PACKETS, NGX_QUIC_DEBUG_FRAMES, NGX_QUIC_DEBUG_ALLOC, NGX_QUIC_DEBUG_CRYPTO`。
```bash
./configure
    --with-http_v3_module
    --with-debug
    --with-cc-opt="-DNGX_QUIC_DEBUG_PACKETS -DNGX_QUIC_DEBUG_CRYPTO"
```