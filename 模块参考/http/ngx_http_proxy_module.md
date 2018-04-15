# ngx_http_perl_module

- [指令](#directives)
    - [proxy_bind](#proxy_bind)
    - [proxy_buffer_size](#proxy_buffer_size)
    - [proxy_buffering](#proxy_buffering)
    - [proxy_buffers](#proxy_buffers)
    - [proxy_busy_buffers_size](#proxy_busy_buffers_size)
    - [proxy_cache](#proxy_cache)
    - [proxy_cache_background_update](#proxy_cache_background_update)
    - [proxy_cache_bypass](#proxy_cache_bypass)
    - [proxy_cache_convert_head](#proxy_cache_convert_head)
    - [proxy_cache_key](#proxy_cache_key)
    - [proxy_cache_lock](#proxy_cache_lock)
    - [proxy_cache_lock_age](#proxy_cache_lock_age)
    - [proxy_cache_lock_timeout](#proxy_cache_lock_timeout)
    - [proxy_cache_max_range_offset](#proxy_cache_max_range_offset)
    - [proxy_cache_methods](#proxy_cache_methods)
    - [proxy_cache_min_uses](#proxy_cache_min_uses)
    - [proxy_cache_path](#proxy_cache_path)
    - [proxy_cache_purge](#proxy_cache_purge)
    - [proxy_cache_revalidate](#proxy_cache_revalidate)
    - [proxy_cache_use_stale](#proxy_cache_use_stale)
    - [proxy_cache_valid](#proxy_cache_valid)
    - [proxy_connect_timeout](#proxy_connect_timeout)
    - [proxy_cookie_domain](#proxy_cookie_domain)
    - [proxy_cookie_path](#proxy_cookie_path)
    - [proxy_force_ranges](#proxy_force_ranges)
    - [proxy_headers_hash_bucket_size](#proxy_headers_hash_bucket_size)
    - [proxy_headers_hash_max_size](#proxy_headers_hash_max_size)
    - [proxy_hide_header](#proxy_hide_header)
    - [proxy_http_version](#proxy_http_version)
    - [proxy_ignore_client_abort](#proxy_ignore_client_abort)
    - [proxy_ignore_headers](#proxy_ignore_headers)
    - [proxy_intercept_errors](#proxy_intercept_errors)
    - [proxy_limit_rate](#proxy_limit_rate)
    - [proxy_max_temp_file_size](#proxy_max_temp_file_size)
    - [proxy_method](#proxy_method)
    - [proxy_next_upstream](#proxy_next_upstream)
    - [proxy_next_upstream_timeout](#proxy_next_upstream_timeout)
    - [proxy_next_upstream_tries](#proxy_next_upstream_tries)
    - [proxy_no_cache](#proxy_no_cache)
    - [proxy_pass](#proxy_pass)
    - [proxy_pass_header](#proxy_pass_header)
    - [proxy_pass_request_body](#proxy_pass_request_body)
    - [proxy_pass_request_headers](#proxy_pass_request_headers)
    - [proxy_read_timeout](#proxy_read_timeout)
    - [proxy_redirect](#proxy_redirect)
    - [proxy_request_buffering](#proxy_request_buffering)
    - [proxy_send_lowat](#proxy_send_lowat)
    - [proxy_send_timeout](#proxy_send_timeout)
    - [proxy_set_body](#proxy_set_body)
    - [proxy_set_header](#proxy_set_header)
    - [proxy_ssl_certificate](#proxy_ssl_certificate)
    - [proxy_ssl_certificate_key](#proxy_ssl_certificate_key)
    - [proxy_ssl_ciphers](#proxy_ssl_ciphers)
    - [proxy_ssl_crl](#proxy_ssl_crl)
    - [proxy_ssl_name](#proxy_ssl_name)
    - [proxy_ssl_password_file](#proxy_ssl_password_file)
    - [proxy_ssl_protocols](#proxy_ssl_protocols)
    - [proxy_ssl_server_name](#proxy_ssl_server_name)
    - [proxy_ssl_session_reuse](#proxy_ssl_session_reuse)
    - [proxy_ssl_trusted_certificate](#proxy_ssl_trusted_certificate)
    - [proxy_ssl_verify](#proxy_ssl_verify)
    - [proxy_ssl_verify_depth](#proxy_ssl_verify_depth)
    - [proxy_store](#proxy_store)
    - [proxy_store_access](#proxy_store_access)
    - [proxy_temp_file_write_size](#proxy_temp_file_write_size)
    - [proxy_temp_path](#proxy_temp_path)
- [内嵌变量](#embedded_variables)

`ngx_http_proxy_module` 模块允许将请求传递给另一台服务器。

<a id="example_configuration"></a>

## 示例配置

```nginx
location / {
    proxy_pass       http://localhost:8000;
    proxy_set_header Host      $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

**待续……**

## 原文档
[http://nginx.org/en/docs/http/ngx_http_proxy_module.html](http://nginx.org/en/docs/http/ngx_http_proxy_module.html)