# 测试使用docker 共享 network/ipc/pid等资源

# network 共享
通过配置 network_mode: "service:main" 设置网络共享， 也就是容器间共享ip地址、端口号
```shell
# 登录curl-1
docker exec -it curl sh

# 访问main服务成功
curl localhost

# 访问sidecar1服务成功
curl localhost:70

# 查看 pid 看不到 sidecar1和main的pid
ps -a

# 查看网络端口占用, 可以看到80,70网络端口被占用 pid未知
netstat -ltpn
# 查看 curl-1, sidecar1, main ip地址相同(docker inspect查看)
```

# ipc 共享
通过配置 ipc: "service:main" 设置ipc共享

# pid 共享
通过配置 pid: "service:main" 设置pid共享
