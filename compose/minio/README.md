# 部署测试minio
参考 https://github.com/bitnami/containers/blob/main/bitnami/minio/docker-compose-distributed-multidrive.yml
## 部署服务
1. 启动服务，访问 http://localhost:9001 ，
2. 创建 Access Key

### 部署问题
1. 使用bitnami镜像 集群节点环境变量配置必须固定格式如: MINIO_DISTRIBUTED_NODES: minio{0...3}/data-{0...1}, 不能逐个列出节点和磁盘，不能使用 MINIO_VOLUMES 指定磁盘，否则能启动但是各个节点不能组成集群

## 客户端
客户端mc可以连接多个服务端，默认预先配置了4组配置: gcs(google 存储), local(指定的minio),s3(亚马逊对象存储), play(minio官方提供的一个测试minio地址), 配置信息保存在 ~/.mc/config.json(bitnami容器没有用户目录放在/.mc/config.json), 可以直接修改该文件并挂载到容器，也可以通过命令修改其中的配置
启动客户端
```shell
docker run -it --rm --name minio-client \
    --network minio-cluster \
    --volume ./config/minio-client-config.json:/.mc/config.json \
    bitnami/minio-client:2023.12.29 \
    sh

# 查看已经配置的服务端
mc alias list

# 配置本地连接(local)的Access Keys
mc alias set local  http://minio0:9000 RerS1F4TGjWMr9CkKWnG XB9fYjqp3AMEFtTZuZkJjQImOyc9PpOE8rgQ1GWF
# 查看local的bucket
mc ls local

# 在local创建一个名为 bucket1 的 bucket
mc mb local/bucket1
```

## 配置 Prometheus

### 配置 Prometheus 服务
通过客户端连接到集群的一台服务器，这里假设连接名字叫local， 依次执行以下命令，将运行结果复制到 Prometheus 配置文件
启动Prometheus可以抓取统计信息， 这里会同时生成 Prometheus job 访问需要的 token
```shell
mc admin prometheus generate local
mc admin prometheus generate local node
mc admin prometheus generate local bucket
mc admin prometheus generate local resource

# 测试配置
curl -XGET -H 'Authorization: Bearer ${token}' 'http://minio0:9000/minio/v2/metrics/cluster'
```

### 配置 minio 服务
确保服务器有以下三个环境变量，并配置正确
```
# Prometheus地址
MINIO_PROMETHEUS_URL: http://prometheus:9090
# 这里只配置 Prometheus 中 cluster的jobid
MINIO_PROMETHEUS_JOB_ID: minio_cluster
# 这里配置为 public 则 Prometheus 抓取指标不用token认证，否则需要在job中配置 bearer_token 属性
MINIO_PROMETHEUS_AUTH_TYPE: public
```

## 对象存储操作

### 桶权限
1. 添加一个桶: bucket1, 该桶下新建三个目录: public_write, public_read, private; 现在控制桶的权限 public_read 可以匿名读取，public_write可以匿名写入， user1_only 需要 user1 才能读写。
    a. public_read可以通过添加匿名策略（Anonymous Access）前缀分别为目录名称来实现
    b. user1_only需要配置 策略文件, 添加一个policy如下(参考: https://min.io/docs/minio/linux/administration/identity-access-management/policy-based-access-control.html#minio-policy-actions):
    ```json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "s3:ListBucket"
                ],
                "Resource": [
                    "arn:aws:s3:::bucket1"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "s3:*"
                ],
                "Resource": [
                    "arn:aws:s3:::bucket1/private"
                ]
            }
        ]
    }
    ```
    然后将策略授权给 user1 用户

## 节点负载均衡
部署nginx为节点做负载均衡
### 问题
1. 抄官方配置，导致502错误，原因是后算转发配置了https协议，应该更改为http协议，另外使用子域名比较简单，因为上下文会导致跳转错误。 
2. 配置域名时配置了环境变量 MINIO_SERVER_URL 会导致无法登录， 原因暂时不明， 只要配置环境 MINIO_DOMAIN 和 MINIO_BROWSER_REDIRECT_URL 就可以登录并且通过api访问文件了。