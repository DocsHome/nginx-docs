# ngx_http_upstream_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [upstream](#upstream)
    - [server](#server)
    - [zone](#zone)
    - [state](#state)
    - [hash](#hash)
    - [ip_hash](#ip_hash)
    - [keepalive](#keepalive)
    - [keepalive_requests](#keepalive_requests)
    - [keepalive_timeout](#keepalive_timeout)
    - [ntlm](#ntlm)
    - [least_conn](#least_conn)
    - [least_time](#least_time)
    - [queue](#queue)
    - [random](#random)
    - [sticky](#sticky)
    - [sticky_cookie_insert](#sticky_cookie_insert)
- [内部变量](#embedded_variables)

`ngx_http_upstream_module` 模块用于定义可被 [proxy_pass](ngx_http_proxy_module.md#proxy_pass)、[fastcgi_pass](ngx_http_fastcgi_module.md#fastcgi_pass)、[uwsgi_pass](ngx_http_uwsgi_module.md#uwsgi_pass)、[scgi_pass](ngx_http_scgi_module.md#scgi_pass)、[memcached_pass](ngx_http_memcached_module.md#memcached_pass) 和 [grpc_pass](ngx_http_grpc_module.md#grpc_pass) 指令引用的服务器组。

<a id="example_configuration"></a>

## 示例配置

```nginx
upstream backend {
    server backend1.example.com       weight=5;
    server backend2.example.com:8080;
    server unix:/tmp/backend3;

    server backup1.example.com:8080   backup;
    server backup2.example.com:8080   backup;
}

server {
    location / {
        proxy_pass http://backend;
    }
}
```

动态可配置组定期[健康检查](ngx_http_upstream_hc_module.md)为[商业订阅](http://nginx.com/products/?_ga=2.192708585.259929927.1564163363-1186072494.1564163363)部分：

```nginx
resolver 10.0.0.1;

upstream dynamic {
    zone upstream_dynamic 64k;

    server backend1.example.com      weight=5;
    server backend2.example.com:8080 fail_timeout=5s slow_start=30s;
    server 192.0.2.1                 max_fails=3;
    server backend3.example.com      resolve;
    server backend4.example.com      service=http resolve;

    server backup1.example.com:8080  backup;
    server backup2.example.com:8080  backup;
}

server {
    location / {
        proxy_pass http://dynamic;
        health_check;
    }
}
```

<a id="directives"></a>

## 指令

### upstream

|\-|说明|
|:------|:------|
|**语法**|**upstream** `name { ... }`;|
|**默认**|——|
|**上下文**|http|

定义一组服务器。服务器可以监听不同的端口。此外，可以混合监听 TCP 和 UNIX 域套接字。

例如：

```nginx
upstream backend {
    server backend1.example.com weight=5;
    server 127.0.0.1:8080       max_fails=3 fail_timeout=30s;
    server unix:/tmp/backend3;

    server backup1.example.com  backup;
}
```

默认情况下，使用加权轮询均衡算法在服务器间分配请求。在上面的示例中，每 7 个请求将按如下方式分发：5 个请求转到 `backend1.example.com`，另外 2 个请求分别转发给第二个和第三个服务器。如果在与服务器通信期间发生错误，请求将被传递到下一个服务器，依此类推，直到尝试完所有正常的服务器。如果无法从这些服务器中获得成功响应，则客户端将接收到与最后一个服务器的通信结果。

### server

|\-|说明|
|:------|:------|
|**语法**|**server** `address [parameters]`;|
|**默认**|——|
|**上下文**|upstream|

定义服务器的地址（`address`）和其他参数（`parameters`）。可以将地址指定为域名或 IP 地址，端口可选，或者指定为以 `unix:` 为前缀的 UNIX 域套接字路径。如果未指定端口，则使用 80 端口。解析为多个 IP 地址的域名一次定义多个服务器。

可定义以下参数：

- `weight=number`

    设置服务器的权重，默认为 1。

- `max_conns=number`

    限制与被代理服务器的最大并发活动连接数（`number`）（1.11.5）。默认值为零，表示没有限制。如果服务器组不驻留在[共享内存](ngx_http_upstream_module.md#zone)中，则每个worker 进程的限制都有效。

    > 如果启用了[空闲 keepalive](ngx_http_upstream_module.md#keepalive) 连接、多个 [worker 进程](../核心功能.md#worker_processes)和[共享内存](ngx_http_upstream_module.md#zone)，则被代理服务器的活动和空闲连接总数可能会超过 `max_conns` 的值。

    > 自 1.5.9 版本至 1.11.5 版本之前，此参数为[商业订阅](http://nginx.com/products/?_ga=2.268156877.259929927.1564163363-1186072494.1564163363)部分。

- `max_fails=number`

    设置在 `fail_timeout` 参数设置的时间内发生与服务器通信的失败重试最大次数，以考虑服务器在 `fail_timeout` 参数设置的时间内不可用。默认情况下，失败尝试次数设置为 1。零值则禁止重试计数。失败尝试由 [proxy_next_upstream](ngx_http_proxy_module.md#proxy_next_upstream)、[fastcgi_next_upstream](ngx_http_fastcgi_module.md#fastcgi_next_upstream)、[uwsgi_next_upstream](ngx_http_uwsgi_module.md#uwsgi_next_upstream)、[scgi_next_upstream](ngx_http_scgi_module.md#scgi_next_upstream)、[memcached_next_upstream](ngx_http_memcached_module.md#memcached_next_upstream) 和 [grpc_next_upstream](ngx_http_grpc_module.md#grpc_next_upstream) 指令定义。

- `fail_timeout=time`

    设置

    - 在时间范围内与服务器通信的失败尝试达到指定次数，应将服务器视为不可用
    - 服务器被视为不可用的时长

    默认情况下，参数设置为 10 秒。

- `backup`

    将服务器标记为备用服务器。当主服务器不可用时，它将接收请求。

- `down`

    将服务器标记为永久不可用。

此外，以下参数为[商业订阅](http://nginx.com/products/?_ga=2.99512918.99786210.1588592638-1615340879.1588592638)部分：

- `resolve`

    监控与服务器域名对应的 IP 地址的变更，并自动修改 upstream 配置，无需重新启动 nginx（1.5.12）。服务器组必须驻留在[共享内存](ngx_http_upstream_module.md#zone)中。

    要使此参数起作用，必须在 [http](ngx_http_core_module.md#http) 块中指定 [resolver](ngx_http_core_module.md#resolver) 指令：

    ```nginx
    http {
        resolver 10.0.0.1;

        upstream u {
            zone ...;
            ...
            server example.com resolve;
        }
    }
    ```

- `route=string`

    设置服务器路由名称。

- `service=name`

    能够解析 DNS [SRV](https://tools.ietf.org/html/rfc2782) 记录并设置服务名称（1.9.13）。要使此参数起作用，必须为服务器指定 [resolve](ngx_http_upstream_module.md#resolve) 参数并指定不带端口号的主机名。

    如果服务名称不包含点（`.`），则构造符合 [RFC](https://tools.ietf.org/html/rfc2782) 的名称，并将 TCP 协议添加到服务前缀。例如，要查找 `_http._tcp.backend.example.com` SRV 记录，必须指定该指令：

    ```
    server backend.example.com service=http resolve;
    ```

    如果服务名称包含一个或多个点，则通过加入服务前缀和服务器名称来构造名称。例如，要查找 `_http._tcp.backend.example.com和server1.backend.example.com` SRV 记录，必须指定指令：

    ```
    server backend.example.com service=_http._tcp resolve;
    server example.com service=server1.backend resolve;
    ```

    最高优先级的 SRV 记录（具有相同最低优先级值的记录）被解析为主服务器，其余 SRV 记录被解析为备份服务器。如果为服务器指定了 [backup](ngx_http_upstream_module.md#backup) 参数，则高优先级 SRV 记录将解析为备份服务器，其余 SRV 记录将被忽略。

- `slow_start=time`

    当不健康的服务器变成[健康](ngx_http_upstream_hc_module.md#health_check)状态时，或者服务器在一段时间被认为不可用后变得可用时，设置服务器将其权重从零恢复到标称值的时间（`time`）。默认值为零，即禁用慢启动。

    > 该参数不能与 [hash](ngx_http_upstream_module.md#hash) 和 [ip_hash](ngx_http_upstream_module.md#ip_hash) 负载均衡方式一起使用。

- `drain`

    使服务器进入 draining 模式（1.13.6）。在此模式下，只有[绑定](ngx_http_upstream_module.md#sticky)到服务器的请求才会被代理。

    > 在 1.13.6 版之前，只能使用 [API](http/ngx_http_api_module.md) ​​模块更改参数。

    > 如果组中只有单个服务器，则忽略 `max_fails`、`fail_timeout` 和 `slow_start` 参数，并且永远不会将此类服务器视为不可用。

### zone

|\-|说明|
|:------|:------|
|**语法**|**zone** `name [size]`;|
|**默认**|——|
|**上下文**|upstream|
|**提示**|该指令在 1.9.0 版本中出现|

定义共享内存区域的名称（`name`）和大小（`size`），该区域在 wo'r'kr之间共享组配置和运行时状态。几个组可能共享同一个区域。在这种情况下，仅需指定一次大小（`size`）即可。

此外，作为[商业订阅](http://nginx.com/products/?_ga=2.242046977.2090741542.1564472262-1186072494.1564163363)部分，此类组允许更改组成员身份或修改特定服务器的设置，无需重新启动 nginx。 可以通过 [API](ngx_http_api_module.md) 模块（1.13.3）访问配置。

> 在 1.13.3 版之前，只能通过 [upstream_conf](ngx_http_upstream_conf_module.md#upstream_conf) 处理的特殊 location 访问配置。

### state

|\-|说明|
|:------|:------|
|**语法**|**state** `file`;|
|**默认**|——|
|**上下文**|upstream|
|**提示**|该指令在 1.9.7 版本中出现|

指定一个保持动态可配置组状态的文件（`file`）。

示例：

```nginx
state /var/lib/nginx/state/servers.conf; # path for Linux
state /var/db/nginx/state/servers.conf;  # path for FreeBSD
```

该状态目前仅限于有参数的服务器列表。解析配置时会读取文件，每次[更改](ngx_http_api_module.md#http_upstreams_http_upstream_name_servers_) upstream 配置时都会更新该文件。应避免直接更改文件内容。该指令不能与 [server](ngx_http_upstream_module.md#server) 指令一起使用。

> [配置重新加载](../../介绍/控制nginx.md#reconfiguration)或[二进制升级](../../介绍/控制nginx.md#upgrade)期间所做的更改可能会丢失。

> 该指令为[商业订阅](http://nginx.com/products/?_ga=2.213195671.2090741542.1564472262-1186072494.1564163363)部分。

### hash

|\-|说明|
|:------|:------|
|**语法**|**hash** `key [consistent]`;|
|**默认**|——|
|**上下文**|upstream|
|**提示**|该指令在 1.7.2 版本中出现|

指定服务器组的负载均衡策略，其中客户端/服务器映射基于哈希 `key` 值。`key` 可以包含文本、变量及其组合。请注意，从组中添加或删除服务器可能会导致大部分 key 重新映射到不同的服务器。该方法与 [Cache::Memcached](https://metacpan.org/pod/Cache::Memcached) Perl 库兼容。

如果指定了 `consistent` 参数，则将使用 [ketama](https://www.metabrew.com/article/libketama-consistent-hashing-algo-memcached-clients) 一致性哈希策略。该策略确保在向组中添加或删除服务器时，只有少数 key 被重新映射到不同的服务器。这有助于为缓存服务器实现更高的缓存命中率。该方法与 [Cache::Memcached::Fast](https://metacpan.org/pod/Cache::Memcached::Fast) Perl 库兼容，`ketama_points` 参数设置为 160。

### ip_hash

|\-|说明|
|:------|:------|
|**语法**|**ip_hash**;|
|**默认**|——|
|**上下文**|upstream|

指定一个组应使用基于客户端 IP 地址在服务器之间分发请求的负载均衡方式。客户端 IPv4 地址的前三个八位字节或整个 IPv6 地址作为哈希 key。该方法确保来自同一客户端的请求始终传递到同一服务器，除非服务器不可用。后一种情况下，客户端请求将被传递到另一个服务器。大多数情况下始终是同一台服务器。

> 从 1.3.2 和 1.2.2 版本开始支持 IPv6 地址。

如果需要临时删除其中一个服务器，则应使用 `down` 参数进行标记，以保留客户端 IP 地址的当前哈希值。

示例：

```nginx
upstream backend {
    ip_hash;

    server backend1.example.com;
    server backend2.example.com;
    server backend3.example.com down;
    server backend4.example.com;
}
```

> 在 1.3.1 和 1.2.2 版本之前，使用 `ip_hash` 负载均衡策略无法为服务器指定权重。

### keepalive

|\-|说明|
|:------|:------|
|**语法**|**keepalive** `connections`;|
|**默认**|——|
|**上下文**|upstream|
|**提示**|该指令在 1.1.4 版本中出现|

激活缓存以连接到 upstream 服务器。

`connections` 参数设置在每个 worker（worker）的缓存中保留的 upstream 服务器的最大空闲 keepalive 连接数。超过此数量时，将关闭最近最少使用的连接。

> 需要特别注意的是，`keepalive` 指令不限制 nginx worker 进程可以打开的 upstream 服务器的连接总数。`connections` 参数应设置为足够小的数字，以便 upstream 服务器也可以处理新的传入连接。

使用 keepalive 连接的 memcached  upstream 示例配置：

```nginx
upstream memcached_backend {
    server 127.0.0.1:11211;
    server 10.0.0.2:11211;

    keepalive 32;
}

server {
    ...

    location /memcached/ {
        set $memcached_key $uri;
        memcached_pass memcached_backend;
    }

}
```

对于 HTTP，[proxy_http_version](ngx_http_proxy_module.md#proxy_http_version) 指令应设置为 `1.1`，并且应清除 **Connection** header 字段：

```nginx
upstream http_backend {
    server 127.0.0.1:8080;

    keepalive 16;
}

server {
    ...

    location /http/ {
        proxy_pass http://http_backend;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        ...
    }
}
```

> 或者，可以通过将 **Connection: Keep-Alive** header 字段传递给 upstream 服务器来使用 HTTP/1.0 持久连接，但不建议使用此方法。

对于 FastCGI 服务器，需要设置 [fastcgi_keep_conn](ngx_http_fastcgi_module.md#fastcgi_keep_conn) 才能使 keepalive 连接正常工作：

```nginx
upstream fastcgi_backend {
    server 127.0.0.1:9000;

    keepalive 8;
}

server {
    ...

    location /fastcgi/ {
        fastcgi_pass fastcgi_backend;
        fastcgi_keep_conn on;
        ...
    }
}
```

> 使用除默认轮询方法之外的负载均衡器策略时，必须在 `keepalive` 指令之前激活它们。

> SCGI 和 uwsgi 协议没有 keepalive 连接的概念。

### keepalive_requests

|\-|说明|
|:------|:------|
|**语法**|**keepalive_requests** `number`;|
|**默认**|keepalive_requests 100;|
|**上下文**|upstream|
|**提示**|该指令在 1.15.3 版本中出现|

设置可通过一个 keepalive 连接提供的最大请求数。在达到最大请求数后，连接将关闭。

### keepalive_timeout

|\-|说明|
|:------|:------|
|**语法**|**keepalive_timeout** `timeout`;|
|**默认**|keepalive_timeout 60s;|
|**上下文**|upstream|
|**提示**|该指令在 1.15.3 版本中出现|

设置超时时间，在此期间与 upstream 服务器的空闲 keepalive 连接将保持打开状态。

### ntlm

|\-|说明|
|:------|:------|
|**语法**|**ntlm**;|
|**默认**|——|
|**上下文**|upstream|
|**提示**|该指令在 1.9.2 版本中出现|

允许使用 [NTLM 身份验证](https://en.wikipedia.org/wiki/Integrated_Windows_Authentication)代理请求。一旦客户端发送有以 `Negotiate` 或 `NTLM` 开头的 `Authorization` header 字段值的请求，upstream 连接将绑定到客户端连接。之后的客户端请求将通过相同的 upstream 连接进行代理，从而保持身份验证上下文。

为了使 NTLM 身份验证生效，必须启用与 upstream 服务器的 keepalive 连接。[proxy_http_version](ngx_http_proxy_module.md#proxy_http_version) 指令应设置为 `1.1`，并且应清除 **Connection** header 字段：

```nginx
upstream http_backend {
    server 127.0.0.1:8080;

    ntlm;
}

server {
    ...

    location /http/ {
        proxy_pass http://http_backend;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        ...
    }
}
```

> 使用除默认轮询策略之外的负载均衡器策略时，必须在 `ntlm` 指令之前激活它们。

> 该指令为[商业订阅](http://nginx.com/products/?_ga=2.6482235.860729840.1564753618-1186072494.1564163363)部分。

### least_conn

|\-|说明|
|:------|:------|
|**语法**|**least_conn**;|
|**默认**|——|
|**上下文**|upstream|
|**提示**|该指令在 1.3.1 和 1.2.2 版本中出现|

指定组应使用将请求传递到活动连接数最少的服务器，同时考虑服务器权重的负载均衡策略。如果多个同样的服务器，则使用加权轮询均衡方式依次尝试。

### least_time

|\-|说明|
|:------|:------|
|**语法**|**least_time** `header` &#124; `last_byte` &#124; `[inflight]`;|
|**默认**|——|
|**上下文**|upstream|
|**提示**|该指令在 1.7.10 版本中出现|

指定组应使用将请求传递到有最短平均响应时间和最少活动连接数的服务器，同时考虑服务器权重的负载均衡策略。如果有多个同样的服务器，则使用加权轮询均衡方式依次尝试。

如果指定了 `header` 参数，则使用接收[响应头](ngx_http_upstream_module.md#var_upstream_header_time)的时间。如果指定了 `last_byte` 参数，则使用接收[完整响应](ngx_http_upstream_module.md#var_upstream_response_time)的时间。如果指定了 `inflight` 参数（1.11.6），则还会考虑不完整的请求。

> 在 1.11.6 版本之前，默认情况下会考虑未完成的请求。

> 该指令作为[商业订阅](http://nginx.com/products/?_ga=2.26878900.860729840.1564753618-1186072494.1564163363)部分提供。

### queue

|\-|说明|
|:------|:------|
|**语法**|**queue** `number [timeout=time]`;|
|**默认**|——|
|**上下文**|upstream|
|**提示**|该指令在 1.5.12 版本中出现|

如果在处理请求时无法立即选择 upstream 服务器，则请求将被放在队列中。该指令指定可以同时在队列中的最大请求数（`number`）。如果队列已满，或者在超时参数（`timeout`）指定的时间段内无法选择要传递请求的服务器，则会将 **502 (Bad Gateway)** 错误返回给客户端。

`timeout` 参数的默认值为 60 秒。

> 使用除默认的轮询策略之外的负载均衡策略时，必须在 `queue` 指令之前激活它们。

> 该指令作为[商业订阅](http://nginx.com/products/?_ga=2.60564644.860729840.1564753618-1186072494.1564163363)部分提供。

### random

|\-|说明|
|:------|:------|
|**语法**|**random** `[two [method]]`;|
|**默认**|——|
|**上下文**|upstream|
|**提示**|该指令在 1.15.1 版本中出现|

指定组应使用将请求随机传递给服务器，同时考虑服务器权重的负载均衡策略。

可选的 `two` 参数指示 nginx 随机选择[两个](https://homes.cs.washington.edu/~karlin/papers/balls.pdf)服务器，然后使用指定的方法（`method`）选择服务器。默认方法是 `least_conn`，它将请求传递给活动连接数最少的服务器。

`least_time` 方法将请求传递给平均响应时间最短且活动连接数最少的服务器。如果指定了 `least_time=header`，则使用接收[响应头](ngx_http_upstream_module.md#var_upstream_header_time)的时间。如果指定了 `least_time=last_byte`，则使用接收[完整响应](ngx_http_upstream_module.md#var_upstream_response_time)的时间。

> `least_time` 方法作为[商业订阅](http://nginx.com/products/?_ga=2.27050036.860729840.1564753618-1186072494.1564163363)部分提供。

### sticky

|\-|说明|
|:------|:------|
|**语法**|**sticky** `cookie name [expires=time] [domain=domain] [httponly] [secure] [path=path]`;<br/>**sticky** `route $variable ...`;<br/>**sticky** `learn create=$variable lookup=$variable zone=name:size [timeout=time] [header] [sync]`;|
|**默认**|——|
|**上下文**|upstream|
|**提示**|该指令在 1.5.7 版本中出现|

启用会话关联，这会将来自同一客户端的请求传递到一组服务器中的同一服务器。有三种方法可供选择：

- `cookie`

    使用 `cookie` 方法时，有关指定服务器的信息将在 nginx 生成的 HTTP cookie 中传递：

    ```nginx
    upstream backend {
        server backend1.example.com;
        server backend2.example.com;

        sticky cookie srv_id expires=1h domain=.example.com path=/;
    }
    ```

    来自尚未绑定到特定服务器的客户端的请求将由配置的均衡方法选择服务器传递。使用此 cookie 的后续请求将传递到指定的服务器。如果指定的服务器无法处理请求，则选择新服务器，与客户端未绑定特定服务器的情况一样处理。

    第一个参数设置为要审查或检查的 cookie 的名称。cookie 值是一个 IP 地址和端口的 MD5 哈希值或 UNIX 域套接字路径的十六进制表示形式。但如果指定了 [server](ngx_http_upstream_module.md#server) 指令的 `route` 参数，则 cookie 值将是 `route` 参数的值：

    ```nginx
    upstream backend {
        server backend1.example.com route=a;
        server backend2.example.com route=b;

        sticky cookie srv_id expires=1h domain=.example.com path=/;
    }
    ```

    在这种情况下，`srv_id` cookie 的值将是 `a` 或 `b`。

    其他参数如下：

    - `expires=time`

        设置浏览器保留 cookie 的时间（`time`）。特殊值 `max` 将 cookie 设置在 `31 Dec 2037 23:55:55 GMT` 时到期。如果未指定参数，cookie 将在浏览器会话结束时到期。

    - `domain=domain`

        定义 cookie 的域（`domain`）。参数值可以包含变量（1.11.5）。

    - `httponly`

        将 `HttpOnly` 属性添加到 cookie 中（1.7.11）。

    - `secure`

        将 `Secure` 属性添加到 cookie 中（1.7.11）。

    - `path=path`

        定义 cookie 的设置路径（`path`）。

    被省略参数将不会被设置在 cookie 中。

- `route`

    使用 `route` 方法时，被代理服务器在收到第一个请求时为客户端分配路由。来自此客户端的所有后续请求将在 cookie 或 URI 中携带路由信息。此信息将与 [server](ngx_http_upstream_module.md#server) 指令的 `route` 参数进行比较，以标识应将请求代理到哪个服务器。如果未指定 `route` 参数，则路由名称将是 IP 地址和端口的 MD5 哈希值或 UNIX 域套接字路径的十六进制表示形式。如果指定的服务器无法处理请求，则使用配置的均衡策略选择新服务器，与请求中没有路由信息的情况处理方式一样。

    `route` 方法的参数指定可能包含路由信息的变量。第一个非空变量用于查找匹配服务器。

   示例：

    ```nginx
    map $cookie_jsessionid $route_cookie {
        ~.+\.(?P<route>\w+)$ $route;
    }

    map $request_uri $route_uri {
        ~jsessionid=.+\.(?P<route>\w+)$ $route;
    }

    upstream backend {
        server backend1.example.com route=a;
        server backend2.example.com route=b;

        sticky route $route_cookie $route_uri;
    }
    ```

    此处，路由取自 `JSESSIONID` cookie（如果请求中存在）。否则，使用来自 URI 的路由。

- `learn`

    当使用 `learn` 方法（1.7.1）时，nginx 会分析 upstream 服务器响应并了解经常在 HTTP cookie 中传递的服务器会话。

    ```nginx
    upstream backend {
    server backend1.example.com:8080;
    server backend2.example.com:8081;

    sticky learn
            create=$upstream_cookie_examplecookie
            lookup=$cookie_examplecookie
            zone=client_sessions:1m;
    }
    ```

    在该示例中， upstream 服务器通过在响应中设置 cookie `EXAMPLECOOKIE` 来创建会话。使用此 cookie 的其他请求将传递到同一服务器。如果服务器无法处理请求，则选择新服务器，与客户端尚未绑定特定服务器的情况一样。

    参数 `create` 和 `lookup` 分别指示如何创建新会话和搜索现有会话的变量。两个参数可以多次指定，在这种情况下使用第一个非空变量。

    会话存储在共享内存区域中，其名称（`name`）和大小（`size`）由 `zone` 参数配置。一兆字节区域可以在 64 位平台上存储大约 4000 个会话。在 `timeout` 参数指定的时间内未访问的会话将从区域中删除。默认情况下，超时时间设置为 10 分钟。

    `header` 参数（1.13.1）允许在从 upstream 服务器接收响应头之后立即创建会话。

    `sync` 参数（1.13.8）启用共享内存区域[同步](../stream/ngx_stream_zone_sync_module.md#zone_sync)。

> 该指令作为[商业订阅](http://nginx.com/products/?_ga=2.25871412.860729840.1564753618-1186072494.1564163363)部分提供。

### sticky_cookie_insert

|\-|说明|
|:------|:------|
|**语法**|**sticky_cookie_insert** `name [expires=time] [domain=domain] [path=path]`;|
|**默认**|——|
|**上下文**|upstream|

从 1.5.7 版本开始，该指令已过时。应使用新的 [sticky](ngx_http_upstream_module.md#sticky) 指令代替：

```
sticky cookie name [expires=time] [domain=domain] [path=path];
```

<a id="embedded_variables"></a>

## 内部变量

`ngx_http_upstream_module` 模块支持以下内部变量：

<a id="upstream_addr"></a>

- `$upstream_addr`

    保存 IP 地址和端口，或 upstream 服务器的 UNIX 域套接字的路径。如果在请求处理期间接触了多个服务器，则它们的地址用逗号分隔，例如 `192.168.1.1:80, 192.168.1.2:80, unix:/tmp/sock`。如果从一个服务器组到另一个服务器组的内部发生重定向，由 `X-Accel-Redirect` 或 `error_page` 发起，则来自不同组的服务器地址由冒号分隔，例如 `192.168.1.1:80, 192.168.1.2:80, unix:/tmp/sock : 192.168.10.1:80, 192.168.10.2:80`。 如果无法选择服务器，则变量将保留服务器组的名称。

- `$upstream_bytes_received`

    从 upstream 服务器（1.11.4）接收的字节数。来自多个连接的值由逗号和冒号分隔，参考 [$upstream_addr](#upstream_addr) 变量中的地址格式。

- `$upstream_bytes_sent`

    发送到 upstream 服务器的字节数（1.15.8）。来自多个连接的值由逗号和冒号分隔，参考 [$upstream_addr](#upstream_addr) 变量中的地址格式。

- `$upstream_cache_status`

    保存访问响应缓存的状态（0.8.3）。状态可以是 `MISS`、`BYPASS`、`EXPIRED`、`STALE`、`UPDATING`、`REVALIDATED` 或 `HIT`。

- `$upstream_connect_time`

    保存与 upstream 服务器建立连接所花费的时间（1.9.1），时间以秒为单位，精度为毫秒。在 SSL 的情况下，包含握手时间。多个连接的时间用逗号和冒号分隔，参考 [$upstream_addr](#upstream_addr) 变量中的地址格式。

- `$upstream_cookie_name`

    upstream 服务器在 `Set-Cookie` 响应头字段（1.7.1）中发送的有指定名称的 cookie。仅保存最后一台服务器响应中的 cookie。

- `$upstream_header_time`

    保存从 upstream 服务器接收响应头所花费的时间（1.7.10），时间以秒为单位，精度为毫秒。多个响应的时间用逗号和冒号分隔，参考 [$upstream_addr](#upstream_addr) 变量中的地址格式。

- `$upstream_http_name`

    保存服务器响应头字段。例如，`Server` 响应头字段可通过 `$upstream_http_server` 变量获得。将头字段名称转换为变量名称的规则与以 [$http_](ngx_http_core_module.md#var_http_) 前缀开头的变量相同。仅保存最后一个服务器响应中的头字段。

- `$upstream_queue_time`

    保存请求在 upstream 队列中花费的时间（1.13.9），时间以秒为单位，精度为毫秒。多个响应的时间用逗号和冒号分隔，参考 [$upstream_addr](#upstream_addr) 变量中的地址格式。

- `$upstream_response_length`

    保存从 upstream 服务器获得的响应长度（0.7.27），长度以字节为单位。多个响应的长度用逗号和冒号分隔，参考 [$upstream_addr](#upstream_addr) 变量中的地址格式。

- `$upstream_response_time`

    保存从 upstream 服务器接收响应所花费的时间，时间以秒为单位，精度为毫秒。多个响应的时间用逗号和冒号分隔，参考 [$upstream_addr](#upstream_addr) 变量中的地址格式。

- `$upstream_status`

    保存从 upstream 服务器获得的响应的状态代码。多个响应的状态代码用逗号和冒号分隔，如 [$upstream_addr](#upstream_addr) 变量中的地址格式。如果没有服务器被选中，该变量的值将为 502 (Bad Gateway) 状态码。

- `$upstream_trailer_name`

    保存从 upstream 服务器（1.13.10）获得的响应结束时的字段。

## 原文档

- [http://nginx.org/en/docs/http/ngx_http_upstream_module.html](http://nginx.org/en/docs/http/ngx_http_upstream_module.html)
