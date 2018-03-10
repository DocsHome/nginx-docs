# ngx_http_auth_request_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [auth_request](#auth_request)
    - [auth_request_set](#auth_request_set)

`ngx_http_auth_request_module` 模块（1.5.4+）基于子请求结果实现客户端授权。如果子请求返回一个 2xx 响应代码，则允许访问。如果返回 401 或 403，则拒绝访问并抛出相应的错误代码。子请求返回的任何其他响应代码被认为是一个错误。

对于 401 错误，客户端也从子请求响应中接收 **WWW-Authenticate** 头。

该模块不是默认构建，应该在构建时使用 `--with-http_auth_request_module` 配置参数启用。

该模块可以通过 [satisfy](ngx_http_core_module.md#satisfy) 指令与其他访问模块（如 [ngx_http_access_module](ngx_http_access_module.md)、[ngx_http_auth_basic_module](ngx_http_auth_basic_module.md) 和 [ngx_http_auth_jwt_module](ngx_http_auth_jwt_module.md)）进行组合。

> 在 1.7.3 版本之前，无法缓存对授权子请求的响应（使用 [proxy_cache](ngx_http_proxy_module.html#proxy_cache)、[proxy_store](ngx_http_proxy_module.html#proxy_store) 等）。

<a id="example_configuration"></a>

## 示例配置
```nginx
location /private/ {
    auth_request /auth;
    ...
}

location = /auth {
    proxy_pass ...
    proxy_pass_request_body off;
    proxy_set_header Content-Length "";
    proxy_set_header X-Original-URI $request_uri;
}
```

<a id="directives"></a>

## 指令

### auth_request

|\-|说明|
|:------|:------|
|**语法**|**auth_request** `uri` &#124; `off`;|
|**默认**|auth_request off;|
|**上下文**|http、server、location|

启用基于子请求结果的授权，并设置发送子请求的 URI。

### auth_request_set

|\-|说明|
|:------|:------|
|**语法**|**auth_request_set** `$variable value;`;|
|**默认**|——|
|**上下文**|http|

在授权请求完成后，将请求 `variable`（变量）设置为给定的 `value`（值）。该值可能包含授权请求中的变量，例如 `$upstream_http_*`。

## 原文档
[http://nginx.org/en/docs/http/ngx_http_auth_request_module.html](http://nginx.org/en/docs/http/ngx_http_auth_request_module.html)
