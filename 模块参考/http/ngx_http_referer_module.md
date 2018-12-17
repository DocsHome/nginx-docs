# ngx_http_referer_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [referer_hash_bucket_size](#referer_hash_bucket_size)
    - [referer_hash_max_size](#referer_hash_max_size)
    - [valid_referers](#valid_referers)
- [内嵌变量](#embedded_variables)

`ngx_http_referer_module` 模块用于阻止 **Referer** 头字段为无效值的请求访问站点。需记住的是，使用适当的 **Referer** 字段值来伪造请求非常容易，因此本模块的预期目的不是要彻底阻止此类请求，而是阻止常规浏览器发送的大量流量请求。还应该考虑到，即使是有效请求，常规浏览器也可能不发送 **Referer** 字段。

<a id="example_configuration"></a>

## 示例配置

```nginx
valid_referers none blocked server_names
               *.example.com example.* www.example.org/galleries/
               ~\.google\.;

if ($invalid_referer) {
    return 403;
}
```

<a id="directives"></a>

## 指令

### referer_hash_bucket_size

|\-|说明|
|:------|:------|
|**语法**|**referer_hash_bucket_size** `size`;|
|**默认**|referer_hash_bucket_size 64;|
|**上下文**|server、location|

设置有效引用哈希表的桶大小。设置哈希表的详细信息在单独的[文档](../../介绍/设置哈希.md)中提供。

### referer_hash_max_size

|\-|说明|
|:------|:------|
|**语法**|**referer_hash_max_size** `size`;|
|**默认**|referer_hash_max_size 2048;|
|**上下文**|server、location|
|**提示**|该指令在 1.0.5 版本中出现|

设置有效引用哈希表的最大 `size`。设置哈希表的详细信息在单独的[文档](../../介绍/设置哈希.md)中提供。

### valid_referers

|\-|说明|
|:------|:------|
|**语法**|**valid_referers** `none` &#124; `blocked` &#124; `server_names` &#124; `string ...`;|
|**默认**|——|
|**上下文**|server、location|

指定 **Referer** 请求头字段值将导致内嵌的 `$invalid_referer` 变量设置为空字符串。否则，变量将为 `1`。匹配搜索不区分大小写。

参数说明如下：

- `none`

    请求头中缺少 **Referer** 字段

- `blocked`

    **Referer** 字段出现在请求头中，但其值已被防火墙或代理服务器删除，这些值为不以 `http://` 或 `https://` 开头的字符串

- `server_names`

    **Referer** 请求头字段包含一个服务器名称

- 任意字符串

    定义一个服务器名称和一个可选的 URI 前缀。服务器名称的开头或结尾可以包含`*`。在检查期间，**Referer** 字段中的服务器端口被忽略

- 正则表达式

    第一个符号应为 `〜`。要注意的是，表达式只与 `http://` 或 `https://` 之后的文本匹配。

示例：

```nginx
valid_referers none blocked server_names
               *.example.com example.* www.example.org/galleries/
               ~\.google\.;
```

<a id="embedded_variables"></a>

## 内嵌变量

- `$invalid_referer`

    如果 **Referer** 请求头字段的值[有效](#valid_referers)，则为空字符串，否则为 1。
    
## 原文档
[http://nginx.org/en/docs/http/ngx_http_referer_module.html](http://nginx.org/en/docs/http/ngx_http_referer_module.html)
