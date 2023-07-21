docker exec -it mysqlgr-mysql1-1 mysql -uroot -pMypass@112233 \
  -e "SET SQL_LOG_BIN=0;" \
  -e "CREATE USER rpl_user@'%' IDENTIFIED BY 'Pwd@1234';" \
  -e "GRANT REPLICATION SLAVE        ON *.* TO rpl_user@'%';" \
  -e "GRANT CONNECTION_ADMIN         ON *.* TO rpl_user@'%';" \
  -e "GRANT BACKUP_ADMIN             ON *.* TO rpl_user@'%';" \
  -e "GRANT GROUP_REPLICATION_STREAM ON *.* TO rpl_user@'%';" \
  -e "FLUSH PRIVILEGES;" \
  -e "SET SQL_LOG_BIN=1;"

# 初始化master， -e "SET GLOBAL group_replication_start_on_boot=on;" \
# 主机名，ip地址等参数要和docker-compose.yml一致
docker exec -it mysqlgr-mysql1-1 mysql -uroot -pMypass@112233 \
  -e "CHANGE REPLICATION SOURCE TO SOURCE_USER='rpl_user', SOURCE_PASSWORD='Pwd@1234' FOR CHANNEL 'group_replication_recovery';" \
  -e "INSTALL PLUGIN group_replication SONAME 'group_replication.so';" \
  -e "SET GLOBAL group_replication_group_name='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';" \
  -e "SET GLOBAL group_replication_local_address= 'mysql1:33061';" \
  -e "SET GLOBAL group_replication_ip_allowlist='192.168.96.0/20';" \
  -e "SET GLOBAL group_replication_group_seeds= 'mysql1:33061,mysql2:33061,mysql3:33061';" \
  -e "SET GLOBAL group_replication_single_primary_mode=off;" \
  -e "SET GLOBAL group_replication_enforce_update_everywhere_checks=ON;" \
  -e "SET GLOBAL group_replication_bootstrap_group=ON;" \
  -e "START GROUP_REPLICATION;" \
  -e "SET GLOBAL group_replication_bootstrap_group=OFF;"

docker exec -it mysqlgr-mysql2-1 mysql -uroot -pMypass@112233 \
  -e "INSTALL PLUGIN group_replication SONAME 'group_replication.so';" \
  -e "SET GLOBAL group_replication_group_name='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';" \
  -e "SET GLOBAL group_replication_local_address= 'mysql2:33061';" \
  -e "SET GLOBAL group_replication_ip_allowlist='192.168.96.0/20';" \
  -e "SET GLOBAL group_replication_group_seeds= 'mysql1:33061,mysql2:33061,mysql3:33061';" \
  -e "SET GLOBAL group_replication_single_primary_mode=off;" \
  -e "SET GLOBAL group_replication_enforce_update_everywhere_checks=ON;" \
  -e "SET GLOBAL group_replication_bootstrap_group=OFF;" \
  -e "CHANGE REPLICATION SOURCE TO SOURCE_USER='rpl_user', SOURCE_PASSWORD='Pwd@1234' FOR CHANNEL 'group_replication_recovery';" \
  -e "START GROUP_REPLICATION;"

docker exec -it mysqlgr-mysql3-1 mysql -uroot -pMypass@112233 \
  -e "INSTALL PLUGIN group_replication SONAME 'group_replication.so';" \
  -e "SET GLOBAL group_replication_group_name='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';" \
  -e "SET GLOBAL group_replication_local_address= 'mysql3:33061';" \
  -e "SET GLOBAL group_replication_ip_allowlist='192.168.96.0/20';" \
  -e "SET GLOBAL group_replication_group_seeds= 'mysql1:33061,mysql2:33061,mysql3:33061';" \
  -e "SET GLOBAL group_replication_single_primary_mode=off;" \
  -e "SET GLOBAL group_replication_enforce_update_everywhere_checks=ON;" \
  -e "SET GLOBAL group_replication_bootstrap_group=OFF;" \
  -e "CHANGE REPLICATION SOURCE TO SOURCE_USER='rpl_user', SOURCE_PASSWORD='Pwd@1234' FOR CHANNEL 'group_replication_recovery';" \
  -e "START GROUP_REPLICATION;"

