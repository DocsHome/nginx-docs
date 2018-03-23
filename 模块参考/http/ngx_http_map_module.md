# ngx_http_map_module

- [指令](#directives)
    - [map](#map)
    - [map_hash_bucket_size](#map_hash_bucket_size)
    - [map_hash_max_size](#map_hash_max_size)

`ngx_http_map_module` 模块创建的变量的值取决于其他变量值。

<a id="example_configuration"></a>

## 示例配置

```nginx
map $http_host $name {
    hostnames;

    default       0;

    example.com   1;
    *.example.com 1;
    example.org   2;
    *.example.org 2;
    .example.net  3;
    wap.*         4;
}

map $http_user_agent $mobile {
    default       0;
    "~Opera Mini" 1;
}
```

<a id="directives"></a>

## 指令

### map

|\-|说明|
|------:|------|
|**语法**|**map** `string $variable { ... }`;|
|**默认**|——|
|**上下文**|http|

创建一个新变量，其值取决于第一个参数中指定的一个或多个源变量的值。

> 在 0.9.0 版本之前，只能在第一个参数中指定一个变量。

> 由于只有在使用变量时才计算变量的值，因此仅仅声明大量的 `map` 变量也不会增加额外请求处理负荷。

`map` 块内的参数指定源和结果值之间的映射。

源值可以是字符串或正则表达式（0.9.6）。

字符串匹配将忽略大小写。

正则表达式应该以区分大小写匹配的 `〜` 符号开始，或者以区分大小写匹配的 `〜*` 符号开始（1.0.4）。正则表达式可以包含命名和位置捕获，之后可以将其用于其他指令和作为结果变量。

如果源值与下面描罗列的特殊参数名称之一相匹配，则应该以 `\` 符号为前缀转义。

结果值可以包含文本，变量（0.9.0）及其组合（1.11.0）。

还支持以下特殊参数：

- `default`

    如果源值不匹配指定变体，则设置结果值。如果未指定 `default`，则默认结果值为空字符串。

- `hostname`

    表示源值可以是具有前缀或后缀掩码的主机名：

    ```nginx
    *.example.com 1;
    example.*     1;
    ```

    以下两条记录

    ```nginx
    example.com 1;
    * .example.com 1;
    ````

    可以合并：

    ```nginx
    .example.com 1;
    ```

    这个参数应该在值列表之前指定。

- `include file`

    包含一个包含值的文件。可以有多个包含。

- `volatile`
    
    表示该变量不可缓存（1.11.7）

如果源值匹配多于一个指定的变体，例如 掩码和正则表达式匹配时，将按照以下优先级顺序选择第一个匹配变体：

1. 没有掩码的字符串值
2. 带有前缀掩码的最长字符串值，例如 `*.example.com`
3. 带有后缀掩码的最长字符串值，例如 `mail.*`
4. 首先匹配正则表达式（按照在配置文件中出现的顺序）
5. 默认值

### map_hash_bucket_size

|\-|说明|
|------:|------|
|**语法**|**map_hash_bucket_size** `size`;|
|**默认**|map_hash_bucket_size 32&#124;64&#124;128;|
|**上下文**|http|

设置 [map](#map) 变量哈希表的桶大小。默认值取决于处理器的缓存行大小。设置哈希表的详细内容可在单独的[文档](../../介绍/设置哈希.md)中找到。

### map_hash_max_size

|\-|说明|
|------:|------|
|**语法**|**map_hash_max_size** `size`;|
|**默认**|map_hash_max_size 2048;|
|**上下文**|http|

设置 [map](#map) 变量哈希表的最大大小（`size`）。设置哈熟表的详细内容可在单独的[文档](../../介绍/设置哈希.md)中找到。

## 原文档

[http://nginx.org/en/docs/http/ngx_http_map_module.html](http://nginx.org/en/docs/http/ngx_http_map_module.html)