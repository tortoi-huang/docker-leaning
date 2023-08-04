-- 创建同步数据用的账号及授权, 账号用于其他节点连接到本地节点同步数据，如果没有创建则其他节点无法连接到本地节点
SET SQL_LOG_BIN=0;
CREATE USER rpl_user@'%' IDENTIFIED BY 'Pwd@1234';
GRANT REPLICATION SLAVE        ON *.* TO rpl_user@'%';
GRANT CONNECTION_ADMIN         ON *.* TO rpl_user@'%';
GRANT BACKUP_ADMIN             ON *.* TO rpl_user@'%';
GRANT GROUP_REPLICATION_STREAM ON *.* TO rpl_user@'%';
FLUSH PRIVILEGES;
SET SQL_LOG_BIN=1;

-- 安装和配置数据同步插件, 这里主机和ip需要与docker-compose.yml一致
CHANGE REPLICATION SOURCE TO SOURCE_USER='rpl_user', SOURCE_PASSWORD='Pwd@1234' FOR CHANNEL 'group_replication_recovery';

-- 以下三行每次重启整个集群后都要在master执行
-- SET PERSIST group_replication_bootstrap_group=ON;
-- START GROUP_REPLICATION;
-- SET PERSIST group_replication_bootstrap_group=OFF;

-- 以下一行每次重启整个集群后都要在非master执行
-- START GROUP_REPLICATION;