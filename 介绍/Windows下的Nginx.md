# Windows 下的 nginx

[已知问题](#已知问题)
[以后可能的发展](#以后可能的发展)

Nginx 的 Windows 版本使用了本地的 Win32 API（而不是 Cygwin 模拟层）。目前仅使用 `select()` 和 `poll()` (1.15.9) 连接处理方式。由于此版本和其他存在已知的问题的 Nginx Windows 版本都被认为是 beta 版本，因此您不应该期望它具有高性能和可扩展性。现在，它提供了与 Unix 版本的 nginx 几乎相同的功能，除了 XSLT 过滤器、图像过滤器、GeoIP 模块和嵌入式 Perl 语言。

<!-- more -->

要安装 nginx 的 Windows 版本，请 [下载](http://nginx.org/en/download.html) 最新的主线发行版（1.17.2），因为 nginx 的主线分支包含了所有已知的补丁。之后解压文件到 `nginx-1.17.2` 目录下，然后运行 `nginx`。以下是 `C盘` 的根目录：

```bash
cd c:\
unzip nginx-1.17.2.zip
cd nginx-1.17.2
start nginx
```

运行 `tasklist` 命令行工具查看 nginx 进程：

```bash
C:\nginx-1.17.2>tasklist /fi "imagename eq nginx.exe"

Image Name           PID Session Name     Session#    Mem Usage
=============== ======== ============== ========== ============
nginx.exe            652 Console                 0      2 780 K
nginx.exe           1332 Console                 0      3 112 K
```
其中有一个是主进程（master），另一个是工作进程（worker）。如果 nginx 未能启动，请在错误日志 `logs\error.log` 中查找原因。如果日志文件尚未创建，可以在 Windows 事件日志中查找原因。如果显示的页面为错误页面，而不是预期结果，也可以在 `logs\error.log` 中查找原因。

Nginx 的 Windows 版本使用运行目录作为配置文件中的相对路径前缀。在上面的例子中，前缀是 `C:\nginx-1.17.2\`。在配置文件中的路径必须使类 Unix 风格的正斜杠：

```nginx
access_log   logs/site.log;
root         C:/web/html;
```
Nginx 的 Windows 版本作为标准的控制台应用程序（而不是服务）运行，可以使用以下命令进行管理：

- `nginx -s stop` 快速退出
- `nginx -s quit` 正常退出
- `nginx -s reload` 重新加载配置文件，使用新的配置启动工作进程，正常关闭旧的工作进程
- `nginx -s reopen` 重新打开日志文件

## 已知问题
- 虽然可以启动多个工作进程，但实际上只有一个工作进程做完全部的工作
- 不支持 UDP 代理功能

## 以后可能的发展
- 作为服务运行
- 使用 I/O 完成端口作为连接处理方式
- 在单个工作进程中使用多个工作线程

## 原文档

[http://nginx.org/en/docs/windows.html](http://nginx.org/en/docs/windows.html)
