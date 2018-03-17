# ngx_http_js_module

- [指令](#directives)
    - [js_include](#js_include)
    - [js_content](#js_content)
    - [ js_set](# js_set)
- [请求与响应参数](#arguments)

`ngx_http_js_module` 模块用于在 [nginScript](../../介绍/关于nginScript.md) 中实现 location 和变量处理器 — 它是 JavaScript 语言的一个子集。

此模块不是默构建，可以使用 `--add-module` 配置参数与 nginScript 模块一起编译：

```bash
./configure --add-module=path-to-njs/nginx
```

可以使用以下命令克隆 nginScript 模块[仓库](http://hg.nginx.org/njs?_ga=2.21584507.1917722686.1520954456-1859001452.1520648382)（需要 [Mercurial](https://www.mercurial-scm.org/) 客户端）：

```bash
hg clone http://hg.nginx.org/njs
```

该模块也可以构建为[动态形式](../核心功能.md#load_module)：

```
./configure --add-dynamic-module=path-to-njs/nginx
```

<a id="example_configuration"></a>

## 示例配置

```nginx
js_include http.js;

js_set $foo     foo;
js_set $summary summary;

server {
    listen 8000;

    location / {
        add_header X-Foo $foo;
        js_content baz;
    }

    location /summary {
        return 200 $summary;
    }
}
```

`http.js` 文件：

```js
function foo(req, res) {
    req.log("hello from foo() handler");
    return "foo";
}

function summary(req, res) {
    var a, s, h;

    s = "JS summary\n\n";

    s += "Method: " + req.method + "\n";
    s += "HTTP version: " + req.httpVersion + "\n";
    s += "Host: " + req.headers.host + "\n";
    s += "Remote Address: " + req.remoteAddress + "\n";
    s += "URI: " + req.uri + "\n";

    s += "Headers:\n";
    for (h in req.headers) {
        s += "  header '" + h + "' is '" + req.headers[h] + "'\n";
    }

    s += "Args:\n";
    for (a in req.args) {
        s += "  arg '" + a + "' is '" + req.args[a] + "'\n";
    }

    return s;
}

function baz(req, res) {
    res.headers.foo = 1234;
    res.status = 200;
    res.contentType = "text/plain; charset=utf-8";
    res.contentLength = 15;
    res.sendHeader();
    res.send("nginx");
    res.send("java");
    res.send("script");

    res.finish();
}
```

<a id="directives"></a>

## 指令

### js_include

|\-|说明|
|------:|------|
|**语法**|**js_include** `file`;|
|**默认**|——|
|**上下文**|http|

指定一个在 nginScript 中实现 location 和变量处理器的文件。

### hls_buffers

|\-|说明|
|------:|------|
|**语法**|**js_content** `function`;|
|**默认**|——|
|**上下文**|location、limit_except|

将 nginScript 函数设置为 location 内容处理器。

### js_set

|\-|说明|
|------:|------|
|**语法**|**js_set** `$variable function`;|
|**默认**|——|
|**上下文**|http|
|**提示**|该指令在 1.5.12 版本中出现|

为指定变量设置 nginScript 函数。

<a id="arguments"></a>

## 请求与响应参数

每个 HTTP nginScript 处理器接收两个参数，请求和响应。

请求对象具有以下属性：

- `uri`

    请求的当前 URI，只读

- `method`

    请求方法，只读

- `httpVersion`

    HTTP 版本，只读

- `remoteAddress`

    客户端地址，只读

- `headers{}`

    请求头对象，只读

    例如，可以使用语法 `headers['Header-Name']` 或 `headers.Header_name` 来访问 `Header-Name` 头

- `args{}`

    请求参数对象，只读

- `variables{}`

    nginx 变量对象，只读

- `log(string)`

    将 `string` 写入错误日志

响应对象具有以下属性：

- `status`

    响应状态，可写

- `headers{}`

    响应头对象

- `contentType`

    响应的 `Content-Type` 头字段值，可写

- `contentLength`

    响应的 `Content-Length` 头字段值，可写

响应对象具有以下方法：

- `sendHeader()`

    将 HTTP 头发送到客户端

- `send(string)`

    将部分响应体的发送给客户端

- `finish()`

    完成向客户端发送响应

## 原文档

[http://nginx.org/en/docs/http/ngx_http_js_module.html](http://nginx.org/en/docs/http/ngx_http_js_module.html)