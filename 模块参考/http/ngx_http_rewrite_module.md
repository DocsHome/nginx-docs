# ngx_http_rewrite_module

- [指令](#directives)
    - [break](#break)
    - [if](#if)
    - [return](#return)
    - [rewrite](#rewrite)
    - [rewrite_log](#rewrite_log)
    - [set](#set)
    - [uninitialized_variable_warn](#uninitialized_variable_warn)
- [内部实现](#internals)

`ngx_http_rewrite_module` 模块使用 PCRE 正则表达式更改请求 URI、返回重定向和有条件地选择配置。

[break](#break)、[if](#if)、[return](#return)、[rewrite](#rewrite) 和 [set](#set) 指令将按以下顺序处理：

- 在 [server](ngx_http_core_module.md#server) 级别下，该模块的指令按顺序执行
- 重复执行：
    - 基于请求 URI 搜索 [location](ngx_http_core_module.md#location)
    - 在 location 内找的该模块的指令按顺序执行
    - 如果请求 URI 被[重写](#rewrite)，则重复循环，但不超过 [10 次](ngx_http_core_module.md#internal)。

<a id="directives"></a>

## 指令

### break

|\-|说明|
|:------|:------|
|**语法**|**break**;|
|**默认**|——|
|**上下文**|server、location、if|

停止处理当前的 `ngx_http_rewrite_module` 指令集。

如果在该 [location](ngx_http_core_module.md#location) 内指定了指令，则请求的下一步处理在该位置将继续。

示例：

```nginx
if ($slow) {
    limit_rate 10k;
    break;
}
```

### if

|\-|说明|
|:------|:------|
|**语法**|**if** `(condition) { ... }`;|
|**默认**|——|
|**上下文**|server、location|

指定的 `condition` 求值之后，如果为 `true`，则执行在大括号内指定的该模块的指令，并在 `if` 指令内为该请求分配配置。`if` 指令内的配置继承自上一层的配置级别。

`condition` 可以是以下任何一种：

- 变量名，如果变量的值为空字符串或 `0`，则为 `false`

    在 1.0.1版本 之前，任何以 `0` 开头的字符串都被视为错误值。

- 使用 `=` 和 `!=` 运算符比较变量和字符串

- 使用 `~`（区分大小写的匹配）和 `~*`（不区分大小写的匹配）运算符，变量将与正则表达式进行匹配。正则表达式可以包含可供以后在 `$1..$9` 变量中重用的捕获。反操作符 `!~` 和 `!~*` 也可用。如果正则表达式包含 `}` 或 `;` 字符，则整个表达式应使用单引号或双引号包围起来。

- 使用 `-f` 和 `!-f` 运算符检查文件是否存在

- 使用 `-d` 和 `!-d` 运算符检查目录是否存在

- 使用 `-e` 和 `!-e` 运算符检查文件、目录或符号链接是否存在

- 使用 `-x` 和 `!-x` 运算符检查是否为可执行文件

示例：

```nginx
if ($http_user_agent ~ MSIE) {
    rewrite ^(.*)$ /msie/$1 break;
}

if ($http_cookie ~* "id=([^;]+)(?:;|$)") {
    set $id $1;
}

if ($request_method = POST) {
    return 405;
}

if ($slow) {
    limit_rate 10k;
}

if ($invalid_referer) {
    return 403;
}
```

> `$invalid_referer` 内嵌变量的值由 [valid_referers](ngx_http_referer_module.md#valid_referers) 指令设置。

### return

|\-|说明|
|:------|:------|
|**语法**|**return** `code [text]`;<br/>**return** `code URL`;<br/>**return** `URL`;|
|**默认**|——|
|**上下文**|server、location、if|

停止处理并将指定的 `code` 返回给客户端。非标准代码 444 在不发送响应头的情况下关闭连接。

从 0.8.42 版本开始，可以指定重定向 URL（对 301、302、303、307 和 308 代码有效）或响应正文 `text`（对其他代码有效）。响应正文和重定向 URL 都可以包含变量。特殊情况下，可以将重定向 URL 指定为此服务器的本地 URI，在这种情况下，根据请求模式（`$scheme`）以及 [server_name_in_redirect](ngx_http_core_module.md#server_name_in_redirect) 和 [port_in_redirect](ngx_http_core_module.md#port_in_redirect) 指令形成完整重定向 URL。

另外，可以将代码为 302 的临时重定向的 `URL` 指定为唯一参数。这样的参数应该以 `http://`、`https://` 或 `$scheme` 字符串开头。`URL` 可以包含变量。

> 在 0.7.51 版本之前只能返回以下代码：204、400、402-406、408、410、411、413、416 和 500-504。

> 在 1.1.16 版本和 1.0.13 版本之前，代码 307 不被视为重定向。

> 在 1.13.0 版本之前，代码 308 不被视为重定向。

另请参见 [error_page](ngx_http_core_module.md#error_page) 指令。

### rewrite

|\-|说明|
|:------|:------|
|**语法**|**rewrite** `regex replacement [flag]`;|
|**默认**|——|
|**上下文**|server、location、if|

如果指定的正则表达式与请求 URI 匹配，则 URI 将根据 `replacement` 中的指定进行更改。`rewrite` 指令按照它们在配置文件中的出现顺序依次执行。可以使用标志来终止指令的下一步处理。如果替换以 `http://`、`https://` 或 `$scheme` 开头的字符串，则处理流程将停止并将重定向返回给客户端。

可选的 `flag` 参数可以是以下之一：

- `last`

    停止处理当前的 `ngx_http_rewrite_module` 指令集并开始搜索新的 location 来匹配变更的 URI

- `break`

    与 [break](#break) 指令一样，停止处理当前的 `ngx_http_rewrite_module` 指令集;

- `redirect`

    返回带有 302 代码的临时重定向，如果替换字符串不以 `http://`、`https://` 或 `$scheme` 开头，则生效

- `permanent`

    返回 301 代码的永久重定向

完整重定向 URL 根据请求模式（`$scheme`）以及 [server_name_in_redirect](ngx_http_core_module.hmdtml#server_name_in_redirect) 和 [port_in_redirect](ngx_http_core_module.md#port_in_redirect) 指令形成。

示例：

```nginx
server {
    ...
    rewrite ^(/download/.*)/media/(.*)\..*$ $1/mp3/$2.mp3 last;
    rewrite ^(/download/.*)/audio/(.*)\..*$ $1/mp3/$2.ra  last;
    return  403;
    ...
}
```

但是如果这些指令放在 `/download/` 位置，`last` 标志应该用 `break` 替换，否则 nginx 会产生 10 个循环并返回 500 错误：

```nginx
location /download/ {
    rewrite ^(/download/.*)/media/(.*)\..*$ $1/mp3/$2.mp3 break;
    rewrite ^(/download/.*)/audio/(.*)\..*$ $1/mp3/$2.ra  break;
    return  403;
}
```

如果 `replacement` 包含新请求参数，则先前的请求参数将最加在它们之后。如果不希望这样，可在 `replacement` 的末尾加上一个问号可以避免追加，例如：

```nginx
rewrite ^/users/(.*)$ /show?user=$1? last;
```

如果正则表达式包含 `}` 或 `;` 字符，则整个表达式应使用单引号或双引号包围。

### rewrite_log

|\-|说明|
|:------|:------|
|**语法**|**rewrite_log** `on` &#124; `oof`;|
|**默认**|rewrite_log off;|
|**上下文**|http、server、location、if|

启用或禁用在 `notice` 级别将 `ngx_http_rewrite_module` 模块指令处理结果记录到 [error_log](../核心功能.md#error_log) 中。

### set

|\-|说明|
|:------|:------|
|**语法**|**set** `$variable value`;|
|**默认**|——|
|**上下文**|server、location、if|

为指定的 `variable` 设置一个 `value`，`value` 可以包含文本、变量及其组合。

### uninitialized_variable_warn

|\-|说明|
|:------|:------|
|**语法**|**uninitialized_variable_warn** `on` &#124; `oof`;|
|**默认**|uninitialized_variable_warn on;|
|**上下文**|http、server、location、if|

控制是否记录有关未初始化变量的警告。

<a id="internals"></a>

## 内部实现

`ngx_http_rewrite_module` 模块指令在配置阶段编译为内部指令，其在请求处理期间被解释执行。解释器是一个简单的虚拟栈机器。

例如以下指令（directive）：

```nginx
location /download/ {
    if ($forbidden) {
        return 403;
    }

    if ($slow) {
        limit_rate 10k;
    }

    rewrite ^/(download/.*)/media/(.*)\..*$ /$1/mp3/$2.mp3 break;
}
```
将会翻译成以下指令（instruction）：

```
variable $forbidden
check against zero
    return 403
    end of code
variable $slow
check against zero
match of regular expression
copy "/"
copy $1
copy "/mp3/"
copy $2
copy ".mp3"
end of regular expression
end of code
```

请注意，上面的 [limit_rate](ngx_http_core_module.md#limit_rate) 指令没有相关指令（instruction)，因为它与 `ngx_http_rewrite_module` 模块无关。这些单独配置是为 [if](#id) 块创建的。如果条件成立，则为此配置分配一个请求，其中 `limit_rate` 等于 10k。

指令：

```nginx
rewrite ^/(download/.*)/media/(.*)\..*$ /$1/mp3/$2.mp3 break;
```

如果正则表达式中的第一个斜杠放在括号内，可以让生成的指令（instruction）变得更轻：


```nginx
rewrite ^(/download/.*)/media/(.*)\..*$ $1/mp3/$2.mp3 break;
```

生成的指令如下：

```
match of regular expression
copy $1
copy "/mp3/"
copy $2
copy ".mp3"
end of regular expression
end of code
```
    
## 原文档
[http://nginx.org/en/docs/http/ngx_http_rewrite_module.html](http://nginx.org/en/docs/http/ngx_http_rewrite_module.html)
