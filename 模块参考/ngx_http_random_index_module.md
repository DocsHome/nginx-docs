# ngx_http_random_index_module

`ngx_http_random_index_module` 模块处理以 “/” 结尾的请求，然后随机选择一个文件作为首页展示，这个模块优先于 `ngx_http_index_module`。

这个模块默认不会被构建到nginx中，需要在编译时加入 `--with-http_random_index_module` 配置参数。

## 配置示例
```nginx
location / {
    reandom_index on;
}
```
## 原文档

- [http://nginx.org/en/docs/http/ngx_http_random_index_module.html](http://nginx.org/en/docs/http/ngx_http_random_index_module.html)
