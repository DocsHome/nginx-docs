# ngx_http_auth_jwt_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [auth_jwt](#auth_jwt)
    - [auth_jwt_header_set](#auth_jwt_header_set)
    - [auth_jwt_claim_set](#auth_jwt_claim_set)
    - [auth_jwt_key_file](#auth_jwt_key_file)
- [内嵌变量](#embedded_variables)

`ngx_http_auth_jwt_module` 模块（1.11.3）通过验证使用指定的密钥提供的 [JSON Web Token](https://tools.ietf.org/html/rfc7519)（JWT）来实现客户端授权。JWT claims 必须以 [JSON Web Signature](https://tools.ietf.org/html/rfc7515)（JWS）结构编码。该模块可用于 [OpenID Connect](http://openid.net/specs/openid-connect-core-1_0.html) 身份验证。

该模块可以通过 [satisfy](ngx_http_core_module.md#satisfy) 指令与其他访问模块（如 [ngx_http_access_module](ngx_http_access_module.md)、[ngx_http_auth_basic_module](ngx_http_auth_basic_module.md) 和 [ngx_http_auth_request_module](ngx_http_auth_request_module.md)）进行组合。

> 此模块可作为我们商业订阅的一部分。

<a id="example_configuration"></a>

## 示例配置
```nginx
location / {
    auth_jwt          "closed site";
    auth_jwt_key_file conf/keys.json;
}
```

<a id="directives"></a>

## 指令

### auth_jwt

|\-|说明|
|:------|:------|
|**语法**|**auth_jwt** `string [token=$variable]` &#124; `off`;|
|**默认**|auth_jwt off;|
|**上下文**|http、server、location|

启用 JSON Web Token 验证。指定的字符串作为一个 `realm`。参数值可以包含变量。

可选的 `token` 参数指定一个包含 JSON Web Token 的变量。默认情况下，JWT 作 [Bearer Token](https://tools.ietf.org/html/rfc6750) 在 **Authorization** 头中传递。JWT 也可以作为 cookie 或查询字符串的一部分传递：

```nginx
auth_jwt "closed site" token=$cookie_auth_token;
```

特殊值 `off` 取消从上一配置级别继承的 `auth_jwt` 指令的作用。

### auth_basic_user_file

|\-|说明|
|:------|:------|
|**语法**|**auth_jwt_header_set** `$variable name`;|
|**默认**|——|
|**上下文**|http|
|**提示**|该指令在 1.11.10 版本中出现|

将 `variable` 设置为给定的 JOSE 头参数 `name`。

### auth_jwt_claim_set

|\-|说明|
|:------|:------|
|**语法**|**auth_jwt_claim_set** `$variable name`;|
|**默认**|——|
|**上下文**|http|
|**提示**|该指令在 1.11.10 版本中出现|

将 `variable` 设置为给定的 JWT claim 参数 `name`。

### auth_jwt_key_file

|\-|说明|
|:------|:------|
|**语法**|**auth_jwt_key_file** `file`;|
|**默认**|——|
|**上下文**|http、server、location|

指定用于验证 JWT 签名的 [JSON Web Key Set](https://tools.ietf.org/html/rfc7517#section-5) 格式的 `file`（文件）。参数值可以包含变量。

<a id="embedded_variables"></a>

## 内嵌变量

`ngx_http_auth_jwt_module` 模块支持内嵌变量：

- `$jwt_header_name`

    返回 [JOSE 头](https://tools.ietf.org/html/rfc7515#section-4)的值
- `$jwt_claim_name`

    返回 [JWT claim](https://tools.ietf.org/html/rfc7519#section-4) 的值

## 原文档
[http://nginx.org/en/docs/http/ngx_http_auth_jwt_module.html](http://nginx.org/en/docs/http/ngx_http_auth_jwt_module.html)
