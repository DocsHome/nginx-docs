# ngx_stream_js_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [js_access](#js_access)
    - [js_filter](#js_filter)
    - [js_include](#js_include)
    - [js_preread](#js_preread)
    - [js_set](#js_set)
- [会话对象属性](#properties)

`ngx_stream_js_module` 模块用于在 [njs](../../介绍/关于nginScript.md) 中实现处理程序 —— 这是 JavaScript 语言的一个子集。

默认情况下不构建此模块。可在[此处](http://nginx.org/en/docs/njs/install.html)下载和安装说明。

<a id="example_configuration"></a>

> 此示例适用于 njs [0.2.4](http://nginx.org/en/docs/njs/changes.html#njs0.2.4) 及更高版本。对于 njs [0.2.3](http://nginx.org/en/docs/njs/changes.html#njs0.2.3) 及更早版本，请使用[此示例](http://nginx.org/en/docs/njs/examples.html#legacy)。

## 示例配置

```nginx
load_module modules/ngx_stream_js_module.so;
...

stream {
    js_include stream.js;

    js_set $bar bar;
    js_set $req_line req_line;

    server {
        listen 12345;

        js_preread preread;
        return     $req_line;
    }

    server {
        listen 12346;

        js_access  access;
        proxy_pass 127.0.0.1:8000;
        js_filter  header_inject;
    }
}

http {
    server {
        listen 8000;
        location / {
            return 200 $http_foo\n;
        }
    }
}
```

`stream.js` 内容：

```js
var line = '';

function bar(s) {
    var v = s.variables;
    s.log("hello from bar() handler!");
    return "bar-var" + v.remote_port + "; pid=" + v.pid;
}

function preread(s) {
    s.on('upload', function (data, flags) {
        var n = data.indexOf('\n');
        if (n != -1) {
            line = data.substr(0, n);
            s.done();
        }
    });
}

function req_line(s) {
    return line;
}

// Read HTTP request line.
// Collect bytes in 'req' until
// request line is read.
// Injects HTTP header into a client's request

var my_header =  'Foo: foo';
function header_inject(s) {
    var req = '';
    s.on('upload', function(data, flags) {
        req += data;
        var n = req.search('\n');
        if (n != -1) {
            var rest = req.substr(n + 1);
            req = req.substr(0, n + 1);
            s.send(req + my_header + '\r\n' + rest, flags);
            s.off('upload');
        }
    });
}

function access(s) {
    if (s.remoteAddress.match('^192.*')) {
        s.abort();
        return;
    }

    s.allow();
}
```

<a id="directives"></a>

## 指令

### js_access

|\-|说明|
|------:|------|
|**语法**|**js_access** `function`;|
|**默认**|——|
|**上下文**|stream、server|

设置一个将在 [access](../../介绍/Nginx如何处理TCP_UDP会话.md) 阶段调用的 njs 函数。

### js_filter

|\-|说明|
|------:|------|
|**语法**|**js_filter** `function`;|
|**默认**|——|
|**上下文**|stream、server|

设置一个数据过滤器。

### js_include

|\-|说明|
|------:|------|
|**语法**|**js_include** `file`;|
|**默认**|——|
|**上下文**|stream|

指定一个使用 njs 实现服务器和变量处理程序的文件。

### js_preread

|\-|说明|
|------:|------|
|**语法**|**js_preread** `function`;|
|**默认**|——|
|**上下文**|stream、server|

设置一个将在 [preread]((../../介绍/Nginx如何处理TCP_UDP会话.md)) 阶段调用的 njs 函数。

### js_set

|\-|说明|
|------:|------|
|**语法**|**js_set** `function`;|
|**默认**|——|
|**上下文**|stream|

设置一个用于指定变量的 njs 函数。

<a id="properties"></a>

## 会话对象属性

每一个流 njs 处理程序都会接收一个参数，一个流会话[对象](http://nginx.org/en/docs/njs/reference.html#stream)。

## 原文档
[http://nginx.org/en/docs/stream/ngx_stream_js_module.html](http://nginx.org/en/docs/stream/ngx_stream_js_module.html)