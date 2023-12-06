# 创建一个innodb ReplicaSet(主从复制)集群
## 参考 
mysql官方文档: https://dev.mysql.com/doc/mysql-shell/8.0/en/deploying-innodb-replicasets.html

## 操作
1. 运行docker compose up 启动量个mysql实例, 此时实例尚未组成集群
2. 初始化集群
```shell
# 登录到其中一个节点登录到mysqlsh配置集群管理员，每个节点的集群管理员的用户名和密码都必须一样
dba.configureReplicaSetInstance('root@mysql-server-1:3306', {clusterAdmin: "'rsadmin'@'mysql%'", clusterAdminPassword: "mysql", password: "mysql"});
dba.configureReplicaSetInstance('root@mysql-server-2:3306', {clusterAdmin: "'rsadmin'@'mysql%'", clusterAdminPassword: "mysql", password: "mysql"});
dba.configureReplicaSetInstance('root@mysql-server-3:3306', {clusterAdmin: "'rsadmin'@'mysql%'", clusterAdminPassword: "mysql", password: "mysql"});

# 连接到其中一个节点创建ReplicaSet集群, 同步方式默认为异步(ASYNC)
# \connect root@mysql-server-1
var rs = dba.createReplicaSet("rs_example")

# 添加slave节点
rs.addInstance("root@mysql-server-2:3306", {recoveryMethod: "clone"})
rs.addInstance("root@mysql-server-3:3306", {recoveryMethod: "clone"})

# 检查集群状态
rs.status()

# 主从切换,切换到mysql-server-3:3306
rs.setPrimaryInstance("mysql-server-3:3306")
```