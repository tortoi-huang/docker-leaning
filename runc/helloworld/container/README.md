# 环境准备
## 安装 go
## 安装 cni plugin
```bash
sudo mkdir -p /opt/cni/bin

wget -qO- https://github.com/containernetworking/plugins/releases/download/v1.6.2/cni-plugins-linux-amd64-v1.6.2.tgz | sudo tar -C /opt/cni/bin -xvz 
# export CNI_PATH=/opt/cni/bin
```
## 安装 cni tool
```bash
go install github.com/containernetworking/cni/cnitool@v1.2.3
# sudo cp ~/go/bin/cnitool /opt/cni/bin/
# ln -s /opt/cni/bin/cnitool /usr/local/bin/cnitool
```
# 创建网络空间
如果没有手动创建网络空间 runc 会自动创建一个临时网络空间，该空间无法通过 sudo ip netns list 看到, 因为 list 指令只能看到持久化的网络空间

```bash
# 创建网络空间
sudo ip netns add test-app-ns
# 查看网络空间
sudo ip netns list
sudo ls /var/run/netns/
# runc 所运行的进程使用的网络空间
# sudo ls /proc/{pid}/ns

```

# 配置网络访问
使用 cni 创建一个 bridge 的 nat 网络
```bash

# /opt/cni/bin/bridge 不能添加多插件配置
# sudo CNI_COMMAND=ADD CNI_CONTAINERID=test-app-ns CNI_NETNS=/var/run/netns/test-app-ns CNI_IFNAME=eth0 CNI_PATH=/opt/cni/bin /opt/cni/bin/bridge < 10-runc-cni.conf
# 删除桥接网络
# sudo CNI_COMMAND=DEL CNI_CONTAINERID=test-app-ns CNI_NETNS=/var/run/netns/test-app-ns CNI_IFNAME=eth0 CNI_PATH=/opt/cni/bin /opt/cni/bin/bridge < 10-runc-cni.conf

# 多插件配置需要使用 /opt/cni/bin cnitool
# add 后面的参数runc需要和配置文件中的name属性一致, 需要将配置文件复制到目录/etc/cni/net.d/
sudo cp 10-runc-cni.conflist /etc/cni/net.d/
sudo CNI_PATH=/opt/cni/bin cnitool add runc /var/run/netns/test-app-ns
# sudo CNI_PATH=/opt/cni/bin cnitool del runc /var/run/netns/test-app-ns
# sudo rm /etc/cni/net.d/10-runc-cni.conflist

sudo ip netns exec test-app-ns ip addr
```

# runc 容器
```bash
# 初始化 OCI Bundle, 就是生成模板文件 config.json
# runc spec
# mkdir rootfs
# cp ../app/app ./rootfs/

# 确保在 config.json 目录执行, test-app 是容器id 随意命名
sudo runc run test-app
# 上述运行完成后会退出容器， -d 参数表示容器不会退出, 使用 -d 参数才需要后续清理动作, process.terminal=false 才能启用 -d, 终端输出输出需要重定向到文件，否则会丢失
# sudo runc run -d test-app

# 查看正在运行的容器
sudo runc list
sudo runc state test-app

sudo ip netns exec test-app-ns ip addr

# 终止容器, 本例中程序不是服务类程序，运行完就自动终止，不需要此项
# sudo runc kill test-app SIGTERM
# 删除容器
sudo runc delete test-app
```

# 打包 docker 镜像
将目录 rootfs 打包为 docker 镜像
```bash
# 打包镜像tar, -C rootfs: Change dir to rootfs
tar -C rootfs -cvf test-app.tar --exclude='./proc' --exclude='./sys' --exclude='./dev' --exclude='./.gitkeep' .
# 查看内容
tar -tvf test-app.tar

# 导入镜像, 用 import 导入新镜像,会创建新的层id和镜像id, 不用load, 因为没有层id和镜像id, 需要指定包含点(.)的镜像名前缀, 否则会自动加上 localhost 前缀
docker import test-app.tar helloworld.com/test-app:latest

# 运行镜像
docker run --rm helloworld.com/test-app /app

# 导出镜像查看
docker save -o save-test-app.tar helloworld.com/test-app
mkdir save-test-app
tar -xvf save-test-app.tar -C save-test-app
# 查看其中唯一的层中的文件
find save-test-app -type f -name "*.tar" -print -quit | xargs tar -tvf 

# 清理
docker rmi helloworld.com/test-app
rm save-test-app.tar test-app.tar
rm -rf save-test-app
```

# TODO
1. 无法在宿主机上的8090端口映射到容器的8080端口
2. 使用 overlayFS 对容器文件系统进行分层, 目前只有一层。 大部分容器中通过overlayFS生成最终的 rootfs。

# 问题
1. 提示错误: exec /app: no such file or directory
原因是 app 有系统库依赖，重新编译打包所有依赖解决
```bash
# 检查依赖
ldd rootfs/app
# 重新打包, 包含所有依赖
cd ../app
CGO_ENABLED=0 go build app.go
cd -
cp ../app/app ./rootfs/
```
2. 如何确认runc容器使用哪个网络命名空间？通常 runc会创建以一个临时的网络命名空间，无法使用 sudo ip netns list, 可以在 配置文件 linux.namespaces中网络的元素中指定 使用已有的网络命名空间的path，
查看已有容器是否运行在指定网络命名空间
```bash
# 查看 pid
sudo runc state test-app
# 这里会显示进程使用的网络命名空间文件的inode
sudo ls -al /proc/<PID>/ns/net

# 查看已经存在的网络命名空间的 inode
sudo ls -ali /var/run/netns/
```