# nginx 如何处理 TCP/UDP 会话

来自客户端的 TCP/UDP 会话以阶段的形式被逐步处理：

|阶 段&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|描 述|
|:----|:----|
| Post-accept | 接收客户端请求后的第一个阶段。[ngx_stream_realip_module](http://nginx.org/en/docs/stream/ngx_stream_realip_module.html) 模块在此阶段被调用。|
| Pre-access | 初步检查访问，[ngx_stream_limit_conn_module](http://nginx.org/en/docs/stream/ngx_stream_limit_conn_module.html) 模块在此阶段被调用。 |
| Access | 实际处理之前的客户端访问限制，ngx_stream_access_module 模块在此阶段被调用。 |
| SSL | TLS/SSL 终止，ngx_stream_ssl_module 模块在此阶段被调用。 |
| Preread | 将数据的初始字节读入 [预读缓冲区](http://nginx.org/en/docs/stream/ngx_stream_core_module.html#preread_buffer_size) 中，以允许如 [ngx_stream_ssl_preread_module](http://nginx.org/en/docs/stream/ngx_stream_ssl_preread_module.html) 之类的模块在处理前分析数据。 |
| Content | 实际处理数据的强制阶段，通常 [代理](http://nginx.org/en/docs/stream/ngx_stream_proxy_module.html) 到 [upstream](http://nginx.org/en/docs/stream/ngx_stream_upstream_module.html) 服务器，或者返回一个特定的值给客户端 |
| Log | 此为最后阶段，客户端会话处理结果将被记录， [ngx_stream_log_module module](http://nginx.org/en/docs/stream/ngx_stream_log_module.html) 模块在此阶段被调用。 |

## 原文档
[http://nginx.org/en/docs/stream/stream_processing.html](http://nginx.org/en/docs/stream/stream_processing.html)
