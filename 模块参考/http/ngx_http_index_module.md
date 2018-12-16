ngx_http_mirror_module# ngx_http_index_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [index](#index)

`ngx_http_index_module` 模块处理以斜线字符（`/`）结尾的请求。这些请求也可以由[ngx_http_autoindex_module](ngx_http_autoindex_module.html) 和 [ngx_http_random_index_module](ngx_http_random_index_module.html) 模块来处理。

<a id="example_configuration"></a>

## 示例配置

```nginx
location / {
    index index.$geo.html index.html;
}
```

<a id="directives"></a>

## 指令

### index

|\-|说明|
|------:|------|
|**语法**|**index** `file ...`;|
|**默认**|index index.html;|
|**上下文**|http、server、location|

定义将用作索引的文件。文件名可以包含变量。以指定的顺序检查文件。列表的最后一个元素可以是一个具有绝对路径的文件。例：

```nginx
index index.$geo.html index.0.html /index.html;
```

应该注意的是，使用索引文件发起内部重定向，可以在不同的 location 处理请求。例如，使用以下配置：

```nginx
location = / {
    index index.html;
}

location / {
    ...
}
```

`/` 请求实际上是将在第二个 location 处理为 `/index.html`。

## 原文档
[http://nginx.org/en/docs/http/ngx_http_index_module.html](http://nginx.org/en/docs/http/ngx_http_index_module.html)