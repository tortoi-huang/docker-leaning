docker exec -it mysqlgr-mysql1-1 mysql -uroot -pMypass@112233 \
  -e "SET SQL_LOG_BIN=0;" \
  -e "CREATE USER rpl_user@'%' IDENTIFIED BY 'Pwd@1234';" \
  -e "GRANT REPLICATION SLAVE        ON *.* TO rpl_user@'%';" \
  -e "GRANT CONNECTION_ADMIN         ON *.* TO rpl_user@'%';" \
  -e "GRANT BACKUP_ADMIN             ON *.* TO rpl_user@'%';" \
  -e "GRANT GROUP_REPLICATION_STREAM ON *.* TO rpl_user@'%';" \
  -e "FLUSH PRIVILEGES;" \
  -e "SET SQL_LOG_BIN=1;"

# 更新
docker exec -it mysqlgr-mysql1-1 mysql -uroot -pMypass@112233 \
  -e "CHANGE REPLICATION SOURCE TO SOURCE_USER='rpl_user', SOURCE_PASSWORD='Pwd@1234' FOR CHANNEL 'group_replication_recovery';" \
  -e "SET GLOBAL group_replication_bootstrap_group=ON;" \
  -e "START GROUP_REPLICATION;" \
  -e "SET GLOBAL group_replication_bootstrap_group=OFF;"

docker exec -it mysqlgr-mysql2-1 mysql -uroot -pMypass@112233 \
  -e "CHANGE REPLICATION SOURCE TO SOURCE_USER='rpl_user', SOURCE_PASSWORD='Pwd@1234' FOR CHANNEL 'group_replication_recovery';" \
  -e "START GROUP_REPLICATION;"

docker exec -it mysqlgr-mysql3-1 mysql -uroot -pMypass@112233 \
  -e "CHANGE REPLICATION SOURCE TO SOURCE_USER='rpl_user', SOURCE_PASSWORD='Pwd@1234' FOR CHANNEL 'group_replication_recovery';" \
  -e "START GROUP_REPLICATION;"

