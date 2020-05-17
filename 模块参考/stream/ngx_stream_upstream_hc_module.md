# ngx_stream_upstream_hc_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [health_check](#health_check)
    - [health_check_timeout](#health_check_timeout)
    - [match](#match)

`ngx_stream_upstream_hc_module` 模块（1.9.0）允许对[组](ngx_stream_upstream_module.md#upstream)中服务器启用定期健康检查。服务器组必须驻留在[共享内存](ngx_stream_upstream_module.md#zone)中。

如果健康检查失败，则服务器将被视为不可用。如果为同一组服务器定义了多个健康检查，则任何一次检查失败都会使相应的服务器不可用。客户端连接不会传递给不可用的服务器，并且服务器不会处于「检查」状态。

> 此模块为[商业订阅](http://nginx.com/products/?_ga=2.131045135.1858436578.1589555275-1645619674.1589555275)部分。

<a id="example_configuration"></a>

## 示例配置

```nginx
upstream tcp {
    zone upstream_tcp 64k;

    server backend1.example.com:12345 weight=5;
    server backend2.example.com:12345 fail_timeout=5s slow_start=30s;
    server 192.0.2.1:12345            max_fails=3;

    server backup1.example.com:12345  backup;
    server backup2.example.com:12345  backup;
}

server {
    listen     12346;
    proxy_pass tcp;
    health_check;
}
```

使用此配置，nginx 将每 5 秒钟检查是否能与 tcp 组中的每个服务器建立 TCP 连接。如果无法与服务器建立连接，则健康检查将失败，并且服务器将被视为不可用。

可以为 UDP 协议配置健康检查：

```nginx
upstream dns_upstream {

    zone   dns_zone 64k;

    server dns1.example.com:53;
    server dns2.example.com:53;
    server dns3.example.com:53;
}

server {
    listen       53 udp;
    proxy_pass   dns_upstream;
    health_check udp;
}
```

在这种情况下，nginx 将发送 `nginx health check` 字符串，期望得到的响应中没有 ICMP `Destination Unreachable` 消息。

健康检查也可以配置为[测试](#match)从服务器获得的数据。使用 `match` 指令单独配置测试规则，并在 [health_check](#health_check) 指令的 `match` 参数中引用测试规则。

<a id="directives"></a>

## 指令

### health_check

|\-|说明|
|------:|------|
|**语法**|**health_check** `[parameters]`;|
|**默认**|——|
|**上下文**|server|

对[组](ngx_stream_upstream_module.md#upstream)中服务器启用定期健康检查。

支持以下可选参数：

- `interval=time`

    设置两次连续运行健康检查之间的间隔时间，默认为 5 秒。

- `jitter=time`

    设置每次运行健康检查将随机延迟的时间，默认没有延迟。

- `fails=number`

    设置指定服务器在连续运行健康检查失败次数达到 `number` 后，将被视为不可用，默认为 1。

- `passes=number`

    设置指定服务器在连续通过健康检查次数达到 `number` 后，将被视为健康，默认为 1。

- `mandatory`

    设置服务器的初始「检查中」（checking）状态，直到完成第一次健康检查运行（1.11.7）。客户端连接不会以「检查中」的状态传递到服务器。如果未指定该参数，则服务器初始状态将被视为健康。

- `match=name`

    指定 `match` 块，该匹配块配置健康检查中正常的连接必须要通过的测试。默认情况下，对于 TCP，仅检查与服务器建立 TCP 的连接。对于 [UDP](#health_check_udp)，nginx 发送 `nginx health check` 字符串，期望得到的响应不应存在 ICMP `Destination Unreachable` 消息。

    > 在 1.11.7 版本之前，默认情况下，UDP 运行健康检查需要带有 [send](#match_send) 和 [expect](#match_expect) 参数的 [match](#hc_match) 块。

- `port=number`

    定义连接到服务器执行健康检查（1.9.7）时使用的端口，默认等于[服务器](ngx_stream_upstream_module.md#server)端口。

- `udp`

    指定将 UDP 协议代替默认的 TCP 协议（1.9.13）用于健康检查。

### health_check_timeout

|\-|说明|
|------:|------|
|**语法**|**health_check_timeout** `name { ... }`;|
|**默认**|——|
|**上下文**|stream|

覆盖用于健康检查的 [proxy_timeout](ngx_stream_proxy_module.md#proxy_timeout) 值。

### match

|\-|说明|
|------:|------|
|**语法**|**match** `name { ... }`;|
|**默认**|——|
|**上下文**|stream|

定义用于验证对服务器运行健康检查返回的响应的具名测试集。

可以配置以下参数：

- `send string;`

    向服务器发送一个 `string`（字符串）

- `expect string | ~ regex;`

    从服务器获得的数据应匹配的文字字符串（1.9.12）或正则表达式。正则表达式以前 `~*` 修饰符（不区分大小写）或 `~` 修饰符（不区分大小写）指定。

`send` 和 `expect` 参数都可以包含带有 `\x` 前缀的十六进制文字，后跟两个十六进制数字，例如 `\x80`（1.9.12）。

如果满足以下条件，则通过健康检查：

- TCP 连接建立成功
- 发送了来自 `send` 参数的 `string`（如果已指定）
- 将从服务器获取的数据与来自 `expect` 参数的字符串或正则表达式匹配（如果已指定）
- 经过的时间不超过 [health_check_timeout](#health_check_timeout) 指令中指定的值

示例：

```nginx
upstream backend {
    zone     upstream_backend 10m;
    server   127.0.0.1:12345;
}

match http {
    send     "GET / HTTP/1.0\r\nHost: localhost\r\n\r\n";
    expect ~ "200 OK";
}

server {
    listen       12346;
    proxy_pass   backend;
    health_check match=http;
}
```

> 仅检查从服务器获得的数据的首个 [proxy_buffer_size](ngx_stream_proxy_module.md#proxy_buffer_size) 字节。

## 原文档

[http://nginx.org/en/docs/stream/ngx_stream_upstream_hc_module.html](http://nginx.org/en/docs/stream/ngx_stream_upstream_hc_module.html)