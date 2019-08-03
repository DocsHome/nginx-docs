# ngx_http_upstream_conf_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [upstream_conf](#upstream_conf)

**直到 1.13.10 版本，它被 1.13.3 中的 [ngx_http_api_module](ngx_http_api_module.md) 模块所取代。**

`ngx_http_upstream_conf_module` 模块允许通过简单的 HTTP 接口即时配置上游（upstream）服务器组，而无需重新启动 nginx。[http](ngx_http_upstream_module.md#zone) 或[流](ngx_stream_upstream_module.md#zone)服务器组必须驻留在共享内存中。

> 该模块作为[商业订阅](http://nginx.com/products/?_ga=2.70698388.504417624.1562407216-1811470965.1562407216)部分提供，

<a id="example_configuration"></a>

## 示例配置

```nginx
upstream backend {
    zone upstream_backend 64k;

    ...
}

server {
    location /upstream_conf {
        upstream_conf;
        allow 127.0.0.1;
        deny all;
    }
}
```

<a id="directives"></a>

## 指令

### upstream_conf

|\-|说明|
|:------|:------|
|**语法**|**upstream_conf**;|
|**默认**|——|
|**上下文**|location|

在 location 中引入该指令，开启上游配置 HTTP 接口。 应[限制](ngx_http_core_module.md#satisfy)访问此 location。

配置命令可用于：

- 查看组配置
- 查看、修改或删除服务器
- 添加新服务器

> 由于组中的地址不要求唯一，因此组中的服务器使用 ID 引用。添加新服务器或查看组配置时，会自动分配 ID 并显示 ID。

配置命令作为请求参数传入，例如：

```
http://127.0.0.1/upstream_conf?upstream=backend
```

支持以下参数：

- `stream=`

    选择一个 [stream](../stream/ngx_stream_upstream_module.md) 上游服务器组。如果没有此参数，将选择一个 [http](ngx_http_upstream_module.md) 上游服务器组。

- `upstream=name`

    选择要使用的组。此参数是必需的。

- `id=number`

    选择一个要查看、修改或删除的服务器。

- `remove=`

    从组中删除一个服务器。

- `add=`

    向组中添加一个新服务器。

- `backup=`

    需要添加一个备用服务器。

    > 在 1.7.2 版之前，查看、修改或删除现有备用服务器还需要 `backup=` 参数。

- `server=address`

    与 [http](ngx_http_upstream_module.md#server) 或 [stream](../stream/ngx_stream_upstream_module.md#server) 上游服务器的 `address` 参数相同。

    添加服务器时，可以将其指定为一个域名。这种情况下，将监视与域名对应的 IP 地址的更改并自动应用于上游配置，无需重新启动 nginx（1.7.2）。这需要 [http](ngx_http_upstream_module.md#server) 或 [stream](../stream/ngx_stream_upstream_module.md#server) 块中的 `resolver` 指令。另请参阅 [http](ngx_http_upstream_module.md#server) 或 [stream](../stream/ngx_stream_upstream_module.md#server) 上游服务器的 `resolve` 参数。

- `service=name`

    与 [http](ngx_http_upstream_module.md#service) 或 [stream](../stream/ngx_stream_upstream_module.md#service) 上游服务器的 `service` 参数相同（1.9.13）。

- `weight=number`

    与 [http](ngx_http_upstream_module.md#weight) 或 [stream](../stream/ngx_stream_upstream_module.md#weight) 上游服务器的 `weight` 参数相同。

- `max_conns=number`

    与 [http](ngx_http_upstream_module.md#max_conns) 或 [stream](../stream/ngx_stream_upstream_module.md#max_conns) 上游服务器的 `max_conns` 参数相同。

- `max_fails=number`

    与 [http](ngx_http_upstream_module.md#max_fails) 或 [stream](../stream/ngx_stream_upstream_module.md#max_fails) 上游服务器的 `max_fails` 参数相同。

- `fail_timeout=time`

    与 [http](ngx_http_upstream_module.md#fail_timeout) 或 [stream](../stream/ngx_stream_upstream_module.md#fail_timeout) 上游服务器的 `fail_timeout` 参数相同。

- `slow_start=time`

    与 [http](ngx_http_upstream_module.md#slow_start) 或 [stream](../stream/ngx_stream_upstream_module.md#slow_start) 上游服务器的 `slow_start` 参数相同。

- `down=`

    与 [http](ngx_http_upstream_module.md#down) 或 [stream](../stream/ngx_stream_upstream_module.md#down) 上游服务器的 `down` 参数相同。

- `drain=`
    将 [http](ngx_http_upstream_module.md#draining) 上游服务器置为 `draining` 模式（1.7.5）。在此模式下，只有绑定到服务器的请求才会被代理。

- `up=`
    
    与 [http](ngx_http_upstream_module.md#down) 或 [stream](../stream/ngx_stream_upstream_module.md#down) 上游服务器的 `down` 参数相反。

- `route=string`
    
    与 [http](ngx_http_upstream_module.md#route) 上游服务器的 `route` 参数相同。

前三个参数会选择一个对象。这可以是整个 http 或 stream 上游服务器组，也可以是特定服务器。如果没有其他参数，则会显示所选组或服务器的配置。

例如，要查看整个组的配置，请发送：

```
http://127.0.0.1/upstream_conf?upstream=backend
```

要查看特定服务器的配置，还要指定其 ID：

```
http://127.0.0.1/upstream_conf?upstream=backend&id=42
```

要添加新服务器，请在 `server=` 参数中指定其地址。如果未指定其他参数，添加服务器时将其他参数设置为其默认值（请参阅 [http](ngx_http_upstream_module.md#server) 或 [stream](../stream/ngx_stream_upstream_module.md#server) 的 `server` 指令）。

例如，要添加一个新的主服务器，请发送：

```
http://127.0.0.1/upstream_conf?add=&upstream=backend&server=127.0.0.1:8080
```

要添加一个备用服务器，发送：

```
http://127.0.0.1/upstream_conf?add=&upstream=backend&backup=&server=127.0.0.1:8080
```

要添加一个新的主服务器，将其参数设置为非默认值并将其标记为 `down`，发送：

```
http://127.0.0.1/upstream_conf?add=&upstream=backend&server=127.0.0.1:8080&weight=2&down=
```

删除一个服务器，指定其 ID：

```
http://127.0.0.1/upstream_conf?remove=&upstream=backend&id=42
```

讲一个现有的服务器标记为 `down`，发送：

```
http://127.0.0.1/upstream_conf?upstream=backend&id=42&down=
```

修改一个现有服务器的地址，发送：

```
http://127.0.0.1/upstream_conf?upstream=backend&id=42&server=192.0.2.3:8123
```

修改一个现有服务器的其他参数，发送：

```
http://127.0.0.1/upstream_conf?upstream=backend&id=42&max_fails=3&weight=4
```

以上示例适用于 [http](ngx_http_upstream_module.md) 上游服务器组。[stream](../stream/ngx_stream_upstream_module.md) 上游服务器组需要加上 `stream=` 参数。

## 原文档

- [http://nginx.org/en/docs/http/ngx_http_upstream_conf_module.html](http://nginx.org/en/docs/http/ngx_http_upstream_conf_module.html)
