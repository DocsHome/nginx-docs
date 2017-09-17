# 记录日志到 syslog

`error_log`和`access_log`指令支持把日志记录到syslog。以下参数配置日志记录到syslog：
```
server=address
```
> 定义syslog服务器的地址，可以将该地址指定为附带可选端口的域名或者IP，或者指定为“unix:”前缀之后跟着一个特定的UNIX域套接字路径。如果没有指定端口，则使用UDP的514端口。如果域名解析为多个IP地址，则使用第一个地址。

<!--more -->

```
facility=string
```
> 设置syslog的消息facility（设备），[RFC3164](https://tools.ietf.org/html/rfc3164#section-4.1.1)中定义，facility可以是`kern`，`user`，`mail`，`daemon`，`auth`，`intern`，`lpr`，`news`，`uucp`，`clock`，`authpriv`，`ftp`，`ntp`，`audit`，`alert`，`cron`，`local0`，`local7`其中一个。默认是`local7`.

```
severity=string
```
> 设置`access_log`的消息严重程度，在[RFC3164](https://tools.ietf.org/html/rfc3164#section-4.1.1)中有定义。可能值与`error_log`指令的第二个参数（`level`，级别）相同，默认是`info`。错误消息的严重程度是有nginx确定的，因此在`error_log`指令中忽略该参数。

```
tag=string
```
> 设置syslog消息标签。默认是`nginx`。

```
nohostname
```
> 禁止将`hostname`域添加到syslog的消息（1.9.7）头中。

syslog配置示例：

```nginx
error_log syslog:server=192.168.1.1 debug;

access_log syslog:server=unix:/var/log/nginx.sock,nohostname;
access_log syslog:server=[2001:db8::1]:12345,facility=local7,tag=nginx,severity=info combined;
```

记录日志到syslog的功能自从1.7.2版本开始可用。作为我们[商业订阅](http://nginx.com/products/?_ga=2.80571039.986778370.1500745948-1890203964.1497190280)的一部分，记录日志到syslog的功能从1.5.3开始可用。

## 原文档

- [http://nginx.org/en/docs/syslog.html](http://nginx.org/en/docs/syslog.html)
