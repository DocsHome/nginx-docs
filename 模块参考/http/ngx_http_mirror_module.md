# ngx_http_mirror_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [mirror](#mirror)
    - [mirror_request_body](#mirror_request_body)

`ngx_http_mirror_module` 模块（1.13.4）通过创建后台镜像子请求来实现原始请求的镜像。镜像子请求的响应将被忽略。

> 译者注：利用 mirror 模块，业务可以将线上实时访问流量拷贝至其他环境，基于这些流量可以做版本发布前的预先验证，进行流量放大后的压测等等。

<a id="example_configuration"></a>

## 示例配置

```nginx
location / {
    mirror /mirror;
    proxy_pass http://backend;
}

location /mirror {
    internal;
    proxy_pass http://test_backend$request_uri;
}
```

<a id="directives"></a>

## 指令

### mirror

|\-|说明|
|------:|------|
|**语法**|**mirror** `uri` &#124; `off`;|
|**默认**|mirror off;|
|**上下文**|http、server、location|

设置将做成镜像的原始请求的 URI。可以在同一层级上指定多个镜像（译者注: 多次重复一个镜像可以实现流量放大）。

### mirror_request_body

|\-|说明|
|------:|------|
|**语法**|**mirror_request_body** `on` &#124; `off`;|
|**默认**|mirror_request_body on;|
|**上下文**|http、server、location|

指示是否将客户端请求体做成镜像。启用后，将在创建镜像子请求之前读取客户端请求体。在这种情况下，将禁用由 [proxy_request_buffering](ngx_http_proxy_module.md#proxy_request_buffering)、[fastcgi_request_buffering](ngx_http_fastcgi_module.md#fastcgi_request_buffering)、[scgi_request_buffering](ngx_http_scgi_module.md#scgi_request_buffering) 和 [uwsgi_request_buffering](ngx_http_uwsgi_module.md#uwsgi_request_buffering) 指令设置的未缓冲的客户端请求正代理。

```nginx
location / {
    mirror /mirror;
    mirror_request_body off;
    proxy_pass http://backend;
}

location /mirror {
    internal;
    proxy_pass http://log_backend;
    proxy_pass_request_body off;
    proxy_set_header Content-Length "";
    proxy_set_header X-Original-URI $request_uri;
}
```
## 原文档
[http://nginx.org/en/docs/http/ngx_http_mirror_module.html](http://nginx.org/en/docs/http/ngx_http_mirror_module.html)
