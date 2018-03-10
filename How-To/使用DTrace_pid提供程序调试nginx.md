# 使用 DTrace pid 提供程序调试 nginx

本文假设读者对 nginx 内部原理和 [DTrace](http://nginx.org/en/docs/nginx_dtrace_pid_provider.html#see_also) 有了一定的了解。

虽然使用了 [--with-debug](http://nginx.org/en/docs/debugging_log.html) 选项构建的 nginx 已经提供了大量关于请求处理的信息，但有时候更有必要详细地跟踪代码路径的特定部分，同时省略其余不必要的调试输出。DTrace pid 提供程序（在 Solaris，MacOS 上可用）是一个用于浏览用户程序内部的有用工具，因为它不需要更改任何代码，就可以帮助您完成任务。跟踪和打印 nginx 函数调用的简单 DTrace 脚本示例如下所示：

```d
#pragma D option flowindent

pid$target:nginx::entry {
}

pid$target:nginx::return {
}
```

尽管如此，DTrace 的函数调用跟踪功能仅提供有限的有用信息。实时检查的功能参数通常更加有趣，但也更复杂一些。以下示例旨在帮助读者熟悉 DTrace 以及使用 DTrace 分析 nginx 行为的过程。

使用 DTrace 与 nginx 的常见方案之一是：附加到 nginx 的工作进程来记录请求行和请求开始时间。附加的相应函数是 `ngx_http_process_request()`，参数指向的是一个 `ngx_http_request_t` 结构的指针。使用 DTrace 脚本实现这种请求日志记录可以简单到：

```d
pid$target::*ngx_http_process_request:entry
{
    this->request = (ngx_http_request_t *)copyin(arg0, sizeof(ngx_http_request_t));
    this->request_line = stringof(copyin((uintptr_t)this->request->request_line.data,
                                         this->request->request_line.len));
    printf("request line = %s\n", this->request_line);
    printf("request start sec = %d\n", this->request->start_sec);
}
```

需要注意的是，在上面的示例中，DTrace 需要引用 `ngx_http_process_request` 结构的一些相关信息。不幸的是，虽然可以在 DTrace 脚本中使用特定的 `#include` 指令，然后将其传递给 C 预处理器（使用 `-C` 标志），但这并不能真正起效。由于大量的交叉依赖，几乎所有的 nginx 头文件都必须包含在内。反过来，基于 `configure` 脚本设置，nginx 头将包括 PCRE、OpenSSL 和各种系统头文件。理论上，在 DTrace 脚本预处理和编译时，与特定的 nginx 构建相关的所有头文件都有可能被包含进来，实际上 DTrace 脚本很有可能由于某些头文件中的未知语法而造成无法编译。

上述问题可以通过在 DTrace 脚本中仅包含相关且必要的结构和类型定义来解决。DTrace 必须知道结构、类型和字段偏移的大小。因此，通过手动优化用于 DTrace 的结构定义，可以进一步降低依赖。

让我们使用上面的 DTrace 脚本示例，看看它需要哪些结构定义才能正常地工作。

首先应该包含由 configure 生成的 `objs/ngx_auto_config.h` 文件，因为它定义了一些影响各个方面的 `＃ifdef` 常量。之后，一些基本类型和定义（如 `ngx_str_t`，`ngx_table_elt_t`，`ngx_uint_t` 等）应放在 DTrace 脚本的开头。这些定义经常被使用但不太可能经常改变的。

那里有一个包含许多指向其他结构的指针的 ngx_http_process_request_t 结构。因为这些指针与这个脚本无关，而且因为它们具有相同的大小，所以可以用 void 指针来替换它们。但最好添加合适的 typedef，而不是更改定义：

```d
typedef ngx_http_upstream_t     void;
typedef ngx_http_request_body_t void;
```

最后但同样重要的是，需要添加两个成员结构的定义（`ngx_http_headers_in_t`，`ngx_http_headers_out_t`）、回调函数声明和常量定义。

最后，DTrace 脚本可以从 [这里](http://nginx.org/download/trace_process_request.d) 下载。

以下示例是运行此脚本的输出：

```
# dtrace -C -I ./objs -s trace_process_request.d -p 4848
dtrace: script 'trace_process_request.d' matched 1 probe
CPU     ID                    FUNCTION:NAME
  1      4 .XAbmO.ngx_http_process_request:entry request line = GET / HTTP/1.1
request start sec = 1349162898

  0      4 .XAbmO.ngx_http_process_request:entry request line = GET /en/docs/nginx_dtrace_pid_provider.html HTTP/1.1
request start sec = 1349162899
```

使用类似的技术，读者应该能够跟踪其他 nginx 函数调用。

## 相关阅读

- [Solaris 动态跟踪指南](http://docs.oracle.com/cd/E19253-01/817-6223/index.html)
- [DTrace pid 提供程序介绍](http://dtrace.org/blogs/brendan/2011/02/09/dtrace-pid-provider/)

## 原文档

[http://nginx.org/en/docs/nginx_dtrace_pid_provider.html](http://nginx.org/en/docs/nginx_dtrace_pid_provider.html)
