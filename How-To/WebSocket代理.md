# WebSocket 代理

要将客户端与服务器之间的连接从 HTTP/1.1 转换为 WebSocket，可是使用 HTTP/1.1 中的 [协议切换](https://tools.ietf.org/html/rfc2616#section-14.42) 机制。

然而，有一个微妙的地方：由于 `Upgrade` 是一个[逐跳](https://tools.ietf.org/html/rfc2616#section-13.5.1)（hop-by-hop）头，它不会从客户端传递到代理服务器。当使用转发代理时，客户端可以使用 `CONNECT` 方法来规避此问题。然而，这不适用于反向代理，因为客户端不知道任何代理服务器，这需要在代理服务器上进行特殊处理。

自 1.3.13 版本以来，nginx 实现了特殊的操作模式，如果代理服务器返回一个 101响应码（交换协议），则客户机和代理服务器之间将建立隧道，客户端  通过请求中的 `Upgrade` 头来请求协议交换。

如上所述，包括 `Upgrade` 和 `Connection` 的逐跳头不会从客户端传递到代理服务器，因此为了使代理服务器知道客户端将协议切换到 WebSocket 的意图，这些头必须明确地传递：

```nginx
location /chat/ {
    proxy_pass http://backend;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}
```

一个更复杂的例子是，对代理服务器的请求中的 `Connection` 头字段的值取决于客户端请求头中的 `Upgrade` 字段的存在：

```nginx
http {
    map $http_upgrade $connection_upgrade {
        default upgrade;
        ''      close;
    }

    server {
        ...

        location /chat/ {
            proxy_pass http://backend;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
        }
    }
```

默认情况下，如果代理务器在 60 秒内没有传输任何数据，连接将被关闭。这个超时可以通过 [proxy_read_timeout](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_read_timeout) 指令来增加。 或者，代理服务器可以配置为定期发送 WebSocket ping 帧以重置超时并检查连接是否仍然活跃。

## 原文档

[http://nginx.org/en/docs/http/websocket.html](http://nginx.org/en/docs/http/websocket.html)
