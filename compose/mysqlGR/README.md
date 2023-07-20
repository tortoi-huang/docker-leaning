# 创建一个mysql集群
## 参考 
mysql官方文档: https://dev.mysql.com/doc/refman/8.0/en/group-replication-configuring-instances.html
mysql blog: https://dev.mysql.com/blog-archive/setting-up-mysql-group-replication-with-mysql-docker-images/

## 运行需求
1. 运行本实例前需要现在当前目录创建三个空目录: data1, data2, data3. 分别存放三个节点数据，（因为git不能上传空目录，所以不能实现创建好）
2. 安装docker和docker-compose
3. 首次运行后需要进入MySQL执行初始化指令: 
  3.1. 选择一台电脑作为初始leader,这里选择mysql1，并执行leader初始化sql:
    3.1.1. 创建replication user: https://dev.mysql.com/doc/refman/8.0/en/group-replication-user-credentials.html
    ```sql
    SET SQL_LOG_BIN=0;
    -- SET @@GLOBAL.group_replication_bootstrap_group=1;
    CREATE USER rpl_user@'%' IDENTIFIED BY 'Pwd@1234';
    GRANT REPLICATION SLAVE ON *.* TO rpl_user@'%';
    GRANT CONNECTION_ADMIN ON *.* TO rpl_user@'%';
    GRANT BACKUP_ADMIN ON *.* TO rpl_user@'%';
    GRANT GROUP_REPLICATION_STREAM ON *.* TO rpl_user@'%';
    FLUSH PRIVILEGES;
    -- SET @@GLOBAL.group_replication_bootstrap_group=0;
    SET SQL_LOG_BIN=1;
    ```sql
    3.1.2. 设置并启动leader 
    ```sql
    CHANGE MASTER TO MASTER_USER='rpl_user', MASTER_PASSWORD='Pwd@1234' FOR CHANNEL 'group_replication_recovery';
    SET GLOBAL group_replication_bootstrap_group=ON;
    START GROUP_REPLICATION;
    SET GLOBAL group_replication_bootstrap_group=OFF;
    ```sql
    
  3.2.* 再mysql2和mysql3上设置并启动slave
  ```sql
  change master to master_user='repl' for channel 'group_replication_recovery';
  START GROUP_REPLICATION;
  ```sql
  