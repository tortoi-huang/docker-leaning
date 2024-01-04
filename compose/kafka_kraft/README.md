# 创建 kafka kraft集群
kafka安装目录为 /opt/bitnami/kafka
## 创建topic
```shell
# 
bin/kafka-topics.sh --create --bootstrap-server kafka1:9092 --topic test1 --partitions 3 --replication-factor 3 --config cleanup.policy=delete --config delete.retention.ms=43200000 --config min.insync.replicas=2
# 删除 topic
#kafka-topics.sh --delete --bootstrap-server kafka1:9092 --topic test1
```
## 发送消息
```shell
bin/kafka-console-producer.sh --bootstrap-server kafka1:9092 --topic test1 --property parse.key=true
```
## 消费消息
```shell
bin/kafka-console-consumer.sh --bootstrap-server kafka1:9092 --topic test1 --group console-consumer1 --from-beginning
```

## 数据恢复
 
1. 查看topic原来状态
```shell
bin/kafka-topics.sh --bootstrap-server kafka1:9092 --topic test1 --describe
```
2. 停止一个节点
3. 查看topic状态变化
4. 发送消息
5. 启动停止节点 查看数据变化
6. 停止一个节点，同时删除该节点和该节点的数据目录，重新启动节点，确认新节点加入后数据可以恢复

## 压测
1. 生产
```shell

# throughput 每秒发送消息数量-1不限制，num-records总共发送消息数量
bin/kafka-producer-perf-test.sh --topic test1 --num-records 1000000 --record-size 1024 --throughput -1 --producer-props bootstrap.servers=kafka1:9092
```
2. 消费
```shell
# throughput 每秒发送消息数量-1不限制，
bin/kafka-consumer-perf-test.sh --bootstrap-server kafka1:9092 --topic test1 --fetch-size 1000 --messages 1000000
```

