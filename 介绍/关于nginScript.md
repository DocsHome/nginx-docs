# 关于 nginScript

nginScript 是 JavaScript 语言的一个子集，其可在 [http](http://nginx.org/en/docs/http/ngx_http_js_module.html) 和 [stream](http://nginx.org/en/docs/stream/ngx_stream_js_module.html) 中实现位置（location）和变量处理器。nginScript 符合 [ECMAScript 5.1](http://www.ecma-international.org/ecma-262/5.1/) 规范和部分 [ECMAScript 6](http://www.ecma-international.org/ecma-262/6.0/) 扩展。合规性仍在不断发展。

## 目前支持什么
- 布尔值、数字、字符串、对象、数组、函数和正则表达式
- ES5.1 运算符，ES7 幂运算符
- ES5.1语句：`var`、`if`、`else`、`switch`、`for`、`for in`、`while`、`do while`、`break`、`continue`、`return`、`try`、`catch`、`throw`、`finally`
- ES6 `Number` 和 `Math` 的属性和方法
- `String` 方法：
    - ES5.1：`fromCharCode`、`concat`、`slice`、`substring`、`substr`、`charAt`、`charCodeAt`、`indexOf`、`lastIndexOf`、`toLowerCase`、`toUpperCase`、`trim`、`search`、`match`、`split`、`replace`
    - ES6：`fromCodePoint`、`codePointAt`、`includes`、`startsWith`、`endsWith`、`repeat`
    - 非标准：`fromUTF8`、`toUTF8`、`fromBytes`、`toBytes`
- `Object` 方法：
    - ES5.1：`create`（不支持属性列表），`keys`、`defineProperty`、`defineProperties`、`getOwnPropertyDescriptor`、`getPrototypeOf`、`hasOwnProperty`、`isPrototypeOf`、`preventExtensions`、`isExtensible`、`freeze`、`isFrozen`、`seal`、`isSealed`
- `Array` 方法：
    - ES5.1：`isArray`、`slice`、`splice`、`push`、`pop`、`unshift`、`shift`、`reverse`、`sort`、`join`、`concat`、`indexOf`、`lastIndexOf`、`forEach`、`some`、`every`、`filter`、`map`、`reduce`、`reduceRight`
    - ES6：`of`、`fill`、`find`、`findIndex`
    - ES7：`includes`
- ES5.1 `Function` 方法：`call`、`apply`、`bind`
- ES5.1 `RegExp` 方法：`test`、`exec`
- ES5.1 `Date` 方法
- ES5.1 全局函数：`isFinite`、`isNaN`、`parseFloat`、`parseInt`、`decodeURI`、`decodeURIComponent`、`encodeURI`、`encodeURIComponent`

## 还不支持什么
- ES6 `let` 和 `const` 声明
- 标签
- `arguments` 数组
- `eval` 函数
- `JSON` 对象
- `Error` 对象
- `setTimeout`、`setInterval`、`setImmediate` 函数
- 非整数分数（.235），二进制（0b0101），八进制（0o77）字面量

## 下载与安装
nginScript 可用于以下两个模块：

- [ngx_http_js_module](http://nginx.org/en/docs/http/ngx_http_js_module.html)
- [ngx_stream_js_module](http://nginx.org/en/docs/stream/ngx_stream_js_module.html)

这两个模块都不是默认构建的，它们应该从源文件中编译或者作为一个 Linux 软件包来安装

## Linux 包安装方式
在 Linux 环境中，可以使用 nginScript 模块[包](http://nginx.org/en/linux_packages.html#dynmodules)：

- `nginx-module-njs` - nginScript [动态模块](http://nginx.org/en/docs/ngx_core_module.html#load_module)
- `nginx-module-njs-dbg` - `nginx-module-njs` 包的调试符号

## 源码构建方式
可以使用以下命令克隆 nginScript 的源码[仓库](http://hg.nginx.org/njs?_ga=2.71762323.1468443122.1505551652-1890203964.1497190280)：（需要 [Mercurial](https://www.mercurial-scm.org/) 客户端）：

```bash
hg clone http://hg.nginx.org/njs
```

然后使用 `--add-module` 配置参数进行编译模块：

```bash
./configure --add-module=path-to-njs/nginx
```

该模块也可以构建为[动态的](http://nginx.org/en/docs/ngx_core_module.html#load_module)：

```bash
./configure --add-dynamic-module=path-to-njs/nginx
```

## 原文档

[http://nginx.org/en/docs/njs_about.html](http://nginx.org/en/docs/njs_about.html)
