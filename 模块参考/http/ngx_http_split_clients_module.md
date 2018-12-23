# ngx_http_split_clients_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [split_clients](#split_clients)

`ngx_http_split_clients_module` 模块用于创建适用于 A/B 测试的变量，也称为拆分测试。

<a id="example_configuration"></a>

## 示例配置

```nginx
http {
    split_clients "${remote_addr}AAA" $variant {
                   0.5%               .one;
                   2.0%               .two;
                   *                  "";
    }

    server {
        location / {
            index index${variant}.html;
```

<a id="directives"></a>

## 指令

### split_clients

|\-|说明|
|:------|:------|
|**语法**|**split_clients** `string $variable { ... }`;|
|**默认**|——|
|**上下文**|http|

创建一个用于 A/B 测试的变量。

```nginx
split_clients "${remote_addr}AAA" $variant {
               0.5%               .one;
               2.0%               .two;
               *                  "";
}
```

使用 MurmurHash2 对原始字符串的值进行哈希处理。在以上示例中，哈希值从 0 到 21474835（0.5％）对应 `$variant` 变量的值为 `.one`，哈希值从 21474836 到 107374180（2％）对应的值为 `.two`，哈希值从 107374181 到 4294967295 对应值为 `""`（空字符串）。
    
## 原文档
[http://nginx.org/en/docs/http/ngx_http_split_clients_module.html](http://nginx.org/en/docs/http/ngx_http_split_clients_module.html)
