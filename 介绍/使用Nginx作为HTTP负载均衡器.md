# 使用 nginx 作为 HTTP 负载均衡器
## 介绍
负载均衡跨越多个应用程序实例，是一种常用的技术，其用于优化资源利用率、最大化吞吐量、减少延迟和确保容错配置。

可以使用 nginx 作为高效的 HTTP 负载均衡器，将流量分布到多个应用服务器，并通过 nginx 提高 web 应用程序的性能、可扩展性和可靠性。

## 负载均衡方法
nginx 支持以下负载均衡机制（或方法）：

- **轮询（round-robin）** - 发送给应用服务器的请求以轮询的方式分发
- **最少连接（least-connected）** - 下一个请求被分配给具有最少数量活动连接的服务器
- **ip 哈希（ip-hash）** - 使用哈希函数确定下一个请求应该选择哪一个服务器（基于客户端的 IP 地址）

## 默认负载均衡配置
使用 nginx 进行负载均衡的最简单配置如下所示：

```nginx
http {
    upstream myapp1 {
        server srv1.example.com;
        server srv2.example.com;
        server srv3.example.com;
    }

    server {
        listen 80;

        location / {
            proxy_pass http://myapp1;
        }
    }
}
```
在上述示例中，在 srv1-srv3 上运行相同的应用的三个实例。当负载均衡方法没有被特别配置时，默认采用轮询（round-robin）。所有请求都被 [代理](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_pass) 到服务器组 myapp1，nginx 应用 HTTP 负载均衡来分发请求。

nginx 中的反向代理实现包括 HTTP、HTTPS、FastCGI、uwsgi、SCGI 和 memcached。

要配置 HTTPS 而不是 HTTP 负载均衡，只需要使用 HTTPS 协议。

在为 FastCGI、uwsgi、SCGI 或 memcached 设置负载均衡时，分别使用 [fastcgi_pass](http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html#fastcgi_pass)、[uwsgi_pass](http://nginx.org/en/docs/http/ngx_http_uwsgi_module.html#uwsgi_pass)、[scgi_pass](http://nginx.org/en/docs/http/ngx_http_scgi_module.html#scgi_pass) 和 [memcached_pass](http://nginx.org/en/docs/http/ngx_http_memcached_module.html#memcached_pass) 指令。

## 最少连接负载均衡
另一个负载均衡的规则是最少连接。在一些请求需要更长的时间才能完成的情况下，最少连接可以更公正地控制应用程序实例的负载。

使用最少连接的负载均衡，nginx 将尽量不给过于繁忙的应用服务器负载过多的请求，而是将新的请求分发到不太忙的服务器。

当使用 [least_conn](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#least_conn) 指令作为服务组配置的一部分时，将激活 nginx 中的最少连接负载均衡：

```nginx
upstream myapp1 {
        least_conn;
        server srv1.example.com;
        server srv2.example.com;
        server srv3.example.com;
    }
```

## 会话持久化
请注意，使用轮询或者最少连接的负载均衡，每个后续客户端的请求都可能被分配到不同的服务器。不能保证同一个客户端始终指向同一个服务器。

如果需要将客户端绑定到特定的应用服务器，换而言之，使客户端会话「粘滞」或者「永久」，始终尝试选择特定的服务器，IP 哈希负载均衡机制可以做到这点。

使用 IP 哈希，客户端的 IP 地址用作为哈希键，以确定应用为客户端请求选择服务器组中的哪个服务器。此方法确保了来自同一个客户端的请求始终被定向到同一台服务器，除非该服务器不可用。

要配置 IP 哈希负载均衡，只需要将 [ip_hash](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#ip_hash) 指令添加到服务器 upstream 组配置中即可：

```nginx
upstream myapp1 {
    ip_hash;
    server srv1.example.com;
    server srv2.example.com;
    server srv3.example.com;
}
```

## 加权负载均衡
还可以通过使用服务器权重进一步加强 nginx 的负载均衡算法。

在上面的示例中，服务器权重没有被配置，这意味对于特定的负载均衡方法来说所有指定的服务器都具有同等资格。

特别是使用轮询方式，这也意味着服务器上的请求分配或多或少都是相等的 —— 只要有足够的请求，并且以统一的方式足够快速地完成请求处理。

当服务器指定 [weight](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#server) 参数时，权重将作为负载均衡决策的一部分进行核算。

```nginx
 upstream myapp1 {
        server srv1.example.com weight=3;
        server srv2.example.com;
        server srv3.example.com;
    }
```
通过这样配置，每 5 个新的请求将分布在应用程序实例之中，如下所示：三个请求被定向到 srv1，一个请求将转到 srv2，另一个请求将转到 srv3。

在 nginx 的最近版本中，可以在最少连接和 IP 哈希负载均衡中使用权重。

## 健康检查
nginx 中的反向代理实现包括了带内（或者被动）服务器健康检查。如果特定服务器的响应失败并出现错误，则 nginx 会将此服务器标记为失败，并尝试避免为此后续请求选择此服务器而浪费一段时间。

[max_fails](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#server) 用于设置在 [fail_timeout](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#server) 期间与服务器通信失败重新尝试的次数。默认情况下，[max_fails](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#server) 设置为 1。当设置为 0 时，该服务器的健康检查将被禁用。[fail_timeout](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#server) 参数还定义了服务器被标记为失败的时间。在服务器发生故障后的 [fail_timeout](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#server) 间隔后，nginx 开始以实时客户端的请求优雅地探测服务器。如果探测成功，则将服务器标记为活动。

## 进一步阅读
此外，还有更多的指令和参数可以控制 nginx 中的服务器负载均衡，例如，[proxy_next_upstream](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_next_upstream)、[backup](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#server)、[down](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#server) 和 [keepalive](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#keepalive)。有关更多的信息，请查看我们的参考文档。

最后但同样重要，[应用程序负载均衡](https://www.nginx.com/products/application-load-balancing/?_ga=2.104451654.798520331.1503766923-1890203964.1497190280)、[应用程序健康检查](https://www.nginx.com/products/application-health-checks/?_ga=2.104451654.798520331.1503766923-1890203964.1497190280)、[活动监控](https://www.nginx.com/products/live-activity-monitoring/?_ga=2.104451654.798520331.1503766923-1890203964.1497190280) 和服务组 [动态重新配置](https://www.nginx.com/products/on-the-fly-reconfiguration/?_ga=2.96194266.798520331.1503766923-1890203964.1497190280) 作为我们 NGINX Plus 付费订阅的一部分。

以下文章详细介绍了 NGINX Plus 负载均衡：
- [NGINX 负载均衡与 NGINX Plus](https://www.nginx.com/blog/load-balancing-with-nginx-plus/?_ga=2.96194266.798520331.1503766923-1890203964.1497190280)
- [NGINX 负载均衡与 Nginx Plus 第2部分](https://www.nginx.com/blog/load-balancing-with-nginx-plus-part2/?_ga=2.96194266.798520331.1503766923-1890203964.1497190280)

## 原文档

- [http://nginx.org/en/docs/http/load_balancing.html](http://nginx.org/en/docs/http/load_balancing.html)
