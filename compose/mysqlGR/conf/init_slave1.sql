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
INSTALL PLUGIN group_replication SONAME 'group_replication.so';
SET PERSIST group_replication_group_name='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
SET PERSIST group_replication_local_address= 'mysql2:33061';
SET PERSIST group_replication_ip_allowlist='192.168.96.0/20';
SET PERSIST group_replication_group_seeds= 'mysql1:33061,mysql2:33061,mysql3:33061';
SET PERSIST group_replication_single_primary_mode=off;
SET PERSIST group_replication_enforce_update_everywhere_checks=ON;
CHANGE REPLICATION SOURCE TO SOURCE_USER='rpl_user', SOURCE_PASSWORD='Pwd@1234' FOR CHANNEL 'group_replication_recovery';

-- 以下一行每次重启整个集群后都要执行
-- START GROUP_REPLICATION;
