# ngx_http_gzip_static_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [gzip_static](#gzip_static)

`ngx_http_gzip_static_module` 模块允许发送以 **.gz** 结尾的预压缩文件替代普通文件。
该模块默认不会被构建到 nginx 中，需要在编译时加入 `--with-http_gzip_static_module` 配置参数启用。

<a id="example_configuration"></a>

## 配置示例

```nginx
gzip_static on;
gzip_proxied expired no-cache no-store private auth;
```
<a id="directives"></a>

## 指令

### gzip_static

|\-|说明|
|:------|:------|
|**语法**|**gzip_static** `on` &#124; `off` &#124; `always`; |
|**默认**|gzip_static off;|
|**上下文**|http、server、location|

开启(**on**)或禁用(**off**)会检查预压缩文件是否存在。下列指令也会被影响到 [gzip_http_verson](ngx_http_gzip_module.md#gzip_http_version)， [gzip_proxied](ngx_http_gzip_module.md#gzip_proxied)， [gzip_disable](ngx_http_gzip_module.md#gzip_disable)， [gzip_vary](ngx_http_gzip_module.md#gzip_vary)。

值为 **always** (1.3.6)，在所有情况下都会使用压缩文件，不检查客户端是否支持。如果磁盘上没有未被压缩的文件或者 [ngx_http_gunzip_module](ngx_http_gunzip_module.md) 模块被启用，这个参数非常有用。

文件可以使用`gzip`命令，或者任何兼容文件进行压缩。建议压缩文件和源文件的修改日期和时间保持一致。
