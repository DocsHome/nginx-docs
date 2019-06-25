# ngx_http_ssi_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [ssi](#ssi)
    - [ssi_last_modified](#ssi_last_modified)
    - [ssi_min_file_chunk](#ssi_min_file_chunk)
    - [ssi_silent_errors](#ssi_silent_errors)
    - [ssi_types](#ssi_types)
    - [ssi_value_length](#ssi_value_length)
- [SSI 命令](#commands)
- [内嵌变量](#embedded_variables)

`ngx_http_ssi_module` 模块是一个过滤器，在经过它的响应中处理 SSI（服务器端包含）命令。目前，支持的 SSI 命令列表并不完整。

<a id="example_configuration"></a>

## 示例配置

```nginx
location / {
    ssi on;
    ...
}
```

<a id="directives"></a>

## 指令

### ssi

|\-|说明|
|:------|:------|
|**语法**|**ssi** `on` &#124; `off`;|
|**默认**|ssi off;|
|**上下文**|http、server、location、location 中的 if|

启用或禁用处理响应中的 SSI 命令。

### ssi_last_modified

|\-|说明|
|:------|:------|
|**语法**|**ssi_last_modified** `on` &#124; `off`;|
|**默认**|ssi_last_modified off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.5.1 版本中出现|

允许在 SSI 处理期间保留原始响应中的 **Last-Modified** 头字段，以便于响应缓存。

默认情况下，在处理过程中修改响应内容时会删除头字段，并且可能包含动态生成的元素或与原始响应无关的部分。

### ssi_min_file_chunk

|\-|说明|
|:------|:------|
|**语法**|**ssi_min_file_chunk** `size`;|
|**默认**|ssi_min_file_chunk 1k;|
|**上下文**|http、server、location|

设置响应存储在磁盘上的部分的最小大小（`size`），从使用 [sendfile](ngx_http_core_module.md#sendfile) 发送它们起生效。

### ssi_silent_errors

|\-|说明|
|:------|:------|
|**语法**|**ssi_silent_errors** `on` &#124; `off`;|
|**默认**|ssi_silent_errors off;|
|**上下文**|http、server、location|

如果启用，则在 SSI 处理期间发生错误时，禁止输出 `[an error occurred while processing the directive]` 字符串。

### ssi_types

|\-|说明|
|:------|:------|
|**语法**|**ssi_types** `mime-type ...`;|
|**默认**|ssi_types text/html;|
|**上下文**|http、server、location|

除了 **text/html** 之外，还可以指定在其他 MIME 类型的响应中处理 SSI 命令。特殊值 `*` 匹配任何 MIME 类型（0.8.29）。

### ssi_value_length

|\-|说明|
|:------|:------|
|**语法**|**ssi_value_length** `length`;|
|**默认**|ssi_value_length 256;|
|**上下文**|http、server、location|

设置 SSI 命令中参数值的最大长度。

<a id="commands"></a>

## SSI 命令

SSI 命令的通用格式：

```
<!--# command parameter1=value1 parameter2=value2 ... -->
```

支持以下命令：

- `block`

    定义一个可在 `include` 命令中用作存根的块。该块可以包含其他 SSI 命令。该命令有以下参数：

    - `name`

        块名称

    示例：

    ```
    <!--# block name="one" -->
    stub
    <!--# endblock -->
    ```

- `config`

    设置SSI处理期间使用的一些参数，即：

    - `errmsg`

        在 SSI 处理期间发生错误时输出的字符串。默认输出以下字符串：

        ```
        [an error occurred while processing the directive]
        ```

    - `timefmt`

        传递给 `strftime()` 函数的格式化字符串，用于输出日期和时间。默认为以下格式：

        ```
        "%A, %d-%b-%Y %H:%M:%S %Z"
        ```

        `％s` 格式适合以秒为单位输出时间。

- `echo`

    输出一个变量的值。该命令有以下参数：

    - `var`

        变量名

    -  `encoding`

        编码方式。可能的值包括 `none`、`url` 和 `entity`。默认使用 `entity`。

    - `default`

        一个非标准参数，如果变量未定义，则输出设置的默认字符串。默认情况下，输出 `(none)`。

        ```
        <!--# echo var="name" default="no" -->
        ```

        以上命令将替换成以下命令序列：

        ```
        <!--# if expr="$name" --><!--# echo var="name" --><!--#
        else -->no<!--# endif -->
        ```

- `if`

    执行条件包含。支持以下命令：

    ```
    <!--# if expr="..." -->
    ...
    <!--# elif expr="..." -->
    ...
    <!--# else -->
    ...
    <!--# endif -->
    ```

    目前仅支持一级嵌套。该命令有以下参数：

    - `expr`

        表达式。一个表达式可以是：

        - 变量存在检查：

            ```
            <!--# if expr="$name" -->
            ```

        - 变量与文本比较：

            ```
            <!--# if expr="$name = text" -->
            <!--# if expr="$name != text" -->
            ```

        - 变量与正则表达式比较：

            ```
            <!--# if expr="$name = /text/" -->
            <!--# if expr="$name != /text/" -->
            ```

        如果一个 `text` 包含变量，则替换它们的值。一个正则表达式可以包含位置和命名捕获，之后可通过变量引用使用，例如：

        ```
        <!--# if expr="$name = /(.+)@(?P<domain>.+)/" -->
            <!--# echo var="1" -->
            <!--# echo var="domain" -->
        <!--# endif -->
        ```

- `include`

    将另一个请求的结果包含到一个响应中。该命令有以下参数：

    - `file`

        指定一个包含的文件，例如：

        ```
        <!--# include file="footer.html" -->
        ```

    - `virtual`

        指定一个包含的请求，例如：

        ```
        <!--# include virtual="/remote/body.php?argument=value" -->
        ```

        指定在一个页面上并由代理或 FastCGI/uwsgi/SCGI/gRPC 服务器处理的多个请求并行运行。如果需要顺序处理，则应使用 `wait` 参数。

    - `stub`

        一个非标准参数，用于命名块，如果该块包含的请求导致空请求体或在请求处理期间发生错误，则将输出其内容，例如：

        ```
        <!--# block name="one" -->&nbsp;<!--# endblock -->
        <!--# include virtual="/remote/body.php?argument=value" stub="one" -->
        ```

        在包含的请求上下文中处理替换块内容。

    - `wait`

        一个非标准参数，在继续进行 SSI 处理之前等待请求完全完成，例如：

        ```
        <!--# include virtual="/remote/body.php?argument=value" wait="yes" -->
        ```

    - `set`

        一个非标准参数，将请求处理的成功结果写入指定变量，例如：

        ```
        <!--# include virtual="/remote/body.php?argument=value" set="one" -->
        ```

        响应的最大大小由 [subrequest_output_buffer_size](ngx_http_core_module.md#subrequest_output_buffer_size) 指令（1.13.10）设置：

        ```
        location /remote/ {
            subrequest_output_buffer_size 64k;
            ...
        }
        ```

        在 1.13.10 版之前，只有使用 [ngx_http_proxy_module](ngx_http_proxy_module.md)、[ngx_http_memcached_module](ngx_http_memcached_module.md)、[ngx_http_fastcgi_module](ngx_http_fastcgi_module.md)（1.5.6）、[ngx_http_uwsgi_module](ngx_http_uwsgi_module.md)（1.5.6）和 [ngx_http_scgi_module](ngx_http_scgi_module.md)（1.5.6）模块获得的响应结果才能写入变量。响应的最大大小是使用 [proxy_buffer_size](ngx_http_proxy_module.md#proxy_buffer_size)、[memcached_buffer_size](ngx_http_memcached_module.md#memcached_buffer_size)、[fastcgi_buffer_size](ngx_http_fastcgi_module.md#fastcgi_buffer_size)、[uwsgi_buffer_size](ngx_http_uwsgi_module.md#uwsgi_buffer_size) 和 [scgi_buffer_size](ngx_http_scgi_module.md#scgi_buffer_size) 指令设置的。

- `set`

    设置变量的值。该命令有以下参数：

    - `var`

        变量名

    - `value`

        变量值。如果指定的值包含变量，则替换它们的值。

<a id="embedded_variables"></a>

## 内嵌变量

`ngx_http_ssi_module` 模块支持两个内嵌变量：

- `$date_local`

    当地时区的当前时间。该格式由 `config` 命令和 `timefmt` 参数设置。

- `$date_gmt`

    格林威治标准时间形式的当前时间，该格式由 `config` 命令和 `timefmt` 参数设置。

## 原文档

- [http://nginx.org/en/docs/http/ngx_http_ssi_module.html](http://nginx.org/en/docs/http/ngx_http_ssi_module.html)
