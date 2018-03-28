# ngx_http_image_filter_module

- [指令](#directives)
    - [image_filter](#image_filter)
    - [image_filter_buffer](#image_filter_buffer)
    - [image_filter_interlace](#image_filter_interlace)
    - [image_filter_jpeg_quality](#image_filter_jpeg_quality)
    - [image_filter_sharpen](#image_filter_sharpen)
    - [image_filter_transparency](#image_filter_transparency)
    - [image_filter_webp_quality](#image_filter_webp_quality)

`ngx_http_image_filter_module` 模块（0.7.54+）是一个可以转换 JPEG、GIF、PNG 和 WebP 格式图像的过滤器。

此模块不是默认构建的，可以使用 `--with-http_image_filter_module` 配置参数启用。

> 该模块使用了 [libgd](http://libgd.org/) 库。建议使用该库的最新版本。

> WebP 格式支持出现在 1.11.6 版本中。要转换成此格式的图像，必须在编译 `libgd` 库时启用 WebP 支持。

<a id="example_configuration"></a>

## 示例配置

```nginx
location /img/ {
    proxy_pass   http://backend;
    image_filter resize 150 100;
    image_filter rotate 90;
    error_page   415 = /empty;
}

location = /empty {
    empty_gif;
}
```

<a id="directives"></a>

## 指令

### image_filter

|\-|说明|
|------:|------|
|**语法**|**image_filter** `off`; <br/>**image_filter** `test`;<br/>**image_filter** `size`;<br/>**image_filter** `rotate 90 &#124; 180 &#124; 270`;<br/>**image_filter** `resize width height`;<br/>**image_filter** `crop width height`;|
|**默认**|image_filter off;|
|**上下文**|location|

设置图片执行的转换类型：

- `off`

    关闭对 location 模块的处理

- `test`

    确保响应是 JPEG、GIF、PNG 或 WebP 格式的图片。否则，返回 415（不支持的媒体类型）错误。

- `size`

    以 JSON 格式输出图片的信息，例如：

    ```json
    { "img" : { "width": 100, "height": 100, "type": "gif" } }
    ```

    发生错误时，输出如下：

    ```json
    {}
    ```

- `rotate 90&#124;180&#124;270`

    将图片逆时针旋转指定的度数。参数值可以包含变量。此模式可以单独使用，也可以与调整大小和裁剪转换一起使用。

- `resize width height`

    按比例将图片缩小到指定的尺寸。要只指定一个维度，可以将另一个维度指定为 `-`。当发生错误，服务器将返回 415 状态码（不支持的媒体类型）。参数值可以包含变量。当与 `rotate` 参数一起使用时，旋转变换将在缩小变换**之后**执行。

- `crop width height`

    按比例将图片缩小到较大的一边，并裁剪另一边多余的边缘。要只指定一个维度，可以将另一个维度指定为 `-`。当发生错误，服务器将返回 415 状态码（不支持的媒体类型）。参数值可以包含变量。当与 `rotate` 参数一起使用时，旋转变换将在缩小变换**之前**执行。

### image_filter_buffer

|\-|说明|
|------:|------|
|**语法**|**image_filter_buffer** `size`;|
|**默认**|image_filter_buffer 1M;|
|**上下文**|http、server、location|

设置用于读取图片的缓冲区的最大大小。当超过指定大小时，服务器返回 415 错误状态码（不支持的媒体类型）。

### image_filter_interlace

|\-|说明|
|------:|------|
|**语法**|**image_filter_interlace** `on` &#124; `off`;|
|**默认**|image_filter_interlace off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.3.15 版本中出现|

如果启用此选项，图片最后将被逐行扫描。对于 JPEG，图片最终将采用**逐行 JPEG** 格式。

### image_filter_jpeg_quality

|\-|说明|
|------:|------|
|**语法**|**image_filter_jpeg_quality** `quality`;|
|**默认**|image_filter_jpeg_quality 75;|
|**上下文**|http、server、location|

设置 JPEG 图片的转换质量。可接受的值范围在 1 到 100 之间。较小的值意味着较低的图片质量和较少的数据传输。最大的推荐值是 95，参数值可以包含变量。

### image_filter_sharpen

|\-|说明|
|------:|------|
|**语法**|**image_filter_sharpen** `percent`;|
|**默认**|image_filter_sharpen 0;|
|**上下文**|http、server、location|

增加最终图像的清晰度。锐度百分比可以超过 100。零值将禁用锐化。参数值可以包含变量。

### image_filter_transparency

|\-|说明|
|------:|------|
|**语法**|**image_filter_transparency** `on` &#124; `off`;|
|**默认**|image_filter_transparency on;|
|**上下文**|http、server、location|

定义在使用调色板指定的颜色转换 GIF 图像或 PNG 图像时是否保留透明度。透明度的丧失使图像的质量更好的。PNG 中的 alpha 通道透明度始终保留。

### image_filter_webp_quality

|\-|说明|
|------:|------|
|**语法**|**image_filter_webp_quality** `quality`;|
|**默认**|image_filter_webp_quality 80;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.11.6 版本中出现|

设置 WebP 图片的转换质量。可接受的值在 1 到 100 之间。较小的值意味着较低的图片质量和较少的数据传输。参数值可以包含变量。

## 原文档
[http://nginx.org/en/docs/http/ngx_http_image_filter_module.html](http://nginx.org/en/docs/http/ngx_http_image_filter_module.html)