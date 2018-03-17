# ngx_http_keyval_module

- [指令](#directives)
    - [keyval](#keyval)
    - [keyval_zone](#keyval_zone)

`ngx_http_keyval_module` 模块（1.13.3）创建的带值变量从 [API](ngx_http_api_module.md#http_keyvals_) 管理的键值对中获取。

> 该模块可作为我们[商业订阅](http://nginx.com/products/?_ga=2.259594698.1917722686.1520954456-1859001452.1520648382)的一部分。

<a id="example_configuration"></a>

## 示例配置

```nginx
http {

    keyval_zone zone=one:32k state=one.keyval;
    keyval $arg_text $text zone=one;
    ...
    server {
        ...
        location / {
            return 200 $text;
        }

        location /api {
            api write=on;
        }
    }
}
```

<a id="directives"></a>

## 指令

### keyval

|\-|说明|
|------:|------|
|**语法**|**keyval** `key $variable zone=name`;|
|**默认**|——|
|**上下文**|http|

创建一个新的变量 `$variable`，该变量的值从键值数据库中通过 `key` 查找。字符串匹配忽略大小写。数据库存储在 `zone` 参数指定的共享内存区域中。

### keyval_zone

|\-|说明|
|------:|------|
|**语法**|**keyval_zone** `zone=name:size [state=file]`;|
|**默认**|——|
|**上下文**|http|

设置保存键值数据库的共享内存区域的名称（`name`）和大小（`size`）。键值对由 [API](ngx_http_api_module.md#http_keyvals_) 管理。

可选的 `state` 参数指定一个文件，该文件将键值数据库的当前状态保持为 JSON 格式，并使其在 nginx 重启时保持不变。

## 原文档

[http://nginx.org/en/docs/http/ngx_http_keyval_module.html](http://nginx.org/en/docs/http/ngx_http_keyval_module.html)