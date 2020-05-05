# ngx_stream_upstream_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [upstream](#upstream)
    - [server](#server)
    - [zone](#zone)
    - [state](#state)
    - [hash](#hash)
    - [least_conn](#least_conn)
    - [least_time](#least_time)
    - [random](#random)
    - [resolver](#resolver)
    - [resolver_timeout](#resolver_timeout)
- [内部变量](#embedded_variables)

`ngx_stream_upstream_module` 模块（1.9.0）用于定义可以由 [proxy_pass](ngx_stream_proxy_module.md#proxy_pass) 指令引用的服务器组。

<a id="example_configuration"></a>

## 示例配置

```nginx
upstream backend {
    hash $remote_addr consistent;

    server backend1.example.com:12345  weight=5;
    server backend2.example.com:12345;
    server unix:/tmp/backend3;

    server backup1.example.com:12345   backup;
    server backup2.example.com:12345   backup;
}

server {
    listen 12346;
    proxy_pass backend;
}
```

拥有定期运行[健康检查](ngx_stream_upstream_hc_module.md)的动态可配置组为[商业订阅](http://nginx.com/products/?_ga=2.130645319.99786210.1588592638-1615340879.1588592638)部分：

```nginx
resolver 10.0.0.1;

upstream dynamic {
    zone upstream_dynamic 64k;

    server backend1.example.com:12345 weight=5;
    server backend2.example.com:12345 fail_timeout=5s slow_start=30s;
    server 192.0.2.1:12345            max_fails=3;
    server backend3.example.com:12345 resolve;
    server backend4.example.com       service=http resolve;

    server backup1.example.com:12345  backup;
    server backup2.example.com:12345  backup;
}

server {
    listen 12346;
    proxy_pass dynamic;
    health_check;
}
```

<a id="directives"></a>

## 指令

### upstream

|\-|说明|
|------:|------|
|**语法**|**upstream** `name { ... }`;|
|**默认**|——|
|**上下文**|stream|

定义一组服务器。服务器可以在不同的端口上监听。此外，可以将监听 TCP 和 UNIX 域套接字的服务器混合使用。

示例：

```nginx
upstream backend {
    server backend1.example.com:12345 weight=5;
    server 127.0.0.1:12345            max_fails=3 fail_timeout=30s;
    server unix:/tmp/backend2;
    server backend3.example.com:12345 resolve;

    server backup1.example.com:12345  backup;
}
```

默认使用加权轮询均衡算法在服务器间分配连接。在上面的示例中，每 7 个连接将如下分配：5 个连接转到 `backend1.example.com:12345`，一个连接到第二个和第三个服务器。如果在与服务器通信期间发生错误，则连接将被传递到下一个服务器，依此类推，直到尝试完所有正常运行的服务器为止。如果与所有服务器的通信都失败，则连接将关闭。

### server

|\-|说明|
|------:|------|
|**语法**|**server** `address [parameters]`;|
|**默认**|——|
|**上下文**|upstream|

定义服务器的地址（`address`）和其他参数。该地址可以指定为带有端口的域名或 IP 地址，也可以指定前缀为 `unix` 的 UNIX 域套接字路径。解析为多个 IP 地址的域名一次定义了多个服务器。

可以定义以下参数：

- `weight=number`

    设置服务器的权重，默认情况下为 1。

- `max_conns=number`

    限制到被代理服务器的最大同时连接数（1.11.5）。默认值为零，表示没有限制。如果服务器组未驻留在[共享内存](#zone)中，则此限制在每个 worker 进程中均有效。

    > 在 1.11.5 版本之前，此参数作为[商业订阅](http://nginx.com/products/?_ga=2.208745946.99786210.1588592638-1615340879.1588592638)部分。

- `max_fails=number`

    设置在 `fail_timeout` 参数设置的时间内与服务器通信的失败尝试次数，以便认定服务器在 `fail_timeout` 参数设置的时间内不可用。默认情况下，失败尝试的次数设置为 1。零值将禁用尝试记录。在这里，当与服务器正在建立连接中，失败尝试将是一个错误或超时。

- `fail_timeout=time`

    设置

    - 在时间范围内与服务器通信的失败尝试达到指定次数，应将服务器视为不可用
    - 服务器被视为不可用的时长
    
    默认情况下，该参数设置为 10 秒。

- `backup`

    将服务器标记为备用服务器。当主服务器不可用时，连接将传递到备用服务器。

    > 该参数不能与 [hash](#hash) 和 [random](#random) 负载均衡算法一起使用。

- `down`

    将服务器标记为永久不可用。

此外，以下参数作为[商业订阅](http://nginx.com/products/?_ga=2.134173126.99786210.1588592638-1615340879.1588592638)部分提供：

- `resolve`

    监视与服务器域名相对应的 IP 地址的更改，并自动修改 upstream 配置，而无需重新启动 nginx。服务器组必须驻留在[共享内存](#zone)中。

    为了使此参数生效，必须在 [stream](ngx_stream_core_module.md#resolver) 块或相应的 [upstream](#resolver) 块中指定 `resolver` 指令。

- `service=name`

    启用 DNS [SRV](https://tools.ietf.org/html/rfc2782) 记录的解析并设置服务名称（1.9.13）。为了使此参数生效，必须为服务器指定 [resolve](#resolve) 参数，并指定不带端口号的主机名。

    如果服务名称不包含点（`.`），则构造符合 [RFC](https://tools.ietf.org/html/rfc2782) 的名称，并将 TCP 协议添加到服务前缀。例如，要查找 `_http._tcp.backend.example.com` SRV 记录，必须指定指令：

    如果服务名称包含一个或多个点（`.`），则通过将服务前缀和服务器名称结合在一起来构造名称。例如，要查找 `_http._tcp.backend.example.com` 和 `server1.backend.example.com` SRV 记录，必须指定指令：

    ```nginx
    server backend.example.com service=_http._tcp resolve;
    server example.com service=server1.backend resolve;
    ```

    最高优先级的 SRV 记录（具有相同的最低优先级值的记录）被解析为主服务器，其余的 SRV 记录被解析为备用服务器。如果为服务器指定了 [backup](#backup) 参数，则将高优先级 SRV 记录解析为备用服务器，其余的 SRV 记录将被忽略。

- `slow_start=time`

    设置当服务器从非健康状态转为健康状态或一段时间[不可用](#fail_timeout)后转为可用状态，服务器将其权重从 0 恢复到原值的时间（`time`）。默认值为零，即禁用此功能。

    > 该参数不能与 [hash](#hash) 和 [random](#random) 负载均衡算法一起使用。

如果组中只有一台服务器，则将忽略 `max_fails`、`fail_timeout` 和 `slow_start` 参数，这样的服务器将永远不会被视为不可用。

### zone

|\-|说明|
|------:|------|
|**语法**|**zone** `name [size]`;|
|**默认**|——|
|**上下文**|upstream|

定义共享内存区域的名称（`name`）和大小（`size`），以存储 worker 进程之间共享的组配置和运行时状态。多个组可共享同一区域。在这种情况下，仅指定一次大小就足够了。

另外，在[商业订阅](http://nginx.com/products/?_ga=2.171473384.99786210.1588592638-1615340879.1588592638)部分中，此类组允许更改组成员身份或修改特定服务器的设置，而无需重新启动 nginx。可通过 [API](../http/ngx_http_api_module.md) 模块（1.13.3）访问该配置。

> 在 1.13.3 版本之前，只能访问特殊的 location 来通过 [upstream_conf](../http/ngx_http_upstream_conf_module.md#upstream_conf) 处理。

### state

|\-|说明|
|------:|------|
|**语法**|**state** `file`;|
|**默认**|——|
|**上下文**|upstream|
|**提示**|该指令在 1.9.7 版本中出现|

指定一个文件用于保存动态可配置组的状态。

示例：

```nginx
state /var/lib/nginx/state/servers.conf; # path for Linux
state /var/db/nginx/state/servers.conf;  # path for FreeBSD
```

当前状态仅限于带有参数的服务器列表。解析配置时会读取该文件，并且每次更改 upstream 配置时都会[更新](../http/ngx_http_api_module.md#stream_upstreams_stream_upstream_name_servers_)该文件。应避免直接更改文件内容。该指令不能与 [server](#server) 指令一起使用。

> 在[配置重新加载](../../介绍/控制nginx.md#reconfiguration)或[二进制升级](../../介绍/控制nginx.md#upgrade)期间所做的更改可能会丢失。

> 该指令为[商业订阅](http://nginx.com/products/?_ga=2.128922308.99786210.1588592638-1615340879.1588592638)部分。

### hash

|\-|说明|
|------:|------|
|**语法**|**hash** `key [consistent]`;|
|**默认**|——|
|**上下文**|upstream|

指定服务器组的负载均衡算法，在该服务器组中，客户端——服务器的映射基于哈希键值（key/value）。key 可以包含文本、变量及其组合（1.11.2）。 用法示例：

```nginx
hash $remote_addr;
```

请注意，从组中添加或删除服务器可能会导致大量 key 重新映射到其他服务器。该方法与 [Cache::Memcached](https://metacpan.org/pod/Cache::Memcached) Perl 库兼容。

如果指定了 `consistent` 参数，则将使用 [ketama](https://www.metabrew.com/article/libketama-consistent-hashing-algo-memcached-clients) 一致性哈希算法。该方法可确保在将服务器添加到组中或从组中删除服务器时，只有很少的 key 被重新映射到不同的服务器。这有助于缓存服务器实现更高的缓存命中率。该方法与 `ketama_points` 参数设置为 160 的 [Cache::Memcached::Fast](https://metacpan.org/pod/Cache::Memcached::Fast) Perl 库兼容。

### least_conn

|\-|说明|
|------:|------|
|**语法**|**least_conn**;|
|**默认**|——|
|**上下文**|upstream|

指定组使用的负载均衡算法，其将连接传递到活动连接数最少的服务器，同时要考虑服务器的权重。如果有多个这样的服务器，则依次使用加权轮询均衡算法进行尝试。

### least_time

|\-|说明|
|------:|------|
|**语法**|**least_time** `connect` &#124; `first_byte` &#124; `last_byte` `[inflight]`;|
|**默认**|——|
|**上下文**|upstream|

指定组应使用的负载均衡算法，其将连接传递到平均时间最少且活动连接数最少的服务器，同时考虑服务器的权重。如果有多个这样的服务器，则依次使用加权轮询均衡算法进行尝试。

如果指定了 `connect` 参数，则使用[连接](#var_upstream_connect_time)到 upstream 服务器的时间。如果指定了 `first_byte` 变量，则使用接收数据的[首字节](#var_upstream_first_byte_time)的时间。如果指定了 `last_byte`，则使用接收数据[尾字节](#var_upstream_session_time)的时间。如果指定了 `inflight` 参数（1.11.6），还将考虑不完整连接。

> 在 1.11.6 版本之前，默认情况下会考虑不完整的连接。

> 该指令作为[商业订阅](http://nginx.com/products/?_ga=2.162551156.99786210.1588592638-1615340879.1588592638)部分。

### random

|\-|说明|
|------:|------|
|**语法**|**random** `[two [method]]`;|
|**默认**|——|
|**上下文**|upstream|
|**提示**|该指令在 1.15.1 版本中出现|

指定组应使用的负载均衡算法，其将连接传递到随机选择的服务器，同时要考虑服务器的权重。

可选的两个参数指示 nginx 随机选择[两个](https://homes.cs.washington.edu/~karlin/papers/balls.pdf)服务器，然后使用指定的算法（`method`）选择一个服务器。默认方法是 `minimum_conn`，它将连接传递到活动连接数最少的服务器。

`minimum_time` 算法将连接传递到平均时间最少且活动连接数最少的服务器。如果指定了 `least_time=connect` 参数，则使用[连接](#var_upstream_connect_time)到 upstream 服务器的时间。如果指定了 `least_time=first_byte` 参数，则使用接收数据的[首字节](#var_upstream_first_byte_time)的时间。如果指定了 `least_time=last_byte`，如果指定了 `last_byte`，则使用接收数据[尾字节](#var_upstream_session_time)的时间。

> `least_time` 算法是[商业订阅](http://nginx.com/products/?_ga=2.200372710.99786210.1588592638-1615340879.1588592638)部分。

### resolver

|\-|说明|
|------:|------|
|**语法**|**resolver** `address ... [valid=time] [ipv6=on\|off] [status_zone=zone]`;|
|**默认**|——|
|**上下文**|upstream|
|**提示**|该指令在 1.17.5 版本中出现|

配置用于将 upstream 服务器的名称解析为地址的名称服务器，例如：

```nginx
resolver 127.0.0.1 [::1]:5353;
```

可以将地址指定为域名或 IP 地址，配置一个可选端口。如果未指定端口，则使用 53 端口。以轮询算法查找名称服务器。

默认情况下，nginx 在解析时将同时查找 IPv4 和 IPv6 地址。如果不需要查找 IPv6 地址，则可以指定 `ipv6=off` 参数。

默认情况下，nginx 使用响应的 TTL 值缓存回复。可选的 `valid` 参数覆盖默认行为：

```nginx
resolver 127.0.0.1 [::1]:5353 valid=30s;
```

> 为防止 DNS 欺骗，建议在一个受到保护的可信本地网络中配置 DNS 服务器。

可选的 `status_zone` 参数启用对指定区域中请求和响应的 DNS 服务器统计信息的[收集](../../http/ngx_http_api_module.md#resolvers_)。

> 该指令为[商业订阅](http://nginx.com/products/?_ga=2.175591914.99786210.1588592638-1615340879.1588592638)部分。

### resolver_timeout

|\-|说明|
|------:|------|
|**语法**|**resolver_timeout** `time`;|
|**默认**|resolver_timeout 30s;|
|**上下文**|upstream|
|**提示**|该指令在 1.17.5 版本中出现|

为名称解析设置一个超时时间，例如：

```nginx
resolver_timeout 5s;
```

> 该指令为[商业订阅](http://nginx.com/products/?_ga=2.133192262.99786210.1588592638-1615340879.1588592638)部分。

<a id="embedded_variables"></a>

## 内部变量

`ngx_stream_upstream_module` 模块支持以下内部变量：

- `$upstream_addr`

    保留 IP 地址和端口或 upstream 服务器的 UNIX 域套接字（1.11.4）路径。如果在代理过程中联系了多个服务器，则它们的地址用逗号分隔，例如 `192.168.1.1:12345, 192.168.1.2:12345, unix:/tmp/sock`。如果无法选择服务器，则该变量将保留服务器组的名称。

- `$upstream_bytes_received`

    从 upstream 服务器收到的字节数（1.11.4）。来自多个连接的值使用逗号分隔，参考 `$upstream_addr` 变量中的地址。

- `$upstream_bytes_sent`

    发送到 upstream 服务器的字节数（1.11.4）。来自多个连接的值使用逗号分隔，参考 `$upstream_addr` 变量中的地址。

- `$upstream_connect_time`

    连接 upstream 服务器的时间（1.11.4），时间以毫秒为单位，以秒为单位。多个连接的时间用逗号分隔，参考 `$upstream_addr` 变量中的地址。

- `$upstream_first_byte_time`

    接收数据的第一个字节的时间（1.11.4），时间以毫秒为单位，以秒为单位。多个连接的时间用逗号分隔，参考 `$upstream_addr` 变量中的地址。

- `$upstream_session_time`

    会话持续时间，以毫秒为单位，以毫秒为单位（1.11.4）。多个连接的时间用逗号分隔，参考 `$upstream_addr` 变量中的地址。

## 原文档

[http://nginx.org/en/docs/stream/ngx_stream_upstream_module.html](http://nginx.org/en/docs/stream/ngx_stream_upstream_module.html)