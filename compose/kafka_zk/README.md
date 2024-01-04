# 创建kafka zookeeper集群集群
## 问题:
1. 当kafka容器挂载Windows目录时（在windows环境下运行），删除topic会导致AccessDeniedException，并且无法重启服务器,只能使用docker内置文件系统或者挂载linux目录
2. 当kafka容器挂载linux目录是，目录是docker compose启动时创建的，则kafka启动失败，日志提示： /bitnami/kafka/config': Permission denied，但是zookeeper容器没有这个问题，原因是kafka容器指定了以1001:root用户运行，zookeeper没有指定运行用户而是默认root:root用户运行, docker compose创建的的目录所有者是root:root，所以kafka容器运行权限不足。 解决办法是以root用户运行容器(compose.yaml文件添加
  user: "root"配置)。或者预先建立目录data/kafka，使用chmod修改同组用户可写
