# nginx 如何处理请求

- [基于名称的虚拟服务器](#name_based_virtual_servers)
- [如何使用未定义的 server 名称来阻止处理请求](#how_to_prevent_undefined_server_names)
- [基于名称和 IP 混合的虚拟服务器](#mixed_name_ip_based_servers)
- [一个简单的 PHP 站点配置](#simple_php_site_configuration)

<a id="name_based_virtual_servers"></a>

## 基于名称的虚拟服务器

nginx 首先决定哪个 `server` 应该处理请求，让我们从一个简单的配置开始，三个虚拟服务器都监听了 `*:80` 端口：

```nginx
server {
    listen      80;
    server_name example.org www.example.org;
    ...
}

server {
    listen      80;
    server_name example.net www.example.net;
    ...
}

server {
    listen      80;
    server_name example.com www.example.com;
    ...
}
```

在此配置中，nginx 仅检验请求的 header 域中的 `Host`，以确定请求应该被路由到哪一个 `server`。如果其值与任何的 `server` 名称不匹配，或者该请求根本不包含此 header 域，nginx 会将请求路由到该端口的默认 `server` 中。在上面的配置中，默认 `server` 是第一个（这是 nginx 的标准默认行为）。你也可以在 [listen](http://nginx.org/en/docs/http/ngx_http_core_module.html#listen) 指令中使用 `default_server` 参数，明确地设置默认的 `server`。

```nginx
server {
    listen      80 default_server;
    server_name example.net www.example.net;
    ...
}
```

> `default_server` 参数自 0.8.21 版本起可用。在早期版本中，应该使用 `default` 参数。

请注意，`default_server` 是 `listen port` 的属性，而不是 `server_name` 的。之后会有更多关于这方面的内容。

<a id="how_to_prevent_undefined_server_names"></a>

## 如何使用未定义的 server 名称来阻止处理请求

如果不允许没有 “Host” header 字段的请求，可以定义一个丢弃请求的 server：

```nginx
server {
    listen      80;
    server_name "";
    return      444;
}
```

这里的 `server` 名称设置为一个空字符串，会匹配不带 `Host` 的 header 域请求，nginx 会返回一个表示关闭连接的非标准代码 444。

> 自 0.8.48 版本开始，这是 `server` 名称的默认设置，因此可以省略 `server name ""`。在早期版本中，机器的主机名被作为 `server` 的默认名称。

<a id="mixed_name_ip_based_servers"></a>

## 基于名称和 IP 混合的虚拟服务器

让我们看看更加复杂的配置，其中一些虚拟服务器监听在不同的 IP 地址上监听：

```nginx
server {
    listen      192.168.1.1:80;
    server_name example.org www.example.org;
    ...
}

server {
    listen      192.168.1.1:80;
    server_name example.net www.example.net;
    ...
}

server {
    listen      192.168.1.2:80;
    server_name example.com www.example.com;
    ...
}
```

此配置中，nginx 首先根据 [server](http://nginx.org/en/docs/http/ngx_http_core_module.html#server) 块的 `listen` 指令检验请求的 IP 和端口。之后，根据与 IP 和端口相匹配的 `server` 块的 [server_name](http://nginx.org/en/docs/http/ngx_http_core_module.html#server_name) 项对请求的“Host” header 域进行检验。如果找不到服务器的名称（server_name），请求将由 `default_server` 处理。例如，在 `192.168.1.1:80` 上收到的对 `www.example.com` 的请求将由 `192.168.1.1:80` 端口的 `default_server` （即第一个 server）处理，因为没有 `www.example.com` 在此端口上定义。

如上所述，`default_server` 是 `listen port` 的属性，可以为不同的端口定义不同的 `default_server`：

```nginx
server {
    listen      192.168.1.1:80;
    server_name example.org www.example.org;
    ...
}

server {
    listen      192.168.1.1:80 default_server;
    server_name example.net www.example.net;
    ...
}

server {
    listen      192.168.1.2:80 default_server;
    server_name example.com www.example.com;
    ...
}
```

<a id="simple_php_site_configuration"></a>

## 一个简单的 PHP 站点配置

现在让我们来看看 nginx 是如何选择一个 `location` 来处理典型的简单 PHP 站点的请求：

```nginx
server {
    listen      80;
    server_name example.org www.example.org;
    root        /data/www;

    location / {
        index   index.html index.php;
    }

    location ~* \.(gif|jpg|png)$ {
        expires 30d;
    }

    location ~ \.php$ {
        fastcgi_pass  localhost:9000;
        fastcgi_param SCRIPT_FILENAME
                      $document_root$fastcgi_script_name;
        include       fastcgi_params;
    }
}
```

nginx 首先忽略排序搜索具有最明确字符串的前缀 `location`。在上面的配置中，唯一有符合的是前缀 `location` 为 `/`，因为它匹配任何请求，它将被用作最后的手段。之后，nginx 按照配置文件中列出的顺序检查由 `location` 的正则表达式。第一个匹配表达式停止搜索，nginx 将使用此 `location`。如果没有正则表达式匹配请求，那么 nginx 将使用前面找到的最明确的前缀 `location`。

请注意，所有类型的 `location` 仅仅是检验请求的 URI 部分，不带参数。这样做是因为查询字符串中的参数可以有多种形式，例如：

```
/index.php?user=john&page=1
/index.php?page=1&user=john
```

此外，任何人都可以在查询字符串中请求任何内容：

```
/index.php?page=1&something+else&user=john
```

现在来看看在上面的配置中是如何请求的：
- 请求 `/logo.gif` 首先与 前缀 `location` 为 `/` 相匹配，然后由正则表达式 `\.(gif|jpg|png)$` 匹配，因此由后一个 `location` 处理。使用指令 `root /data/www` 将请求映射到 `/data/www/logo.gif` 文件，并将文件发送给客户端。
- 一个 `/index.php` 的请求也是首先与前缀 `location` 为 `/` 相匹配，然后是正则表达式 `\.(php)$`。因此，它由后一个 `location` 处理，请求将被传递给在 `localhost:9000` 上监听的 FastCGI 服务器。[fastcgi_param](http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html#fastcgi_param) 指令将 FastCGI 参数 `SCRPT_FILENAME` 设置为 `/data/www/index.php`，FastCGI 服务器执行该文件。变量 `$document_root` 与 [root](http://nginx.org/en/docs/http/ngx_http_core_module.html#root) 指令的值是一样的，变量 `$fastcgi_script_name` 的值为请求URI，即 `/index.php`。
- `/about.html` 请求仅与前缀 `location` 为 `/` 相匹配，因此由此 `location` 处理。使用指令 `root /data/www` 将请求映射到 `/data/www/about.html` 文件，并将文件发送给客户端。
- 处理请求 `/` 更复杂。它与前缀 `location` 为 `/` 相匹配。因此由该 `location` 处理。然后，[index](http://nginx.org/en/docs/http/ngx_http_index_module.html#index) 指令根据其参数和 `root /data/www` 指令检验索引文件是否存在。如果文件 `/data/www/index.html` 不存在，并且文件 `/data/www/index.php` 存在，则该指令执行内部重定向到 `/index.php`，就像请求是由客户端发起的，nginx 将再次搜索 `location`。如之前所述，重定向请求最终由 FastCGI 服务器处理。

由 Igor Sysoev 撰写
由 Brian Mercer 编辑

## 原文

- [http://nginx.org/en/docs/http/request_processing.html](http://nginx.org/en/docs/http/request_processing.html)
