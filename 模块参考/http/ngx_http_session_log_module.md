# ngx_http_session_log_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [session_log](#session_log)
    - [session_log_format](#session_log_format)
    - [session_log_zone](#session_log_zone)
- [内嵌变量](#embedded_variables)

`ngx_http_session_log_module` 模块启用会话日志（多个 HTTP 请求的聚合），而不是单个 HTTP 请求。

> 该模块作为我们[商业订阅](http://nginx.com/products/?_ga=2.22237371.1497417506.1556973333-896013220.1554004850)的一部分提供。

<a id="example_configuration"></a>

## 示例配置

以下配置根据请求客户端的地址和 **User-Agent** 请求头字段设置会话日志并将请求映射到会话：

```nginx
session_log_zone /path/to/log format=combined
                    zone=one:1m timeout=30s
                    md5=$binary_remote_addr$http_user_agent;

location /media/ {
    session_log one;
}
```


<a id="directives"></a>

## 指令

### session_log

|\-|说明|
|:------|:------|
|**语法**|**session_log** `name` &#124; `off`;|
|**默认**|session_log off;|
|**上下文**|http、server、location|

允许使用指定的会话日志。特殊值 `off` 取消从先前配置级别继承的所有 `session_log` 指令。

### session_log_format

|\-|说明|
|:------|:------|
|**语法**|**session_log_format** `name string ...`;|
|**默认**|session_log_format combined "...";|
|**上下文**|http|

指定日志的输出格式。`$body_bytes_sent` 变量的值聚合在会话的所有请求中。可用于记录的所有其他变量的值对应于会话中的第一个请求。

### session_log_zone

|\-|说明|
|:------|:------|
|**语法**|**session_log_zone** `path zone=name:size [format=format] [timeout=time] [id=id] [md5=md5]`;|
|**默认**|——|
|**上下文**|http|

设置日志文件的路径，并配置用于存储当前活动会话的共享内存区域。

只要会话中的最后一个请求经过的时间不超过指定的 `timeout`（默认为 30 秒），会话就被视为活动状态。会话不再处于活动状态后将被写入日志。

`id` 参数标识请求映射到的会话。`id` 参数设置为 MD5 哈希的十六进制形式（例如，使用变量从 cookie 中获取）。如果未指定此参数或不是有效的 MD5 哈希，则 nginx 将根据 `md5` 参数的值计算 MD5 哈希，并使用此哈希创建新会话。`id` 和 `md5` 参数都可以包含变量。

`format` 参数设置 [session_log_format](#session_log_format) 指令配置的自定义会话日志格式。如果未指定 `format`，则使用预定义的 `combined`格式。

<a id="embedded_variables"></a>

## 内嵌变量

`ngx_http_session_log_module` 模块支持两个内嵌变量：

- `$session_log_id`

    当前会话 ID

- `$session_log_binary_id`

    二进制形式的当前会话 ID（16字节）。

## 原文档

- [http://nginx.org/en/docs/http/ngx_http_session_log_module.html](http://nginx.org/en/docs/http/ngx_http_session_log_module.html)
