# ngx_http_secure_link_module

- [指令](#directives)
    - [secure_link](#secure_link)
    - [secure_link_md5](#secure_link_md5)
    - [secure_link_secret](#secure_link_secret)
- [内嵌变量](#embedded_variables)

`ngx_http_secure_link_module` 模块（0.7.18）用于检查请求链接的真实性，保护资源免受未经授权的访问，并限制链接有效时长。

通过将请求中传递的校验和值与为请求计算的值进行比较，验证所请求链接的真实性。如果链接有效时长有限且时间已过，则链接将被视为过期。这些检查的状态在 `$secure_link` 变量中可用。

该模块提供两种替代操作模式。第一种模式由 [secure_link_secret](#secure_link_secret) 指令启用，用于检查请求链接的真实性以及保护资源免受未经授权的访问。第二种模式（0.8.50）由 [secure_link](#secure_link) 和 [secure_link_md5](#secure_link_md5) 指令启用，也用于限制链接的有效期。

默认情况下不构建此模块，可使用 `--with-http_secure_link_module` 配置参数启用它。

<a id="directives"></a>

## 指令

### secure_link

|\-|说明|
|:------|:------|
|**语法**|**secure_link** `expression`;|
|**默认**|——|
|**上下文**|http、server、location|

定义一个包含变量的字符串，从中提取链接的校验和值和有效期。

表达式中使用的变量通常与请求相关联。见下面的[例子](#secure_link_md5)。

将从字符串中提取的校验和值与 [secure_link_md5](#secure_link_md5) 指令定义的表达式的 MD5 哈希值进行比较。如果校验和不同，则 `$secure_link` 变量设置为空字符串。如果校验和相同，则检查链接有效期。如果链接的有效期有限且时间已过，则 `$secure_link` 变量将设置为 `0`。否则，它被设置为 `1`。请求中传递的 MD5 哈希值使用 [base64url](https://tools.ietf.org/html/rfc4648#section-5) 编码。

如果链接的有效时长有限，则自 Epoch（Thu, 01 Jan 1970 00:00:00 GMT）以秒为单位设置到期时间。该值在 MD5 哈希之后的表达式中指定，并以逗号分隔。请求中传递的到期时间可通过 `$secure_link_expires` 变量获得，以便在 [secure_link_md5](#secure_link_md5) 指令中使用。如果未指定到期时间，则链接将有无限有效时长。

### secure_link_md5

|\-|说明|
|:------|:------|
|**语法**|**secure_link_md5** `expression`;|
|**默认**|——|
|**上下文**|http、server、location|

定义一个将为其计算 MD5 哈希值并与请求中传递的值进行比较的表达式。

表达式应包含链接（资源）的保护部分和秘密部分。如果链接的有效市场为有限，则表达式还应包含 `$secure_link_expires`。

为防止未经授权的访问，表达式可能包含有关客户端的一些信息，例如其地址和浏览器版本。

例如：

```nginx
location /s/ {
    secure_link $arg_md5,$arg_expires;
    secure_link_md5 "$secure_link_expires$uri$remote_addr secret";

    if ($secure_link = "") {
        return 403;
    }

    if ($secure_link = "0") {
        return 410;
    }

    ...
}
```

`/s/link?md5=_e4Nc3iduzkWRm01TBBNYw&expires=2147483647` 链接限制了 IP 地址为 127.0.0.1 的客户端对 `/s/link` 访问。该链接的有效时长有限，直到 2038 年 1 月 19 日（GMT）。

在 UNIX 上，`md5` 请求参数值可以获取为：

```bash
echo -n '2147483647/s/link127.0.0.1 secret' | \
    openssl md5 -binary | openssl base64 | tr +/ -_ | tr -d =
```

### secure_link_secret

|\-|说明|
|:------|:------|
|**语法**|**secure_link_secret** `word`;|
|**默认**|——|
|**上下文**|http、server、location|

定义一个用于检查所请求链接真实性的暗语（`word`）。

请求链接的完整 URI 如下所示：

```
/prefix/hash/link
```

其中 `hash` 是针对链接和暗语相连计算的 MD5 哈希的十六进制表示，而 `prefix` 是没有斜杠的任意字符串。

如果请求的链接通过了真实性检查，则 `$secure_link` 变量将设置为从请求 URI 中提取的链接。否则，`$secure_link` 变量设置为空字符串。

例如：

```nginx
location /p/ {
    secure_link_secret secret;

    if ($secure_link = "") {
        return 403;
    }

    rewrite ^ /secure/$secure_link;
}

location /secure/ {
    internal;
}
```

`/p/5e814704a28d9bc1914ff19fa0c4a00a/link` 的请求将在内部重定向到 `/secure/link`。

在 UNIX 上，此示例的哈希值可以通过以下方式获得：

```bash
echo -n 'linksecret' | openssl md5 -hex
```

<a id="embedded_variables"></a>

## 内嵌变量

- `$secure_link`

    链接检查的状态。具体值取决于所选的操作模式。

- `$secure_link_expires`

    请求中传递的链接的过期时间，仅用于 `secure_link_md5` 指令。

## 原文档

- [http://nginx.org/en/docs/http/ngx_http_secure_link_module.html](http://nginx.org/en/docs/http/ngx_http_secure_link_module.html)
