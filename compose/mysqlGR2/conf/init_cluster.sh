# 初始化master， -e "SET GLOBAL group_replication_start_on_boot=on;" \
# 主机名，ip地址等参数要和docker-compose.yml一致
docker exec -it mysqlgr-mysql1-1 mysql -uroot -pMypass@112233 \
  -e "SET GLOBAL group_replication_bootstrap_group=ON;" \
  -e "START GROUP_REPLICATION;" \
  -e "SET GLOBAL group_replication_bootstrap_group=OFF;"

docker exec -it mysqlgr-mysql2-1 mysql -uroot -pMypass@112233 \
  -e "START GROUP_REPLICATION;"

docker exec -it mysqlgr-mysql3-1 mysql -uroot -pMypass@112233 \
  -e "START GROUP_REPLICATION;"

