# ngx_stream_keyval_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [keyval](#keyval)
    - [keyval_zone](#keyval_zone)

`ngx_stream_keyval_module` 模块（1.13.7）可用于创建变量，变量的值从由 [API](ngx_http_api_module.md#stream_keyvals_) 管理的键值对中获取。

> 此模块为[商业订阅](http://nginx.com/products/?_ga=2.203887064.99786210.1588592638-1615340879.1588592638)部分。

<a id="example_configuration"></a>

## 示例配置

```nginx
http {

    server {
        ...
        location /api {
            api write=on;
        }
    }
}

stream {

    keyval_zone zone=one:32k state=one.keyval;
    keyval      $ssl_server_name $name zone=one;

    server {
        listen              12345 ssl;
        proxy_pass          $name;
        ssl_certificate     /usr/local/nginx/conf/cert.pem;
        ssl_certificate_key /usr/local/nginx/conf/cert.key;
    }
}
```

<a id="directives"></a>

## 指令

### keyval

|\-|说明|
|:------|:------|
|**语法**|**keyval** `key $variable zone=name`;|
|**默认**|——|
|**上下文**|stream|

创建一个新的 `$variable`，其值在键值数据库中通过 key 查找。匹配规则由 [keyval_zone](#keyval_zone) 指令的 [type](#keyval_type) 参数定义。数据库存储在 `zone` 参数指定的共享内存区域中。

### keyval_zone

|\-|说明|
|:------|:------|
|**语法**|**keyval_zone** `zone=name:size [state=file] [timeout=time] [type=string\|ip\|prefix] [sync]`;|
|**默认**|——|
|**上下文**|stream|

设置维持键值数据库的共享内存区域的名称（`name`）和大小（`size`）。键值对通过 [API](ngx_http_api_module.md#stream_keyvals_) 进行管理。

可选的 `state` 参数指定一个文件（`file`），该文件以 JSON 格式保存键值数据库的当前状态，并在重新启动 nginx 时保持不变。

可选的 `timeout` 参数（1.15.0）设置将键值对从区域中删除的时间。

可选的 `type` 参数（1.17.1）激活一个额外的索引，该索引针对某种类型的键匹配进行了优化，匹配规则在计算[键值](#keyval) `$variable` 时定义。

> 索引存储在相同的共享存储区中，因此需要额外的存储。

- `type=string`

    默认配置，不启用索引；使用记录 key 和一个搜索 key 的完全匹配来执行变量查找

- `type=ip`

    搜索 key 是 IPv4 或 IPv6 地址或 CIDR 范围的文字表示；要匹配记录 key，搜索 key 必须属于记录 key 指定的子网或与 IP 地址完全匹配

- `type=prefix`

    使用记录 key 和搜索 key 的前缀匹配（1.17.5）执行变量查找；要与记录 key 匹配，记录 key 必须是搜索 key 的前缀

可选的 `sync` 参数（1.15.0）启用共享内存区域[同步](ngx_stream_zone_sync_module.md#zone_sync)。同步要求设置超时（`timeout`）参数。

> 如果启用了同步，则将仅在目标群集节点上执行键值对（无论是[一个](ngx_http_api_module.md#patchStreamKeyvalZoneKeyValue)还是[全部](ngx_http_api_module.md#deleteStreamKeyvalZoneData)）的删除操作。经过 `timeout` 时间后，将删除其他群集节点上相同的键值对。

## 原文档

- [http://nginx.org/en/docs/stream/ngx_stream_keyval_module.html](http://nginx.org/en/docs/stream/ngx_stream_keyval_module.html)
