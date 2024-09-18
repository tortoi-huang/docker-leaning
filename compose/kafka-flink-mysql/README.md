# 创建 kafka flink mysql 测试集群
kafka flink mysql 测试集群

## 测试
测试kafka 正常工作
```bash
bin/kafka-topics.sh --create --bootstrap-server broker0:9092 --topic test1 --partitions 3 --replication-factor 3 --config min.insync.replicas=2
```
