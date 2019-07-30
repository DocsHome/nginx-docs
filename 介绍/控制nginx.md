# 控制 nginx

- [配置变更](#配置变更)
- [日志轮转](#日志轮转)
- [升级可执行文件](#升级可执行文件)

可以用信号控制 nginx。默认情况下，主进程（Master）的 pid 写在 `/use/local/nginx/logs/nginx.pid` 文件中。这个文件的位置可以在配置时更改或者在 nginx.conf 文件中使用 `pid` 指令更改。Master 进程支持以下信号：

信号 | 作用
:---|:---
TERM, INT | 快速关闭
QUIT| 正常退出
HUP	| 当改变配置文件时，将有一段过渡时间段（仅 FreeBSD 和 Linux），新启动的 Worker 进程将应用新的配置，旧的 Worker 进程将被平滑退出
USR1| 重新打开日志文件
USR2| 升级可执行文件
WINCH| 正常关闭 Worker 进程

Worker 进程也是可以用信号控制的，尽管这不是必须的。支持以下信号：

信号 | 作用
:---|:---
TERM, INT | 快速关闭
QUIT | 正常关闭
USR1 | 重新打开日志文件
WINCH | 调试异常终止（需要开启 [debug_points](http://nginx.org/en/docs/ngx_core_module.html#debug_points)）

## 配置变更

为了让 nginx 重新读取配置文件，应将 `HUP` 信号发送给 Master 进程。Master 进程首先会检查配置文件的语法有效性，之后尝试应用新的配置，即打开日志文件和新的 socket。如果失败了，它会回滚更改并继续使用旧的配置。如果成功，它将启动新的 Worker 进程并向旧的 Worker 进程发送消息请求它们正常关闭。旧的 Worker 进程关闭监听 socket 并继续为旧的客户端服务，当所有旧的客户端被处理完成，旧的 Worker 进程将被关闭。

我们来举例说明一下。 假设 nginx 是在 FreeBSD 4.x 命令行上运行的

```bash
ps axw -o pid,ppid,user,%cpu,vsz,wchan,command | egrep '(nginx|PID)'
```

得到以下输出结果：

```bash
  PID  PPID USER    %CPU   VSZ WCHAN  COMMAND
33126     1 root     0.0  1148 pause  nginx: master process /usr/local/nginx/sbin/nginx
33127 33126 nobody   0.0  1380 kqread nginx: worker process (nginx)
33128 33126 nobody   0.0  1364 kqread nginx: worker process (nginx)
33129 33126 nobody   0.0  1364 kqread nginx: worker process (nginx)
```

如果把 `HUP` 信号发送到 master 进程，输出的结果将会是：

```bash
 PID  PPID USER    %CPU   VSZ WCHAN  COMMAND
33126     1 root     0.0  1164 pause  nginx: master process /usr/local/nginx/sbin/nginx
33129 33126 nobody   0.0  1380 kqread nginx: worker process is shutting down (nginx)
33134 33126 nobody   0.0  1368 kqread nginx: worker process (nginx)
33135 33126 nobody   0.0  1368 kqread nginx: worker process (nginx)
33136 33126 nobody   0.0  1368 kqread nginx: worker process (nginx)
```

其中一个 PID 为 33129 的 worker 进程仍然在继续工作，过一段时间之后它退出了：

```bash
PID  PPID USER    %CPU   VSZ WCHAN  COMMAND
33126     1 root     0.0  1164 pause  nginx: master process /usr/local/nginx/sbin/nginx
33134 33126 nobody   0.0  1368 kqread nginx: worker process (nginx)
33135 33126 nobody   0.0  1368 kqread nginx: worker process (nginx)
33136 33126 nobody   0.0  1368 kqread nginx: worker process (nginx)
```

## 日志轮转

为了做日志轮转，首先需要重命名。之后应该发送 `USR1` 信号给 master 进程。Master 进程将会重新打开当前所有的日志文件，并将其分配给一个正在运行未经授权的用户为所有者的 worker 进程。成功重新打开之后 Master 进程将会关闭所有打开的文件并且发送消息给 worker 进程要求它们重新打开文件。Worker 进程重新打开新文件和立即关闭旧文件。因此，旧的文件几乎可以立即用于后期处理，例如压缩。

## 升级可执行文件

为了升级服务器可执行文件，首先应该将新的可执行文件替换旧的可执行文件。之后发送 `USR2` 信号到 master 进程。Master 进程首先将以进程 ID 文件重命名为以 `.oldbin` 为后缀的新文件，例如 `/usr/local/nginx/logs/nginx.pid.oldbin`。之后启动新的二进制文件和依次期待能够新的 worker 进程：

```bash
  PID  PPID USER    %CPU   VSZ WCHAN  COMMAND
33126     1 root     0.0  1164 pause  nginx: master process /usr/local/nginx/sbin/nginx
33134 33126 nobody   0.0  1368 kqread nginx: worker process (nginx)
33135 33126 nobody   0.0  1380 kqread nginx: worker process (nginx)
33136 33126 nobody   0.0  1368 kqread nginx: worker process (nginx)
36264 33126 root     0.0  1148 pause  nginx: master process /usr/local/nginx/sbin/nginx
36265 36264 nobody   0.0  1364 kqread nginx: worker process (nginx)
36266 36264 nobody   0.0  1364 kqread nginx: worker process (nginx)
36267 36264 nobody   0.0  1364 kqread nginx: worker process (nginx)
```

之后所有的 worker 进程（旧的和新的）继续接收请求，如果 `WINCH` 信号被发送给了第一个 master 进程，它将向其 worker 进程发送消息要求它们正常关闭，之后它们开始退出：

```
  PID  PPID USER    %CPU   VSZ WCHAN  COMMAND
33126     1 root     0.0  1164 pause  nginx: master process /usr/local/nginx/sbin/nginx
33135 33126 nobody   0.0  1380 kqread nginx: worker process is shutting down (nginx)
36264 33126 root     0.0  1148 pause  nginx: master process /usr/local/nginx/sbin/nginx
36265 36264 nobody   0.0  1364 kqread nginx: worker process (nginx)
36266 36264 nobody   0.0  1364 kqread nginx: worker process (nginx)
36267 36264 nobody   0.0  1364 kqread nginx: worker process (nginx)
```

过一段时间，仅有新的 worker 进程处理请求：

```bash
  PID  PPID USER    %CPU   VSZ WCHAN  COMMAND
33126     1 root     0.0  1164 pause  nginx: master process /usr/local/nginx/sbin/nginx
36264 33126 root     0.0  1148 pause  nginx: master process /usr/local/nginx/sbin/nginx
36265 36264 nobody   0.0  1364 kqread nginx: worker process (nginx)
36266 36264 nobody   0.0  1364 kqread nginx: worker process (nginx)
36267 36264 nobody   0.0  1364 kqread nginx: worker process (nginx)
```

需要注意的是旧的 master 进程不会关闭它的监听 socket，并且如果需要的话，可以管理它来启动 worker 进程。如果出于某些原因不能接受新的可执行文件工作方式，可以执行以下操作之一：

- 发送 `HUP` 信号给旧的 master 进程，旧的 master 进程将会启动不会重新读取配置文件的 worker 进程。之后，通过将 `QUIT` 信号发送到新的主进程就可以正常关闭所有的新进程。
- 发送 `TERM` 信号到新的 master 进程，它将会发送一个消息给 worker 进程要求它们立即关闭，并且它们立即退出（如果由于某些原因新的进程没有退出，应该发送 `KILL` 信号让它们强制退出）。当新的 master 进程退出时，旧 master 将会自动启动新的 worker 进程。

新的 master 进程退出之后，旧的 master 进程会从以进程 ID 命名的文件中忽略掉 `.oldbin` 后缀的文件。

如果升级成功，应该发送 `QUIT` 信号给旧的 master 进程，仅仅新的进程驻留：

```bash
  PID  PPID USER    %CPU   VSZ WCHAN  COMMAND
36264     1 root     0.0  1148 pause  nginx: master process /usr/local/nginx/sbin/nginx
36265 36264 nobody   0.0  1364 kqread nginx: worker process (nginx)
36266 36264 nobody   0.0  1364 kqread nginx: worker process (nginx)
36267 36264 nobody   0.0  1364 kqread nginx: worker process (nginx)
```

## 原文档

- [http://nginx.org/en/docs/control.html](http://nginx.org/en/docs/control.html)
