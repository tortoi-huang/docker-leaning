# 示例程序
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
1. 容器连接宿主网络, runc 没有网络功能，通过删除 config.json中的 linux.namespaces 下的network, 使得容器不在独立网络空间, 共享主机网络, 或者先在主机创建网络 nat 网络，并配置iptable将请求转发到容器网络空间
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