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
1. 客户端操作:
```shell
# 创建一个消费者, 消费队列 persistent://public/default/test, 
# 这里命名是由格式的, persistent 是协议, 还支持non-persistent协议, 这里是指订阅者的offset是否被存储, 而消息必然是被存储的
# public 是租户, default是命名空间, test是topic名字
# 这里 -s "consumer-test" 类似kafka的消费组名称, -t Exclusive 表示独占消费，相同的消费组名只能有一个消费组， 不同组名可以有多个
bin/pulsar-client consume persistent://public/default/test -n 100 -s "consumer-test" -t "Exclusive"
# 发送消息到队列 persistent://public/default/test
bin/pulsar-client produce persistent://public/default/test -n 1 -m "Hello Pulsar 1"
bin/pulsar-client produce public/default/test -n 1 -m "Hello Pulsar 2"
```
2. 管理pulsar, 管理pulsar的官方命令行工具是 ./pulsar-admin, 下面描述命令是此命令的子命令，执行时要加上此前缀,如列出租户命令为 ./pulsar-admin tenants list
    1.1. 租户 tenants
    列出所有租户 tenants list
    创建租户 tenants create tenant_name, 会在zk:/admin/policies下创建一个节点，可以通过tenants get tenant_name, 看到zk上一样的信息
    1.2. 命名空间 namespaces

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