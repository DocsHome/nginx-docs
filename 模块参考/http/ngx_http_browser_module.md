# ngx_http_browser_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [ancient_browser](#ancient_browser)
    - [ancient_browser_value](#ancient_browser_value)
    - [modern_browser](#modern_browser)
    - [modern_browser_value](#modern_browser_value)


`ngx_http_browser_module` 模块创建值由 **User-Agent** 请求头域决定的变量：

- `$modern_browser`

    如果浏览器被识别为现代，则等于 [modern_browser_value](#modern_browser_value) 指令设置的值
- `$ancient_browser`

    如果浏览器被识别为古代，则等于由 [ancient_browser_value](#ancient_browser_value) 指令设置的值

- `$MSIE`

    如果浏览器被识别为任何版本的 MSIE，则等于 `1`

<a id="example_configuration"></a>

## 示例配置
选择一个索引文件：

```nginx
modern_browser_value "modern.";

modern_browser msie      5.5;
modern_browser gecko     1.0.0;
modern_browser opera     9.0;
modern_browser safari    413;
modern_browser konqueror 3.0;

index index.${modern_browser}html index.html;
```

旧浏览器重定向：

```nginx
modern_browser msie      5.0;
modern_browser gecko     0.9.1;
modern_browser opera     8.0;
modern_browser safari    413;
modern_browser konqueror 3.0;

modern_browser unlisted;

ancient_browser Links Lynx netscape4;

if ($ancient_browser) {
    rewrite ^ /ancient.html;
}
```

<a id="directives"></a>

## 指令

### ancient_browser

|\-|说明|
|------:|------|
|**语法**|**ancient_browser** `string ...`;|
|**默认**|——|
|**上下文**|http、server、location|

如果在 **User-Agent** 请求头域中找到任何特殊的子字符串，浏览器将被视为传统类型。特殊字符串 `netscape4` 对应于正则表达式`^Mozilla/[1-4]`。

### ancient_browser_value

|\-|说明|
|------:|------|
|**语法**|**ancient_browser_value** `string`;|
|**默认**|ancient_browser_value 1;|
|**上下文**|http、server、location|

设置 `$ancient_browser` 变量的值。

### modern_browser

|\-|说明|
|------:|------|
|**语法**|**modern_browser** `browser version`; <br /> **modern_browser** `unlisted`;|
|**默认**|——|
|**上下文**|http、server、location|

指定将浏览器视为现代版本开始的版本。浏览器可以是以下任何一种：`msie`、`gecko`（基于 Mozilla 的浏览器）、`opera`、`safari` 或 `konqueror`。

版本可以是以下列格式：X、X.X、X.X.X 或 X.X.X.X。每种格式的最大值分别为 4000、4000.99、4000.99.99 和 4000.99.99.99。

未列出的特殊值如果未被 `modern_browser` 和 [ancient_browser](#ancient_browser) 指令指定，则将其视为现代浏览器。否则被认为是传统浏览器。如果请求没有在头中提供 **User-Agent** 域，则浏览器被视为未列出。

### modern_browser_value

|\-|说明|
|------:|------|
|**语法**|**modern_browser_value** `string`;|
|**默认**|modern_browser_value 1;|
|**上下文**|http、server、location|

设置 `$modern_browser` 变量的值。

## 原文档
[http://nginx.org/en/docs/http/ngx_http_browser_module.html](http://nginx.org/en/docs/http/ngx_http_browser_module.html)