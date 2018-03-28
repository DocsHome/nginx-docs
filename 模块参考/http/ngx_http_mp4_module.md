# ngx_http_mp4_module

- [指令](#directives)
    - [mp4](#mp4)
    - [mp4_buffer_size](#mp4_buffer_size)
    - [mp4_max_buffer_size](#mp4_max_buffer_size)
    - [mp4_limit_rate](#mp4_limit_rate)
    - [mp4_limit_rate_after](#mp4_limit_rate_after)

`ngx_http_mp4_module` 模块为 MP4 文件提供伪流服务端支持。这些文件的扩展名通常为 `.mp4`、`.m4v` 或 `.m4a`。

伪流与兼容的 Flash 播放器可以很好地配合工作。播放器在查询字符串参数中指定的开始时间向服务器发送 HTTP 请求（简单地以 `start` 命名并以秒为单位），服务器以流响应方式使其起始位置与请求的时间相对应，例如：

```nginx
http://example.com/elephants_dream.mp4?start=238.88
```

这将允许随时执行随机查找，或者在时间线中间开始回放。

为了支持搜索，基于 H.264 的格式将元数据存储在所谓的 **moov atom** 中。它是保存整个文件索引信息文件的一部分。

要开始播放，播放器首先需要读取元数据。通过发送一个有 `start=0` 参数的特殊请求来完成的。许多编码软件在文件的末尾插入元数据。这对于伪流播来说很糟糕，因为播放器必须在开始播放之前下载整个文件。如果元数据位于文件的开头，那么 nginx 就可以简单地开始发回文件内容。如果元数据位于文件末尾，nginx 必须读取整个文件并准备一个新流，以便元数据位于媒体数据之前。这涉及到一些 CPU、内存和磁盘 I/O 开销，所以最好事先[准备一个用于伪流传输的原始文件](http://flowplayer.org/plugins/streaming/pseudostreaming.html#prepare)，而不是让 nginx 在每个这样的请求上都这样处理。

该模块还支持设置播放结束点的 HTTP 请求（1.5.13）的 `end` 参数。`end` 参数可以与 `start` 参数一起指定或单独指定：

```nginx
http://example.com/elephants_dream.mp4?start=238.88&end=555.55
```

对于有非零 `start` 或 `end` 参数的匹配请求，nginx 将从文件中读取元数据，准备有所需时间范围的流并将其发送到客户端 这与上面描述的开销相同。

如果匹配请求不包含 `start` 和 `end` 参数，则不会有开销，并且文件仅作为静态资源发送。有些播放器也支持 byte-range 请求，因此不需要这个模块。

该模块不是默认构建的，可以使用 `--with-http_mp4_module` 配置参数启用。

> 如果以前使用过第三方 mp4 模块，则应该禁用它。

[ngx_http_flv_module](ngx_http_flv_module.md) 模块提供了对 FLV 文件的类伪流式的支持。

<a id="example_configuration"></a>

## 示例配置

```nginx
location /video/ {
    mp4;
    mp4_buffer_size       1m;
    mp4_max_buffer_size   5m;
    mp4_limit_rate        on;
    mp4_limit_rate_after  30s;
}
```

<a id="directives"></a>

## 指令

### mp4

|\-|说明|
|------:|------|
|**语法**|**mp4**;|
|**默认**|——|
|**上下文**|location|

启用对 location 模块处理。

### mp4_buffer_size

|\-|说明|
|------:|------|
|**语法**|**mp4_buffer_size** `size`;|
|**默认**|mp4_buffer_size 512K;|
|**上下文**|http、server、location|

设置用于处理 MP4 文件的缓冲区的初始大小。

### mp4_max_buffer_size

|\-|说明|
|------:|------|
|**语法**|**mp4_max_buffer_size** `time`;|
|**默认**|mp4_max_buffer_size 10M;|
|**上下文**|http、server、location|

在元数据处理期间，可能需要更大的缓冲区。它的大小不能超过指定的大小，否则 nginx 将返回 500（内部服务器错误）错误状态码，并记录以下消息：

```
"/some/movie/file.mp4" mp4 moov atom is too large:
12583268, you may want to increase mp4_max_buffer_size
```

### mp4_limit_rate

|\-|说明|
|------:|------|
|**语法**|**mp4_limit_rate** `on` &#124; `off` &#124; `factor`;|
|**默认**|p4_limit_rate off;|
|**上下文**|http、server、location|

限制对客户响应的传输速率。速率限制基于所提供 MP4 文件的平均比特率。要计算速率，比特率将乘以指定的 `factor`。特殊值 `on` 对应于因子 1.1 。特殊值 `off` 禁用速率限制。限制是根据请求设置的，所以如果客户端同时打开两个连接，总体速率将是指定限制的两倍。

> 该指令可作为我们[商业订阅](http://nginx.com/products/?_ga=2.21542971.1499146730.1522076644-1859001452.1520648382)的一部分。

### mp4_limit_rate_after

|\-|说明|
|------:|------|
|**语法**|**mp4_limit_rate_after** `time`;|
|**默认**|mp4_limit_rate_after 60s;|
|**上下文**|http、server、location|

设置媒体数据的初始数量（在回放时计算），之后进一步传输到客户端的响应将受到速率限制。

> 该指令可作为我们[商业订阅](http://nginx.com/products/?_ga=2.21542971.1499146730.1522076644-1859001452.1520648382)的一部分。

## 原文档
[http://nginx.org/en/docs/http/ngx_http_mp4_module.html](http://nginx.org/en/docs/http/ngx_http_mp4_module.html)