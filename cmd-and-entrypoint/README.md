# docker-leaning
测试dockerfile中的CMD指令和ENTRYPOINT指令之间的差别， 以及用户指令。

## 构建镜像
本镜像使用了用户组，需要先登录到docker守护进程所在的服务器添加用户(特别的，wsl需要登录到 docker-desktop实例操作)
在构建镜像时依次执行 Dockerfile 文件中的指令 Dockerfile 中 USER 指令用来切换用户
```shell
docker rmi huang/dockerfile:0.0.1 && docker build --progress plain -t huang/dockerfile:0.0.1 .
```

## 运行
当运行dockers run指令是，实际会运行一个由ENTRYPOINT + CMD拼接起来的的指令.
如dockerfile如下:
```shell
FROM ubuntu:20.04
# other command......
ENTRYPOINT ["/opt/mybin/entrypoint.sh","param1","param2"] 
CMD ["/opt/mybin/cmd.sh","param3", "param4"]
```
在docker命令行上运行以下命令:
```shell
docker run --rm huang/dockerfile:0.0.1
```
实际上会在docker内部运行以下命令:
```shell
/opt/mybin/entrypoint.sh param1 param2 /opt/mybin/cmd.sh param3 param4
```
拼接后cmd的命令/opt/mybin/cmd.sh会当作entrypoint命令的参数。

如果docker run命令带参数则会拼接到ENTRYPOINT后面，并且不再拼接CMD命令参数，这里可以理解CMD指令时默认的docker run参数。

ENTRYPOINT指令会继承自父镜像，并且会被子镜像覆盖，前面的例子：ENTRYPOINT覆盖了ubuntu:20.04镜像的ENTRYPOINT，ubuntu:20.04镜像的ENTRYPOINT指令是sh指令，所以当子镜像ENTRYPOINT 没有定义时，会将父镜像的ENTRYPOINT 和子镜像的CMD拼接, 如下dockerfile:
```shell
FROM ubuntu:20.04
# other command......
#ENTRYPOINT ["/opt/mybin/entrypoint.sh","param1","param2"] 
CMD ["/opt/mybin/cmd.sh","param3", "param4"]
```
实际docker 会运行如下命令:
```shell
sh /opt/mybin/cmd.sh param3 param4
```