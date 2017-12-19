# ngx_http_fastcgi_module

- [指令](#directives)
    - [fastcgi_bind](#fastcgi_bind)
    - [fastcgi_buffer_size](#fastcgi_buffer_size)
    - [fastcgi_buffering](#fastcgi_buffering)
    - [fastcgi_buffers](#fastcgi_buffers)
    - [fastcgi_busy_buffers_size](#fastcgi_busy_buffers_size)
    - [fastcgi_cache](#fastcgi_cache)
    - [fastcgi_cache_background_update](#fastcgi_cache_background_update)
    - [fastcgi_cache_bypass](#fastcgi_cache_bypass)
    - [fastcgi_cache_key](#fastcgi_cache_key)
    - [fastcgi_cache_lock](#fastcgi_cache_lock)
    - [fastcgi_cache_lock_age](#fastcgi_cache_lock_age)
    - [fastcgi_cache_lock_timeout](#fastcgi_cache_lock_timeout)
    - [fastcgi_cache_max_range_offset](#fastcgi_cache_max_range_offset)
    - [fastcgi_cache_methods](#fastcgi_cache_methods)
    - [fastcgi_cache_min_uses](#fastcgi_cache_min_uses)
    - [fastcgi_cache_path](#fastcgi_cache_path)
    - [fastcgi_cache_purge](#fastcgi_cache_purge)
    - [fastcgi_cache_revalidate](#fastcgi_cache_revalidate)
    - [fastcgi_cache_use_stale](#fastcgi_cache_use_stale)
    - [fastcgi_cache_valid](#fastcgi_cache_valid)
    - [fastcgi_catch_stderr](#fastcgi_catch_stderr)
    - [fastcgi_connect_timeout](#fastcgi_connect_timeout)
    - [fastcgi_force_ranges](#fastcgi_force_ranges)
    - [fastcgi_hide_header](#fastcgi_hide_header)
    - [fastcgi_ignore_client_abort](#fastcgi_ignore_client_abort)
    - [fastcgi_ignore_headers](#fastcgi_ignore_headers)
    - [fastcgi_index](#fastcgi_index)
    - [fastcgi_intercept_errors](#fastcgi_intercept_errors)
    - [fastcgi_keep_conn](#fastcgi_keep_conn)
    - [fastcgi_limit_rate](#fastcgi_limit_rate)
    - [fastcgi_max_temp_file_size](#fastcgi_max_temp_file_size)
    - [fastcgi_next_upstream](#fastcgi_next_upstream)
    - [fastcgi_next_upstream_timeout](#fastcgi_next_upstream_timeout)
    - [fastcgi_next_upstream_tries](#fastcgi_next_upstream_tries)
    - [fastcgi_no_cache](#fastcgi_no_cache)
    - [fastcgi_param](#fastcgi_param)
    - [fastcgi_pass](#fastcgi_pass)
    - [fastcgi_pass_header](#fastcgi_pass_header)
    - [fastcgi_pass_request_body](#fastcgi_pass_request_body)
    - [fastcgi_pass_request_headers](#fastcgi_pass_request_headers)
    - [fastcgi_read_timeout](#fastcgi_read_timeout)
    - [fastcgi_request_buffering](#fastcgi_request_buffering)
    - [fastcgi_send_lowat](#fastcgi_send_lowat)
    - [fastcgi_send_timeout](#fastcgi_send_timeout)
    - [fastcgi_split_path_info](#fastcgi_split_path_info)
    - [fastcgi_store](#fastcgi_store)
    - [fastcgi_store_access](#fastcgi_store_access)
    - [fastcgi_temp_file_write_size](#fastcgi_temp_file_write_size)
    - [fastcgi_temp_path](#fastcgi_temp_path)
- [传参到 FastCGI 服务器](#parameters)
- [内嵌变量](#embedded_variables)

`ngx_http_fastcgi_module` 模块允许将请求传递给 FastCGI 服务器。

<a id="example_configuration"></a>

## 示例配置

```nginx
location / {
    fastcgi_pass  localhost:9000;
    fastcgi_index index.php;

    fastcgi_param SCRIPT_FILENAME /home/www/scripts/php$fastcgi_script_name;
    fastcgi_param QUERY_STRING    $query_string;
    fastcgi_param REQUEST_METHOD  $request_method;
    fastcgi_param CONTENT_TYPE    $content_type;
    fastcgi_param CONTENT_LENGTH  $content_length;
}
```

<a id="directives"></a>

## 指令

### fastcgi_bind

|\-|说明|
|------:|------|
|**语法**|**fastcgi_bind** `address [transparent]` \| `off`;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 0.8.22 版本中出现|

通过一个可选的端口（1.11.2）从指定的本地 IP 地址发出到 FastCGI 服务器的传出连接。参数值可以包含变量（1.3.12）。特殊值 `off`（1.3.12）取消从上层配置级别继承到的 `fastcgi_bind` 指令作用，这允许系统自动分配本地 IP 地址和端口。

`transparent` 参数（1.11.0）允许从非本地 IP 地址（例如来自客户端的真实 IP 地址）的到 FastCGI 服务器的传出连接：

```nginx
fastcgi_bind $remote_addr transparent;
```

为了使这个参数起作用，有必要以超级用户权限运行 nginx 工作进程，并配置内核路由来拦截来自 FastCGI 服务器的网络流量。

**待续……**