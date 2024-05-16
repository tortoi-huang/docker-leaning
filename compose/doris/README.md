# doris 研究

## fe
doris fe是由java开发的 启动命令如下:
```shell
# 指定doris安装目录
export DORIS_HOME=
# 设定一个目录保存pid文件
export PID_DIR=

# 指向$DORIS_HOME/lib下的每一个jar文件, 这里很奇怪, 需要逐个指定每隔一个jar, 不能指定lib目录
export CLASSPATH=...
java org.apache.doris.DorisFE
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

