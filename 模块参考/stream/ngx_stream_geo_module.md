# ngx_stream_geo_module

- [示例配置](#example_configuration)
- [指令](#directives)
    - [geo](#geo)

`ngx_stream_geo_module` 模块（1.11.3）用于创建依赖于客户端 IP 地址的变量。

<a id="example_configuration"></a>

## 示例配置

```nginx
geo $geo {
    default        0;

    127.0.0.1      2;
    192.168.1.0/24 1;
    10.1.0.0/16    1;

    ::1            2;
    2001:0db8::/32 1;
}
```

<a id="directives"></a>

## 指令

### geo

|\-|说明|
|------:|------|
|**语法**|**geo** `[$address] $variable { ... }`;|
|**默认**|——|
|**上下文**|stream|

描述指定变量的值与客户端 IP 地址的依赖关系。默认情况下，地址取自 `$remote_addr` 变量，但也可以从其他变量中获取，例如：

```nginx
geo $arg_remote_addr $geo {
    ...;
}
```

> 由于变量仅在使用时进行求值，因此即使存在大量已声明的 `geo` 变量增加连接处理的额外成本。

如果变量（`$variable`）的值不是有效的 IP 地址，则使用 `255.255.255.255` 地址。

地址（`$address`）可为 CIDR 记法中的前缀（包括单个地址）或作为范围。

还支持以下特殊参数：

- `delete`

    删除指定的网络

- `default`

    如果客户端地址与所有指定的地址都不匹配，则设置为该变量的值。当以 CIDR 记法指定地址时，使用 `0.0.0.0/0` 和 `::/0` 而不是默认值。如果未指定 `default`，则默认值为空字符串。

- `include`

    包含一个有地址和值的文件，文件中可以有多个记录。

- `ranges`

    表示地址指定为范围形式。这个参数应该放在第一个。要加快地理数据的加载速度，地址应按升序排列。

示例：

```nginx
geo $country {
    default        ZZ;
    include        conf/geo.conf;
    delete         127.0.0.0/16;

    127.0.0.0/24   US;
    127.0.0.1/32   RU;
    10.1.0.0/16    RU;
    192.168.1.0/24 UK;
}
```

`conf/geo.conf` 文件包含以下内容：

```
10.2.0.0/16    RU;
192.168.2.0/24 RU;
```

使用最佳匹配的值。例如，对于 127.0.0.1 地址，将选择值 `RU`，而不是 `US`。

范围指定示例：

```nginx
geo $country {
    ranges;
    default                   ZZ;
    127.0.0.0-127.0.0.0       US;
    127.0.0.1-127.0.0.1       RU;
    127.0.0.1-127.0.0.255     US;
    10.1.0.0-10.1.255.255     RU;
    192.168.1.0-192.168.1.255 UK;
}
```

## 原文档
[http://nginx.org/en/docs/stream/ngx_stream_geo_module.html](http://nginx.org/en/docs/stream/ngx_stream_geo_module.html)