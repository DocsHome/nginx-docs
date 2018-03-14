# ngx_http_geoip_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [geoip_country](#geoip_country)
    - [geoip_city](#geoip_city)
    - [geoip_org](#geoip_org)
    - [geoip_proxy](#geoip_proxy)
    - [geoip_proxy_recursive](#geoip_proxy_recursive)

`ngx_http_geoip_module` 模块（0.8.6+）使用预编译的 [MaxMind](http://www.maxmind.com/) 数据库，其创建带值的变量依赖客户端 IP 地址。

当使用支持 IPv6 的数据库时（1.3.12、1.2.7），IPv4 地址将被视为 IPv4 映射的 IPv6 地址。

此模块不是默认构建的，可以使用 `--with-http_geoip_module` 配置参数启用。

> 该模块需要 [MaxMind GeoIP](http://www.maxmind.com/app/c) 库。

<a id="example_configuration"></a>

## 示例配置

```nginx
http {
    geoip_country         GeoIP.dat;
    geoip_city            GeoLiteCity.dat;
    geoip_proxy           192.168.100.0/24;
    geoip_proxy           2001:0db8::/32;
    geoip_proxy_recursive on;
    ...
```

<a id="directives"></a>

## 指令

### geoip_country

|\-|说明|
|------:|------|
|**语法**|**geoip_country** `file`;|
|**默认**|——|
|**上下文**|http|

指定一个用于根据客户端 IP 地址确定国家的数据库。使用此数据库时，以下变量可用：

- `$geoip_country_code`

    双字母国家代码，例如 `RU`、`US`

- `$geoip_country_code3`

    三个字母的国家代码，例如 `RUS`、`USA`

- `$geoip_country_name`

    国家名称，例如 `Russian Federation`、`United States`

### geoip_city

|\-|说明|
|------:|------|
|**语法**|**geoip_city** `file`;|
|**默认**|——|
|**上下文**|http|

指定一个用于根据客户端 IP 地址确定国家、地区和城市的数据库。使用此数据库时，以下变量可用：

- `$geoip_area_code`

    电话区号（仅限美国）

    > 由于相应的数据库字段已弃用，因此此变量可能包含过时的信息

- `$geoip_city_continent_code`

    双字母的大陆码，例如 `EU`、`NA`

- `$geoip_city_country_code`

    双字母国家代码，例如 `RU`、`US`

- `$geoip_city_country_code3`

    三个字母的国家代码，例如 `RUS`、`USA`

- `$geoip_city_country_name`

    国家名称，例如 `Russian Federation`、`United States`

- `$geoip_dma_code`

    美国的 DMA 地区代码（也称为**城市代码**），根据 Google AdWords API 中的[地理位置定位](https://developers.google.com/adwords/api/docs/appendix/cities-DMAregions)

- `$geoip_latitude`

    纬度

- `$geoip_longitude`

    经度

- `$geoip_region`

    双符号国家地区代码（地区、领土、州、省、联邦土地等），例如 `48`、`DC`

- `$geoip_region_name`

    国家地区名称（地区，领土，州，省，联邦土地等），例如 `Moscow City`、`District of Columbia`

- `$geoip_city`

    城市名称，例如 `Moscow`、`Washington`

- `$geoip_postal_code`

    邮政编码

### geoip_org

|\-|说明|
|------:|------|
|**语法**|**geoip_org** `file`;|
|**默认**|——|
|**上下文**|http|
|**提示**|该指令在 1.0.3 版本中出现|

指定用于根据客户端 IP 地址确定组织的数据库。使用此数据库时，以下变量可用：

- `$geoip_org`

    组织名称，例如 `The University of Melbourne`

### geoip_proxy

|\-|说明|
|------:|------|
|**语法**|**geoip_proxy** `address` &#124; `CIDR`;|
|**默认**|——|
|**上下文**|http|
|**提示**|该指令在 1.3.0 版本和 1.2.1. 版本中出现|

定义可信地址。当请求来自可信地址时，将使用来自 `X-Forwarded-For` 请求头字段的地址。

### geoip_proxy_recursive

|\-|说明|
|------:|------|
|**语法**|**geoip_proxy_recursive** `on` &#124; `off`;|
|**默认**|geoip_proxy_recursive off;|
|**上下文**|http|
|**提示**|该指令在 1.3.0 版本和 1.2.1. 版本中出现|

如果递归搜索被禁用，那么将使用在 `X-Forwarded-For` 中发送的最后一个地址，而不是匹配其中一个可信地址的原始客户端地址。如果启用递归搜索，则将使用在 `X-Forwarded-For` 中发送的最后一个不可信地址，而不是匹配其中一个可信地址的原始客户端地址。

## 原文档
[http://nginx.org/en/docs/http/ngx_http_geoip_module.html](http://nginx.org/en/docs/http/ngx_http_geoip_module.html)