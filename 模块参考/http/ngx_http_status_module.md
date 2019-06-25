# ngx_http_status_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [status](#status)
    - [status_format](#status_format)
    - [status_zone](#status_zone)
- [数据](#data)
- [兼容性](#compatibility)

**1.13.10 版本起，该模块被 1.13.3 中的 [ngx_http_api_module](ngx_http_api_module.md) 模块所取代。**

`ngx_http_status_module` 模块提供了访问各种状态信息的接口。

> 该模块作为我们[商业订阅](http://nginx.com/products/?_ga=2.221534609.863754713.1561447787-385379447.1523458179)的一部分提供。

<a id="example_configuration"></a>

## 示例配置

```nginx
http {
    upstream backend {
        zone http_backend 64k;

        server backend1.example.com weight=5;
        server backend2.example.com;
    }

    proxy_cache_path /data/nginx/cache_backend keys_zone=cache_backend:10m;

    server {
        server_name backend.example.com;

        location / {
            proxy_pass  http://backend;
            proxy_cache cache_backend;

            health_check;
        }

        status_zone server_backend;
    }

    server {
        listen 127.0.0.1;

        location /upstream_conf {
            upstream_conf;
        }

        location /status {
            status;
        }

        location = /status.html {
        }
    }
}

stream {
    upstream backend {
        zone stream_backend 64k;

        server backend1.example.com:12345 weight=5;
        server backend2.example.com:12345;
    }

    server {
        listen      127.0.0.1:12345;
        proxy_pass  backend;
        status_zone server_backend;
        health_check;
    }
}
```

使用此配置的状态请求示例：

```
http://127.0.0.1/status
http://127.0.0.1/status/nginx_version
http://127.0.0.1/status/caches/cache_backend
http://127.0.0.1/status/upstreams
http://127.0.0.1/status/upstreams/backend
http://127.0.0.1/status/upstreams/backend/peers/1
http://127.0.0.1/status/upstreams/backend/peers/1/weight
http://127.0.0.1/status/stream
http://127.0.0.1/status/stream/upstreams
http://127.0.0.1/status/stream/upstreams/backend
http://127.0.0.1/status/stream/upstreams/backend/peers/1
http://127.0.0.1/status/stream/upstreams/backend/peers/1/weight
```

简单监视页面随分发包一起提供，使用默认配置可以 `/status.html` 身份访问。它需要配置 location `/status` 和 `/status.html`，如上所示。

<a id="directives"></a>

## 指令

### status

|\-|说明|
|:------|:------|
|**语法**|**status**;|
|**默认**|——|
|**上下文**|location|

可以从包含有指令的 location 访问状态信息。应[限制](ngx_http_core_module.md#satisfy)访问此 location。

### status_format

|\-|说明|
|:------|:------|
|**语法**|**status_format** `json`; <br/> **status_format** `jsonp [callback]`;|
|**默认**|`status_format json`|
|**上下文**|http、server、location|

默认情况下，状态信息以 JSON 格式输出。

或以输出为 JSONP 格式输出，`callback` 参数指定回调函数的名称。参数值可以包含变量。如果省略参数，或计算的值为空字符串，则使用 `"ngx_status_jsonp_callback"`。

### status_zone

|\-|说明|
|:------|:------|
|**语法**|**status_zone**;|
|**默认**|——|
|**上下文**|server|

允许在指定的 `zone` 中收集虚拟 [http](ngx_http_core_module.md#server) 或[流](ngx_stream_core_module.md#server)（1.7.11）服务器状态信息。多个服务器可能共享同一个区域（zone）。

<a id="data"></a>

## 数据

提供以下状态信息：

- `version`

    提供的数据集的版本。目前的版本是 8。

- `nginx_version`

    nginx 的版本。

- `nginx_build`

    nginx 的构建名称。

- `address`

    接受状态请求的服务器的地址。

- `generation`

    配置[重新加载](../../介绍/控制nginx.md#reconfiguration)的总数。

- `load_timestamp`

    上次重新加载配置的时间，自 Epoch 后的毫秒数。

- `timestamp`

    Epoch 后的当前时间（以毫秒为单位）。

- `pid`

    处理状态请求的 worker 进程的 ID。

- `ppid`

    启动 [worker 进程](#pid)的主进程的 ID。

- `processes`

    - `respawned`

        异常终止和重生的子进程的总数。

- `connections`

    - `accepted`

        已接受的客户端连接总数。

    - `dropped`

        已删除的客户端连接总数。

    - `active`

    当前活动客户端连接数。

    - `idle`

    当前空闲客户端连接数。

- `ssl`

    - `handshakes`

        SSL 握手成功的总数。

    - `handshakes_failed`

        SSL 握手失败的总数。

    - `session_reuses`

        SSL 握手期间会话​​重用的总次数。

- `requests`

    - `total`

        客户端请求总次数。

    - `current`

        当前的客户端请求数。

- `server_zones`

    对于每个 [status_zone](#status_zone)：

    - `ngx_http_status_module.html`

        当前正在处理的客户端请求数。

    - `requests`

        从客户端收到的客户端请求总数。

    - `responses`

        - `total`

            发送给客户的响应总数。

        - `1xx, 2xx, 3xx, 4xx, 5xx`

            状态代码为 1xx、2xx、3xx、4xx 和 5xx 的响应数。

    - `discarded`

        在未发送响应的情况下完成的请求总数。

    - `received`

        从客户端收到的总字节数。

    - `sent`

        发送给客户端的总字节数。

- `slabs`

    对于每个使用了 slab 分配器的共享内存区域：

    - `pages`

        - `used`

            当前使用的内存页数。

        - `free`

            当前可用内存页数。

    - `slots`

        对于每个内存插槽大小（8、16、32、64、128 等），提供以下数据：

        - `used`

            当前使用的内存槽数。

        - `free`

            当前可用的内存槽数。

        - `reqs`

            尝试分配指定大小内存的总次数。

        - `fails`

            尝试分配指定大小内存的失败次数。

- `upstreams`

    对于每个[动态可配置组](ngx_http_upstream_module.md#zone)，提供以下数据：

    - `peers`

        对于每个 [server](ngx_http_upstream_module.md#server)，提供以下数据：

        - `id`

            服务器的 ID。

        - `server`

            一个服务器[地址](ngx_http_upstream_module.md#server)。

        - `name`

            [server](ngx_http_upstream_module.md#server) 指令中指定的服务器的名称。

        - `service`

            [server](ngx_http_upstream_module.md#server) 指令的服务参数值。

        - `backup`

            一个布尔值，指示服务器是否为备份服务器。

        - `weight`

            服务器的权重。

        - `state`

            当前状态，可以是 `up`、`draining`、`down`、`unavail`、`checking` 或 `unhealthy` 之一。

        - `active`

            当前活动连接数。

        - `max_conns`

            服务器的 [max_conns](ngx_http_upstream_module.md#max_conns) 限制。

        - `requests`

            转发到此服务器的客户端请求总数。

        - `responses`

            - `total`

                从此服务器获取的响应总数。

            - `1xx, 2xx, 3xx, 4xx, 5xx`

                状态代码为 1xx、2xx、3xx、4xx 和 5xx 的响应数。

        - `sent`

            发送到此服务器的总字节数。

        - `received`

            从此服务器接收的总字节数。

        - `fails`

            与服务器通信失败的总次数。

        - `unavail`

            由于尝试不成功的次数达到 [max_fails](ngx_http_upstream_module.md#max_fails) 阈值，服务器对客户端请求变为不可用的次数（状态为 `unavail`）。

        - `health_checks`

            - `checks`

                进行[健康检查](ngx_http_upstream_hc_module.md#health_check)的请求总数。

            - `fails`

                健康检查失败的次数。

            - `unhealthy`

                服务器变为不健康的次数（状态 `unhealthy`）。

            - `last_passed`

                布尔值，表示上次运行状况检查请求是否成功并通过了[测试](ngx_http_upstream_hc_module.md#match)。

        - `downtime`

            服务器处于 `unavail`、`checking` 和 `unhealthy` 状态的总时间。

        - `downstart`

            服务器变为 `unavail`、`checking` 或 `unhealthy` 时的时间（自 Epoch 以来的毫秒数）。

        - `selected`

            上次选择的服务器处理一个请求的时间（自 Epoch 以来的毫秒数）（1.7.5）。

        - `header_time`

            从服务器获取[响应头](ngx_http_upstream_module.md#var_upstream_header_time)的平均时间（1.7.10）。在 1.11.6 版之前，该字段仅在使用 [least_time](ngx_http_upstream_module.md#least_time) 负载均衡方法时可用。

        - `response_time`

            从服务器获得[完整响应](ngx_http_upstream_module.md#var_upstream_response_time)的平均时间（1.7.10）。在 1.11.6 版之前，该字段仅在使用 [least_time](ngx_http_upstream_module.md#least_time) 负载均衡方法时可用。

    - `keepalive`

        当前空闲的 [keepalive](ngx_http_upstream_module.md#keepalive) 连接数。

    - `zombies`

        当前从组中删除但仍处理活动客户端请求的服务器数。

    - `zone`

        保持组配置和运行时状态的共享内存[区域](ngx_http_upstream_module.md#zone)的名称。

    - `queue`

        对于请求[队列](ngx_http_upstream_module.md#queue)，提供以下数据：

        - `size`

            队列中当前的请求数。

        - `max_size`

            可以同时在队列中的最大请求数。

        - `overflows`

            由于队列溢出而拒绝的请求总数。

- `caches`

    对于每个缓存（由 [proxy_cache_path](ngx_http_proxy_module.md#proxy_cache_path) 等配置）：

    - `size`

        当前缓存的大小。

    - `max_size`

        配置中指定的缓存最大大小限制。

    - `cold`

        一个布尔值，标识**缓存加载器**（cache loade）进程是否仍在将数据从磁盘加载到缓存中。

    - `hit, stale, updating, revalidated`

        - `responses`

            从缓存中读取的响应总次数（由于 [proxy_cache_use_stale](ngx_http_proxy_module.md#proxy_cache_use_stale) 等而导致的命中或过时响应）。

        - `bytes`

            从缓存中读取的总字节数。

    - `miss, expired, bypass`

        - `responses`

            未从缓存中获取的响应总数（由于 [proxy_cache_bypass](ngx_http_proxy_module.md#proxy_cache_bypass) 等原因导致的未命中、过期或绕过）。

        - `bytes`

            从代理服务器读取的总字节数。

        - `responses_written`

            写入缓存的响应总数。

        - `bytes_written`

            写入缓存的总字节数。

- `stream`

    - `server_zones`

        对于每个 [status_zone](#status_zone)：

        - `processing`

            当前正在处理的客户端连接数。

        - `connections`

            从客户端接受的连接总数。

        - `sessions`

            - `total`

                已完成的客户会话总数。

            - `2xx, 4xx, 5xx`

                已完成的会话数，状态代码为 2xx、4xx 或 5xx。

        - `discarded`

            在不创建会话的情况下完成的连接总数。

        - `received`

            从客户端收到的总字节数。

        - `sent`

            发送给客户端的总字节数。

    - `upstreams`

        对于每个[动态可配置组](../stream/ngx_stream_upstream_module.md#zone)，提供以下数据：

        - `peers`

            对于每个[服务器](../stream/ngx_stream_upstream_module.md#server)，提供以下数据：

            - `id`

                服务器的 ID。

            - `server`

                一个服务器[地址](../stream/ngx_stream_upstream_module.md#server)。

            - `name`

                [server](../stream/ngx_stream_upstream_module.md#server) 指令中指定的服务器的名称。

            - `service`

                [server](../stream/ngx_stream_upstream_module.md#server) 指令的 [servive](../stream/ngx_stream_upstream_module.md#service) 参数值。

            - `backup`

                一个布尔值，标识服务器是否为一个[备份](../stream/ngx_stream_upstream_module.md#backup)服务器。
            - `weight`

                服务器的[权重](../stream/ngx_stream_upstream_module.md#weight)。

            - `state`

                当前状态，可以是 `up`、`down`、`unavail`、`checking` 或 `unhealthy` 之一。
                
            - `active`

                当前的连接数。

            - `max_conns`

                服务器的 [max_conns](../stream/ngx_stream_upstream_module.md#max_conns) 限制。

            - `connections`

                转发到此服务器的客户端连接总数。

            - `connect_time`

                连接上游（upstream）服务器的平均时间。在 1.11.6 版之前，该字段仅在使用 [least_time](../stream/ngx_stream_upstream_module.md#least_time) 负载均衡方法时可用。

            - `first_byte_time`

                接收第一个数据字节的平均时间。在 1.11.6 版之前，该字段仅在使用 [least_time](../stream/ngx_stream_upstream_module.md#least_time) 负载均衡时可用。

            - `response_time`

                接收最后一个数据字节的平均时间。在 1.11.6 版之前，该字段仅在使用[least_time](../stream/ngx_stream_upstream_module.md#least_time) 负载均衡方法时可用。

            - `sent`

                发送到此服务器的总字节数。

            - `received`

                从此服务器接收的总字节数。

            - `fails`

                与服务器通信失败的总次数。

            - `unavail`

                由于尝试不成功次数达到 [max_fails](../stream/ngx_stream_upstream_module.md#max_fails) 阈值，服务器对客户端连接变为不可用的次数（状态为 `unavail`）

            - `health_checks`

                - `checks`

                    [健康检查](../stream/ngx_stream_upstream_hc_module.md#health_check)的请求总数。

                - `fails`

                    健康检查失败的次数。

                - `unhealthy`

                    服务器处于不健康的次数（状态 `unhealthy`）。

                - `last_passed`

                    布尔值，表示上次运行状况检查请求是否成功并通过了[测试](../stream/ngx_stream_upstream_hc_module.md#match)。

            - `downtime`

                服务器处于 `unavail`、`checking` 和 `unhealthy` 状态的总时间。

            - `downstart`

                服务器变为 `unavail`、`checking` 或 `unhealthy` 时的时间（自 Epoch 以来的毫秒数）。
            
            - `selected`

                上次选中的服务器处理连接的时间（自 Epoch 以来的毫秒数）。

        - `zombies`

            当前已从组中删除但仍处理活动客户端连接的服务器数。

        - `zone`

            保持组配置和运行时状态的共享内存[区域](../stream/ngx_stream_upstream_module.md#zone)的名称。


<a id="compatibility"></a>

## 兼容性

- [版本](#version) 8 中添加了 [http](#upstreams) 和 [stream](#stream_upstreams) upstreams 的 [zone](#zone) 字段。
- [版本](#version) 8 中添加了 [slab](#slabs) 状态数据。
- [版本](#version) 8 中添加了[检查](#state)状态。
- [版本](#version) 8 中添加了 [http](#upstreams) 和 [stream](#stream_upstreams) upstream 的 [name](#name) 和 [service](#service) 字段。
- [版本](#version) 8 中添加了 [nginx_build](#nginx_build) 和 [ppid](#ppid) 字段。
- [版本](#version) 7 中添加了 [session](#sessions) 状态数据和流 [server_zones](stream_server_zones) 中的 [discarded](#stream_discarded) 字段。
- [zombies](#zombies) 字段是从[版本](#version) 6 的 nginx [调试](../../介绍/调试日志.md)版本移过来的。
- [版本](#version) 6 中添加了 [ssl](#ssl) 状态数据。
- [server_zones](#server_zones) 中的 [discarded](#discarded) 字段已在[版本](#version) 6 中添加。
- [queue](#queue) 状态数据已在[版本](#version) 6 中添加。
- [pid](#pid) 字段已在[版本](#version) 6 中添加。
- [upstreams](#upstreams) 中的服务器列表已移至[版本](#version) 6 中的对应项。
- 在[版本](#version) 5 中删除了 upstream 服务器的 `keepalive` 字段。
- [stream](#stream) 状态数据已在[版本](#version) 5 中添加。
- [版本](#version) 5 中添加了 [generation](#generation) 字段。
- [processes](#processes)中的 [respawned](#respawned) 字段已在[版本](#version) 5 中添加。
- [版本](#version) 5 中添加了 upstreams 中的 [header_time](#header_time) 和 [response_time](#response_time) 字段。
- [版本](#version) 4 中添加了 upstreams 中的 [selected](#selected) 字段。
- [版本](#version) 4 中添加了upstreams 的 [draining](#draining) 状态。
- upstreams 中的 [id](#id) 和 [max_conns](#max_conns) 字段已在[版本](#version) 3 中添加。
- [版本](#version) 3 中添加了 [caches](#caches) 中的 `revalidated` 字段。
- [版本](#version) 2 中添加了 [server_zones](#server_zones)、[caches](#caches) 和 [load_timestamp](#load_timestamp) 状态数据。




    
## 原文档
[http://nginx.org/en/docs/http/ngx_http_status_module.html](http://nginx.org/en/docs/http/ngx_http_status_module.html)
