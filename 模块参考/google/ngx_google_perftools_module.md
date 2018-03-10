# ngx_google_perftools_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [google_perftools_profiles](#google_perftools_profiles)

`ngx_google_perftoos_module` 模块（0.6.29）可以使用 [Google 性能工具](https://github.com/gperftools/gperftools) 对 nginx 的 worker 进程进行分析。该模块适用于 nginx 开发人员。

默认情况下不构建此模块，您可以在构建时使用 `--with-google_perftools_module` 配置参数启用此模块。

> 该模块需要 [gperftools](https://github.com/gperftools/gperftools) 库。

<a id="example_configuration"></a>

## 示例配置

```nginx
google_perftools_profiles /path/to/profile;
```

profile 文件将被存储为 `/path/to/profile.<worker_pid>`。

<a id="directives"></a>

## 指令

### google_perftools_profiles

|\-|说明|
|------:|------|
|**语法**|**google_perftools_profiles** `file ...`;|
|**默认**|——|
|**上下文**|main|

设置保存 nginx worker 进程分析信息的文件的名名。worker 进程的 ID 始终是文件名的一部分，并追加在文件名的末尾。

## 原文档
[http://nginx.org/en/docs/ngx_google_perftools_module.html](http://nginx.org/en/docs/ngx_google_perftools_module.html)