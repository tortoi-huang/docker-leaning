# 创建一个mysql集群
## 参考 
mysql官方文档: https://dev.mysql.com/doc/refman/8.0/en/group-replication-configuring-instances.html
mysql blog: https://dev.mysql.com/blog-archive/setting-up-mysql-group-replication-with-mysql-docker-images/

## 运行需求
1. 运行本实例前需要现在当前目录创建三个空目录: data1, data2, data3. 分别存放三个节点数据，（因为git不能上传空目录，所以不能实现创建好）
2. 安装docker和docker-compose
3. 运行docker compose up 启动三个mysql实例
4. 运行init_cluster.sh初始化集群

问题:
1、 挂载的my.cnf总是可写，docker官方的mysql镜像忽略，解决办法1，通过可写方式挂载，然后修改command启动命令，先授权再启动mysql，解决办法2, 更换镜像为mysql官方镜像
2、 启动时提示错误Ignoring --plugin-load[_add] list as the server is running with --initialize(-insecure)
解决办法，在plugin相关的参数前都加上前缀 loose_, 
后续： 此问题仅为通过my.cnf配置插件存在，通过更改为通过sql动态安装和配置group_replication插件将不复存在。
3、 执行 START GROUP_REPLICATION; 提示错误：
ERROR 3096 (HY000): The START GROUP_REPLICATION command failed as there was an error when initializing the group communication layer.
解决办法：之前是用环境变量配置 loose-group-replication-local-address参数无效，更为为my.cnf文件配置 command: --loose-group-replication-local-address="127.0.0.1:33061"，然后成功启动master。
但是当启动slave的时候又提示: [GCS] Error on opening a connection to 33061 on local port: 33061.
再次更改为 在docker启动命令传递该参数 command: --loose-group-replication-local-address="mysql1:33061"， 成功启动slave。

后续： 已更改为sql动态安装和配置group_replication插件。

至此，通过一下sql检查所有节点成功启动连接
```sql
SELECT * FROM performance_schema.replication_group_members;
```sql
4、经上述配置基本启动成功，但是检查日志出现错误: 
 Slave I/O for channel 'group_replication_recovery': error connecting to master 'rpl_user@mysql1:3306' - retry-time: 60 retries: 1 message: Authentication plugin 'caching_sha2_password' reported error: Authentication requires secure connection. Error_code: MY-002061
原因是mysql8使用的密码插件是caching_sha2_password， group_replication还不支持，
解决：修改my.cnf 添加配置 default_authentication_plugin=sha256_password

5、docker stop之后再次启动，发现集群失效了：
```sql
-- 只有一个节点，错误。正确应该有三个节点
SELECT * FROM performance_schema.replication_group_members;
```sql
， 原因是my.cnf配置了 group_replication_start_on_boot=off ,第一次初始化时需要为off,确保在配置完成之前不出错，之后要该为on，重启时才会自动启动复制
解决: 
更改为sql动态安装和配置group_replication插件, group_replication_start_on_boot不存在my.cnf写死的问题。
