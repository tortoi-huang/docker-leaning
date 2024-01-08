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

# 添加 kafka-exporter + prometheus + grafana监控
## 步骤
1. 部署kafka-exporter 暴露kafka指标数据 可通过 http://kafka-exporter:9308/metrics 访问指标数据。通过docker的 command: ["--kafka.server=kafka0:9092", "--kafka.server=kafka1:9092", "--kafka.server=kafka2:9092"] 指定需要暴露的kafka节点信息。
prometheus 官网提供了各种中间件的 exporter: https://prometheus.io/docs/instrumenting/exporters/
2. 部署 prometheus ，通过修改./config/prometheus.yml文件，指定kafka-exporter地址 targets: ["kafka-exporter:9308"]
3. 部署 grafana， 部署启动后登录到Dashboards添加kafka-exporter Dashboards id为 7589，可通过grafana查询可导入的图形 https://grafana.com/grafana/dashboards/

## 问题
1. bitnami 的镜像都是通过用户1001启动进程， 这里 bitnami/grafana 授权似乎有问题，挂载目录总是提示没有权限，不能使用目录挂载。改用官网镜像后使用默认用户执行没有此问题