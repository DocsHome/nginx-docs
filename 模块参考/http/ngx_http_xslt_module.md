# ngx_http_xslt_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [xml_entities](#xml_entities)
    - [xslt_last_modified](#xslt_last_modified)
    - [xslt_param](#xslt_param)
    - [xslt_string_param](#xslt_string_param)
    - [xslt_stylesheet](#xslt_stylesheet)
    - [xslt_types](#xslt_types)

`ngx_http_xslt_module`（0.7.8+）是一个过滤器，可使用一个或多个 XSLT 样式表来转换 XML 响应。

默认不构建此模块，可在构建时使用 `--with-http_xslt_module` 配置参数启用。

> 该模块雨来 [libxml2](http://xmlsoft.org/) 和 [libxslt](http://xmlsoft.org/XSLT/) 库。

<a id="example_configuration"></a>

## 示例配置

```nginx
location / {
    xml_entities    /site/dtd/entities.dtd;
    xslt_stylesheet /site/xslt/one.xslt param=value;
    xslt_stylesheet /site/xslt/two.xslt;
}
```

<a id="directives"></a>

## 指令

### xml_entities

|\-|说明|
|:------|:------|
|**语法**|**xml_entities** `path`;|
|**默认**|——|
|**上下文**|http、server、location|

指定声明字符实体的 DTD 文件。该文件在配置阶段编译。出于技术原因，该模块无法在已处理的 XML 中使用外部子集声明，因此将其忽略，可使用专门定义的文件。该文件不应描述 XML 结构。仅声明所需的字符实体就足够了，例如：

```
<!ENTITY nbsp "&#xa0;">
```

### xslt_last_modified

|\-|说明|
|:------|:------|
|**语法**|**xslt_last_modified** `on` &#124; `off`;|
|**默认**|xslt_last_modified off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.5.1 版本中出现|

允许在 XSLT 转换期间保留原始响应中的 `Last-Modified` 头字段，以方便响应缓存。

默认情况下，在转换期间修改响应的内容时，将删除头字段，并且该头字段可能包含动态生成的元素或片段，这些元素或片段独立于原始响应更改。

### xslt_param

|\-|说明|
|:------|:------|
|**语法**|**xslt_param** `parameter value`;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 1.1.18 版本中出现|

定义 XSLT 样式表的参数。该值（`value`）为 XPath 表达式。`value` 可以包含变量。要将字符串值传递给样式表，可使用 [xslt_string_param](#xslt_string_param) 指令。

可以有多个 `xslt_param` 指令。当且仅当当前级别上没有定义 `xslt_param` 和 [xslt_string_param](#xslt_string_param) 指令时，这些指令才从上一级继承。

### xslt_string_param

|\-|说明|
|:------|:------|
|**语法**|**xslt_string_param** `parameter value`;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 1.1.18 版本中出现|

定义 XSLT 样式表的字符串参数。`value` 中的 XPath 表达式不会被解释。`value` 可以包含变量。

可以有多个 `xslt_string_param` 指令。当且仅当当前级别上没有定义 [xslt_param](#xslt_param) 和 `xslt_string_param` 指令时，这些指令才从上一级继承。

### xslt_stylesheet

|\-|说明|
|:------|:------|
|**语法**|**xslt_stylesheet** `stylesheet [parameter=value ...]`;|
|**默认**|——|
|**上下文**|http、server、location|

定义 XSLT 样式表及其可选参数。在配置阶段将编译样式表。

可以单独指定参数，也可以使用 `:` 定界符将其分组在一行中。如果参数包含 `:` 字符，则应将其转义为 `％3A`。另外，`libxslt` 要求将包含非字母数字字符的参数括在单引号或双引号中，例如：

```
param1='http%3A//www.example.com':param2=value2
```

参数描述可以包含变量，例如，整行参数可以取自单个变量：

```nginx
location / {
    xslt_stylesheet /site/xslt/one.xslt
                    $arg_xslt_params
                    param1='$value1':param2=value2
                    param3=value3;
}
```

可以指定多个样式表。它们将按指定顺序应用。

### xslt_types

|\-|说明|
|:------|:------|
|**语法**|**xslt_types** `mime-type ...`;|
|**默认**|xslt_types text/xml;|
|**上下文**|http、server、location|

除了 `text/xml` 之外，还启用有指定 MIME 类型的响应的转换。特殊值 `*` 与任何 MIME 类型（0.8.29）匹配。如果转换结果是 HTML 响应，则其 MIME 类型将更改为 `text/html`。

## 原文档

- [http://nginx.org/en/docs/http/ngx_http_xslt_module.html](http://nginx.org/en/docs/http/ngx_http_xslt_module.html)
