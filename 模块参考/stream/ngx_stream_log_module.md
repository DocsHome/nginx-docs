# ngx_stream_log_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [access_log](#access_log)
    - [log_format](#log_format)
    - [open_log_file_cache](#open_log_file_cache)

`ngx_stream_log_module` 模块（1.11.4）按指定的格式写入会话日志。

<a id="example_configuration"></a>

## 示例配置

```nginx
log_format basic '$remote_addr [$time_local] '
                 '$protocol $status $bytes_sent $bytes_received '
                 '$session_time';

access_log /spool/logs/nginx-access.log basic buffer=32k;
```

<a id="directives"></a>

## 指令

### access_log

|\-|说明|
|------:|------|
|**语法**|**access_log** `path format [buffer=size] [gzip[=level]] [flush=time] [if=condition]`;<br/>**access_log** `off`;|
|**默认**|access_log off;|
|**上下文**|stream、server|

设置缓冲日志写入的路径、[格式](#log_format)和配置。可以在同一级别指定多个日志。可通过在第一个参数中指定 `syslog:` 前缀来配置记录到 [syslog](../../介绍/记录日志到syslog.md)。特殊值 `off` 取消当前级别的所有 `access_log` 指令。

如果使用 `buffer` 或 `gzip` 参数，则将缓冲 log 的写入。

> 缓冲区大小不得超过磁盘文件的原子写入大小。对于 FreeBSD 而言，这个大小是无限制的。

启用缓冲后，以下情况数据将写入文件：

- 如果下一个日志行不能放入缓冲区
- 如果缓冲的数据早于 `flush` 参数指定的数据
- 当 worker 进程重新打开日志文件或正在关闭时

如果使用 `gzip` 参数，将写入文件之前将压缩缓冲的数据。压缩级别可以设置为 1（最快，压缩级别低）到 9（最慢，压缩级别最高）之间。默认情况下，缓冲区大小等于 64K 字节，压缩级别设置为 1。由于数据是以原子块压缩，因此日志文件可以随时通过 `zcat` 解压缩或读取。

示例：

```nginx
access_log /path/to/log.gz basic gzip flush=5m;
```

> 要使 gzip 压缩起作用，必须在构建 nginx 使用 zlib 库。

文件路径可以包含变量，但是这样的日志有一些约束：

- 被 worker 进程使用凭据的[用户](../http/ngx_http_core_module.md#user)应具有在具有此类日志的目录中创建文件的权限
- 缓冲写入将不起作用
- 每个日志写入都会打开和关闭文件。但是，由于频繁使用的文件的描述符可以存储在[缓存](ngx_stream_log_module.md#open_log_file_cache)中，因此可以在 [open_log_file_cache](ngx_stream_log_module.md#open_log_file_cache) 指令的 `valid` 参数指定的时间内继续写入旧文件

`if` 参数启用条件日志。如果 `condition` 计值为 0 或空字符串，则不会记录会话。

### log_format

|\-|说明|
|------:|------|
|**语法**|**log_format** `name [escape=default\|json\|none] string ...`;|
|**默认**|——|
|**上下文**|stream|

指定日志格式，例如：

```nginx
log_format proxy '$remote_addr [$time_local] '
                 '$protocol $status $bytes_sent $bytes_received '
                 '$session_time "$upstream_addr" '
                 '"$upstream_bytes_sent" "$upstream_bytes_received" "$upstream_connect_time"';
```

`escape` 参数（1.11.8）允许在变量中设置转义的 `json` 或 `default` 字符，默认情况下，使用 `default` 转义。 `none` 参数（1.13.10）禁用转义。

### open_log_file_cache

|\-|说明|
|------:|------|
|**语法**|**open_log_file_cache** `max=N [inactive=time] [min_uses=N] [valid=time]`;<br/>**open_log_file_cache** `off`;|
|**默认**|open_log_file_cache off;|
|**上下文**|stream、server|

定义一个缓存，用于存储名称中包含变量的常用日志的文件描述符。该指令有以下参数：

- `max`

    设置缓存中的最大描述符数，如果缓存变满，则最近最少使用（LRU）的描述符将被关闭

- `inactive`

    如果在此期间没有发生访问，则设置关闭缓存描述符的时间。默认为 10 秒

- `min_uses`

    设置在 `inactive` 参数定义的时间内文件使用的最小数量，使描述符在缓存中保持打开状态。默认为 1

- `valid`

    设置检查同名文件是否仍然存在的时间。默认为 60 秒

- `off`

    禁用缓存

用法示例：

```nginx
open_log_file_cache max=1000 inactive=20s valid=1m min_uses=2;
```

## 原文档
[http://nginx.org/en/docs/stream/ngx_stream_log_module.html](http://nginx.org/en/docs/stream/ngx_stream_log_module.html)