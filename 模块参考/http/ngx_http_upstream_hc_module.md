# ngx_http_upstream_hc_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [health_check](#health_check)
    - [match](#match)

`ngx_http_upstream_hc_module` 模块允许对周边 location 中引用的[组](ngx_http_upstream_module.md#upstream)中的服务器进行定期健康检查。服务器组必须驻留在[共享内存](ngx_http_upstream_module.md#zone)中。

如果健康检查失败，则服务器将被视为运行状况不佳。如果为同一组服务器定义了多个健康检查，则任何检查的单个故障都将使相应的服务器被视为运行状况不佳。客户端请求不会传递到处于 **checking** 状态的服务器和不健康的服务器。

> 请注意，与健康检查一起使用时，大多数变量都将为空值。

> 该模块作为[商业订阅](http://nginx.com/products/?_ga=2.72493466.860729840.1564753618-1186072494.1564163363)部分提供。

<a id="example_configuration"></a>

## 示例配置

```nginx
upstream dynamic {
    zone upstream_dynamic 64k;

    server backend1.example.com      weight=5;
    server backend2.example.com:8080 fail_timeout=5s slow_start=30s;
    server 192.0.2.1                 max_fails=3;

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

使用此配置，nginx 将每隔五秒向 `backend` 组中的每个服务器发送 `/` 请求。如果发生任何通信错误或超时，或代理服务器以 2xx 或 3xx 以外的状态码响应，则健康检查将失败，并且服务器将被视为运行状况不佳。

可以配置健康检查以测试响应的状态码、某些头字段及其值的存在以及报文体。测试使用 [match](#match) 指令单独配置，并在 [health_check](#health_check) 指令的 `match` 参数中引用：

```nginx
http {
    server {
    ...
        location / {
            proxy_pass http://backend;
            health_check match=welcome;
        }
    }

    match welcome {
        status 200;
        header Content-Type = text/html;
        body ~ "Welcome to nginx!";
    }
}
```

此配置显示，发起传递一个健康检查，健康检查请求的响应应该为成功，状态码为 200，并在正文中包含 `Welcome to nginx!`。

<a id="directives"></a>

## 指令

### health_check

|\-|说明|
|:------|:------|
|**语法**|**health_check** `[parameters]`;|
|**默认**|——|
|**上下文**|location|

启用对周边 location 中引用的[组](ngx_http_upstream_module.md#upstream)中的服务器定期健康检查。

支持以下可选参数：

- `interval=time`

    设置两次连续健康检查之间的间隔时间，默认为 5 秒

- `jitter=time`

    设置每个健康检查随机延迟的时间，默认情况下，没有延迟

- `fails=number`

    设置特定服务器的连续失败健康检查的数量，在此之后，此服务器将被视为不健康，默认情况下为 1。

- `passes=number`

    设置特定服务器的连续通过健康检查的数量，在此之后服务器将被视为健康，默认情况下为 1。

- `uri=uri`

    定义健康检查请求中使用的 URI，默认情况下为 `/`。

- `mandatory`

    设置服务器的初始 **checking** 状态，直到第一次运行健康检查完成（1.11.7）。客户端请求不会传递到处于 **checking** 状态的服务器。如果未指定参数，则服务器开始将被视为健康。

- `match=name`

    指定 `match` 块配置测试，为响应通过测试做参照，以便通过健康检查。默认情况下，响应的状态码应为 2xx 或 3xx。

- `port=number`

    定义连接到服务器以执行健康检查时使用的端口（1.9.7）。默认情况下，等于 [server](ngx_http_upstream_module.md#server) 端口。

### match

|\-|说明|
|:------|:------|
|**语法**|**match** `name { ... }`;|
|**默认**|——|
|**上下文**|http|

定义用于验证健康检查请求的响应的具名测试集。

可以在响应中测试以下项目：

- `status 200;`

    状态码为 200

- `status ! 500;`

    状态码非 500

- `status 200 204;`

    状态码为 200 或 204

- `status ! 301 302;`

    状态码既不是 301 也不是 302

- `status 200-399;`

    状态码在 200 到 399 之间

- `status ! 400-599;`

    状态码不在 400 到 599 之间

- `status 301-303 307;`

    状态码为 301、302、303 或 307

- `header Content-Type = text/html;`

    header 包含值为 `text/html` 的 **Content-Type**

- `header Content-Type != text/html;`

    header 包含 **Content-Type**，其值不是 `text/html`

- `header Connection ~ close;`

    header 包含 **Connection** ，其值与正则表达式 `close` 匹配

- `header Connection !~ close;`

    header 包含 **Connection**，其值与正则表达式 `close` 不匹配

- `header Host;`

    header 包含 **Host**

- `header ! X-Accel-Redirect;`

    header 没有 **X-Accel-Redirect**

- `body ~ "Welcome to nginx!";`

    正文内容匹配正则表达式 `Welcome to nginx!`

- `body !~ "Welcome to nginx!";`

    正文内容不符合正则表达式 `Welcome to nginx!`

- `require $variable ...;`

    所有指定的变量都不为空且不等于 `"0"`（1.15.9）。

如果指定了多个测试，则响应仅在匹配所有测试时才匹配。

> 仅检查响应体的前 256k 数据。

示例：

```nginx
# status is 200, content type is "text/html",
# and body contains "Welcome to nginx!"
match welcome {
    status 200;
    header Content-Type = text/html;
    body ~ "Welcome to nginx!";
}
# status is not one of 301, 302, 303, or 307, and header does not have "Refresh:"
match not_redirect {
    status ! 301-303 307;
    header ! Refresh;
}
# status ok and not in maintenance mode
match server_ok {
    status 200-399;
    body !~ "maintenance mode";
}
# status is 200 or 204
map $upstream_status $good_status {
    200 1;
    204 1;
}

match server_ok {
    require $good_status;
}
```

## 原文档

- [http://nginx.org/en/docs/http/ngx_http_upstream_hc_module.html](http://nginx.org/en/docs/http/ngx_http_upstream_hc_module.html)
