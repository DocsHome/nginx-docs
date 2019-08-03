# ngx_http_userid_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [userid](#userid)
    - [userid_domain](#userid_domain)
    - [userid_expires](#userid_expires)
    - [userid_mark](#userid_mark)
    - [userid_name](#userid_name)
    - [userid_p3p](#userid_p3p)
    - [userid_path](#userid_path)
    - [userid_service](#userid_service)
- [内嵌变量](#embedded_variables)

`ngx_http_userid_module` 模块设置方便客户端识别的 cookie。可以使用内嵌变量 [$uid_got](#uid_got) 和 [$uid_set](#uid_set) 记录已接收和设置的 cookie。该模块与 Apache 的 [mod_uid](http://www.lexa.ru/programs/mod-uid-eng.html) 模块兼容。

<a id="example_configuration"></a>

## 示例配置

```nginx
userid         on;
userid_name    uid;
userid_domain  example.com;
userid_path    /;
userid_expires 365d;
userid_p3p     'policyref="/w3c/p3p.xml", CP="CUR ADM OUR NOR STA NID"';
```

<a id="directives"></a>

## 指令

### userid

|\-|说明|
|:------|:------|
|**语法**|**userid** `on` &#124; `v1` &#124; `log` &#124; `off`;|
|**默认**|userid off;|
|**上下文**|http、server、location|

启用或禁用设置 cookie 和记录接受到的 cookie：

- `on`

    启用版本 2 cookie 设置并记录接收到的 cookie

- `v1`

    启用版本 1 cookie 设置并记录接收到的 cookie

- `log`

    禁用 cookie 设置，但允许记录接收到的 cookie

- `off`

    禁用 cookie 设置和记录接收到的 cookie

### userid_domain

|\-|说明|
|:------|:------|
|**语法**|**userid_domain** `name` &#124; `none`;|
|**默认**|userid_domain none;|
|**上下文**|http、server、location|

为设置的 cookie 定义域。`none` 参数禁用 cookie 域设置。

### userid_expires

|\-|说明|
|:------|:------|
|**语法**|**userid_expires** `time` &#124; `max` &#124; `off`;|
|**默认**|userid_expires off;|
|**上下文**|http、server、location|

设置浏览器保留 cookie 的时间（`time`）。特殊值 `max` 将 cookie 设置在 `31 Dec 2037 23:55:55 GMT` 时到期。如果未指定参数，cookie 将在浏览器会话结束时到期。

### userid_mark

|\-|说明|
|:------|:------|
|**语法**|**userid_mark** `letter` &#124; `digit` &#124; `=` &#124; `off`;|
|**默认**|userid_mark off;|
|**上下文**|http、server、location|

如果参数不是 `off`，则启用 cookie 标记机制并设置用作标记的字符。此机制用于在保留客户端标识符的同时添加或更改 [userid_p3p](ngx_http_userid_module.md#userid_p3p) 和/或 cookie 的过期时间。标记可以是英文字母（区分大小写）、数字或 `=` 字符的任何字符。

如果设置了标记，则将其与 cookie 中传递的客户端标识符的 base64 形式中的第一个填充符号进行比较。如果它们不匹配，则会重新发送带有指定标记、到期时间和 **P3P** 头的 cookie。

### userid_name

|\-|说明|
|:------|:------|
|**语法**|**userid_name** `name`;|
|**默认**|userid_name uid;|
|**上下文**|http、server、location|

设置 cookie 的名称。

### userid_p3p

|\-|说明|
|:------|:------|
|**语法**|**userid_p3p** `string` &#124; `none`;|
|**默认**|userid_p3p none;|
|**上下文**|http、server、location|

设置将与 cookie 一起发送的 **P3P** 头字段的值。如果指令设置为特殊值 `none`，则不会在响应中发送 **P3P** 头。

### userid_path

|\-|说明|
|:------|:------|
|**语法**|**userid_path** `path`;|
|**默认**|userid_path /;|
|**上下文**|http、server、location|

为设置的 cookie 定义路径。

### userid_service

|\-|说明|
|:------|:------|
|**语法**|**userid_service** `number`;|
|**默认**|userid_service 服务器的 IP 地址;|
|**上下文**|http、server、location|

如果标识符由多个服务器（服务）发出，则应为每个服务分配其自己的编号（`number`），以确保客户端标识符是唯一的。 对于版本 1 cookie，默认值为零。对于版本 2 cookie，默认值是从服务器 IP 地址的最后四个八位字节组成的数字。

<a id="embedded_variables"></a>

## 内嵌变量

`ngx_http_userid_module` 模块支持以下内嵌变量：

<a id="uid_got"></a>

- `$uid_got`

    cookie 名称和收到的客户端标识符

- `$uid_reset`

    如果变量设置为非空字符串且非 `"0"`，则重置客户端标识符。特殊值 `log` 会将关于重置标识符的消息输出到 [error_log](../核心功能.md#error_log)。

<a id="uid_set"></a>

- `$uid_set`

    cookie 名称和已发送的客户端标识符


## 原文档

- [http://nginx.org/en/docs/http/ngx_http_userid_module.html](http://nginx.org/en/docs/http/ngx_http_userid_module.html)
