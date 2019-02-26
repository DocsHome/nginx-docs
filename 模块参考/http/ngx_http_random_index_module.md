# ngx_http_random_index_module

`ngx_http_random_index_module` 模块处理以 `/` 结尾的请求，然后随机选择目录中的一个文件作为索引文件展示，该模块优先于 [ngx_http_index_module](ngx_http_index_module.md) 之前处理。

该模块默认不会被构建到 nginx 中，需要在编译时加入 `--with-http_random_index_module` 配置参数启用。

## 配置示例

```nginx
location / {
    random_index on;
}
```

### random_index

|\-|说明|
|:------|:------|
|**语法**|**random_index** `on` &#124; `off`;|
|**默认**|random_index off;|
|**上下文**|location|

启用或禁用 `location` 周边的模块处理。

## 原文档

- [http://nginx.org/en/docs/http/ngx_http_random_index_module.html](http://nginx.org/en/docs/http/ngx_http_random_index_module.html)
