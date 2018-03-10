# ngx_http_charset_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [charset](#charset)
    - [charset_map](#charset_map)
    - [charset_types](#charset_types)
    - [override_charset](#override_charset)
    - [source_charset](#source_charset)

`ngx_http_charset_module` 模块将指定的字符集添加到 **Content-Type** 响应头域。此外，该模块可以将数据从一个字符集转换为另一个字符集，但也存在一些限制：

- 转换工作只能是从服务器到客户端
- 只能转换单字节字符集
- 或转为/来自 UTF-8 的单字节字符集。

<a id="example_configuration"></a>

## 示例配置

```nginx
include        conf/koi-win;

charset        windows-1251;
source_charset koi8-r;
```

<a id="directives"></a>

## 指令

### charset

|\-|说明|
|:------|:------|
|**语法**|**charset** `charset` &#124; `off`;|
|**默认**|charset off;|
|**上下文**|http、server、location、location 中的 if|

将指定的字符集添加到 **Content-Type** 响应头域。如果此字符集与 [source_charset](#source_charset) 指令指定的字符集不同，则执行转换。

参数 `off` 取消将字符集添加到 **Content-Type** 响应头。

可以使用一个变量来定义字符集：

```nginx
charset $charset;
```

在这种情况下，变量的值至少要在 [charset_map](#charset_map)、[charset](#charset) 或 [source_charset](#source_charset) 其中一个指令配置一次。对于 `utf-8`、`windows-1251` 和 `koi8-r` 字符集，将 `conf/koi-win`、`conf/koi-utf` 和 `conf/win-utf` 文件包含到配置中就足够了。对于其他字符集，只需制作一个虚构的转换表即可，例如：

```nginx
charset_map iso-8859-5 _ { }
```

另外，可以在 **X-Accel-Charset** 响应头域中设置一个字符集。可以使用[proxy_ignore_headers](ngx_http_proxy_module.md#proxy_ignore_headers)、[fastcgi_ignore_headers](ngx_http_fastcgi_module.md#fastcgi_ignore_headers)、[uwsgi_ignore_headers](ngx_http_uwsgi_module.md#uwsgi_ignore_headers) 和 [scgi_ignore_headers](ngx_http_scgi_module.md#scgi_ignore_headers) 指令禁用此功能。

### charset_map

|\-|说明|
|:------|:------|
|**语法**|**charset_map** `charset1 charset2 { ... }`;|
|**默认**|——|
|**上下文**|http|

描述转换表，将一个字符集转换到另一个字符集。反向转换表也使用相同的数据构建。字符代码是十六进制格式。不在 80-FF 范围内的字符将被替换为 `?`。当从 UTF-8 转换时，一个字节字符集中丢失的字符将被替换为 `&#XXXX;`。

示例：

```nginx
charset_map koi8-r windows-1251 {
    C0 FE ; # small yu
    C1 E0 ; # small a
    C2 E1 ; # small b
    C3 F6 ; # small ts
    ...
}
```

在将转换表描述为 UTF-8 时，应在第二列中给出 UTF-8 字符集代码，例如：

```nginx
charset_map koi8-r utf-8 {
    C0 D18E ; # small yu
    C1 D0B0 ; # small a
    C2 D0B1 ; # small b
    C3 D186 ; # small ts
    ...
}
```

在分发文件 `conf/koi-win`、`conf/koi-utf` 和 `conf/win-utf` 中提供了从 `koi8-r` 到 `windows-1251` 以及从 `koi8-r` 和 `windows-1251` 到 `utf-8` 的完整转换表。

### charset_types

|\-|说明|
|:------|:------|
|**语法**|**charset_types** `mime-type ...`;|
|**默认**|charset_types text/html text/xml text/plain text/vnd.wap.wml
application/javascript application/rss+xml;|
|**上下文**|http、server、location|
|**提示**|该指令在 0.7.9 版本中出现|

除了 `text/html` 之外，还可以使用指定了 MIME 类型的响应中的模块处理。特殊值 `*` 可匹配任何 MIME 类型（0.8.29）。

> 直到 1.5.4 版本，`application/x-javascript` 被作为默认的 MIME 类型，而不是`application/javascript`。

### override_charset

|\-|说明|
|:------|:------|
|**语法**|**override_charset** `on` &#124; `off`;|
|**默认**|override_charset off;|
|**上下文**|http、server、location、location 中的 if|

当应答已经在 **Content-Type** 响应头域中携带字符集时，确定是否应该对从代理或 FastCGI/uwsgi/SCGI 服务器接收的应答执行转换。如果启用转换，则在接收到的响应中指定的字符集将用作源字符集。

> 应该注意的是，如果在子请求中接收到响应，则始终执行从响应字符集到主请求字符集的转换，而不管 `override_charset` 指令如何设置。

### source_charset

|\-|说明|
|:------|:------|
|**语法**|**source_charset** `charset`;|
|**默认**|——|
|**上下文**|http、server、location、location 中的 if|

定义响应的源字符集。如果此字符集与 [charset](#charset) 指令中指定的字符集不同，则执行转换。

## 原文档
[http://nginx.org/en/docs/http/ngx_http_charset_module.html](http://nginx.org/en/docs/http/ngx_http_charset_module.html)
