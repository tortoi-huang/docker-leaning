# hadoop集群搭建
hadoop配置文件有 *-defalut.xml 和 *-site.xml 两种， *-defalut.xml 为默认值， *-site.xml 为覆盖默认值的修改值

## 笔记
1. datanode和namenode之间的配置关联是通过 core-site.xml中的 fs.defaultFS 配置

## 问题
1. 网页上无法上传文件: http://localhost:9870/explorer.html#/ 原因是上传文件时会跳转到datanode的地址 http://datanode1:9864，但是没有暴露datanode地址，并且没有配置域名，所以无法上传， 需要暴露datanode 9864端口和修改host文件解决，或者登录一台hadoop机器使用命令 hdfs dfs -put -f source_file_path  target_file_path