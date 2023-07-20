FROM mysql:8.0.33

# 配置文件如果可写则会被mysql忽略， 但是在windows上无法只读挂载，遂新建一个镜像
RUN chmod a-w \etc\mysql\conf.d\*