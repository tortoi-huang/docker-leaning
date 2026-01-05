# 测试部署 scylladb

## 配置

### 宿主机配置
```bash
# 配置aio可用数量，默认65535不够会导致启动报错
sudo vim /etc/sysctl.conf
# 追加
# fs.aio-max-nr = 1048576
# 重启
sudo sysctl -p
```
### 开发模式
scylladb 依赖xfs文件系统，在其他文件系统运行生产模式会无法启动，这里需要配置为开发模式保证启动
```yaml
# 当前镜像无法通过 scylla.yaml 配置开关开发者模式
services:
  scylla1:
    << : *scylla-templ
    container_name: scylla1
    hostname: scylla1
    command: >
      --smp 4
      --memory 8G
      --seeds=scylla1,scylla2
      --broadcast-address scylla1
      --broadcast-rpc-address scylla1
      --developer-mode 1
```

## 部署服务

```bash
# sudo docker exec -it scylla1 nodetool status
sudo docker exec -it scylla1 cqlsh

# 健康检查 参考: https://docs.scylladb.com/manual/stable/reference/api/index.html
curl -i http://127.0.0.1:10000/storage_service/native_transport
```