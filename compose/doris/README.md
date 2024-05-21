# doris 研究

## 官网范例
https://github.com/apache/doris/blob/master/docker/runtime/docker-compose-demo/build-cluster/docker-compose/3fe_3be/docker-compose.yaml
启动后进入fe
```shell
sudo docker exec -it doris-fe-01 sh

mysql -u root -P 9030 -h 172.20.80.2

```
```sql
-- 显示fe状态
show frontends;
-- 显示be状态
show backends;

-- 创建表 
CREATE TABLE session_data
(
    visitorid   SMALLINT,
    sessionid   BIGINT,
    visittime   DATETIME,
    city        CHAR(20),
    province    CHAR(20),
    ip          varchar(32),
    brower      CHAR(20),
    url         VARCHAR(1024)
)
DUPLICATE KEY(visitorid, sessionid) -- 只用于指定排序列，相同的 KEY 行不会合并
DISTRIBUTED BY HASH(sessionid, visitorid) BUCKETS 10;

-- 插入数据
insert into session_data(visittime) values('visittime2');
```

### 问题
1. 往一个 DATETIME 列插入一个不能转换为日期的字符串 提示插入成功，实际插入失败
2. 环境变量中的ip没有发现可以使用域名替换的方法

## fe
doris fe是由java开发的, 容器启动脚本 init_fe.sh > start_fe.sh > java.
其中:
1. init_fe.sh 检查和初始化需要的环境变量

2. start_fe.sh 设置 java classpath 以及java 启动命令行参数

3. java 启动 doris-fe.jar 中的主类 org.apache.doris.DorisFE, 简化如下
```shell
# 指定doris安装目录
export DORIS_HOME=
# 设定一个目录保存pid文件
export PID_DIR=
# 指向$DORIS_HOME/lib下的每一个jar文件, 这里很奇怪, 需要逐个指定每隔一个jar, 不能指定lib目录
java -cp lib/*:lib/doris-fe.jar org.apache.doris.DorisFE
```

### 问题
Java 命令运行 包含main函数的类时， 包含该类的jar包必须单独写出来, 并且classpath 指向目录必须使用通配符 * 匹配全部, 不能匹配部分文件名, 如 *.jar, 如以下写法可以正确运行:
```shell
# 放后面可以运行
java -cp lib/*:lib/doris-fe.jar org.apache.doris.DorisFE

# 放前面可以运行
java -cp lib/doris-fe.jar:lib/* org.apache.doris.DorisFE

# 逐个jar 写出来可以运行
java -cp lib/doris-fe.jar:lib/aaa.jar,bbb.jar org.apache.doris.DorisFE
```

以下写法都会出错:

1. 指定目录
> java -cp lib org.apache.doris.DorisFE
> Error: Could not find or load main class org.apache.doris.DorisFE

2. cp 没有单独指定 org.apache.doris.DorisFE 的jar包
> java -cp lib/* org.apache.doris.DorisFE
> Could not find or load main class lib.ST4-4.3.4.jar

3. cp 通配符匹配部分文件
> java -cp lib/doris-fe.jar:lib/*.jar org.apache.doris.DorisFE
>  Unable to initialize main class org.apache.doris.DorisFE

### 启动容器
```shell
sudo docker run -d --rm --env apache-doris-fe:2.1.2

```