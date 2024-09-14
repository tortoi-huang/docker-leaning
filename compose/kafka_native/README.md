# 创建 kafka kraft集群
kafka native 集群

## 测试
因为 kafka native 镜像不提供 kafka-topics.sh 等命令, 测试需要另外创建 jvm 原生的镜像容器
```bash
sudo docker run --rm -it --network kafka-cluster apache/kafka:3.8.0 sh
```
### 创建topic
```shell
# 
bin/kafka-topics.sh --create --bootstrap-server broker1:19092 --topic test1 --partitions 3 --replication-factor 3 --config cleanup.policy=delete --config delete.retention.ms=43200000 --config min.insync.replicas=2
bin/kafka-topics.sh --list --bootstrap-server broker1:19092 
# 删除 topic
# kafka-topics.sh --delete --bootstrap-server broker1:19092 --topic test1
```
### 发送消息
```shell
# parse.key 表示消息格式为 key value, 配置为 false 则只有 value, key 和 value 默认使用 tab 分隔
bin/kafka-console-producer.sh --bootstrap-server broker1:19092 --topic test1 --property parse.key=true acks=all
```
### 消费消息
```shell
bin/kafka-console-consumer.sh --bootstrap-server broker1:19092 --topic test1 --group console-consumer1 --from-beginning
```

### 数据恢复
 
1. 查看topic原来状态
```shell
bin/kafka-topics.sh --bootstrap-server broker1:19092 --describe --topic test1
```
2. 停止一个节点
3. 查看topic状态变化
4. 发送消息
5. 启动停止节点 查看数据变化
6. 停止一个节点，同时删除该节点和该节点的数据目录，重新启动节点，确认新节点加入后数据可以恢复
7. 停止两个节点，只有一个存活节点，MIN_INSYNC_REPLICAS=2时插入数据失败, MIN_INSYNC_REPLICAS=1时插入成功

### 压测
1. 生产
```shell

# throughput 每秒发送消息数量-1不限制，num-records总共发送消息数量
bin/kafka-producer-perf-test.sh --topic test1 --num-records 100000 --record-size 1024 --throughput -1 --producer-props bootstrap.servers=broker1:19092 acks=all
```
2. 消费
```shell
# throughput 每秒发送消息数量-1不限制，
bin/kafka-consumer-perf-test.sh --bootstrap-server broker1:19092 --topic test1 --fetch-size 1000 --messages 1000000
```

## 添加 kafka-exporter + prometheus + grafana 监控
### 部署 kafka-exporter 
kafka 本身没有为 prometheus 提供数据接口 需要通过 kafka-exporter 来访问 kafka 集群将数据以 prometheus 的格式提供出来   

暴露 kafka 指标数据 可通过 http://kafka-exporter:9308/metrics 访问指标数据。通过 docker 的 command: ["--kafka.server=broker0:19092", "--kafka.server=broker1:19092", "--kafka.server=broker2:19092"] 指定需要暴露的 kafka 节点信息。   

prometheus 官网提供了各种中间件的 exporter: https://prometheus.io/docs/instrumenting/exporters/

### 部署 prometheus 
通过修改 ./config/prometheus.yml 文件，指定 kafka-exporter 地址 targets: ["kafka-exporter:9308"]
```yaml
scrape_configs:
  # 添加kafka的监控信息
  - job_name: "kafka_kraft"
    static_configs:
      - targets: ["kafka-exporter:9308"]
```

### 部署 grafana
grafana 初始用户名密码为 admin/admin, 首次登陆需要修改   
默认会启动一个嵌入式数据库 sqlite3

#### 部署 kafka-exporte Dashboard
1. 登录到 grafana
2. 进入 Connections/Data sources 菜单, 点击 "Add data source" 进入下一步
3. 选择 Prometheus 进入下一步
4. 在 Prometheus server URL 输入框输入: http://prometheus:9090 点击 "Save & test" 
5. 进入 Dashboards 菜单, 点击 new/import 进入下一步
6. 在 Import via grafana.com 输入框中输入 7589 后点击 load 进入下一步
这里 7589 是 grafana 维护的一个 Dashboard 编号, 需要联网下载相关文件, 可以通过 https://grafana.com/grafana/dashboards/ 查找到各种 Dashboard
7. 在 Prometheus 输入框选择刚才配置的 data source, 点击 import

## 总结
1. acks=all 要求所有存活的 replication 持久化成功，不要求已经宕机的 replication 持久化成功
2. min.insync.replicas topic 写成功的最小副本数, 默认值为 1. 只要符合此配置, 即便存活的 replication 小于 topic replication 总数的一半也能写成功, eplication 总数小于此值的 topic 不受影响。
## 问题
1. 按角色区分节点后，我发区分哪些参数应该配置在 controller，哪些应该配置在 broker