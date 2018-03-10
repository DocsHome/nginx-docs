# ngx_http_auth_basic_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [auth_basic](#auth_basic)
    - [auth_basic_user_file](#auth_basic_user_file)

`ngx_http_auth_basic_module` 模块允许通过使用 **HTTP Basic Authentication** 协议验证用户名和密码来限制对资源的访问。

也可以通过地址、子请求结果或 JWT 来限制访问。可使用 [satisfy](ngx_http_core_module.html#satisfy) 指令通过地址和密码同时限制访问。

<a id="example_configuration"></a>

## 示例配置
```nginx
location / {
    auth_basic           "closed site";
    auth_basic_user_file conf/htpasswd;
}
```

<a id="directives"></a>

## 指令

### auth_basic

|\-|说明|
|:------|:------|
|**语法**|**auth_basic** `string` &#124; `off`;|
|**默认**|auth_basic off;|
|**上下文**|http、server、location、limit_except|

使用 **HTTP Basic Authentication** 协议，启用用户名和密码验证。指定的参数用作为一个 `realm`。参数值可以包含变量（1.3.10、1.2.7）。特殊值 `off` 可以取消从先前配置级别继承的 `auth_basic` 指令的影响。

### auth_basic_user_file

|\-|说明|
|:------|:------|
|**语法**|**auth_basic_user_file** `file`;|
|**默认**|——|
|**上下文**|http、server、location、limit_except|

指定一个用于保存用户名和密码的文件，格式如下：

```
# comment
name1:password1
name2:password2:comment
name3:password3
```

`file` 的名称可以包含变量。

支持以下密码类型：

- 用 `crypt()` 函数加密；可以使用 Apache HTTP Server 分发的或 `openssl passwd` 命令中的 `htpasswd` 工具生成；
- 使用基于 MD5 密码算法（apr1）的 Apache 变体进行散列计算；可以用与上述相同的工具生成；
- [RFC 2307](https://tools.ietf.org/html/rfc2307#section-5.3) 中指定的 `{scheme}data` 语法（1.0.3+）；目前的实现方案包括 `PLAIN`（一个不应该使用的示例）、`SHA`（1.3.13）（简单 SHA-1 散列，不应该使用）和 `SSHA`（一些软件包使用了加盐的 SHA-1 散列，特别是 OpenLDAP 和 Dovecot）。

> 增加了对 SHA 模式的支持，仅用于帮助从其他 Web 服务器迁移。 它不应该用于新密码，因为它使用的未加盐的 SHA-1 散列容易受到[彩虹表](http://en.wikipedia.org/wiki/Rainbow_attack)的攻击。

## 原文档

[http://nginx.org/en/docs/http/ngx_http_auth_basic_module.html](http://nginx.org/en/docs/http/ngx_http_auth_basic_module.html)
