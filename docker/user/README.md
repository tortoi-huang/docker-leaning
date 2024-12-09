# docker 用户及权限

## 结论
docker compose中指定用户必须是容器内 /etc/passwd 中存在的用户, 如果没有在创建容器时指定用户，则默认为root用户，用户id默认是0。 通常在创建镜像时在 dockerfile 指定中用户名或者用户id，如果指定用户名则相当于在 /etc/passwd 添加一个用户, 如果指定用户id则相当于设定容器运行的root用户的id