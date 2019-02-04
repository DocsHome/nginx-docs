# ngx_http_perl_module

- [指令](#directives)
- [已知问题](#issues)
    - [perl](#perl)
    - [perl_modules](#perl_modules)
    - [perl_require](#perl_require)
    - [perl_set](#perl_set)
- [从 SSI 调用 Perl](#ssi)
- [$r 请求对象方法](#methods)

`ngx_http_perl_module` 模块用于在 Perl 中实现 location 和变量处理器，并将 Perl 调用插入到 SSI中。

此模块不是默认构建，可以在构建时使用 `--with-http_perl_module` 配置参数启用。

> 该模块需要 [Perl](https://www.perl.org/get.html) 5.6.1 或更高版本。C 编译器应该与用于构建Perl 的编译器兼容。

<a id="issues"></a>

## 已知的问题

该模块还处于实验阶段，以下是一些注意事项。

为了让 Perl 能在重新配置过程中重新编译已修改的模块，应使用 `-Dusemultiplicity=yes` 或 `-Dusethreads=yes` 参数来构建它。另外，为了让 Perl 在运行时泄漏更少的内存，应使用 `-Dusemymalloc=no` 参数来构建它。要检查已构建的 Perl 中这些参数值（在示例中已指定首选值），请运行：

```nginx
$ perl -V:usemultiplicity -V:usemymalloc
usemultiplicity='define';
usemymalloc='n';
```

请注意，在使用新的 `-Dusemultiplicity=yes` 或 `-Dusethreads=yes` 参数重新构建 Perl 之后，所有二进制 Perl 模块也必须重新构建 — 否则它们将停止使用新的 Perl。

在每次重新配置后，master 进程和 worker 进程都有可能增加。如果 master 进程增加到不可接受的大小，则可以使用[实时升级](../../介绍/控制nginx.md#upgrade)流程而无需更改可执行文件。

当 Perl 模块执行长时间运行的操作时，例如解析域名、连接到另一台服务器或查询数据库时，将不会处理分配给当前 worker 进程的其他请求。因此，建议仅执行可预测且执行时间短的操作，例如访问本地文件系统。

<a id="example_configuration"></a>

## 示例配置

```nginx
http {

    perl_modules perl/lib;
    perl_require hello.pm;

    perl_set $msie6 '

        sub {
            my $r = shift;
            my $ua = $r->header_in("User-Agent");

            return "" if $ua =~ /Opera/;
            return "1" if $ua =~ / MSIE [6-9]\.\d+/;
            return "";
        }

    ';

    server {
        location / {
            perl hello::handler;
        }
    }
```

The perl/lib/hello.pm module:

```perl
package hello;

use nginx;

sub handler {
    my $r = shift;

    $r->send_http_header("text/html");
    return OK if $r->header_only;

    $r->print("hello!\n<br/>");

    if (-f $r->filename or -d _) {
        $r->print($r->uri, " exists!\n");
    }

    return OK;
}

1;
__END__
```


<a id="directives"></a>

## 指令

### perl

|\-|说明|
|------:|------|
|**语法**|**perl** `module::function`&#124;`'sub { ... }'`;|
|**默认**|——|
|**上下文**|location、limit_except|

给指定的 location 设置一个 Perl 处理程序。

### perl_modules

|\-|说明|
|------:|------|
|**语法**|**perl_modules** `path`;|
|**默认**|——|
|**上下文**|http|

为 Perl 模块设置额外的路径。

### perl_require

|\-|说明|
|------:|------|
|**语法**|**perl_require** `module`;|
|**默认**|——|
|**上下文**|http|

定义每次重新配置期间将要加载的模块的名称。可存在多个 `perl_require` 指令。

### perl_set 

|\-|说明|
|------:|------|
|**语法**|**perl_set** `$variable module::function`&#124;`'sub { ... }'`;|
|**默认**|——|
|**上下文**|http|

为指定的变量安装一个 Perl 处理程序。

<a id="ssi"></a>

## 从 SSI 调用 Perl

使用 SSI 命令调用 Perl 的格式如下：

```
<!--# perl sub="module::function" arg="parameter1" arg="parameter2" ...
-->
```

<a id="methods"></a>

## $r 请求对象方法

- `$r->args`
    
    返回请求参数。

- `$r->filename`

    返回与请求 URI 相对应的文件名。

- `$r->has_request_body(handler)`

    如果请求中没有请求体，则返回 0。如果存在，则为请求设置指定的处理程序，并返回 1。在读取请求体后，nginx 将调用指定的处理程序。请注意，处理函数应该通过引用传递。例：

    ```perl
    package hello;

    use nginx;

    sub handler {
        my $r = shift;

        if ($r->request_method ne "POST") {
            return DECLINED;
        }

        if ($r->has_request_body(\&post)) {
            return OK;
        }

        return HTTP_BAD_REQUEST;
    }

    sub post {
        my $r = shift;

        $r->send_http_header;

        $r->print("request_body: \"", $r->request_body, "\"<br/>");
        $r->print("request_body_file: \"", $r->request_body_file, "\"<br/>\n");

        return OK;
    }

    1;

    __END__
    ```

- `$r->allow_ranges`

    在发送响应时启用字节范围。

- `$r->discard_request_body`

    指示 nginx 放弃请求体。

- `$r->header_in(field)`

    返回指定的客户端请求头字段的值。

- `$r->header_only`

    确定整个响应还是仅将头部发送给客户端。

- `$r->header_out(field, value)`

    为指定的响应头字段设置一个值。

- `$r->internal_redirect(uri)`

    做一个内部重定向到指定的 uri。在 Perl 处理程序执行完成后重定向。
    
    > 目前不支持重定向到具名 location。

- `$r->log_error(errno, message)`

    将指定的消息写入 [error_log](ngx_core_module.md#error_log)。如果 `errno` 不为零，则错误码及其描述将被附加到消息中。

- `$r->print(text, ...)`
    
    将数据传递给客户端。

- `$r->request_body`

    如果尚未将请求体写入临时文件中，则返回客户端请求体。为了确保客户端请求体在内存中，其大小应该由 [client_max_body_size](ngx_http_core_module.md#client_max_body_size) 来限制，并且应该使用 [client_body_buffer_size](ngx_http_core_module.md#client_body_buffer_size) 来设置足够的缓冲区大小。

- `$r->request_body_file`

    客户端请求体返回文件的名称。处理完成后，该文件将被删除。要始终将请求体写入文件，应启用 [client_body_in_file_only](ngx_http_core_module.md#client_body_in_file_only)。

- `$r->request_method`

    返回客户端请求的 HTTP 方法。

- `$r->remote_addr`

    返回客户端 IP 地址。

- `$r->flush`

    立即向客户端发送数据。

- `$r->sendfile(name[, offset[, length]])`
    将指定的文件内容发送到客户端。可选参数指定要传输的数据的初始偏移量（`offset`）和长度（`length`）。数据在 Perl 处理程序完成之后开始传输。

- `$r->send_http_header([type])`

    将响应头发送给客户端。可选的 `type` 参数用于设置 **Content-Type** 响应头字段的值。如果该值为空字符串，则不会发送 **Content-Type** 头字段。

- `$r->status(code)`

    设置响应状态码。

- `$r->sleep(milliseconds, handler)`

    设置指定的处理程序（`handler`）和指定停止请求处理的时间（`milliseconds`）。在此期间，nginx 继续处理其他请求。在经过指定的时间后，nginx 将调用已安装的处理程序。请注意，处理函数应该通过引用传递。为了在处理程序之间传递数据，应使用 `$r->variable()`。例：

    ```perl
    package hello;

    use nginx;

    sub handler {
        my $r = shift;

        $r->discard_request_body;
        $r->variable("var", "OK");
        $r->sleep(1000, \&next);

        return OK;
    }

    sub next {
        my $r = shift;

        $r->send_http_header;
        $r->print($r->variable("var"));

        return OK;
    }

    1;

    __END__
    ```

- `$r->unescape(text)`

    解码 **％XX** 格式编码的文本。

- `$r->uri`

    返回请求 URI。

- `$r->variable(name[, value])`

    返回或设置指定变量的值。对于每个请求来说这些变量都是本地变量。

## 原文档

[http://nginx.org/en/docs/http/ngx_http_perl_module.html](http://nginx.org/en/docs/http/ngx_http_perl_module.html)