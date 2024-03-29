# 创建一个innodb cluster集群
## 参考 
开源配置: https://github.com/neumayer/mysql-docker-compose-examples
mysql官方文档: https://dev.mysql.com/doc/mysql-shell/8.0/en/mysql-innodb-cluster.html

## 操作
1. 运行docker compose up 启动三个mysql实例, 此时三个单独的实例尚未组成集群
2. 检查每个实例是否配置正确: 
```powershell
# 登录主机
docker exec -it innodb_cluster-mysql-server-1-1 sh
```
在docker 容器内执行mysqlshell检查mysql状态
```shell
# 启动mysql shell, 也可以启动同时登录 mysqlsh root@mysql-server-1:3306
mysqlsh
# 创建连接会话
shell.connect('root@mysql-server-1:3306', 'mysql')

# 检查当前会话节点状态, 或者在未登录状态检查指定节点的的状态: dba.checkInstanceConfiguration('root@mysql-server-2:3306')
dba.checkInstanceConfiguration()

# 上述检查应该打印 "status": "ok", 如果返回检查不通过则应该使用下列命令修正, 通常建议使用环境变量或者my.cnf变量修正而非dba.configureInstance()，
dba.configureInstance()
```
3. 初始化集群
```shell
# 登录到节点mysql-server-1 mysql shell, 执行创建集群命令, 创建一个名为devCluster的集群， communicationStack默认是mysql，consistency默认是EVENTUAL
var cluster = dba.createCluster("devCluster", {communicationStack: "XCom", consistency: "BEFORE_ON_PRIMARY_FAILOVER"});
# 将其他节点添加到集群, waitRecovery默认 1，交互式需要确认并打印数据同步信息，recoveryMethod默认为clone，不选会交互式提示选择
cluster.addInstance({user: "root", host: "mysql-server-2", password: "mysql"}, {waitRecovery: 0, recoveryMethod: "clone"})
# 执行完上述命令后mysql-server-2会关闭， 需要手工使用docker start启动，待启动完成后加入集群成功,同样的方式操作mysql-server-3节点
cluster.addInstance({user: "root", host: "mysql-server-3", password: "mysql"}, {waitRecovery: 0, recoveryMethod: "clone"})

# 检查集群状态
cluster.status()
```
4. 测试集群节点宕机
```powershell
# 主节点宕机
docker stop innodb_cluster-mysql-server-1-1
# 登录到节点-mysql-server-2执行恢复
 docker exec -it innodb_cluster-mysql-server-2-1 sh
```
登录到节点-mysql-server-2查看执行恢复
```shell
mysqlsh root@mysql-server-2:3306
# 获取集群对象
var cluster = dba.getCluster("devCluster")
# 查看集群状态
cluster.status()
```
重启宕机节点
```powershell
# 主节点宕机
docker start innodb_cluster-mysql-server-1-1
```
登录到集群
```shell
mysqlsh root@mysql-server-2:3306
# 获取集群对象
var cluster = dba.getCluster("devCluster")
# 查看集群状态
cluster.status()
# 如果集群中节点状态不为online则需要在健康的节点上执行以下命令重新添加节点到集群, 在镜像版本8.0.12发现重启不会自动添加到集群，需要这部处理，升级到8.0.32后不用
cluster.rejoinInstance("root@mysql-server-1")
```
测试所有节点宕机
```powershell
# 重启所有节点
docker compose restart
```
通过mysqlsh重启集群，登录到其中一个节点的mysqlsh
```shell
var cluster = dba.rebootClusterFromCompleteOutage("devCluster")
```

5. 单主多主模式切换
```shell
#mysqlsh
# 切换到多主模式
cluster.switchToMultiPrimaryMode()
# 切换到单主模式
cluster.switchToSinglePrimaryMode()
```

## 问题:
1. 按配置升级镜像版本8.0.12到8.0.32启动出错，通过添加启动命令行参数解决: --binlog_transaction_dependency_tracking=WRITESET
2. 当节点宕机时，在线的主节点会定时发出rejoin命令，最多会执行3次，超过3次就不会自动rejoin，需要启动宕机节点后手动rejoin。
3. 使用cluster.status()检查集群状态时发现各个节点的address是一个随机字符串，原因是当集群创建时默认使用了hostname来设置变量group_replication_local_address， 通过在docker-compose文件中添加hostname字段定义该文件， 也可以通过addInstance(instance, {"localAddress": "${hostname}"})来解决
4. 当执行 cluster.addInstance({user: "root", host: "mysql-server-2", password: "mysql"})配置时，会在目标实例上执行sql: RESTART 预计，但是docker 关掉之后并不会重启，需要在docker-compose中添加配置 restart: on-failure 来替代

## 配置
1. 创建集群配置: dba.createCluster("devCluster",{replicationAllowedHost:'192.0.2.0/24',communicationStack: "xcom"});其中 replicationAllowedHost是白名单，communicationStack是通讯协议，默认为mysql。
2. 添加实例到集群: addInstance(instance[, options]),有诸多参数配置，包括实例重启、断线重连事件间隔，实例地址（参考问题3）等，更多配置参考: https://dev.mysql.com/doc/mysql-shell/8.0/en/add-instances-cluster.html
