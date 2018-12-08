# ngx_http_log_module

- [指令](#directives)
    - [access_log](#access_log)
    - [log_format](#log_format)
    - [open_log_file_cache](#open_log_file_cache)

`ngx_http_log_module` 模块可让请求日志以指定的格式写入。

请求会在处理结束的 location 的上下文中记录。如果在请求处理期间发生[内部重定向](ngx_http_core_module.md#internal)，可能会造成与原始 location 不同。

<a id="example_configuration"></a>

## 示例配置

```nginx
log_format compression '$remote_addr - $remote_user [$time_local] '
                       '"$request" $status $bytes_sent '
                       '"$http_referer" "$http_user_agent" "$gzip_ratio"';

access_log /spool/logs/nginx-access.log compression buffer=32k;
```

<a id="directives"></a>

## 指令

### access_log

|\-|说明|
|------:|------|
|**语法**|**access_log** `path [format [buffer=size] [gzip[=level]] [flush=time] [if=condition]]`; <br /> **access_log** `off`;|
|**默认**|access_log logs/access.log combined;|
|**上下文**|http、server、location、location 中的 if、limit_except|

设置缓冲日志写入的路径、格式和配置。可以在同一级别指定多个日志。可以通过在第一个参数中指定 `syslog:` 前缀配置将日志记录到 [syslog](../../介绍/记录日志到syslog.md)。特殊值 `off` 取消当前级别的所有 `access_log` 指令。如果未指定格式，则使用预定义的 `combined` 格式。

如果使用缓冲区或 `gzip` 参数（1.3.10、1.2.7），则日志写入将被缓冲。

> 缓冲区大小不得超过原子写入磁盘文件的大小。对于 FreeBSD，该大小是无限的。

启用缓冲时，以下情况数据将被写入文件中：

- 如果下一个日志行不适合放入缓冲区
- 如果缓冲数据比 `flush参数`指定的更旧（1.3.10,1.2.7）
- 当 worker 进程[重新打开](../../介绍/控制nginx.md)日志文件或正在关闭时

如果使用 `gzip` 参数，那么在写入文件之前，缓冲的数据将被压缩。压缩级别可以设置在 1（最快、较少压缩）和 9（最慢、最佳压缩）之间。默认情况下，缓冲区大小等于 64K 字节，压缩级别设置为 1。由于数据是以原子块的形式压缩的，因此日志文件可以随时解压缩或由 `zcat` 读取。

示例：

```nginx
access_log /path/to/log.gz combined gzip flush=5m;
```

> 要使 gzip 压缩起作用，必须在构建 nginx 时使用 zlib 库。

文件路径可以包含变量（0.7.6+），但存在一些限制：

- 被 woker 进程使用凭据的[用户](ngx_core_module.md#user)应有在此类日志在目录中创建文件的权限
- 缓冲写入不起作用
- 该文件在每次日志写入都要打开和关闭。然而，由于常用文件的描述符可以存储在[缓存](#open_log_file_cache)中，因此可以在 [open_log_file_cache](#open_log_file_cache) 指令的 `valid` 参数指定的时间内继续写入旧文件
- 在每次写入日志期间，检查请求根目录是否存在，如果不存在，则不创建日志。因此，在同一级别指定 [root](ngx_http_core_module.md#root) 和 access_log 是一个好方法：

```nginx
server {
    root       /spool/vhost/data/$host;
    access_log /spool/vhost/logs/$host;
    ...
```

`if` 参数（1.7.0）启用条件日志记录。如果 `condition`为 `0` 或空字符串，则不会记录请求。在以下示例中，不会记录响应代码为 2xx 和 3xx 的请求：

```nginx
map $status $loggable {
    ~^[23]  0;
    default 1;
}

access_log /path/to/access.log combined if=$loggable;
```

### log_format

|\-|说明|
|------:|------|
|**语法**|**log_format** `name [escape=default\|json\|none] string ...`;|
|**默认**|log_format combined "...";|
|**上下文**|http|

指定日志格式。

`escape` 参数（1.11.8）允许设置 `json` 或 `default` 字符在变量中转义，默认情况下使用 `default` 转义。`none` 参数（1.13.10）禁用转义。

日志格式可以包含公共变量和仅在日志写入时存在的变量：

- `$bytes_sent`

    发送给客户端的字节数

- `$connection`

    连接序列号

- `$connection_requests`

    当前通过连接发出的请求数量（1.1.18）

- `$msec`

    以秒为单位的时间，日志写入时的毫秒精度

- `$pipe`

    如果请求是 pipe，则为 **p**，否则为 **.**

- `$request_length`

    请求长度（包括请求行、头部和请求体）

- `$request_time`

    以毫秒为精度的请求处理时间，以秒为单位。从客户端读取第一个字节到最后一个字节发送到客户端并写入日志过程的时间

- `$status`

    响应状态

- `$time_iso8601`

    本地时间采用 ISO 8601 标准格式

- `$time_local`

    本地时间采用通用日志格式（Common Log Format）

> 在现代 nginx 版本中，变量 [$status](ngx_http_core_module.md#var_status)（1.3.2、1.2.2）、[$bytes_sent](ngx_http_core_module.md#var_bytes_sent)（1.3.8、1.2.5）、[$connection](ngx_http_core_module.md#var_connection)（1.3.8、1.2.5）、[$connection_requests](ngx_http_core_module.md#var_connection_requests)（1.3.8、1.2.5）、[$msec](ngx_http_core_module.md#var_msec)（1.3.9、1.2.6）、[$request_time](ngx_http_core_module.md#var_request_time)（1.3.9、1.2.6）、[$pipe](ngx_http_core_module.md#var_pipe)（1.3.12、1.2.7）、`$request_length`（1.3.12、1.2.7）、[$time_iso8601](http://nginx.org/en/docs/http/ngx_http_core_module.html#var_request_length)（1.3.12、1.2.7）和 [$time_local](ngx_http_core_module.md#var_time_local)（1.3.12、1.2.7）也作为公共变量。

发送到客户端的头字段前缀为 `sent_http_`，例如 `$sent_http_content_range`。

配置始终包含预定义的 `combined` 格式：

```nginx
log_format combined '$remote_addr - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent"';
```

### open_log_file_cache

|\-|说明|
|------:|------|
|**语法**|**open_log_file_cache** `max=N [inactive=time] [min_uses=N] [valid=time]`; <br /> **open_log_file_cache** `off`;|
|**默认**|open_log_file_cache off;|
|**上下文**|http、server、location|

定义一个缓存，用于存储名称中包含变量的常用日志的文件描述符。该指令有以下参数：

- `max`

    设置缓存中描述符的最大数量。如果缓存变满，则最近最少使用（LRU）的描述符将被关闭

- `inactive`

    如果在此时间后缓存描述符没有被访问，则被关闭，默认为 10 秒

- `min_uses`

    在 `inactive` 参数定义的时间内设置文件使用的最小数量，以使描述符在缓存中保持打开状态，默认为 1

- `valid`

    设置检查同名文件是否仍然存在的时间，默认为 60 秒

- `off`

    禁用缓存

使用示例：

```nginx
open_log_file_cache max=1000 inactive=20s valid=1m min_uses=2;
```

## 原文档

[http://nginx.org/en/docs/http/ngx_http_log_module.html](http://nginx.org/en/docs/http/ngx_http_log_module.html)