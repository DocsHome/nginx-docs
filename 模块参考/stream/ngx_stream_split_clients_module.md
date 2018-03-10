# ngx_stream_split_clients_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [split_clients](#split_clients)

`ngx_stream_split_clients_module` 模块（1.11.3）创建适用于 A/B 测试的变量，也称为拆分测试。

<a id="example_configuration"></a>

## 示例配置

```nginx
stream {
    ...
    split_clients "${remote_addr}AAA" $upstream {
                  0.5%                feature_test1;
                  2.0%                feature_test2;
                  *                   production;
    }

    server {
        ...
        proxy_pass $upstream;
    }
}
```

<a id="directives"></a>

## 指令

### split_clients

|\-|说明|
|------:|------|
|**语法**|**split_clients** `string $variable { ... }`|
|**默认**|——|
|**上下文**|stream|

为 A/B 测试创建一个变量，例如：

```nginx
split_clients "${remote_addr}AAA" $variant {
               0.5%               .one;
               2.0%               .two;
               *                  "";
}
```

使用 MurmurHash2 对原始字符串的值进行哈希处理。在给出的例子中，从 0 到 21474835 （0.5％）的哈希值对应于 `$variant` 变量的值 `.one`，从 21474836 到 107374180 （2％）的哈希值对应于值 `.two`，哈希值从 107374181 到 4294967295 对应于值 `""`（空字符串）。

## 原文档
[http://nginx.org/en/docs/stream/ngx_stream_split_clients_module.html](http://nginx.org/en/docs/stream/ngx_stream_split_clients_module.html)