# 记录日志到 syslog

[error_log](http://nginx.org/en/docs/ngx_core_module.html#error_log) 和 [access_log](http://nginx.org/en/docs/http/ngx_http_log_module.html#access_log) 指令支持把日志记录到 syslog。以下配置参数将使 nginx 日志记录到 syslog：

```yaml
server=address
```
> 定义 syslog 服务器的地址，可以将该地址指定为附带可选端口的域名或者 IP，或者指定为 “unix:” 前缀之后跟着一个特定的 UNIX 域套接字路径。如果没有指定端口，则使用 UDP 的 514 端口。如果域名解析为多个 IP 地址，则使用第一个地址。

<!--more -->

```
facility=string
```

> 设置 syslog 的消息 facility（设备），[RFC3164](https://tools.ietf.org/html/rfc3164#section-4.1.1) 中定义，facility可以是 `kern`，`user`，`mail`，`daemon`，`auth`，`intern`，`lpr`，`news`，`uucp`，`clock`，`authpriv`，`ftp`，`ntp`，`audit`，`alert`，`cron`，`local0`，`local7` 中的一个，默认是 `local7`。

```
severity=string
```

> 设置 [access_log](http://nginx.org/en/docs/http/ngx_http_log_module.html#access_log) 的消息严重程度，在 [RFC3164](https://tools.ietf.org/html/rfc3164#section-4.1.1) 中定义。可能值与 [error_log](http://nginx.org/en/docs/ngx_core_module.html#error_log) 指令的第二个参数（ `level`，级别）相同，默认是 `info`。错误消息的严重程度由 nginx 确定，因此在 `error_log` 指令中将忽略该参数。

```
tag=string
```
> 设置 syslog 消息标签。默认是 `nginx`。

```
nohostname
```
> 禁止将 `hostname` 域添加到 syslog 的消息（1.9.7）头中。

syslog配置示例：

```nginx
error_log syslog:server=192.168.1.1 debug;

access_log syslog:server=unix:/var/log/nginx.sock,nohostname;
access_log syslog:server=[2001:db8::1]:12345,facility=local7,tag=nginx,severity=info combined;
```

记录日志到 syslog 的功能自从 1.7.2 版本开始可用。作为我们 [商业订阅](http://nginx.com/products/?_ga=2.80571039.986778370.1500745948-1890203964.1497190280) 的一部分，记录日志到 syslog 的功能从 1.5.3 开始可用。

## 原文档

- [http://nginx.org/en/docs/syslog.html](http://nginx.org/en/docs/syslog.html)
