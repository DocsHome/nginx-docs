# ngx_stream_log_module

- [示例配置](#ngx_stream_map_module)
- [指令](#directives)
    - [map](#map)
    - [map_hash_bucket_size](#map_hash_bucket_size)
    - [map_hash_max_size](#map_hash_max_size)

`ngx_stream_map_module` 模块（1.11.2）用于创建变量，其值取决于其他变量的值。

<a id="example_configuration"></a>

## 示例配置

```nginx
map $remote_addr $limit {
    127.0.0.1    "";
    default      $binary_remote_addr;
}

limit_conn_zone $limit zone=addr:10m;
limit_conn addr 1;
```

<a id="directives"></a>

## 指令

### map

|\-|说明|
|------:|------|
|**语法**|**map** `string $variable { ... }`;|
|**默认**|——|
|**上下文**|stream|

创建一个新变量，其值取决于第一个参数中指定的一个或多个源变量的值。

> 由于仅在使用变量时才对它们进行求值，因此即使声明大量 `map` 变量，也不会为连接处理造成影响。

`map` 块内的参数指定一个源值和结果值之间的映射关系。

源值可为字符串或正则表达式。

字符串匹配时忽略大小写。

正则表达式应以 `~` 符号开头（区分大小写），或者以 `~*` 符号开头（区分大小写）。正则表达式可以包含命名捕获和位置捕获，这些捕获以后可以在其他指令中与结果变量一起使用。

如果源值与以下描述的特殊参数名称之一匹配，则应在其前面加上 `\` 转义符号。

结果值可以包含文本，变量及其组合。

还支持以下特殊参数：

- `default 默认值`

    如果源值不匹配任何指定的变量值，则设置结果值。如果未指定 `default`，则默认结果值为空字符串

- `主机名`

    指示源值可以是带有前缀或后缀掩码的主机名：

    ```
    *.example.com 1;
    example.*     1;
    ```

    以下两条记录

    ```
    example.com   1;
    *.example.com 1;
    ```

    可以组合在一起：

    ```
    .example.com  1;
    ```

    该参数应在值列表之前指定。

- `include 文件`

    包含有值的文件。可包含多个

- `volatile`

    表示该变量不可缓存（1.11.7）

如果源值匹配多个指定变体之一，例如 无论是掩码（mask）匹配还是正则表达式匹配，都将按照以下优先级顺序选择第一个匹配的变量值：

1. 不带掩码的字符串值
2. 带有前缀掩码的最长字符串值，例如 `*.example.com`
3. 带后缀掩码的最长字符串值，例如 `mail.*`
4. 第一个匹配的正则表达式（在配置文件中出现的顺序）
5. 默认值

### map_hash_bucket_size

|\-|说明|
|------:|------|
|**语法**|**map_hash_bucket_size** `size`;|
|**默认**|map_hash_bucket_size 32&#124;64&#124;128;|
|**上下文**|stream|

设置 [map](#map) 变量哈希表的存储桶大小。默认值取决于处理器的缓存行大小。有关设置哈希表的详细信息已在单独的[文档](../../介绍/设置哈希.md)中提供。

### map_hash_max_size

|\-|说明|
|------:|------|
|**语法**|**map_hash_max_size** `size`;|
|**默认**|map_hash_max_size 2048;|
|**上下文**|stream|

设置 [map](#map) 变量哈希表的最大大小（`size`）。有关设置哈希表的详细信息已在单独的[文档](../../介绍/设置哈希.md)中提供。

## 原文档
[http://nginx.org/en/docs/stream/ngx_stream_map_module.html](http://nginx.org/en/docs/stream/ngx_stream_map_module.html)