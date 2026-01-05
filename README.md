# docker-leaning


## wsl systemctl docker 代理配置
宿主机使用v2rayn等上网时需要设置代理服务器，但是systemd启动的程序不会读取系统环境变量和用户环境变量，需要使用drop-in方式设置环境变量

如果需要永久添加环境变量则在目录 /etc/systemd/system/<unit>.service.d/ 添加环境变量

如果需要临时添加环境变量则在目录 /run/systemd/system/<unit>.service.d/ 添加环境变量

举例为docker添加代理服务器变量， 文件目录 /etc/systemd/system/docker.service.d/http-proxy.conf
```toml
[Service]
Environment="http_proxy=http://10.168.60.42:8080"
Environment="https_proxy=http://10.168.60.42:8080"
Environment="no_proxy=localhost,127.0.0.1,10.0.0.0/8,172.16.0.0/12"
```