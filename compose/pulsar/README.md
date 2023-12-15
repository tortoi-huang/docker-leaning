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
shell命令(powershell续行符需要替换为反引号`)
```shell
docker run -it --rm  --network pulsar_pulsar \
    -e "webServiceUrl=http://broker-1:8080,broker-2:8080,broker-3:8080" \
    -e "brokerServiceUrl=pulsar://broker-1:6650,broker-2:6650,broker-3:6650" \
    apachepulsar/pulsar:3.1.1 bash -c "bin/apply-config-from-env.py conf/client.conf && sh"
```
容器内使用客户端操作:
```shell
# 创建一个消费者, 消费队列persistent://public/default/test
bin/pulsar-client consume persistent://public/default/test -n 100 -s "consumer-test" -t "Exclusive"
# 发送消息到队列 persistent://public/default/test
bin/pulsar-client produce persistent://public/default/test -n 1 -m "Hello Pulsar 1"
bin/pulsar-client produce public/default/test -n 1 -m "Hello Pulsar 2"
```

## pulsar-manager 访问
pulsar-manager 还不能在启动时自动创建默认用户，需要手工创建用户.
登录到pulsar-manager 执行添加账号操作
```shell
docker exec -it pulsar-manager bash -c /pulsar-manager/init_manager_user.sh
```

## 进阶
1. 本实例最开始是用pulsar官方的镜像启动的zookeeper集群和bookkeeper集群，经过测试，可以替换为标准的zookeeper镜像搭建zookeeper集群，和使用标准的bookkeeper镜像搭建bookkeeper集群。其中分支feat-office上的是pulsar官方镜像搭建的集群，feat-std-mw上搭建的是各个中间件官方的标准镜像搭建的集群

## 问题:
1. 在 pulsar-manager 配置上花了不少时间, 当前版本不能启动时设置登录名和密码, 需要执行init_manager_user.sh来设置用户名和密码.
2. pulsar-manager登录后还是无法添加环境，垃圾！