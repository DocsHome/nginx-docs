# ngx_http_headers_module

- [指令](#directives)
    - [hls](#hls)
    - [hls_buffers](#hls_buffers)
    - [hls_forward_args](#hls_forward_args)
    - [hls_fragment](#hls_fragment)
    - [hls_mp4_buffer_size](#hls_mp4_buffer_size)
    - [hls_mp4_max_buffer_size](#hls_mp4_max_buffer_size)

`ngx_http_hls_module` 模块为 MP4 和 MOV 媒体文件提供 HTTP Live Streaming（HLS）服务器端支持。这些文件通常具有 `.mp4`、`.m4v`、`.m4a`、`.mov` 或 `.qt` 扩展名。该模块支持 H.264 视频编解码器、AAC 和 MP3 音频编解码器。

对于每个媒体文件，支持两种 URI：

- 带有 `.m3u8` 文件扩展名的播放列表 URI。该 URI 可以接受可选参数：
    - `start` 和 `end` 以秒为单位定义播放列表范围（1.9.0）。
    - `offset` 将初始播放位置移动到以秒为单位的时间偏移（1.9.0）。正值设置播放列表开头的时间偏移量。负值设置播放列表中最后一个片段末尾的时间偏移量。
    - `len` 以秒为单位定义片段长度。
- 带有 `.ts` 文件扩展名的片段 URI。该 URI 可以接受可选参数：
    - `start` 和 `end` 以秒为单位定义片段范围。

> 该模块可作为我们[商业订阅](http://nginx.com/products/?_ga=2.248085959.1917722686.1520954456-1859001452.1520648382)的一部分。

<a id="example_configuration"></a>

## 示例配置

```nginx
location / {
    hls;
    hls_fragment            5s;
    hls_buffers             10 10m;
    hls_mp4_buffer_size     1m;
    hls_mp4_max_buffer_size 5m;
    root /var/video/;
}
```

在此配置中，`/var/video/test.mp4` 文件支持以下 URI：

```nginx
http://hls.example.com/test.mp4.m3u8?offset=1.000&start=1.000&end=2.200
http://hls.example.com/test.mp4.m3u8?len=8.000
http://hls.example.com/test.mp4.ts?start=1.000&end=2.200
```

<a id="directives"></a>

## 指令

### hls

|\-|说明|
|------:|------|
|**语法**|**hls**;|
|**默认**|——|
|**上下文**|location|

为当前 location 打开 HLS 流。

### hls_buffers

|\-|说明|
|------:|------|
|**语法**|**hls_buffers** `number size`;|
|**默认**|hls_buffers 8 2m;|
|**上下文**|http、server、location|

设置用于读取和写入数据帧的缓冲区的最大数量（`number`）和大小（`size`）。

### hls_forward_args

|\-|说明|
|------:|------|
|**语法**|**hls_forward_args** `on` &#124; `off`;|
|**默认**|hls_forward_args off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.5.12 版本中出现|

将播放列表请求中的参数添加到片段的 URI 中。这对于在请求片段时或在使用 [ngx_http_secure_link_module](ngx_http_secure_link_module.md) 模块保护 HLS 流时执行客户端授权非常有用。

例如，如果客户端请求播放列表 `http://example.com/hls/test.mp4.m3u8?a=1&b=2`，参数 `a=1` 和 `b=2` 将在参数 `start` 和 `end` 后面添加到片段 URI 中：

```
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-TARGETDURATION:15
#EXT-X-PLAYLIST-TYPE:VOD

#EXTINF:9.333,
test.mp4.ts?start=0.000&end=9.333&a=1&b=2
#EXTINF:7.167,
test.mp4.ts?start=9.333&end=16.500&a=1&b=2
#EXTINF:5.416,
test.mp4.ts?start=16.500&end=21.916&a=1&b=2
#EXTINF:5.500,
test.mp4.ts?start=21.916&end=27.416&a=1&b=2
#EXTINF:15.167,
test.mp4.ts?start=27.416&end=42.583&a=1&b=2
#EXTINF:9.626,
test.mp4.ts?start=42.583&end=52.209&a=1&b=2

#EXT-X-ENDLIST
```

如果 HLS 流受到 [ngx_http_secure_link_module](ngx_http_secure_link_module.md) 模块的保护，则不应在 [secure_link_md5](ngx_http_secure_link_module.md#secure_link_md5) 表达式中使用 `$uri`，因为这会在请求片段时触发错误。应该使用 [Base URI](ngx_http_map_module.md#map) 而不是 `$uri`（在示例中为 `$hls_uri`）：

```nginx
http {
    ...

    map $uri $hls_uri {
        ~^(?<base_uri>.*).m3u8$ $base_uri;
        ~^(?<base_uri>.*).ts$   $base_uri;
        default                 $uri;
    }

    server {
        ...

        location /hls {
            hls;
            hls_forward_args on;

            alias /var/videos;

            secure_link $arg_md5,$arg_expires;
            secure_link_md5 "$secure_link_expires$hls_uri$remote_addr secret";

            if ($secure_link = "") {
                return 403;
            }

            if ($secure_link = "0") {
                return 410;
            }
        }
    }
}
```

### hls_fragment

|\-|说明|
|------:|------|
|**语法**|**hls_fragment** `time`;|
|**默认**|hls_fragment 5s;|
|**上下文**|http、server、location|

定义未使用 `len` 参数请求的播放列表 URI 的默认片段长度。

### hls_mp4_buffer_size

|\-|说明|
|------:|------|
|**语法**|**hls_mp4_buffer_size** `size`;|
|**默认**|hls_mp4_buffer_size 512k;|
|**上下文**|http、server、location|

设置用于处理 MP4 和 MOV 文件的缓冲区的初始大小（`size`）。

### hls_mp4_max_buffer_size

|\-|说明|
|------:|------|
|**语法**|**hls_mp4_max_buffer_size** `size`;|
|**默认**|hls_mp4_max_buffer_size 10m;|
|**上下文**|http、server、location|

在元数据处理期间，可能需要更大的缓冲区。其大小不能超过指定的大小（`size`），否则 nginx 将返回 500 状态码（内部服务器错误），并记录以下消息：

```
"/some/movie/file.mp4" mp4 moov atom is too large:
12583268, you may want to increase hls_mp4_max_buffer_size
```

## 原文档

[http://nginx.org/en/docs/http/ngx_http_hls_module.html](http://nginx.org/en/docs/http/ngx_http_hls_module.html)