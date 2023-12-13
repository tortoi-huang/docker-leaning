# 创建pulsar集群
## 目标:
创建一个3个bookkeeper, 3个broker的 pulsar集群.
## 配置
1. 创建zookeeper集群配置docker-compose-zk.yml，3个节点。符合pulsar要求的版本的zookeeper集群就可以，不一定需要使用pulsar官方的镜像.
2. 初始化集群，初始化只是在zookeeper上配置集群信息，不依赖pulsar，创建zookeeper后就可以执行
3. 创建bookkeeper集群配置docker-compose-bk.yml, 3个节点。
4. 创建broker集群配置docker-compose-broke.yml, 3个节点。
## 创建
```shell
docker compose up -d
```

## 测试
创建一个客户端镜像连接服务器测试
进入客户端容器:
shell命令
```shell
docker run -it --rm  --network pulsar_pulsar \
    -e "webServiceUrl=http://broker-1:8080,broker-:8080,broker-3:8080" \
    -e "brokerServiceUrl=pulsar://broker-1:6650,broker-2:6650,broker-3:6650" \
    apachepulsar/pulsar:3.1.1 bash -c "bin/apply-config-from-env.py conf/client.conf && sh"
```
或者 powershell
```powershell
docker run -it --rm --network pulsar_pulsar `
    -e "webServiceUrl=http://broker-1:8080,broker-:8080,broker-3:8080" `
    -e "brokerServiceUrl=pulsar://broker-1:6650,broker-2:6650,broker-3:6650" `
    apachepulsar/pulsar:3.1.1 bash -c "bin/apply-config-from-env.py conf/client.conf && sh"
```
容器内使用客户端操作:
```shell
# 创建一个消费者
bin/pulsar-client consume persistent://public/default/test -n 100 -s "consumer-test" -t "Exclusive"
# 发送消息
bin/pulsar-client produce persistent://public/default/test -n 1 -m "Hello Pulsar"
```

## 
## 问题:
1. 在 pulsar-manager 配置上花了不少时间, 这个东西bug太多, 不能用.
