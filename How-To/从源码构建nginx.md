# 从源码构建 nginx

编译时使用 `configure` 命令进行配置。它定义了系统的各个方面，包括了 nginx 进行连接处理使用的方法。最终它会创建出一个 `Makefile`。`configure` 命令支持以下参数：

- **--prefix=path**

    定义一个用于保留服务器文件的目录。此目录也将用于所有通过 `configure` 设置的相对路径（除了库源码路径外）和 `nginx.conf` 配置文件。默认设置为 `/usr/local/nginx` 目录。
- **--sbin-path=path**

    设置 nginx 可执行文件的名称。此名称仅在安装过程中使用。默认情况下，文件名为 `prefix/sbin/nginx`。
- **--conf-path=path**

    设置 `nginx.conf` 配置文件的名称。如果需要，nginx 可以使用不同的配置文件启动，方法是使用命令行参数 `-c` 指定文件。默认情况下，文件名为 `prefix/conf/nginx.conf`。
- **--pid-path=path**

    设置存储主进程的进程 ID 的 nginx.pid 文件名称。安装后，可以在 `nginx.conf` 配置文件中使用 [pid](http://nginx.org/en/docs/ngx_core_module.html#pid) 指令更改文件名。默认文件名为 `prefix/logs/nginx.pid`。
- **--lock-path=path**

    设置锁文件的名称前缀。安装后，可以在 `nginx.conf` 配置文件中使用 [lock_file](http://nginx.org/en/docs/ngx_core_module.html#lock_file) 指令更改对应的值。默认值为 `prefix/logs/nginx.lock`。
- **--error-log-path=path**

    设置主要错误、警告和诊断文件的名称。安装后，可以在 `nginx.conf` 配置文件中使用 [error_log](http://nginx.org/en/docs/ngx_core_module.html#error_log) 指令更改文件名。默认情况下，文件名为 `prefix/logs/error.log`。
- **--http-log-path=path**

    设置 HTTP 服务器主请求日志文件名称。安装后，可以在 `nginx.conf` 配置文件中使用 [access_log](http://nginx.org/en/docs/http/ngx_http_log_module.html#access_log) 指令更改文件名。默认情况下，文件名为 `prefix/logs/access.log`。
- **--build=name**

    设置一个可选的 nginx 构建名称
- **--user=name**

    设置一个非特权用户名称，其凭据将由工作进程使用。安装后，可以在 `nginx.conf` 配置文件中使用 [user](http://nginx.org/en/docs/ngx_core_module.html#user) 指令更改名称。默认的用户名为 `nobody`。
- **--group=name**

    设置一个组的名称，其凭据将由工作进程使用。安装后，可以在 `nginx.conf` 配置文件中使用 [user](http://nginx.org/en/docs/ngx_core_module.html#user) 指令更改名称。默认情况下，组名称设置为一个非特权用户的名称。
- **--with-select_module 和 --without-select_module**

    启用或禁用构建允许服务器使用 `select()` 方法的模块。如果平台不支持其他更合适的方法（如 kqueue、epoll 或 /dev/poll），则将自动构建该模块。
- **--with-poll_module 和 --without-poll_module**

    启用或禁用构建允许服务器使用 `poll()` 方法的模块。如果平台不支持其他更合适的方法（如 kqueue、epoll 或 /dev/poll），则将自动构建该模块。
- **with-threads**
    
    允许使用线程池[thread pools](http://nginx.org/en/docs/ngx_core_module.html#thread_pool)
- **with-file-aio**

    启用在FreeBSD和Linux上[asynchronous file I/O](http://nginx.org/en/docs/http/ngx_http_core_module.html#aio) (aio)指令的使用
- **--without-http_gzip_module**

    禁用构建 HTTP 服务器[响应压缩](http://nginx.org/en/docs/http/ngx_http_gzip_module.html)模块。需要 zlib 库来构建和运行此模块。
- **--without-http_rewrite_module**

    禁用构建允许 HTTP 服务器[重定向请求](http://nginx.org/en/docs/http/ngx_http_rewrite_module.html)和[更改请求 URI](http://nginx.org/en/docs/http/ngx_http_rewrite_module.html) 的模块。需要 PCRE 库来构建和运行此模块。
- **--without-http_proxy_module**

    禁用构建 HTTP 服务器[代理模块](http://nginx.org/en/docs/http/ngx_http_proxy_module.html)。
- **--with-http_ssl_module**

    允许构建可将 [HTTPS 协议支持](http://nginx.org/en/docs/http/ngx_http_ssl_module.html)添加到 HTTP 服务器的模块。默认情况下，此模块参与构建。构建和运行此模块需要 OpenSSL 库支持。
- **with-http_v2_module**

    允许构建一个支持[HTTP/2](http://nginx.org/en/docs/http/ngx_http_v2_module.html) 的模块。默认情况下，该模块不构建。
- **with-http_realip_module**
    
    允许构建[ngx_http_realip_module](http://nginx.org/en/docs/http/ngx_http_realip_module.html) 模块，该模块将客户端地址更改为在指定的header中发送的地址。该模块默认不构建。
- **with-http_addition_module**

    允许构建[ngx_http_addition_module](http://nginx.org/en/docs/http/ngx_http_addition_module.html) 模块，该模块能够在响应之前和之后添加文本。该模块默认不构建。
- **with-http_xslt_module**和**with-http_xslt_module=dynamic**

    允许构建使用一个或者多个XSLT样式表转化为XML响应的[ngx_http_xslt_module](http://nginx.org/en/docs/http/ngx_http_xslt_module.html)。该模块默认不构建。[libxslt](http://xmlsoft.org/XSLT/) 和 [libxml2](http://xmlsoft.org/) 库需要这个模块来构建和启动。
- **with-http_image_filter_module**和**with-http_image_filter_module=dynamic**

    允许构建[ngx_http_image_filter_module](http://nginx.org/en/docs/http/ngx_http_image_filter_module.html) 模块，该模块可以转换 JPEG, GIF, PNG, 和 WebP 格式的图片。该模块默认不构建。
- **with-http_geoip_module**和**with-http_geoip_module=dynamic**
    
    允许构建[ngx_http_geoip_module](http://nginx.org/en/docs/http/ngx_http_geoip_module.html) 模块。该模块根据客户端 IP 地址和预编译[MaxMind](https://www.maxmind.com/en/home) 的数据库创建变量。该模块默认不构建。
- **with-http_sub_module**

    允许构建[ngx_http_sub_module](http://nginx.org/en/docs/http/ngx_http_sub_module.html) 模块。该模块通过将一个指定的字符串替换为另一个来修改相应。该模块默认不构建。
- **with-http_dav_module**
    
    允许构建[ngx_http_dav_module ](http://nginx.org/en/docs/http/ngx_http_dav_module.html) 模块。该模块通过WebDEV协议提供文件管理自动化。该模块默认不构建。
- **with-http_flv_module**
    
    允许构建[ngx_http_flv_module](http://nginx.org/en/docs/http/ngx_http_flv_module.html) 模块。该模块为 Flash Videos (FLV) 文件提供伪流服务器端的支持。该模块默认不构建。
- **with-http_mp4_module**
    
    允许构建[ngx_http_mp4_module](http://nginx.org/en/docs/http/ngx_http_mp4_module.html) 模块。该模块为 MP4 文件提供伪流服务器端的支持。该模块默认不构建。
- **with-http_gunzip_module**
    
    允许构建[ngx_http_gunzip_module](http://nginx.org/en/docs/http/ngx_http_gunzip_module.html) 模块。该模块使用 `Content-Encoding: gzip` 来解压缩响应对于那些不支持`gzip`编码方法的客户端。该模块默认不构建。
- **with-http_auth_request_module**
    
    允许构建[ngx_http_auth_request_module](http://nginx.org/en/docs/http/ngx_http_auth_request_module.html) 模块。该模块基于子请求的结果实现客户端授权。该模块默认不构建。
- **with-http_random_index_module**
    
    允许构建[ngx_http_random_index_module](http://nginx.org/en/docs/http/ngx_http_random_index_module.html) 模块。该模块处理斜杠字符 ('/') 结尾的请求，并选择目录中的随机文件作为索引文件。该模块默认不构建。
- **with-http_secure_link_module**
    
    允许构建[ngx_http_secure_link_module](http://nginx.org/en/docs/http/ngx_http_secure_link_module.html) 模块。该模块默认不构建。
- **with-http_degradation_module**
    
    允许构建 `with-http_degradation_module` 模块。该模块默认不构建。
- **with-http_slice_module**
    
    允许构建[ngx_http_slice_module](http://nginx.org/en/docs/http/ngx_http_slice_module.html) 将请求拆分为子请求的模块，每个模块都返回一定范围的响应。该模块提供了更有效的大响应缓存。该模块默认不构建。
- **with-http_stub_status_module**
    
    允许构建[ngx_http_stub_status_module](http://nginx.org/en/docs/http/ngx_http_stub_status_module.html) 模块。该模块提供对基本状态信息的访问。该模块默认不构建。
- **without-http_charset_module**
    
    禁用构建压缩 HTTP 响应的[ngx_http_charset_module](http://nginx.org/en/docs/http/ngx_http_charset_module.html) 模块。该模块将指定的字符集添加到 `Content-Type` 响应头字段，还可以将数据从一个字符集转化为另一个字符集。
- **without-http_gzip_module**
    
    禁用构建压缩 HTTP 响应的[compresses responses](http://nginx.org/en/docs/http/ngx_http_gzip_module.html) 模块。构建和运行这个模块需要 zlib 库。
- **without-http_ssi_module**
    
    禁用构建[without-http_ssi_module](http://nginx.org/en/docs/http/ngx_http_gzip_module.html) 模块。该模块在通过它的响应中处理 SSI (服务端包含) 命令。
- **without-http_userid_module**
    
    允许构建[ngx_http_userid_module](http://nginx.org/en/docs/http/ngx_http_userid_module.html) 模块。该模块设置适合客户端识别的cookie。
- **without-http_access_module**
    
    禁用构建[ngx_http_access_module](http://nginx.org/en/docs/http/ngx_http_access_module.html) 模块。该模块允许限制对某些客户端地址的访问。
- **without-http_auth_basic_module**
 
    禁用构建[ngx_http_auth_basic_module](http://nginx.org/en/docs/http/ngx_http_auth_basic_module.html) 模块。该模块允许通过使用HTTP基本身份验证协议验证用户名密码来限制对资源的访问。
- **without-http_mirror_module**
 
    禁用构建[ngx_http_mirror_module](http://nginx.org/en/docs/http/ngx_http_mirror_module.html) 模块。该模块通过创建后台镜像子请求来实现原始请求的镜像。
- **without-http_autoindex_module**
 
    禁用构建[ngx_http_autoindex_module](http://nginx.org/en/docs/http/ngx_http_autoindex_module.html) 模块。该模块处理以斜杠('/')结尾的请求，并在[ngx_http_index_module](http://nginx.org/en/docs/http/ngx_http_index_module.html) 模块找不到索引文件的情况下生成目录列表。
- **without-http_geo_module**
 
    禁用构建[ngx_http_geo_module](http://nginx.org/en/docs/http/ngx_http_geo_module.html) 模块。该模块使用取决于客户端IP地址的值创建变量。
- **without-http_map_module**
 
    禁用构建[ngx_http_map_module](http://nginx.org/en/docs/http/ngx_http_map_module.html) 模块。该模块使用取决于其他变量的值创建变量。
- **without-http_split_clients_module**
 
    禁用构建[ngx_http_split_clients_module](http://nginx.org/en/docs/http/ngx_http_split_clients_module.html) 模块。该模块为 A/B 测试创建变量。
- **without-http_referer_module**
 
    禁用构建[ngx_http_referer_module](http://nginx.org/en/docs/http/ngx_http_referer_module.html) 模块。该模块可以阻止对 “Referer” 头字段中具有无效值的请求访问站点。
- **without-http_proxy_module**
 
    禁用构建允许HTTP服务器重定向的请求和更改请求URI [redirect requests and change URI of requests](http://nginx.org/en/docs/http/ngx_http_rewrite_module.html) 的模块。
- **without-http_proxy_module**
 
    禁用构建[proxying module](http://nginx.org/en/docs/http/ngx_http_proxy_module.html) HTTP服务器代理模块。 
- **without-http_fastcgi_module**
 
    禁用构建将请求传递给FastCGI服务器的[ngx_http_fastcgi_module](http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html)模块。
- **without-http_uwsgi_module**
 
    禁用构建将请求传递给uwsgi服务器的[ngx_http_uwsgi_module](http://nginx.org/en/docs/http/ngx_http_uwsgi_module.html) 模块。
- **without-http_scgi_module**
 
    禁用构建将请求传递给SCGI服务器的[ngx_http_scgi_module](http://nginx.org/en/docs/http/ngx_http_scgi_module.html) 模块。
- **without-http_grpc_module**
 
    禁用构建将请求传递给个RPC服务器[ngx_http_grpc_module](http://nginx.org/en/docs/http/ngx_http_grpc_module.html) 模块。
- **without-http_memcached_module**
 
    禁用构建[ngx_http_memcached_module](http://nginx.org/en/docs/http/ngx_http_memcached_module.html) 模块。该模块从 memcached 服务器获得响应。
- **without-http_limit_conn_module**
 
    禁用构建[ngx_http_limit_conn_module](http://nginx.org/en/docs/http/ngx_http_limit_conn_module.html) 模块。该模块限制每个密钥的链接数，例如，来自单个IP地址的链接数。
- **without-http_limit_req_module**
 
    禁用构建限制每个键的请求处理速率[ngx_http_limit_req_module](http://nginx.org/en/docs/http/ngx_http_limit_req_module.html) 模块。例如，来自单个IP地址的请求的处理速率。
- **without-http_empty_gif_module**
 
    禁用构建发出单像素透明GIF[emits single-pixel transparent GIF](http://nginx.org/en/docs/http/ngx_http_empty_gif_module.html) 模块。
- **without-http_browser_module**
 
    禁用构建[ngx_http_browser_module](http://nginx.org/en/docs/http/ngx_http_browser_module.html) 模块。该模块创建的值的变量取决于 “User-Agent” 请求标头字段的值。
- **without-http_upstream_hash_module**
 
    禁用构建实现散列负载均衡的方法[hash](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#hash) 模块。  
- **without-http_upstream_ip_hash_module**
 
    禁用构建实现[IP_Hash](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#ip_hash) 负载均衡方法的模块。 
- **without-http_upstream_least_conn_module**
 
    禁用构建实现[least_conn](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#least_conn) 负载均衡方法的模块。 
- **without-http_upstream_keepalive_module**
 
    禁用构建[caching of connections](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#keepalive) 模块。该模块提供到上游服务器的链接缓存。 
- **without-http_upstream_zone_module**
 
    禁用构建[zone](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#zone) 模块。该模块可以将上游组的运行时状态存储在共享内存区域中。 
- **with-http_perl_module**和**with-http_perl_module=dynamic**
 
    构建[嵌入式Perl](http://nginx.org/en/docs/http/ngx_http_perl_module.html) 模块。该模块默认不构建。 
- **--with-perl_modules_path=path**
 
    定义一个保留Perl模块的路径。 
- **with-perl=path**
 
    设置Perl二进制文件的名字。 
- **http-client-body-temp-path**
 
    定义用于存储保存客户端的请求主体的临时文件的目录。安装后，可以使用[client_body_temp_path](http://nginx.org/en/docs/http/ngx_http_core_module.html#client_body_temp_path) 指令在nginx.conf配置文件中始终更改目录。默认的目录名为 `prefix/client_body_temp`。 
- **http-proxy-temp-path=path**
 
    定义一个目录，用于存储临时文件和从代理服务器接受的数据。安装后可以使用[proxy_temp_path](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_temp_path) 指令在nginx.conf配置文件中更改。默认的目录名为 `profix/proxy_temp`
- **http-fastcgi-temp-path=path**
 
    定义一个目录，用于存储临时文件和从 FastCGI 服务器接受的数据。安装后可以使用[fastcgi_temp_path](http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html#fastcgi_temp_path) 指令在nginx.conf配置文件中更改。 默认的目录为 `prefix/fastcgi_temp`
- **http-uwsgi-temp-path=path**
 
    定义一个目录，用于存储临时文件和从 uwsgi  服务器接受的数据。安装后可以使用[uwsgi_temp_path](http://nginx.org/en/docs/http/ngx_http_uwsgi_module.html#uwsgi_temp_path) 指令在nginx.conf配置文件中更改。 默认的目录为 `prefix/uwsgi_temp`
- **http-scgi-temp-path=path**
 
    定义一个目录，用于存储临时文件和从 SCGI 服务器接受的数据。安装后可以使用[scgi_temp_path](http://nginx.org/en/docs/http/ngx_http_scgi_module.html#scgi_temp_path) 指令在nginx.conf配置文件中更改。 默认的目录为 `prefix/scgi_temp`
- **without-http**
 
    禁用构建[HTTP](http://nginx.org/en/docs/http/ngx_http_core_module.html) 模块。 
- **without-http-cache**
 
    禁用 HTTP 缓存。                                                                                                           
- **with-mail**和**with-mail=dynamic**
 
    启用构建 POP3/IMAP4/SMTP [mail proxy](http://nginx.org/en/docs/mail/ngx_mail_core_module.html) 模块。
- **with-mail_ssl_module**
 
    启用构建[SSL/TLS protocol support](http://nginx.org/en/docs/mail/ngx_mail_ssl_module.html) 模块，将SSL/TLS协议支持添加到邮件代理服务器。默认不构建此模块。需要OpenSSL库来构建和运行此模块。
- **without-mail_pop3_module**
 
    禁用邮件代理服务器中的[POP3](http://nginx.org/en/docs/mail/ngx_mail_pop3_module.html) 协议。
- **without-mail_imap_module**
 
    禁用邮件代理服务器中的[IMAP](http://nginx.org/en/docs/mail/ngx_mail_imap_module.html) 协议。
- **without-mail_smtp_module**
 
    禁用邮件代理服务器中的[SMTP](http://nginx.org/en/docs/mail/ngx_mail_smtp_module.html) 协议。
- **with-stream**和**with-stream=dynamic**
 
    启用构建[流模块](http://nginx.org/en/docs/stream/ngx_stream_core_module.html) 模块以进行通用的 TCP/UDP 代理和负载均衡。该模块默认不构建。
- **with-stream_ssl_module**
 
    启用构建[SSL/TLS protocol support](http://nginx.org/en/docs/stream/ngx_stream_ssl_module.html) 模块。为流模块添加SSL/TLS协议支持。默认不构建此模块。需要OpenSSL库来构建和运行此模块。
- **with-stream_realip_module**
 
    启用构建[ngx_stream_realip_module](http://nginx.org/en/docs/http/ngx_stream_realip_module.html) 模块。该模块将客户端地址更改为 PROXY 协议头中发送的地址。默认不构建此模块。
- **with-stream_geoip_module**和**with-stream_geoip_module=dynamic**
 
    启用构建[ngx_stream_geoip_module](http://nginx.org/en/docs/stream/ngx_stream_geoip_module.html) 模块。该模块根据客户端地址和预编译的[MaxMind](http://www.maxmind.com/) 数据库创建变量。默认不构建。
- **with-stream_ssl_preread_module**
 
    禁用构建[with-http_degradation_modulengx_stream_ssl_preread_module](http://nginx.org/en/docs/stream/ngx_stream_ssl_preread_module.html) 模块。该模块允许从[ClientHello](https://tools.ietf.org/html/rfc5246#section-7.4.1.2) 消息中提取消息而不终止SSL/TLS。
- **without-stream_limit_conn_module**
 
    禁用构建[ngx_stream_limit_conn_module](http://nginx.org/en/docs/stream/ngx_stream_limit_conn_module.html) 模块。该模块限制每个密钥的连接数，例如，来自单个IP地址的连接数。
- **without-stream_geo_module**
 
    禁用构建[ngx_stream_geo_module](http://nginx.org/en/docs/stream/ngx_stream_geo_module.html) 模块。该模块使用取决于客户端IP地址的值创建变量。
- **without-stream_map_module**
 
    禁用构建[ngx_stream_map_module](http://nginx.org/en/docs/stream/ngx_stream_map_module.html) 模块。该模块根据其他变量的值创建值。
- **without-stream_split_clients_module**
 
    禁用构建[ngx_stream_split_clients_module](http://nginx.org/en/docs/stream/ngx_stream_split_clients_module.html) 模块。该模块为 A/B 测试创建变量
- **without-stream_return_module**
 
    禁用构建[ngx_stream_return_module](http://nginx.org/en/docs/stream/ngx_stream_return_module.html) 模块。该模块将一些指定值发送到客户端，然后关闭连接。
- **without-stream_upstream_hash_module**
 
    禁用构建[hash](http://nginx.org/en/docs/stream/ngx_stream_upstream_module.html#hash) 实现散列负载平衡方法的模块。
- **without-stream_upstream_least_conn_module**
 
    禁用构建[least_conn](http://nginx.org/en/docs/stream/ngx_stream_upstream_module.html#least_conn) 实现散列负载平衡方法的模块。
- **without-stream_upstream_zone_module**
 
    禁用构建[zone](http://nginx.org/en/docs/stream/ngx_stream_upstream_module.html#zone) 的模块。该模块可以将上游组的运行时状态存储在共享内存区域中
- **with-google_perftools_module**
 
    禁用构建[ngx_google_perftools_module ](http://nginx.org/en/docs/ngx_google_perftools_module.html) 模块。该模块可以使用 [Google Performance Tools](https://github.com/gperftools/gperftools) 分析nginx工作进程。该模块适用于nginx开发人员，默认情况下不构建。
- **with-cpp_test_module**
 
    启用构建ngx_cpp_test_module模块。
- **add-module=path**
 
    启用外部模块。
- **add-dynamic-module=path**
 
    启用动态模块。
- **with-compat**
 
    实现动态兼容模块。
- **with-cc=path**
 
    设置C编译器的名称。
- **with-cpp=path**
 
    设置C++处理器的名称。
- **with-cc-opt=parameters**
 
    设置将添加到CFLAGS变量的其他参数。在FreeBSD下使用系统PCRE库时，应指定`--with-cc-opt =" - I / usr / local / include"`。如果需要增加 select() 支持的文件数，也可以在此处指定，例如： `- with-cc-opt =" - D FD_SETSIZE = 2048"`。
- **with-ld-opt=parameters**
 
    设置将在链接期间使用的其他参数。在FreeBSD下使用系统PCRE库时，应指定`--with-ld-opt =" - L / usr / local / lib"`。
- **with-cpu-opt=cpu**
 
    指定编译的 CPU ，pentium, pentiumpro, pentium3, pentium4, athlon, opteron, sparc32, sparc64, ppc64。
- **without-pcre**
 
    禁用 PCRE 库的使用。
- **with-pcre**
 
    强制使用 PCRE 库。
- **with-pcre=path**
 
    设置 PCRE 库源的路径。需要从 [PCRE](http://www.pcre.org/) 站点下载分发（版本4.4 - 8.42）并将其解压缩。剩下的工作由nginx的./configure和make完成。该位置指令和 [ngx_http_rewrite_module](http://nginx.org/en/docs/http/ngx_http_rewrite_module.html) 模块中的正则表达式支持需要该库。
- **with-pcre-opt=parameters**
 
    为PCRE设置其他构建选项。
- **with-zlib-opt=parameters**
 
    为zlib设置其他构建选项。
- **with-zlib-asm=cpu**
 
    启用使用针对其中一个指定CPU优化的zlib汇编程序源：pentium，pentiumpro。
- **with-libatomic**
 
    强制libatomic_ops库使用。
- **with-libatomic=path**
 
    设置libatomic_ops库源的路径。
- **with-openssl=path**
 
    设置OpenSSL库源的路径。
- **with-openssl-opt=parameters**
 
    为OpenSSL设置其他构建选项。
- **with-debug**
 
    启用 [调试日志](http://nginx.org/en/docs/debugging_log.html) 。                                                                                                                                                             
- **--with-pcre=path**

    设置 PCRE 库的源路径。发行版（4.4 至 8.40 版本）需要从 [PCRE](http://www.pcre.org/) 站点下载并提取。其余工作由 nginx 的 `./configure` 和 `make` 完成。该库是 [location](http://nginx.org/en/docs/http/ngx_http_core_module.html#location) 指令和 [ngx_http_rewrite_module](http://nginx.org/en/docs/http/ngx_http_rewrite_module.html) 模块中正则表达式支持所必需的。
- **--with-pcre-jit**

    使用“即时编译（just-in-time compilation）”支持（1.1.12版本的 [pcre_jit](http://nginx.org/en/docs/ngx_core_module.html#pcre_jit) 指令）构建 PCRE 库。
- **--with-zlib=path**

    设置 zlib 库的源路径。发行版（1.1.3 至 1.2.11 版本）需要从 [zlib](http://zlib.net/) 站点下载并提取。其余工作由 nginx 的 `./configure` 和 `make` 完成。该库是 [ngx_http_gzip_module](http://nginx.org/en/docs/http/ngx_http_gzip_module.html) 模块所必需的。
- **--with-cc-opt=parameters**

    设置添加到 CFLAGS 变量的额外参数。当在 FreeBSD 下使用系统的 PCRE 库时，应指定 `--with-cc-opt="-I /usr/local/include"`。如果需要增加 `select()` 所支持的文件数量，也可以在这里指定，如：`--with-cc-opt="-D FD_SETSIZE=2048"`。
- **--with-ld-opt=parameters**

    设置链接期间使用的其他参数。在 FreeBSD 下使用系统 PCRE 库时，应指定--with-ld-opt="-L /usr/local/lib"`。

参数使用示例：

```bash
./configure \
    --sbin-path=/usr/local/nginx/nginx \
    --conf-path=/usr/local/nginx/nginx.conf \
    --pid-path=/usr/local/nginx/nginx.pid \
    --with-http_ssl_module \
    --with-pcre=../pcre-8.40 \
    --with-zlib=../zlib-1.2.11
```

配置完成之后，使用 `make` 和 `make install` 编译和安装 nginx。

## 原文档

[http://nginx.org/en/docs/configure.html](http://nginx.org/en/docs/configure.html)
