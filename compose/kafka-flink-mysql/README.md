# 创建 kafka flink mysql 测试集群
kafka flink mysql 测试集群

## 启动和关闭集群
```bash
# 下载安装s3 jar依赖
mkdir -p lib/s3 lib/kafka
wget -O lib/s3/flink-s3-fs-hadoop-1.20.0.jar https://repo1.maven.org/maven2/org/apache/flink/flink-s3-fs-hadoop/1.20.0/flink-s3-fs-hadoop-1.20.0.jar

wget -O lib/kafka/flink-connector-kafka-3.2.0-1.19.jar https://repo1.maven.org/maven2/org/apache/flink/flink-connector-kafka/3.2.0-1.19/flink-connector-kafka-3.2.0-1.19.jar

wget -O lib/kafka/kafka-clients-3.8.0.jar https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/3.8.0/kafka-clients-3.8.0.jar

# 启动集群
sudo sudo docker compose up -d
# 关闭集群并删除所有数据
sudo docker compose down -v
```
## 单元测试
### 测试kafka
```bash
# sudo docker exec -it broker0 sh

# 查看集群状态
sudo docker exec -it controller0 /opt/bitnami/kafka/bin/kafka-metadata-quorum.sh --bootstrap-controller localhost:9093 describe --status
# 这里应该看到所有节点
sudo docker exec -it controller0 /opt/bitnami/kafka/bin/kafka-metadata-quorum.sh --bootstrap-controller localhost:9093 describe --replication

sudo docker exec -it broker0 /opt/bitnami/kafka/bin/kafka-topics.sh --create --bootstrap-server broker0:9092 --topic test1 --partitions 2 --replication-factor 2 --config min.insync.replicas=2

sudo docker exec -it broker0 /opt/bitnami/kafka/bin/kafka-producer-perf-test.sh --topic test1 --num-records 10000 --record-size 1024 --throughput -1 --producer-props bootstrap.servers=broker0:9092

sudo docker exec -it broker0 /opt/bitnami/kafka/bin/kafka-topics.sh --bootstrap-server broker0:9092 --topic test1 --describe

```

### 测试 mariadb
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

### 测试 minio
下载 aws 的 s3 browers 配置s3 选 s3 compatible account， ssl为false， endpoints为 localhost:9000, 可以正确连接到 minio 查询和创建 bucket

### 测试 flink
```bash
bash -c 'sudo docker exec -it jobmgr curl http://localhost:8081/config'|jq
bash -c 'sudo docker exec -it jobmgr curl http://localhost:8081/taskmanagers'|jq
bash -c 'sudo docker exec -it jobmgr curl http://localhost:8081/jobmanager/config'|jq
bash -c 'sudo docker exec -it jobmgr curl http://localhost:8081/jobmanager/environment'|jq
sudo docker exec -it jobmgr curl http://localhost:8081/jobmanager/metrics

```

### 测试 flink sql gateway
```bash
# sudo docker exec -it sql sh
# 因为容器每部没有jq命令，并且docker exec的输出无法被 $()和管道等当前shell捕获，这里暴露8083端口到本机处理
curl http://localhost:8083/v3/info

export sg_sid=$(curl -X POST http://localhost:8083/v3/sessions|jq -r '.sessionHandle')
echo $sg_sid

curl -X POST http://localhost:8083/v3/sessions/$sg_sid/statements --data '{"statement": "SELECT 1"}'
# 查看 http://localhost:8081/#/job/completed 可以看到任务已经提交
```

## 集成测试
使用 sql 从kafka 读取数据，更新到 mysql
```bash
# 关闭集群并删除所有数据
sudo docker compose down -v
# 启动集群
sudo sudo docker compose up -d

sudo docker exec -it broker0 /opt/bitnami/kafka/bin/kafka-topics.sh --create --bootstrap-server broker0:9092 --topic test1 --partitions 2 --replication-factor 2 --config min.insync.replicas=2

# 发送消息
sudo docker exec -it broker0 sh -c '/opt/bitnami/kafka/bin/kafka-console-producer.sh --bootstrap-server broker0:9092 --topic test1 --property parse.key=true --property key.separator== acks=all <<"EOF"
file1={"userId": 1, "itemId": 100000, "behavior": "hello world"}
file2={"userId": 2, "itemId": 100001, "behavior": "user name2"}
file3={"userId": 3, "itemId": 100002, "behavior": "behavior test"}
EOF'

# 消费消息
sudo docker exec -it broker0 /opt/bitnami/kafka/bin/kafka-console-consumer.sh --bootstrap-server broker0:9092 --topic test1 --group console-consumer1 --from-beginning

# 开启 flink sql 事务
export sg_sid=$(curl -X POST http://localhost:8083/v3/sessions|jq -r '.sessionHandle')
echo $sg_sid

# TODO 测试没通过，提交 flink sql 任务
curl -XPOST -H "Content-type: application/json" -d $'{
  "statement": "CREATE TABLE KafkaTable (\\n  `kfk_key` STRING,\\n  `user_id` BIGINT,\\n  `item_id` BIGINT,\\n  `behavior` STRING,\\n  `ts` TIMESTAMP(3) METADATA FROM \'timestamp\'\\n) WITH (\\n  \'connector\' = \'kafka\',\\n  \'topic\' = \'test1\',\\n  \'properties.bootstrap.servers\' = \'broker0:9092,broker1:9092\',\\n  \'properties.group.id\' = \'flinkGroup\',\\n  \'scan.startup.mode\' = \'earliest-offset\',\\n  \'format\' = \'json\',\\n  \'key.fields\' = \'kfk_key\'\\n)"
}' http://localhost:8083/v3/sessions/$sg_sid/statements
```

## 总结
### flink 内存
基于 flink 1.20 版本总结

flink 内存总体可以分为4大块: 堆内存, 堆外内存, 元数据内存, jvm overhead内存
+ 堆内存: java对象占用的内存, 通过垃圾回收器管理，大小取决于运行时的java对象的总大小
+ 堆外内存: 在java程序中手动分配的内存, 需要程序员手工分配和回收
+ 元数据内存: java方法(类)空间内存, 保存类的信息，静态变量，需要大小取决于类的数量和静态变量的数量
+ jvm overhead内存: jvm运行时额外需要的内存, 如编译字节码到机器码需要的内存， 缓存jit指令等

官方容器镜像问题：
+ config.yaml 不是只读的， 启动时会被改写
+ 通过环境变量 FLINK_PROPERTIES 配置属性时，没有配置的属性依然会使用 config.yaml 及默认配置, 而不是通过已经从环境变量配置的属性自动计算出其他关联属性, 如果在环境变量配置内存, 则需要配置所有的内存项目, 否则可能会启动出错或者内存浪费. 并且环境变量配置项不支持注释, 注释会被当作一行配置直接写入配置中，有注入的风险
+ flink 通过配置 taskmanager.memory.flink.size 和 jobmanager.memory.process.size 计算 taskmanager.memory.managed.size 错误, 如果使用了比默认值更小的内存配置则需要手动设置 taskmanager.memory.managed.size
