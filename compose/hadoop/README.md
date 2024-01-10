# hadoop集群搭建
hadoop配置文件有 *-defalut.xml 和 *-site.xml 两种， *-defalut.xml 为默认值， *-site.xml 为覆盖默认值的修改值

## 笔记
1. datanode和namenode之间的配置关联是通过 core-site.xml中的 fs.defaultFS 配置

## 问题
1. 网页上无法上传文件: http://localhost:9870/explorer.html#/ 原因是上传文件时会跳转到datanode的地址 http://datanode1:9864，但是没有暴露datanode地址，并且没有配置域名，所以无法上传， 需要暴露datanode 9864端口和修改host文件解决，或者登录一台hadoop机器使用命令 hdfs dfs -put -f source_file_path  target_file_path
2. namenode配置CORE-SITE.XML_hadoop.tmp.dir=file:/data/hadoop/tmp一直提示 hadoop URI has an authority component 异常，将文件file:前缀删除后正常
3. 挂载外部目录提示 File file:/data/hadoop/tmp/dfs/data does not exist， 修改启动用户为root解决