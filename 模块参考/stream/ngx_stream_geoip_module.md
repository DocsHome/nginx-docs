# ngx_stream_geoip_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [geoip_country](#geoip_country)
    - [geoip_city](#geoip_city)
    - [geoip_org](#geoip_org)

`ngx_stream_geoip_module` 模块（1.11.3）使用预编译的 [MaxMind](http://www.maxmind.com/) 数据库创建依赖于客户端 IP 地址的变量。

使用支持 IPv6 的数据库时，查找 IPv4 地址将转为查找 IPv4 映射的 IPv6 地址。

默认构建不包含此模块，可在构建时使用 `--with-stream_geoip_module` 配置参数启用。

> 该模块需要 [MaxMind GeoIP](http://www.maxmind.com/app/c) 库。

<a id="example_configuration"></a>

## 示例配置

```nginx
stream {
    geoip_country         GeoIP.dat;
    geoip_city            GeoLiteCity.dat;

    map $geoip_city_continent_code $nearest_server {
        default        example.com;
        EU          eu.example.com;
        NA          na.example.com;
        AS          as.example.com;
    }
   ...
}
```

<a id="directives"></a>

## 指令

### geoip_country

|\-|说明|
|------:|------|
|**语法**|**geoip_country** `file`;|
|**默认**|——|
|**上下文**|stream|

指定用于根据客户端 IP 地址确定国家的数据库。使用此数据库时，以下变量可用：

- `$geoip_country_code`

    两个字母表示的国家代码，比如 `RU`、`US`

- `$geoip_country_code3`

    三个字母表示的国家代码，比如 `RUS`、`USA`

- `$geoip_country_name`

    国家名称，比如 `Russian Federation`、`United States`

### geoip_city

|\-|说明|
|------:|------|
|**语法**|**geoip_city** `file`;|
|**默认**|——|
|**上下文**|stream|

指定用于根据客户端 IP 地址确定国家、地区和城市的数据库。使用此数据库时，以下变量可用：

- `$geoip_area_code`

    电话区号（仅限美国）

    > 因为使用到过时的数据库字段，此变量可能包含过时的信息。

- `$geoip_city_continent_code`

    两个字母表示的大陆代码，比如 `RU`、`US`

- `$geoip_city_country_code`

    两个字母表示的国家代码，比如 `RU`、`US`

- `$geoip_city_country_code3`

    三个字母表示的国家代码，比如 `RUS`、`USA`

- `$geoip_city_country_name`

    国家名称，比如 `Russian Federation`、`United States`

- `$geoip_dma_code`

    美国 DMA 区域代码（也称为**都市代码**），根据 Google AdWords API 中的[地理位置](https://developers.google.com/adwords/api/docs/appendix/cities-DMAregions)定位。

- `$geoip_latitude`

    维度

- `$geoip_longitude`

    经度

- `$geoip_region`

    双符号国家区域代码（地区、领土、州、省、联邦土地等），例如 `48`、`DC`。

- `$geoip_region_name`

    国家地区名称（地区、领土、州、省、联邦土地等），例如：`Moscow City`、`District of Columbia`。

- `$geoip_city`

    城市名称，例如：`Moscow”`、`Washington`。

- `$geoip_postal_code`

    邮政编码

### geoip_org

|\-|说明|
|------:|------|
|**语法**|**geoip_org** `file`;|
|**默认**|——|
|**上下文**|stream|

指定用于根据客户端 IP 地址确定组织的数据库。使用此数据库时，以下变量可用：

- `$geoip_org`

    组织名称，例如：`The University of Melbourne`。

## 原文档
[http://nginx.org/en/docs/stream/ngx_stream_geoip_module.html](http://nginx.org/en/docs/stream/ngx_stream_geoip_module.html)