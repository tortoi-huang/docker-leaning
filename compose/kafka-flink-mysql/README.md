# 创建 kafka flink mysql 测试集群
kafka flink mysql 测试集群

## 测试
测试kafka 正常工作
```bash
# sudo docker exec -it broker0 sh
/opt/bitnami/kafka/bin/kafka-topics.sh --create --bootstrap-server broker0:9092 --topic test1 --partitions 2 --replication-factor 2 --config min.insync.replicas=2

/opt/bitnami/kafka/bin/kafka-producer-perf-test.sh --topic test1 --num-records 100000 --record-size 1024 --throughput -1 --producer-props bootstrap.servers=broker0:9092

/opt/bitnami/kafka/bin/kafka-topics.sh --bootstrap-server broker0:9092 --topic test1 --describe
```

测试 mariadb
```sql
-- shell： sudo docker exec -it mariadb mariadb -p
create database my_test;
use my_test;
CREATE TABLE test_db (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    my_name VARCHAR(32),
    create_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

insert into test_db(my_name) values ('hello'),('world');

select * from test_db;
```