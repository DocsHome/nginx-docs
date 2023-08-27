# ngx_http_api_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [api](#api)
    - [status_zone](#status_zone)
- [兼容性](#compatibility)
- [端点](#endpoints)
    - [/](#root)
    - [/nginx](#nginx)
    - [/processes](#processes)
    - [/connections](#connections)
    - [/slabs/](#slabs_)
    - [/slabs/{slabZoneName}](#slabs_slab_zone_name)
    - [/http/](#http_)
    - [/http/requests](#)
    - [/http/server_zones/](#)
    - [/http/server_zones/{httpServerZoneName}](#)
    - [/http/location_zones/](#)
    - [/http/location_zones/{httpLocationZoneName}](#)
    - [/http/caches/](#)
    - [/http/caches/{httpCacheZoneName}](#)
    - [/http/limit_conns/](#)
    - [/http/limit_conns/{httpLimitConnZoneName}](#)
    - [/http/limit_reqs/](#)
    - [/http/limit_reqs/{httpLimitReqZoneName}](#)
    - [/http/upstreams/](#)
    - [/http/upstreams/{httpUpstreamName}/](#)
    - [/http/upstreams/{httpUpstreamName}/servers/](#)
    - [/http/upstreams/{httpUpstreamName}/servers/{httpUpstreamServerId}](#)
    - [/http/keyvals/](#)
    - [/http/keyvals/{httpKeyvalZoneName}](#)
    - [/stream/](#)
    - [/stream/server_zones/](#)
    - [/stream/server_zones/{streamServerZoneName}](#)
    - [/stream/limit_conns/](#)
    - [/stream/limit_conns/{streamLimitConnZoneName}](#)
    - [/stream/upstreams/](#)
    - [/stream/upstreams/{streamUpstreamName}/](#)
    - [/stream/upstreams/{streamUpstreamName}/servers/](#)
    - [/stream/upstreams/{streamUpstreamName}/servers/{streamUpstreamServerId}](#)
    - [/stream/keyvals/](#)
    - [/stream/keyvals/{streamKeyvalZoneName}](#)
    - [/stream/zone_sync/](#)
    - [/resolvers/](#)
    - [/resolvers/{resolverZoneName}](#)
    - [/ssl](#)
- [响应对象](#definitions)

`ngx_http_api_module` 模块（1.13.3）提供了 REST API，可用于访问各种状态信息，动态配置上游（upstream）服务器组以及管理[键值对](ngx_http_keyval_module.md)，无需重新配置 nginx。

> 该模块将取代 [ngx_http_status_module](ngx_http_status_module.md) 和 [ngx_http_upstream_conf_module](ngx_http_upstream_conf_module.md) 模块。

使用 `PATCH` 或 `POST` 方法时，请确保有效载荷不超过用于读取客户端请求正文的[缓冲区大小](ngx_http_core_module.md#client_body_buffer_size)，否则，可能会返回 413（Request Entity Too Large，请求实体过大）错误。

> 此模块为[商业订阅](http://nginx.com/products/?_ga=2.125744266.1838789148.1589710940-1645619674.1589555275)部分。

<a id="example_configuration"></a>

## 示例配置

```nginx
http {
    upstream backend {
        zone http_backend 64k;

        server backend1.example.com weight=5;
        server backend2.example.com;
    }

    proxy_cache_path /data/nginx/cache_backend keys_zone=cache_backend:10m;

    server {
        server_name backend.example.com;

        location / {
            proxy_pass  http://backend;
            proxy_cache cache_backend;

            health_check;
        }

        status_zone server_backend;
    }

    keyval_zone zone=one:32k state=one.keyval;
    keyval $arg_text $text zone=one;

    server {
        listen 127.0.0.1;

        location /api {
            api write=on;
            allow 127.0.0.1;
            deny all;
        }
    }
}

stream {
    upstream backend {
        zone stream_backend 64k;

        server backend1.example.com:12345 weight=5;
        server backend2.example.com:12345;
    }

    server {
        listen      127.0.0.1:12345;
        proxy_pass  backend;
        status_zone server_backend;
        health_check;
    }
}
```

所有 API 请求都在 URI 中包含一个受支持的 API [版本](#api_version)。API 请求示例如下：

```
http://127.0.0.1/api/6/
http://127.0.0.1/api/6/nginx
http://127.0.0.1/api/6/connections
http://127.0.0.1/api/6/http/requests
http://127.0.0.1/api/6/http/server_zones/server_backend
http://127.0.0.1/api/6/http/caches/cache_backend
http://127.0.0.1/api/6/http/upstreams/backend
http://127.0.0.1/api/6/http/upstreams/backend/servers/
http://127.0.0.1/api/6/http/upstreams/backend/servers/1
http://127.0.0.1/api/6/http/keyvals/one?key=arg1
http://127.0.0.1/api/6/stream/
http://127.0.0.1/api/6/stream/server_zones/server_backend
http://127.0.0.1/api/6/stream/upstreams/
http://127.0.0.1/api/6/stream/upstreams/backend
http://127.0.0.1/api/6/stream/upstreams/backend/servers/1
```

<a id="directives"></a>

## 指令

### api

|\-|说明|
|------:|------|
|**语法**|**api** `[write=on\|off]`;|
|**默认**|——|
|**上下文**|location|

为此 location 打开 REST API 接口。访问此 location 应受到[限制](ngx_http_core_module.md#satisfy)。

`write` 参数确定 API 是只读的还是读写。默认情况下，API 为只读。

所有 API 请求都应在 URI 中包含受支持的 API 版本。如果请求 URI 等于 location 前缀，则返回支持的 API 版本列表。当前的 API 版本是 `6`。

请求行中的可选的 `fields` 参数指定将输出所请求对象的哪些字段：

```
http://127.0.0.1/api/6/nginx?fields=version,build
```

### status_zone

|\-|说明|
|------:|------|
|**语法**|**api** `status_zone` &#124; `first_byte` &#124; `last_byte` `[inflight]`;|
|**默认**|——|
|**上下文**|server、location、location 中的 if|
|**提示**|该指令在 1.13.12 版本中出现|

在指定区域（`zone`）中启用虚拟 [http](ngx_http_core_module.md#server) 或[流](../stream/ngx_stream_core_module.md#server)服务器状态信息的收集。多个服务器可以共享同一区域。

从 1.17.0 版本开始，可以按每个 [location](ngx_http_core_module.md#location) 收集状态信息。特殊值 `off` 禁用在嵌套 location 块中收集统计信息。注意，统计是在处理结束的 location 的上下文中收集的。如果在请求处理期间发生[内部重定向](ngx_http_core_module.md#internal)，则它可能与原始 location 不同。

<a id="compatibility"></a>

## 兼容性

- [/stream/limit_conns/](#stream_limit_conns_) 数据已在 6 [版本](#api_version)中添加
- [/http/limit_conns/](#http_limit_conns_) 数据已在 6 [版本](#api_version)中添加
- [/http/limit_reqs/](#http_limit_reqs_) 数据已在 6 [版本](#api_version)中添加
- 自 5 [版本](#api_version)起，可以[设置](#postHttpKeyvalZoneData)或[更改](#patchHttpKeyvalZoneKeyValue)[键值](ngx_http_keyval_module.md)对的 `expire` 参数。
- [/resolvers/](#resolvers_) 数据是在 5 [版本](#api_version)中添加
- [/http/location_zones/](#http_location_zones_) 数据是在 5 [版本](#api_version)中添加
- [nginx 错误对象](#def_nginx_error)的 `path` 和 `method` 字段在 4 [版本](#api_version)中已删除。这些字段在早期的 api 版本中继续存在，但显示为空值。
- [/stream/zone_sync/](#stream_zone_sync_) 数据已在 3 [版本](#api_version)中添加
- [drain](#def_nginx_http_upstream_conf_server) 参数在 2 [版本](#api_version)中添加
- [/stream/keyvals/](#stream_keyvals_) 数据在 2 [版本](#api_version)中添加

<a id="endpoints"></a>

## 端点

<a id="root"></a>

- `/`

    支持的请求方法

    - `GET` 返回根端点列表

        返回根端点列表

        可能的响应：

        - 200 - 成功，返回一个字符串数组
        - 404 - 未知版本（`UnknownVersion`），返回 [Error](#def_nginx_error)


<a id="nginx"></a>

- `/nginx`

    支持的请求方法

    - `GET` 返回 nginx 运行实例的状态

        返回 nginx 版本、内部名称、地址、加载配置的数量、master 和 worker 进程的 ID 信息。

        请求参数：

        - `fields`（`string`，可选）

            限制 nginx 运行实例的哪些字段可以输出

        可能的响应：

        - 200 - 成功，返回 [nginx](#def_nginx_object)
        - 404 - 未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)

<a id="processes"></a>

- `/processes`

    支持的请求方法

    - `GET` 返回 nginx 进程状态

        返回异常终止和重新启动的子进程的数量。

        可能的响应：

        - 200 - 成功，返回 [Processes](#def_nginx_processes)
        - 404 - 未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)


    - `DELETE` 重置 nginx 进程统计信息

        重置异常终止和重启的子进程的计数器。

        可能的响应：

        - 200 - 成功
        - 404 - 未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error) 
        - 405 - 不允许的请求方法（`MethodDisabled`）,返回 [Error](#def_nginx_error)        

<a id="connections"></a>

- `/connections`

    支持的请求方法

    - `GET` 返回 nginx 进程状态

        返回客户端连接的统计信息。

        请求参数：

        - `fields`（`string`，可选）

            限制客户端连接统计信息中哪些字段可以输出 

        可能的响应：

        - 200 - 成功，返回 [Connections](#def_nginx_connections)
        - 404 - 未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)
        - 405 - 不允许的请求方法（`MethodDisabled`）,返回 [Error](#def_nginx_error)   

    - `DELETE` 重置客户端连接统计信息

        重置接受和删除的客户端连接的统计信息。

        可能的响应：

        - 200 - 成功
        - 404 - 未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error) 
        - 405 - 不允许的请求方法（`MethodDisabled`）,返回 [Error](#def_nginx_error)    

<a id="slabs_"></a>

- `/slabs/`

    支持的请求方法

    - `GET` 返回所有 slab 的状态信息。

        返回每个与 slab 分配器共享内存区域的 slab 的状态。

        请求参数：

        - `fields`（`string`，可选）

            限制 slab 区域信息中哪些字段可以输出，如果 `fields` 为空，将仅输出区域的名称。

        可能的响应：

        - 200 - 成功，为所有 slab 返回一个[「与 slab 分配器共享内存区域」](#def_nginx_slab_zone) 对象的集合
        - 404 - 未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)

<a id="slabs_slabZoneName"></a>

- `/slabs/{slabZoneName}`

    所有请求方法的通用参数：

    - `slabZoneName`（`string` 类型，必须）

        带有 slab 分配器的共享内存区域的名字。 

    支持的请求方法

    - `GET` 返回指定的 slab 状态信息。

        返回指定的 slab 分配器共享内存区域的 slab 状态。

        请求参数：

        - `fields`（`string`，可选）

            限制 slab 区域信息中哪些字段可以输出，如果 `fields` 为空，将仅输出区域的名称。

        可能的响应：

        - 200 - 成功，为所有 slab 返回一个[「与 slab 分配器共享内存区域」](#def_nginx_slab_zone) 对象的集合
        - 404 - 未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)

待完善...

---

<a id="http_keyvals_"></a>

- `/http/keyvals/`

    支持的方法

    - `GET` 返回 HTTP 键值共享内存区域中的所有键值对

        返回存储在流键值共享内存[区域](./ngx_http_keyval_module.md#keyval_zone)中的所有键值对

        请求参数：

        - `fields`（`string`，可选）

            如果 `fields` 为空，只返回 HTTP 键值共享内存区的名称

    可能的响应：

    - 200 - 成功，返回一个包含所有键值对的 [HTTP Keyval Shared Memory Zone](#def_nginx_http_keyval_zone) 对象集合
    - 404 - 未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)

<a id="http_keyvals_httpKeyvalZoneName"></a>

- `/http/keyvals/{httpKeyvalZoneName}`

  所有请求方法的通用参数：

    - `httpKeyvalZoneName`（`string`，必须）

        HTTP 键值共享内存区域的名称

    支持的方法：

    - `GET` 返回指定的 HTTP 键值共享内存区域所有键值对

        返回指定的 HTTP 键值共享内存[区域](./ngx_http_keyval_module.md#keyval_zone)存储的所有键值对

        请求参数：

        - `key`（`string`，可选）

            从当前 HTTP 键值对共享内存区域中获取一个指定的键值对

        可能的响应：

        - 200 - 成功，返回一个 [HTTP Keyval Shared Memory Zone](#def_nginx_http_keyval_zone) 
        - 404 - 键值对未找到（`KeyvalNotFound`）、键值对的 key 未找到（`KeyvalKeyNotFound`）、未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)

    - `POST` 向指定 HTTP 键值共享内存区域添加一个新的键值对

        向指定 HTTP 键值共享内存[区域](./ngx_http_keyval_module.md#keyval_zone)添加一个新的键值对，如果区域空间空闲，可添加多个键值对

        请求参数：

        - `Key-value`（[HTTP Keyval Shared Memory Zone](#def_nginx_http_keyval_zone_post_patch)，必须）

            以 JSON 格式表示的键值对数据，如果内存区域空闲，可添加多个键值对。可以在键值对中以毫秒为单位设置 `expire` 参数的值来覆盖 [keyval_zone](./ngx_http_keyval_module.md#keyval_zone) 指令中的 [`timeout`](./ngx_http_keyval_module.md#keyval_timeout) 参数配置的过期时间设置新增键值对的过期时间。

        可能的响应：

        - 201 - 已创建
        - 400 - 非法 JSON（`KeyvalFormatError`）、非法的 key 格式（`KeyvalFormatError`）、key 必填（`KeyvalFormatError`）、key 超时时间不允许（`KeyvalFormatError`）、仅有一个 key 可以被添加（`KeyvalFormatError`）、读取请求体发生错误（`BodyReadError`）或返回 [Error](#def_nginx_error)
        - 404 - key 不存在（`KeyvalNotFound`、未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)
        - 405 - 不允许的请求方法（`MethodDisabled`），返回 [Error](#def_nginx_error)
        - 409 - 实体已存在（`EntryExists`）、Key 已存在（`KeyvalKeyExists`）
        - 413 - 请求实体过长，返回 [Error](#def_nginx_error)
        - 415 - JSON 错误（`JsonError`），返回 [Error](#def_nginx_error)

    - `PATCH` 修改一个键值对或删除一个 key

        修改键值对中指定 key 的值；根据 key 将值设置为 `null` 来达到删除 key 的目的；修改键值对的过期时间；如果集群的键值共享内存区域的[同步](../stream/ngx_stream_zone_sync_module.md#zone_sync)为启用状态，删除 key 的操作仅发生在当前集群节点。可以在键值对中以毫秒为单位设置 `expire` 参数的值来覆盖 [keyval_zone](./ngx_http_keyval_module.md#keyval_zone) 指令中的 [`timeout`](./ngx_http_keyval_module.md#keyval_timeout) 参数配置的过期时间设置新增键值对的过期时间。

        请求参数：

        - `httpKeyvalZoneKeyValue`（[HTTP Keyval Shared Memory Zone](#def_nginx_http_keyval_zone_post_patch)，必须）

            以 JSON 格式表示的 key 新值

        可能的响应：

        - 204 - 操作成功
        - 400 - 非法 JSON（`KeyvalFormatError`）、非法的 key 格式（`KeyvalFormatError`）、key 必填（`KeyvalFormatError`）、key 超时时间不允许（`KeyvalFormatError`）、仅有一个 key 可以被添加（`KeyvalFormatError`）、读取请求体发生错误（`BodyReadError`）或返回 [Error](#def_nginx_error)
        - 404 - key 不存在（`KeyvalNotFound`、未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)
        - 405 - 不允许的请求方法（`MethodDisabled`），返回 [Error](#def_nginx_error)
        - 409 - 实体已存在（`EntryExists`）、Key 已存在（`KeyvalKeyExists`）
        - 413 - 请求实体过长，返回 [Error](#def_nginx_error)
        - 415 - JSON 错误（`JsonError`），返回 [Error](#def_nginx_error)

    - `DELETE` 清空 HTTP 键值共享内存区域数据

        删除流键值共享内存[区域](./ngx_http_keyval_module.md#keyval_zone)中的所有键值对，如果集群的键值共享内存区域的[同步](../stream/ngx_stream_zone_sync_module.md#zone_sync)为启用状态，清空的操作仅发生在当前集群节点。

        可能的响应：

        - 204 - 成功
        - 404 - Key 找不到（`KeyvalNotFound`），未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)
        - 405 - 不允许的请求方法（`MethodDisabled`）,返回 [Error](#def_nginx_error)

<a id="stream_"></a>

- `/stream/`

    支持的方法：

    - `GET` 返回所有与流相关的端点

        返回一个包含所有与流相关的第一级端点列表

        可能的响应：

        - 200 - 成功，返回一个字符串数组
        - 404 - 未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)

<a id="stream_server_zones_"></a>

- `/stream/server_zones/`

    支持的方法：

    - `GET` 返回所有流服务器区域的状态信息

        返回每个流[服务器区域](#status_zone) 状态信息

        请求参数：

        - `fields`（`string`，可选）

            限制返回的流服务器区域信息中的数据字段，如果 `fields` 为空，仅返回服务器区域的名称

        可能的响应：

        - 200 - 成功，返回一个包含所有流服务器区域信息的 [Stream Server Zone](#def_nginx_stream_server_zone) (#def_nginx_stream_limit_conn_zone) 对象集合
        - 404 - 未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)

<a id="stream_server_zones_streamServerZoneName"></a>

- `/stream/server_zones/{streamServerZoneName}`

   所有请求方法的通用参数：

    - `streamServerZoneName`（`string`，必须）

        流服务器区域的名称

    支持的方法：

    - `GET` 返回指定的流服务器区域的状态信息

        返回指定流服务器区域的状态信息

        请求参数：

        - `fields`（`string`，可选）

            限制流服务器区域状态信息返回的数据字段

        可能的响应：

        - 200 - 成功，返回一个 [Stream Server Zone](#def_nginx_stream_server_zone) 
        - 404 - 服务器区域未找到（`ServerZoneNotFound`）、未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)

    - `DELETE` 重置一个指定的流服务器区域统计信息

        重置指定的流服务器区域的连接接受数、断开数，会话数，字节接收和发送数等统计信息

        可能的响应：

        - 204 - 成功
        - 404 - 服务器区域未找到（`ServerZoneNotFound`）、未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)
        - 405 - 不允许的请求方法（`MethodDisabled`），返回 [Error](#def_nginx_error)

<a id="stream_limit_conns_"></a>

- `/stream/limit_conns/`

    支持的方法：

    - `GET` 返回所有流的 limit_conn 区域的状态信息

        返回每个流的 [limit_conn zone](../stream/ngx_stream_limit_conn_module.md#limit_conn_zone) 状态信息

        请求参数：

        - `fields`（`string`，可选）

            限制 [limit_conn zone](../stream/ngx_stream_limit_conn_module.md#limit_conn_zone) 返回的数据字段

        可能的响应：

        - 200 - 成功，返回一个包含所有流连接限制信息的 [Stream Connections Limiting](#def_nginx_stream_limit_conn_zone) 对象集合
        - 404 - limit_conn 未找到（`LimitConnNotFound`）、未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)

<a id="stream_limit_conns_streamLimitConnZoneName"></a>

- `/stream/limit_conns/{streamLimitConnZoneName}`

    所有请求方法的通用参数：

    - `streamLimitConnZoneName`（`string`，必须）

        [limit_conn zone](../stream/ngx_stream_limit_conn_module.md#limit_conn_zone) 的名称

    支持的方法：

    - `GET` 返回指定的流 limit_conn 区域的状态信息

        返回一个流 [limit_conn zone](../stream/ngx_stream_limit_conn_module.md#limit_conn_zone)

        请求参数：

        - `fields`（`string`，可选）

            限制 [limit_conn zone](../stream/ngx_stream_limit_conn_module.md#limit_conn_zone) 返回的数据字段

        可能的响应：

        - 200 - 成功，返回一个 [Stream Connections Limiting](#def_nginx_stream_limit_conn_zone) 
        - 404 - limit_conn 未找到（`LimitConnNotFound`）、未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)

    - `DELETE` 重置一个指定的流 limit_conn 区域统计信息

        重置连接限制统计信息

        可能的响应：

        - 204 - 成功
        - 404 - limit_conn 未找到（`LimitConnNotFound`）、未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)
        - 405 - 不允许的请求方法（`MethodDisabled`），返回 [Error](#def_nginx_error)


<a id="stream_upstreams_"></a>

- `/stream/upstreams/`

    支持的方法：

    - `GET` 返回所有流上游服务器的状态信息

        返回每个上游服务器组状态及其所有服务器信息

        请求参数：

        - `fields`（`string`，可选）

            限制返回上游服务器组的信息字段，如果 `fields` 为空，仅返回上游的名称

        可能的响应：

        - 200 - 成功，返回一个包含所有流上游的 [Stream Upstream](#def_nginx_stream_upstream)  对象集合
        - 404 - 未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)



<a id="stream_upstreams_streamUpstreamName_"></a>

- `/stream/upstreams/{streamUpstreamName}/`

    所有请求方法的通用参数：

    - `streamUpstreamName`（`string`，必须）

        流上游服务器组名称

    支持的方法：

    - `GET` 返回流上游服务器组状态信息

        返回指定的流上游服务器组状态及其所有服务器信息

        请求参数：

        - `fields`（`string`，可选）

            限制返回信息中的字段

        可能的响应：

        - 200 - 成功，返回一个 [Stream Upstream](#def_nginx_stream_upstream) 
        - 400 - 上游为静态（`UpstreamStatic`）,返回 [Error](#def_nginx_error)
        - 404 - 未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)

    - `DELETE` 重置指定流上游服务器组的统计信息

        重置指定流上游服务器组中每个服务器的统计信息

        可能的响应：

        - 204 - 成功
        - 400 - 上游为静态（`UpstreamStatic`）,返回 [Error](#def_nginx_error)
        - 404 - 未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)
        - 405 - 不允许的请求方法（`MethodDisabled`），返回 [Error](#def_nginx_error)

<a id="stream_upstreams_streamUpstreamName_servers_"></a>

- `/stream/upstreams/{streamUpstreamName}/servers/`

    所有请求方法的通用参数：

    - `streamUpstreamName`（`string`，必须）

        上游流服务器组名称

    支持的方法：

    - `GET` 返回流上游服务器组所有服务器的配置信息

        返回流上游服务器组所有服务器的配置信息

        可能的响应：

        - 200 - 成功，返回一个 [Stream Upstream Server](#def_nginx_stream_upstream_conf_server) 对象
        - 400 - 上游为静态（`UpstreamStatic`）、返回 [Error](#def_nginx_error)
        - 404 - 未知版本（`UnknownVersion`）、找不到上游信息（`UpstreamNotFound`）、返回 [Error](#def_nginx_error)

    - `POST` 添加一个服务器到流上游服务器组中

        添加一个服务器到流上游服务器组中，使用 JSON 格式指定服务器配置数据

        请求参数：

        - `postStreamUpstreamServer`（[Stream Upstream Server](#def_nginx_stream_upstream_conf_server)，必须）

            新服务器的地址和其他可选参数，以 JSON 格式表示，`ID`、`backup` 和 `service`  参数不能改变。

        可能的响应：

        - 201 - 添加成功，返回一个 [Stream Upstream Server](#def_nginx_stream_upstream_conf_server) 对象
        - 400 - 上游为静态（`UpstreamStatic`）、无效的 `parameter` 值（`UpstreamConfFormatError`）、`server` 参数缺失（`UpstreamConfFormatError`）、未知参数 `name`（`UpstreamConfFormatError`）、嵌套的对象或列表（`UpstreamConfFormatError`）、解析发生 `error`（`UpstreamBadAddress`）、服务器 `host` 中没有端口（`UpstreamBadAddress`）、服务上游 `host` 可能没有端口（`UpstreamBadAddress`）、服务上游 `host` 需要域名（`UpstreamBadAddress`）、无效的 `weight`（`UpstreamBadWeight`）、无效的 `max_conns`（`UpstreamBadMaxConns`）、无效的 `max_fails`（`UpstreamBadMaxFails`）、无效的 `fail_timeout`（`UpstreamBadFailTimeout`）、无效的 `slow_start`（`UpstreamBadSlowStart`）、`service` 为空（`UpstreamBadService`）、没有定义 resolver 用于解析（`UpstreamConfNoResolver`）、上游 `name` 没有备份服务器（`UpstreamNoBackup`）、上游 `name` 内存耗尽（`UpstreamOutOfMemory`）、读取请求体失败（`BodyReadError`）、返回 [Error](#def_nginx_error)
        - 404 - 未知版本（`UnknownVersion`）、找不到上游信息（`UpstreamNotFound`）、返回 [Error](#def_nginx_error)
        - 405 - 不允许的请求方法（`MethodDisabled`），返回 [Error](#def_nginx_error)
        - 409 - 记录已存在（`EntryExists`），返回 [Error](#def_nginx_error)
        - 415 - JSON 错误（`JsonError`），返回 [Error](#def_nginx_error)

    - `DELETE` 从流上游服务器组中移除某个服务器

        从流上游服务器组中移除某个服务器

        可能的响应：

        - 200 - 成功，返回一个 [Stream Upstream Server](#def_nginx_stream_upstream_conf_server) 对象
        - 400 - 上游为静态（`UpstreamStatic`）、无效服务器 ID（`UpstreamBadServerId`）、服务器 `id` 不可移除（`UpstreamServerImmutable`）、返回 [Error](#def_nginx_error)
        - 404 - ID 为 `id` 的服务器不存在（`UpstreamServerNotFound`）、未知版本（`UnknownVersion`）、找不到上游信息（`UpstreamNotFound`）、返回 [Error](#def_nginx_error)
        - 405 - 不允许的请求方法（`MethodDisabled`），返回 [Error](#def_nginx_error)




<a id="stream_upstreams_streamUpstreamName_servers_streamUpstreamServerId"></a>

- `/stream/upstreams/{streamUpstreamName}/servers/{streamUpstreamServerId}`

    所有请求方法的通用参数：

    - `streamUpstreamName`（`string`，必须）

        上游服务器组名称

    - `streamUpstreamServerId`（`string`，必须）

        服务器 ID

    支持的方法：

    - `GET` 返回上游服务器组中某个服务器的配置信息

        返回上游服务器组中某个服务器的配置信息

        可能的响应：

        - 200 - 成功，返回一个 [Stream Upstream Server](#def_nginx_stream_upstream_conf_server) 对象
        - 400 - 上游为静态（`UpstreamStatic`）、非法服务器 ID（`UpstreamBadServerId`）、返回 [Error](#def_nginx_error)
        - 404 - 未知版本（`UnknownVersion`）、找不到上游信息（`UpstreamNotFound`）、服务器 ID 不存在（`UpstreamServerNotFound`）、返回 [Error](#def_nginx_error)

    - `PATCH` 修改流上游服务器组的某个服务器信息

        修改流上游服务器组的某个服务器配置信息，使用 JSON 格式指定服务器配置数据

        请求参数：

        - `patchStreamUpstreamServer`（[Stream Upstream Server](#def_nginx_stream_upstream_conf_server)，必须）

            服务器参数，以 JSON 格式表示，`ID`、`backup` 和 `service`  参数不能改变。

        可能的响应：

        - 200 - 成功，返回一个 [Stream Upstream Server](#def_nginx_stream_upstream_conf_server) 对象
        - 400 - 上游为静态（`UpstreamStatic`）、无效的 `parameter` 值（`UpstreamConfFormatError`）、未知参数 `name`（`UpstreamConfFormatError`）、嵌套的对象或列表（`UpstreamConfFormatError`）、解析发生 `error`（`UpstreamBadAddress`）、无效的 `server` 参数（`UpstreamBadAddress`）、服务器 `server` 没有端口（`UpstreamBadAddress`）、无效服务器 ID（`UpstreamBadServerId`）、无效的 `weight`（`UpstreamBadWeight`）、无效的 `max_conns`（`UpstreamBadMaxConns`）、无效的 `max_fails`（`UpstreamBadMaxFails`）、无效的 `fail_timeout`（`UpstreamBadFailTimeout`）、无效的 `slow_start`（`UpstreamBadSlowStart`）、读取请求体失败（`BodyReadError`）、`service` 为空（`UpstreamBadService`）、服务器 `ID` 的地址不能变更（`UpstreamServerImmutable`）、服务器 `ID` 的 `weight` 不能变更（`UpstreamServerWeightImmutable`）、上游 `name` 内存耗尽（`UpstreamOutOfMemory`）、返回 [Error](#def_nginx_error)
        - 404 - ID 为 `id` 的服务器不存在（`UpstreamServerNotFound`）、未知版本（`UnknownVersion`）、找不到上游信息（`UpstreamNotFound`）、返回 [Error](#def_nginx_error)
        - 405 - 不允许的请求方法（`MethodDisabled`），返回 [Error](#def_nginx_error)
        - 415 - JSON 错误（`JsonError`），返回 [Error](#def_nginx_error)

    - `DELETE` 从流上游服务器组中移除某个服务器

        从流上游服务器组中移除某个服务器

        可能的响应：

        - 200 - 成功，返回一个 [Stream Upstream Server](#def_nginx_stream_upstream_conf_server) 对象
        - 400 - 上游为静态（`UpstreamStatic`）、无效服务器 ID（`UpstreamBadServerId`）、服务器 `id` 不可移除（`UpstreamServerImmutable`）、返回 [Error](#def_nginx_error)
        - 404 - ID 为 `id` 的服务器不存在（`UpstreamServerNotFound`）、未知版本（`UnknownVersion`）、找不到上游信息（`UpstreamNotFound`）、返回 [Error](#def_nginx_error)
        - 405 - 不允许的请求方法（`MethodDisabled`），返回 [Error](#def_nginx_error)


<a id="stream_keyvals_"></a>

- `/stream/keyvals/`

    支持的方法

    - `GET` 返回流键值区域中的所有键值对

        返回存储在流键值共享内存[区域](../stream/ngx_stream_keyval_module.md#keyval_zone)中的所有键值对

        请求参数：

        - `fields`（`string`，可选）

            如果 `fields` 为空，只返回流键值共享内存区域的名称

    可能的响应：

    - 200 - 成功，返回一个包含所有键值对的 [Stream Keyval Shared Memory Zone](#def_nginx_stream_keyval_zone) 对象集合
    - 404 - 未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)

<a id="stream_keyvals_streamKeyvalZoneName"></a>

- `/stream/keyvals/{streamKeyvalZoneName}`

    所有请求方法的通用参数：

    - `streamKeyvalZoneName`（`string`，必须）

        流键值共享内存区域的名字

    支持的方法

    - `GET` 返回流键值区域中的键值对

        返回存储在流键值共享内存[区域](../stream/ngx_stream_keyval_module.md#keyval_zone)中的键值对

        请求参数：

        - `key`（`string`，可选）

            要从流键值共享内存区域中获取的键值的 key

        可能的响应：

        - 200 - 成功，返回 [Stream Keyval Shared Memory Zone](#def_nginx_stream_keyval_zone)
        - 404 - 键值对找不到（`KeyvalNotFound`），未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)

    - `POST` 添加一个键值对到流键值共享内存区域中

        添加一个新的键值对到流键值共享内存[区域](../stream/ngx_stream_keyval_module.md#keyval_zone)中。如果内存区域空闲，可添加多个键值对

        请求参数：

        - `Key-value`（[Stream Keyval Shared Memory Zone](#def_nginx_stream_keyval_zone)，必须）

            一个键值对规定必须为 JSON 格式，如果内存区域空闲，可添加多个键值对。可以在键值对中以毫秒为单位设置 `expire` 参数的值来覆盖 [keyval_zone](https://nginx.org/en/docs/stream/ngx_stream_keyval_module.html#keyval_zone) 指令中的 [`timeout`](../stream/ngx_stream_keyval_module.md#keyval_timeout) 参数配置的过期时间设置新增键值对的过期时间。

        可能的响应：

        - 201 - 已创建
        - 400 - 非法 JSON（`KeyvalFormatError`）、非法的 key 格式（`KeyvalFormatError`）、key 必填（`KeyvalFormatError`）、key 超时时间不允许（`KeyvalFormatError`）、仅有一个 key 可以被添加（`KeyvalFormatError`）、读取请求体发生错误（`BodyReadError`）或返回 [Error](#def_nginx_error)
        - 404 - key 不存在（`KeyvalNotFound`、未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)
        - 405 - 不允许的请求方法（`MethodDisabled`），返回 [Error](#def_nginx_error)
        - 409 - 实体已存在（`EntryExists`）、Key 已存在（`KeyvalKeyExists`）
        - 413 - 请求实体过长，返回 [Error](#def_nginx_error)
        - 415 - JSON 错误（`JsonError`），返回 [Error](#def_nginx_error)

    - `PATCH` 修改一个键值对或删除一个 key

        修改键值对中指定 key 的值；根据 key 将值设置为 `null` 来达到删除 key 的目的；修改键值对的过期时间；如果集群的键值共享内存区域的[同步](../stream/ngx_stream_zone_sync_module.md#zone_sync)为启用状态，删除 key 的操作仅发生在当前集群节点。可以在键值对中以毫秒为单位设置 `expire` 参数的值来覆盖 [keyval_zone](https://nginx.org/en/docs/stream/ngx_stream_keyval_module.html#keyval_zone) 指令中的 [`timeout`](../stream/ngx_stream_keyval_module.md#keyval_timeout) 参数配置的过期时间设置新增键值对的过期时间。

        请求参数：

        - `streamKeyvalZoneKeyValue`（[Stream Keyval Shared Memory Zone](#def_nginx_stream_keyval_zone)，必须）

            以 JSON 格式表示的 key 新值

        可能的响应：

        - 204 - 操作成功
        - 400 - 非法 JSON（`KeyvalFormatError`）、非法的 key 格式（`KeyvalFormatError`）、key 必填（`KeyvalFormatError`）、key 超时时间不允许（`KeyvalFormatError`）、仅有一个 key 可以被添加（`KeyvalFormatError`）、读取请求体发生错误（`BodyReadError`）或返回 [Error](#def_nginx_error)
        - 404 - key 不存在（`KeyvalNotFound`、未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)
        - 405 - 不允许的请求方法（`MethodDisabled`），返回 [Error](#def_nginx_error)
        - 409 - 实体已存在（`EntryExists`）、Key 已存在（`KeyvalKeyExists`）
        - 413 - 请求实体过长，返回 [Error](#def_nginx_error)
        - 415 - JSON 错误（`JsonError`），返回 [Error](#def_nginx_error)

    - `DELETE` 清空流键值共享内存区域数据

        删除流键值共享内存[区域](../stream/ngx_stream_keyval_module.md#keyval_zone)中的所有键值对，如果集群的键值共享内存区域的[同步](../stream/ngx_stream_zone_sync_module.md#zone_sync)为启用状态，清空的操作仅发生在当前集群节点。

        可能的响应：

        - 204 - 成功
        - 404 - Key 找不到（`KeyvalNotFound`），未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)
        - 405 - 不允许的请求方法（`MethodDisabled`）,返回 [Error](#def_nginx_error)

<a id="stream_zone_sync"></a>

- `/stream/zone_sync/`

    支持的方法

    - `GET` 返回节点的同步状态

        返回一个集群节点的同步状态

        可能的响应：

        - 200 - 成功，返回 [Stream Zone Sync Node](#def_nginx_stream_zone_sync)
        - 404 - 未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)


<a id="resolvers_"></a>

- `/resolvers/`

    支持的方法

    - `GET` 返回所有 resolver zone 的统计信息

        返回所有 resolver zone 的统计信息

        请求参数：

        - `fields`（`string`，可选）

            限制 resolver zone 统计信息输出哪些字段

        可能的响应：

        - 200 - 成功，返回一个包含所有 resolver 的 [Resolver Zone](#def_nginx_resolver_zone) 集合
        - 404 - 未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)


<a id="resolvers_resolverZoneName"></a>

- `/resolvers/{resolverZoneName}`

    所有请求方法的通用参数：

    - `resolverZoneName`（`string`，必须）

        resolver zone 的名字

    支持的方法

    - `GET` 返回 resolver zone 的统计信息

        返回 resolver zone 的统计信息

        请求参数：

        - `fields`（`string`，可选）

            限制 resolver zone 统计信息输出哪些字段（requests、responses 或者全部）

        可能的响应：

        - 200 - 成功，返回 [Resolver Zone](#def_nginx_resolver_zone)
        - 404 - Resolver Zone 找不到（`ResolverZoneNotFound`），未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)

    - `DELETE` 重置 resolver zone 的统计信息

        重置 resolver zone 的统计信息

        可能的响应：

        - 204 - 成功
        - 404 - Resolver Zone 找不到（`ResolverZoneNotFound`），未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)
        - 405 - 不允许的请求方法（`MethodDisabled`）,返回 [Error](#def_nginx_error)


<a id="ssl"></a>

- `/ssl`

    支持的方法

    - `GET` 返回 SSL 统计信息

        返回 SSL 统计信息

        请求参数：

        - `fields`（`string`，可选）

            限制 SSL 统计信息输出哪些字段

        可能的响应：

        - 200 - 成功，返回 [SSL](#def_nginx_ssl_object)
        - 404 - 未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)

    - `DELETE` 重置 SSL 统计信息

        重置 SSL 统计信息

        可能的响应：

        - 204 - 成功
        - 404 - 未知版本（`UnknownVersion`）,返回 [Error](#def_nginx_error)
        - 405 - 不允许的请求方法（`MethodDisabled`）,返回 [Error](#def_nginx_error)


<a id="definitions"></a>

## 响应对象

- nginx

    nginx 的基本信息：

    - `version`（`string`）

        nginx 的版本号
    
    - `build`（`string`）

        nginx 的内部版本号

    - `address`（`string`）

        接收状态请求的服务器地址

    - `generation`（`integer`）

        配置[重载](../../介绍/控制nginx.md#reconfiguration)次数
    
    - `load_timestamp`（`string`）

        最近一次配置重载时间，ISO 8601 时间格式，精确到毫秒

    - `timestamp`（`string`）

        当前时间，ISO 8601 时间格式，精确到毫秒

    - `pid`（`integer`）

        当前处理状态请求的 worker 进程的 ID

    - `ppid`（`integer`）

        启动当前 [worker 进程](./ngx_http_status_module.md#pid)的 master 进程的 ID

    示例：

    ```json
    {
        "nginx" : {
            "version" : "1.17.3",
            "build" : "nginx-plus-r19",
            "address" : "206.251.255.64",
            "generation" : 6,
            "load_timestamp" : "2019-10-01T11:15:44.467Z",
            "timestamp" : "2019-10-01T09:26:07.305Z",
            "pid" : 32212,
            "ppid" : 32210
        }
    }
    ```

- 进程

    - `respawned`（`integer`）

        异常终止和重新创建的子进程总数

    示例：

    ```json
    {
        "respawned" : 0
    }
    ```

- 连接

    接收、断开、活动和空闲状态连接的数量

    - `accepted`（`integer`）

        接收客户端连接的总数

    - `dropped`（`integer`）

        断开客户端连接的总数

    - `active`（`integer`）

        当前处于活动状态的客户端连接数

    - `idle`（`integer`）

        当前空闲的客户端连接数

    示例：

    ```json
    {
        "accepted" : 4968119,
        "dropped" : 0,
        "active" : 5,
        "idle" : 117
    }
    ```

- SSL

    - `handshakes`（`integer`）

        成功进行 SSL 握手总数

    - `handshakes_failed`（`integer`）

        SSL 握手失败总数

    - `session_reuses`（`integer`）

        SSL 握手期间会话复用总数

    示例：

    ```json
    {
        "handshakes" : 79572,
        "handshakes_failed" : 21025,
        "session_reuses" : 15762
    }
    ```

- slab 分配器共享内存区域

    - `pages`

        空闲和已使用的内存页数量

        - `used`（`integer`）

            当前已使用的内存页数量

        - `free`（`integer`）

            当前空闲内存页数量

    - `slots`

        内存槽（8、16、32、64、128等）状态数据

        一个[内存槽](#def_nginx_slab_zone_slot)对象集合

    示例：

    ```json
    {
        "pages" : {
            "used" : 1143,
            "free" : 2928
        },
        "slots" : {
            "8" : {
            "used" : 0,
            "free" : 0,
            "reqs" : 0,
            "fails" : 0
            },
            "16" : {
            "used" : 0,
            "free" : 0,
            "reqs" : 0,
            "fails" : 0
            },
            "32" : {
            "used" : 0,
            "free" : 0,
            "reqs" : 0,
            "fails" : 0
            },
            "64" : {
            "used" : 1,
            "free" : 63,
            "reqs" : 1,
            "fails" : 0
            },
            "128" : {
            "used" : 0,
            "free" : 0,
            "reqs" : 0,
            "fails" : 0
            },
            "256" : {
            "used" : 18078,
            "free" : 178,
            "reqs" : 1635736,
            "fails" : 0
            }
        }
    }
    ```

- 内存槽

    - `used`（`integer`）

        当前内存槽已使用数量

    - `free`（`integer`）

        当前空闲内存槽数量

    - `reqs`（`integer`）

        尝试申请内存空间的总次数

    - `fails`（`integer`）

        尝试申请内存空间失败的次数

- HTTP 请求

    - `total`（`integer`）

        客户端请求总次数

    - `current`（`integer`）

        当前客户端请求次数

    示例：

    ```json
    {
        "total" : 10624511,
        "current" : 4
    }
    ```

- HTTP 服务器区（Zone）

    - `processing`（`integer`）

        当前正在处于处理中的客户端请求数量

    - `requests`（`integer`）

        接收的客户端请求数量

    - `responses`

        响应客户端总次数，`1xx`、`2xx`、`3xx`、`4xx` 和 `5xx` 类响应状态码和每个具体状态码的响应次数信息

        - `1xx`（`integer`）

            响应 `1xx` 类状态码的次数

        - `2xx`（`integer`）

            响应 `2xx` 类状态码的次数

        - `3xx`（`integer`）

            响应 `3xx` 类状态码的次数

        - `4xx`（`integer`）

            响应 `4xx` 类状态码的次数

        - `5xx`（`integer`）

            响应 `5xx` 类状态码的次数

        - `codes`

            每个具体状态码的响应次数

            - `codeNumber`（`integer`）

                每个具体状态码的响应次数
        
        - `total`（`integer`）

            响应客户端总次数

    - `discarded`（`integer`）

        未发送响应而完成的请求总数

    - `received`（`integer`）

        接收到客户端得总字节数

    - `sent`（`integer`）

        发送给客户端得总字节数

    示例：

    ```json
    {
        "processing" : 1,
        "requests" : 706690,
        "responses" : {
            "1xx" : 0,
            "2xx" : 699482,
            "3xx" : 4522,
            "4xx" : 907,
            "5xx" : 266,
            "codes" : {
            "200" : 699482,
            "301" : 4522,
            "404" : 907,
            "503" : 266
            },
            "total" : 705177
        },
        "discarded" : 1513,
        "received" : 172711587,
        "sent" : 19415530115
    }
    ```

- HTTP Location Zone

    - `requests`（`integer`）

        已接收到的客户端请求数量

    - `responses`

        响应客户端总次数，`1xx`、`2xx`、`3xx`、`4xx` 和 `5xx` 类响应状态码和每个具体状态码的响应次数信息

        - `1xx`（`integer`）

            响应 `1xx` 类状态码的次数

        - `2xx`（`integer`）

            响应 `2xx` 类状态码的次数

        - `3xx`（`integer`）

            响应 `3xx` 类状态码的次数

        - `4xx`（`integer`）

            响应 `4xx` 类状态码的次数

        - `5xx`（`integer`）

            响应 `5xx` 类状态码的次数

        - `codes`

            每个具体状态码的响应次数

            - `codeNumber`（`integer`）

                每个具体状态码的响应次数
        
        - `total`（`integer`）

            响应客户端总次数

    - `discarded`（`integer`）

        未发送响应而完成的请求总数

    - `received`（`integer`）

        接收到客户端得总字节数

    - `sent`（`integer`）

        发送给客户端得总字节数

    示例：

    ```json
    {
        "processing" : 1,
        "requests" : 706690,
        "responses" : {
            "1xx" : 0,
            "2xx" : 699482,
            "3xx" : 4522,
            "4xx" : 907,
            "5xx" : 266,
            "codes" : {
            "200" : 699482,
            "301" : 4522,
            "404" : 907,
            "503" : 266
            },
            "total" : 705177
        },
        "discarded" : 1513,
        "received" : 172711587,
        "sent" : 19415530115
    }
    ```

- HTTP 缓存

    - `size`（`integer`）

        当前缓存大小

    - `max_size`（`integer`）

        配置中指定的最大缓存大小限制

    - `cold`（`boolean`）

        一个布尔值，指定缓存加载器进程是否一直从磁盘加载数据到缓存中

    - `hit`

        - `responses`（`integer`）

            从缓存中读取的[有效](./ngx_http_proxy_module.md#proxy_cache_valid)响应总数

        - `bytes`（`integer`）

            从缓存读取的总字节数

    - `stale`

        - `responses`（`integer`）

            从缓存中读取的过期响应总数（参考 [proxy_cache_use_stale](./ngx_http_proxy_module.md#proxy_cache_use_stale) 和其他 `*_cache_use_stale` 指令）

        - `bytes`（`integer`）

            从缓存读取的总字节数

    - `updating`

        - `responses`（`integer`）

            更新响应时从缓存中读取的过期响应总数（参考 [proxy_cache_use_stale](./ngx_http_proxy_module.md#proxy_cache_use_stale) 和其他 `*_cache_use_stale` 指令）

        - `bytes`（`integer`）

            从缓存读取的总字节数

    - `revalidated`

        - `responses`（`integer`）

            更新响应时从缓存中读取的过期和重新校验响应总数（参考 [proxy_cache_use_stale](./ngx_http_proxy_module.md#proxy_cache_use_stale) 和其他 `*_cache_use_stale` 指令）

        - `bytes`（`integer`）

            从缓存读取的总字节数

    - `miss`

        - `responses`（`integer`）

            缓存中未找到的响应总数

        - `bytes`（`integer`）

            从被代理服务器读取的字节总数

        - `responses_written`（`integer`）

            写入到缓存中的响应总数

        - `bytes_written`（`integer`）

            写入到缓存的字节总数

    - `expired`

        - `responses`（`integer`）

            未从缓存中获取的过期响应总数

        - `bytes`（`integer`）

            从被代理服务器读取的字节总数

        - `responses_written`（`integer`）

            写入到缓存中的响应总数

        - `bytes_written`（`integer`）

            写入到缓存的字节总数

    - `bypass`

        - `responses`（`integer`）

            由于 [proxy_cache_bypass](./ngx_http_proxy_module.md#proxy_cache_bypass) 和其他 `*_cache_bypass` 指令配置而未在缓存中找到的响应总数

        - `bytes`（`integer`）

            从被代理服务器读取的字节总数

        - `responses_written`（`integer`）

            写入到缓存中的响应总数

        - `bytes_written`（`integer`）

            写入到缓存的字节总数

    示例：

    ```json
    {
        "size" : 530915328,
        "max_size" : 536870912,
        "cold" : false,
        "hit" : {
            "responses" : 254032,
            "bytes" : 6685627875
        },
        "stale" : {
            "responses" : 0,
            "bytes" : 0
        },
        "updating" : {
            "responses" : 0,
            "bytes" : 0
        },
        "revalidated" : {
            "responses" : 0,
            "bytes" : 0
        },
        "miss" : {
            "responses" : 1619201,
            "bytes" : 53841943822
        },
        "expired" : {
            "responses" : 45859,
            "bytes" : 1656847080,
            "responses_written" : 44992,
            "bytes_written" : 1641825173
        },
        "bypass" : {
            "responses" : 200187,
            "bytes" : 5510647548,
            "responses_written" : 200173,
            "bytes_written" : 44992
        }
    }
    ```

- HTTP 连接限制

    - `passed`（`integer`）

        未受限也不作为受限的连接总数

    - `rejected`（`integer`）

        拒绝的连接总数

    - `rejected_dry_run`（`integer`）

        在 [dry run](./ngx_http_limit_conn_module.md#limit_conn_dry_run) 模式下视为被拒绝的连接总数

    示例：

    ```json
    {
        "passed" : 15,
        "rejected" : 0,
        "rejected_dry_run" : 2
    }
    ```

- HTTP 请求速率限制

    - `passed`（`integer`）

        未受限也不作为受限的请求总数

    - `delayed`（`integer`）

        延迟请求的总数

    - `rejected`（`integer`）

        拒绝的请求总数

    - `delayed_dry_run`（`integer`）

        在 [dry run](./ngx_http_limit_req_module.md#limit_req_dry_run) 模式下视为延迟的请求总数

    - `rejected_dry_run`（`integer`）

        在 [dry run](./ngx_http_limit_req_module.md#limit_req_dry_run) 模式下视为被拒绝的请求总数

    示例：

    ```json
    {
        "passed" : 15,
        "delayed" : 4,
        "rejected" : 0,
        "delayed_dry_run" : 1,
        "rejected_dry_run" : 2
    }
    ```

- HTTP 上游（Upstream）

    - `peers`

        一个数组

        - `id`（`integer`）

            服务器 ID

        - `server`（`string`）

            服务器[地址](./ngx_http_upstream_module.md#server)

        - `service`（`string`）

            [server](./ngx_http_upstream_module.md#server) 指令的 [service](./ngx_http_upstream_module.md#service) 参数值

        - `name`（`string`）

            服务器在 [server](./ngx_http_upstream_module.md#server)指令中指定的 name

        - `backup`（`boolean`）

            布尔值，代表服务器是否为[备用](./ngx_http_upstream_module.md#backup)服务器

        - `weight`（`integer`）

            服务器[权重](./ngx_http_upstream_module.md#weight)

        - `state`（`string`）

            当前状态，`up`、`draining`、`down`、`unavail`、`checking` 或 `unhealthy` 中的其一值

        - `active`（`integer`）

            当前活动连接数

        - `max_conns`（`integer`）

            服务器的最大连接限制（[max_conn](./ngx_http_upstream_module.md#max_conns)）

        - `requests`（`integer`）

            客户端请求转发到此服务器的总数

        - `responses`

            - `1xx`（`integer`）

                状态码为 `1xx` 的响应数量

            - `2xx`（`integer`）

                状态码为 `2xx` 的响应数量

            - `3xx`（`integer`）

                状态码为 `3xx` 的响应数量

            - `4xx`（`integer`）

                状态码为 `4xx` 的响应数量

            - `5xx`（`integer`）

                状态码为 `5xx` 的响应数量

            - `codes`

                每个具体状态码的响应数量

                - `codeNumber`（`integer`）

                    具体状态码的响应数量

            - `total`（`integer`）

                从此服务器获取的响应数量

        - `sent`（`integer`）

            发到此服务器的字节总数

        - `received`（`integer`）

            接收到此服务器的字节总数

        - `fails`（`integer`）

            尝试与此服务器通信失败的次数

        - `unavail`（`integer`）

            由于失败重试达到 [max_fails](./ngx_http_upstream_module.md#max_fails) 阈值配置，对于客户端请求，此服务器为不可用状态的次数

        - `health_checks`

            - `checks`（`integer`）

                [健康检查](./ngx_http_upstream_hc_module.md#health_check)发出的请求总数

            - `fails`（`integer`）

                健康检查失败的次数

            - `unhealthy`（`integer`）

                健康检查中，服务器为非健康状态（`unhealthy` 状态）的次数
                
            - `last_passed`（`boolean`）

                布尔值，表示最后一次健康检查是否成功并且[测试](./ngx_http_upstream_hc_module.md#match)通过

        - `downtime`（`integer`）

            服务器处于 `unavail`、`checking` 和 `unhealthy` 状态的时长

        - `downstart`（`string`）

            服务器处于 `unavail`、`checking` 或`unhealthy` 状态时的时间，ISO 8601 时间格式，精确到毫秒

        - `selected`（`string`）

            此服务器最近一次被挑选处理请求的时间，ISO 8601 时间格式，精确到毫秒

        - `header_time`（`integer`）

            从此服务器获取[响应头](./ngx_http_upstream_module.md#var_upstream_header_time)的平均时长

        - `response_time`（`integer`）

            从此服务器获取[响应](./ngx_http_upstream_module.md#var_upstream_response_time)的平均时长

    - `keepalive`（`integer`）

        当前 [keepalive](./ngx_http_upstream_module.md#keepalive) 连接的数量

    - `zombies`（`integer`）

        当前已经从组中移除但仍在处理请求的服务器数量

    - `zone`（`string`）

        用于存储组配置和运行时状态的共享内存[区域](./ngx_http_upstream_module.md#zone)名称

    - `queue`

        请求[队列](./ngx_http_upstream_module.md#queue)，包含一下数据：

        - `size`（`integer`）

            存在队列中的请求数量

        - `max_size`（`integer`）

            队列存储请求的最大数量

        - `overflows`（`integer`）

            由于队列溢出而被拒绝的请求总数

    示例：

    ```json
    {
        "upstream_backend" : {
            "peers" : [
            {
                "id" : 0,
                "server" : "10.0.0.1:8088",
                "name" : "10.0.0.1:8088",
                "backup" : false,
                "weight" : 5,
                "state" : "up",
                "active" : 0,
                "max_conns" : 20,
                "requests" : 667231,
                "header_time" : 20,
                "response_time" : 36,
                "responses" : {
                "1xx" : 0,
                "2xx" : 666310,
                "3xx" : 0,
                "4xx" : 915,
                "5xx" : 6,
                "codes" : {
                    "200" : 666310,
                    "404" : 915,
                    "503" : 6
                },
                "total" : 667231
                },
                "sent" : 251946292,
                "received" : 19222475454,
                "fails" : 0,
                "unavail" : 0,
                "health_checks" : {
                "checks" : 26214,
                "fails" : 0,
                "unhealthy" : 0,
                "last_passed" : true
                },
                "downtime" : 0,
                "downstart" : "2019-10-01T11:09:21.602Z",
                "selected" : "2019-10-01T15:01:25.000Z"
            },
            {
                "id" : 1,
                "server" : "10.0.0.1:8089",
                "name" : "10.0.0.1:8089",
                "backup" : true,
                "weight" : 1,
                "state" : "unhealthy",
                "active" : 0,
                "max_conns" : 20,
                "requests" : 0,
                "responses" : {
                "1xx" : 0,
                "2xx" : 0,
                "3xx" : 0,
                "4xx" : 0,
                "5xx" : 0,
                "codes" : {
                },
                "total" : 0
                },
                "sent" : 0,
                "received" : 0,
                "fails" : 0,
                "unavail" : 0,
                "health_checks" : {
                "checks" : 26284,
                "fails" : 26284,
                "unhealthy" : 1,
                "last_passed" : false
                },
                "downtime" : 262925617,
                "downstart" : "2019-10-01T11:09:21.602Z",
                "selected" : "2019-10-01T15:01:25.000Z"
            }
            ],
            "keepalive" : 0,
            "zombies" : 0,
            "zone" : "upstream_backend"
        }
    }
    ```

- HTTP 上游服务器

    HTTP 上游[服务器](./ngx_http_upstream_module.md#server)动态可配置参数

    - `id`（`integer`）

        上游服务器 ID，自动分配，不能更改

    - `server`（`string`）

        与 HTTP 上游服务器的 [address](./ngx_http_upstream_module.md#address)  参数值一致。当添加一个服务器时，可以将它指定为一个域名。这种情况下，域名对应的 IP 地址的变更被监控并自动应用到上游配置而无需重启 nginx，这要求 `http` 块中配置 [resolver](./ngx_http_core_module.md#resolver) 指令，可参考 HTTP 上游服务器的 [resolver](./ngx_http_core_module.md#resolver)  参数。

    - `service`（`string`）

        与 HTTP 上游服务器的 [service](./ngx_http_upstream_module.md#service) 参数值一致，此参数不能被修改

    - `weight`（`integer`）

        与 HTTP 上游服务器的 [weight](./ngx_http_upstream_module.md#weight) 参数值一致

    - `max_conns`（`integer`）

        与 HTTP 上游服务器的 [max_conns](./ngx_http_upstream_module.md#max_conns) 参数值一致

    - `max_fails`（`integer`）

        与 HTTP 上游服务器的 [max_fails](./ngx_http_upstream_module.md#max_fails) 参数值一致

    - `fail_timeout`（`integer`）

        与 HTTP 上游服务器的 [fail_timeout](./ngx_http_upstream_module.md#fail_timeout) 参数值一致

    - `slow_start`（`string`）

        与 HTTP 上游服务器的 [slow_start](./ngx_http_upstream_module.md#slow_start) 参数值一致

    - `route`（`string`）

        与 HTTP 上游服务器的 [route](./ngx_http_upstream_module.md#route) 参数值一致

    - `backup`（`boolean`）

        与 HTTP 上游服务器的 [backup](./ngx_http_upstream_module.md#backup) 参数值一致

    - `down`（`boolean`）

        与 HTTP 上游服务器的 [down](./ngx_http_upstream_module.md#down) 参数值一致

    - `drain`（`boolean`）

        与 HTTP 上游服务器的 [drain](./ngx_http_upstream_module.md#drain) 参数值一致

    - `parent`（`string`）

        解析服务器的父服务器 ID，自动分配，不能修改

    - `host`（`string`）

        解析服务器的主机名，自动分配，不能修改

    示例：

    ```json
    {
        "id" : 1,
        "server" : "10.0.0.1:8089",
        "weight" : 4,
        "max_conns" : 0,
        "max_fails" : 0,
        "fail_timeout" : "10s",
        "slow_start" : "10s",
        "route" : "",
        "backup" : true,
        "down" : true
    }
    ```

- HTTP 键值共享内存空间

    当使用 POST 或者 PATCH 方法时，HTTP 键值共享内存空间的内容

    示例：

    ```json
    {
        "key1" : "value1",
        "key2" : "value2",
        "key3" : {
            "value" : "value3",
            "expire" : 30000
        }
    }
    ```

- 流服务器区（Stream Server Zone）


    - `processing`（`integer`）

        当前正在处于处理中的客户端请求数量

    - `connections`（`integer`）

        接收的客户端请求数量

    - `sessions`

        会话完成总数，响应`2xx`、`4xx` 和 `5xx` 类状态码的完成会话数量

        - `2xx`（`integer`）

            响应 `2xx` 类[状态码](../stream/ngx_stream_core_module.md#var_status)的次数

        - `4xx`（`integer`）

            响应 `4xx` 类[状态码]../stream/ngx_stream_core_module.md#var_status)的次数

        - `5xx`（`integer`）

            响应 `5xx` 类[状态码]../stream/ngx_stream_core_module.md#var_status)的次数

        - `total`（`integer`）

            完成客户端会话总次数

    - `discarded`（`integer`）

        未创建会话而完成连接总数

    - `received`（`integer`）

        接收到客户端得总字节数

    - `sent`（`integer`）

        发送给客户端得总字节数

    示例：

    ```json
    {
        "dns" : {
                "processing" : 1,
                "connections" : 155569,
                "sessions" : {
                "2xx" : 155564,
                "4xx" : 0,
                "5xx" : 0,
                "total" : 155569
            },
            "discarded" : 0,
            "received" : 4200363,
            "sent" : 20489184
        }
    }
    ```

- 流连接限制

    - `passed`（`integer`）

        未受限也不作为受限的连接总数

    - `rejected`（`integer`）

        拒绝的连接总数

    - `rejected_dry_run`（`integer`）

        在 [dry run](../stream/ngx_stream_limit_conn_module.md#limit_conn_dry_run) 模式下视为被拒绝的连接总数

    示例：

    ```json
    {
        "passed" : 15,
        "rejected" : 0,
        "rejected_dry_run" : 2
    }
    ```

- 流上游（Upstream）

    - `peers`

        数组类型

        - `id`（`integer`）

            服务器 ID

        - `server`（`string`）

            服务器[地址](../stream/ngx_stream_upstream_module.md#server)

        - `service`（`string`）

            [server](../stream/ngx_stream_upstream_module.md#service) 指令的 [service](../stream/ngx_stream_upstream_module.md#server) 参数值

        - `name`（`string`）

            服务器在 [server](../stream/ngx_stream_upstream_module.md#server)指令中指定的 name

        - `backup`（`boolean`）

            布尔值，代表服务器是否为[备用](../stream/ngx_stream_upstream_module.md#backup)服务器

        - `weight`（`integer`）

            服务器[权重](..//stream/ngx_stream_upstream_module.md#weight)

        - `state`（`string`）

            当前状态，`up`、`draining`、`down`、`unavail`、`checking` 或 `unhealthy` 中的其一值

        - `active`（`integer`）

            当前连接数

        - `max_conns`（`integer`）

            服务器的最大连接限制（[max_conn](../stream/ngx_stream_upstream_module.md#weight）

        - `connections`（`integer`）

            客户端连接转发到此服务器的总数

        - `connect_time`（`integer`）

            连接到上游服务器平均耗时

        - `first_byte_time`（`integer`）

            接收数据的第一个字节平均时间

        - `response_time`（`integer`）

            返回数据的最后一个字节平均时间

        - `sent`（`integer`）

            发到此服务器的字节总数

        - `received`（`integer`）

            接收到此服务器的字节总数

        - `fails`（`integer`）

            尝试与此服务器通信失败的次数

        - `unavail`（`integer`）

            由于失败重试达到 [max_fails](../stream/ngx_stream_upstream_module.md#max_fails) 阈值配置，对于客户端连接，此服务器为不可用状态的次数

        - `health_checks`

            - `checks`（`integer`）

                [健康检查](../stream/ngx_stream_upstream_module.md#max_fails)发出的请求总数

            - `fails`（`integer`）

                健康检查失败的次数

            - `unhealthy`（`integer`）

                健康检查中，服务器为非健康状态（`unhealthy` 状态）的次数
                
            - `last_passed`（`boolean`）

                布尔值，表示最后一次健康检查是否成功并且[测试](../stream/ngx_stream_upstream_hc_module.md#match)通过

        - `downtime`（`integer`）

            服务器处于 `unavail`、`checking` 和 `unhealthy` 状态的时长

        - `downstart`（`string`）

            服务器处于 `unavail`、`checking` 或`unhealthy` 状态时的时间，ISO 8601 时间格式，精确到毫秒

        - `selected`（`string`）

            此服务器最近一次被挑选处理请求的时间，ISO 8601 时间格式，精确到毫秒

    - `zombies`（`integer`）

        当前已经从组中移除但仍在处理活动连接的服务器数量

    - `zone`（`string`）

        用于存储组配置和运行时状态的共享内存[区域](../stream/ngx_stream_upstream_module.md#zone)名称

    示例：

    ```json
    {
        "dns" : {
            "peers" : [
            {
                "id" : 0,
                "server" : "10.0.0.1:12347",
                "name" : "10.0.0.1:12347",
                "backup" : false,
                "weight" : 5,
                "state" : "up",
                "active" : 0,
                "max_conns" : 50,
                "connections" : 667231,
                "sent" : 251946292,
                "received" : 19222475454,
                "fails" : 0,
                "unavail" : 0,
                "health_checks" : {
                "checks" : 26214,
                "fails" : 0,
                "unhealthy" : 0,
                "last_passed" : true
                },
                "downtime" : 0,
                "downstart" : "2019-10-01T11:09:21.602Z",
                "selected" : "2019-10-01T15:01:25.000Z"
            },
            {
                "id" : 1,
                "server" : "10.0.0.1:12348",
                "name" : "10.0.0.1:12348",
                "backup" : true,
                "weight" : 1,
                "state" : "unhealthy",
                "active" : 0,
                "max_conns" : 50,
                "connections" : 0,
                "sent" : 0,
                "received" : 0,
                "fails" : 0,
                "unavail" : 0,
                "health_checks" : {
                "checks" : 26284,
                "fails" : 26284,
                "unhealthy" : 1,
                "last_passed" : false
                },
                "downtime" : 262925617,
                "downstart" : "2019-10-01T11:09:21.602Z",
                "selected" : "2019-10-01T15:01:25.000Z"
            }
            ],
            "zombies" : 0,
            "zone" : "dns"
        }
    }
    ```

- HTTP 上游服务器

    流上游[服务器](../stream/ngx_stream_upstream_module.md#server)动态可配置参数

    - `id`（`integer`）

        上游服务器 ID，自动分配，不能更改

    - `server`（`string`）

        与流上游服务器的 [address](../stream/ngx_stream_upstream_module.html#server)  参数值一致。当添加一个服务器时，可以将它指定为一个域名。这种情况下，域名对应的 IP 地址的变更被监控并自动应用到上游配置而无需重启 nginx，这要求 `stream` 块中配置 [resolver](../stream/ngx_stream_core_module.md#resolver) 指令，可参考流上游服务器的 [resolver](../stream/ngx_stream_core_module.md#resolver) 参数。

    - `service`（`string`）

        与流上游服务器的 [service](../stream/ngx_stream_upstream_module.md#service) 参数值一致，此参数不能被修改

    - `weight`（`integer`）

        与流上游服务器的 [weight](../stream/ngx_stream_upstream_module.md#weight) 参数值一致

    - `max_conns`（`integer`）

        与流上游服务器的 [max_conns](../stream/ngx_stream_upstream_module.md#max_conns) 参数值一致

    - `max_fails`（`integer`）

        与流上游服务器的 [max_fails](../stream/ngx_stream_upstream_module.md#max_fails) 参数值一致

    - `fail_timeout`（`integer`）

        与流上游服务器的 [fail_timeout](../stream/ngx_stream_upstream_module.md#fail_timeout) 参数值一致

    - `slow_start`（`string`）

        与流上游服务器的 [slow_start](../stream/ngx_stream_upstream_module.md#slow_start) 参数值一致

    - `backup`（`boolean`）

        与流上游服务器的 [backup](../stream/ngx_stream_upstream_module.md#backup) 参数值一致

    - `down`（`boolean`）

        与流上游服务器的 [down](../stream/ngx_stream_upstream_module.md#down) 参数值一致

    - `parent`（`string`）

        解析服务器的父服务器 ID，自动分配，不能修改

    - `host`（`string`）

        解析服务器的主机名，自动分配，不能修改

    示例：

    ```json
    {
        "id" : 0,
        "server" : "10.0.0.1:12348",
        "weight" : 1,
        "max_conns" : 0,
        "max_fails" : 1,
        "fail_timeout" : "10s",
        "slow_start" : 0,
        "backup" : false,
        "down" : false
    }
    ```

- 流键值共享内存空间

    当使用 GET 方法时，流键值共享内存空间的内容

    示例：

    ```json
    {
        "key1" : "value1",
        "key2" : "value2",
        "key3" : "value3"
    }
    ```

    当使用 POST 或 PATCH 方法时，流键值共享内存空间的内容

    示例：

    ```json
    {
        "key1" : "value1",
        "key2" : "value2",
        "key3" : {
            "value" : "value3",
            "expire" : 30000
        }
    }
    ```

- 流区域同步节点（Stream Zone Sync Node）

    - `zones`

        同步每一个共享内存区域的信息

        一个 [Sync Zone](#def_nginx_stream_zone_sync_zone) 对象集合

    - `status`

        集群中每个节点的同步状态

        - `bytes_in`（`integer`）

            本节点接收到的字节数

        - `msgs_in`（`integer`）

            本节点接收到的消息数量

        - `msgs_out`（`integer`）

            本节点发送的消息数量

        - `bytes_out`（`integer`）

            本节点发送的字节数量

        - `nodes_online`（`integer`）

            本节点已连接的通道数量

    示例：

    ```json
    {
        "zones" : {
            "zone1" : {
            "records_pending" : 2061,
            "records_total" : 260575
            },
            "zone2" : {
            "records_pending" : 0,
            "records_total" : 14749
            }
        },
        "status" : {
            "bytes_in" : 1364923761,
            "msgs_in" : 337236,
            "msgs_out" : 346717,
            "bytes_out" : 1402765472,
            "nodes_online" : 15
        }
    }
    ```

- 同步区域

    同步一个共享内存区域的状态

    - `records_pending`（`integer`）

        需要发送到集群的记录数

    - `records_total`（`integer`）

        存储在共享内存区域中的记录总数

- Resolver Zone

    每个 [resolver zone](ngx_http_core_module.md#resolver_status_zone) 的静态 DNS 请求和响应统计信息

    - `requests`

        - `name`（`integer`）

            解析名称为地址的请求数

        - `srv`（`integer`）

            解析 SRV 记录的请求数

        - `addr`（`integer`）

            解析地址为名字的请求数

    - `responses`

        - `noerror`（`integer`）

            成功响应数

        - `formerr`（`integer`）

            FORMERR（`Format error`）响应数

        - `servfail`（`integer`）

            SERVFAIL（`Server failure`）响应数

        - `nxdomain`（`integer`）

            NXDOMAIN（`Host not found`）响应数

        - `notimp`（`integer`）

            NOTIMP（`Unimplemented`）响应数

        - `refused`（`integer`）

            REFUSED（`Operation refused`）响应数

        - `timedout`（`integer`）

            超时响应数

        - `unknown`（`integer`）

            以未知错误状态完成的请求数量

    示例：

    ```json
    {
        "resolver_zone1" : {
            "requests" : {
            "name" : 25460,
            "srv" : 130,
            "addr" : 2580
            },
            "responses" : {
            "noerror" : 26499,
            "formerr" : 0,
            "servfail" : 3,
            "nxdomain" : 0,
            "notimp" : 0,
            "refused" : 0,
            "timedout" : 243,
            "unknown" : 478
            }
        }
    }
    ```

- 错误

    nginx 错误对象

    - `error`

        - `status`（`integer`）

            HTTP 错误码

        - `text`（`string`）

            错误描述文本

        - `code`（`string`）

            nginx 内部错误码

    - `request_id`（`string`）

        请求 ID，值等于 [$request_id](ngx_http_core_module.md#var_request_id) 变量

    - `href`（`string`）

        参考文档链接

## 原文档

[http://nginx.org/en/docs/http/ngx_http_api_module.html](http://nginx.org/en/docs/http/ngx_http_api_module.html)