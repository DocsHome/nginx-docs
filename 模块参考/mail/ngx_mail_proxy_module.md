# ngx_mail_proxy_module

- [指令](#directives)
    - [proxy_buffer](#proxy_buffer)
    - [proxy_pass_error_message](#proxy_pass_error_message)
    - [proxy_timeout](#proxy_timeout)
    - [xclient](#xclient)

<a id="directives"></a>

## 指令

### proxy_buffer

|\-|说明|
|:------|:------|
|**语法**|**proxy_buffer** `size`;|
|**默认**|proxy_buffer 4k&#124;8k|
|**上下文**|mail、server|

设置用于代理的缓冲区的大小。默认情况下，缓冲区大小等于一个内存页。根据平台的不同，它可以是 4K 或 8K。

### proxy_pass_error_message

|\-|说明|
|:------|:------|
|**语法**|**proxy_pass_error_message** `on` &#124; `off`;|
|**默认**|proxy_pass_error_message off;|
|**上下文**|mail、server|

指示是否将后端身份验证期间获得的错误消息传递给客户端。

通常，如果 nginx 中的身份验证成功，则后端无法返回错误。如果仍然返回错误，则表示发生了一些内部错误。在这种情况下，后端消息可能包含不应显示给客户端的信息。但是，对于某些 POP3 服务器，响应一个密码错误信息是正常现象。例如，CommuniGatePro 通过定期输出[身份验证错误](http://www.stalker.com/CommuniGatePro/POP.html#Alerts)来通知用户[邮箱溢出](http://www.stalker.com/CommuniGatePro/Alerts.html#Quota)或其他事件。在这种情况下，应启用该指令。

### proxy_timeout

|\-|说明|
|:------|:------|
|**语法**|**proxy_timeout** `timeout`;|
|**默认**|proxy_timeout 24h;|
|**上下文**|mail、server|

设置客户端或代理服务器连接上两次连续的读取或写入操作之间的超时（`timeout`）。如果在此时间内没有数据传输，则连接将关闭。

### xclient

|\-|说明|
|:------|:------|
|**语法**|**xclient** `on` &#124; `off`;|
|**默认**|xclient on;|
|**上下文**|mail、server|

连接到 SMTP 后端时，启用或禁用 [XCLIENT](http://www.postfix.org/XCLIENT_README.html) 命令与客户端参数的传递。

借助 `XCLIENT`，MTA 能够将客户端信息写入日志并基于此数据应用各种限制。

如果启用了 `XCLIENT`，则 nginx 在连接到后端时会传递以下命令：

- 附带[服务器名称](ngx_mail_core_module.md#server_name)的 EHLO
- `XCLIENT`
- 由客户传递的 `EHLO` 或 `HELO`

如果客户端 IP 地址[找到](ngx_mail_core_module.md#resolver)的名称指向相同的地址，则会在 `XCLIENT` 命令的 `NAME` 参数中传递该名称。如果找不到名称、指向其他地址或未指定[解析器](ngx_mail_core_module.md#resolver)，则在 `NAME` 参数中传递 `[UNAVAILABLE]`。如果在解析过程中发生错误，则使用 `[TEMPUNAVAIL]` 值。

如果禁用了 `XCLIENT`，则如果客户端已通过 `EHLO`，则 nginx 在连接到后端时将使用[服务器名称](ngx_mail_core_module.md#server_name)传递 EHLO 命令；否则，使用服务器名称传递 `HELO`。

## 原文档

- [http://nginx.org/en/docs/mail/ngx_mail_proxy_module.html](http://nginx.org/en/docs/mail/ngx_mail_proxy_module.html)
