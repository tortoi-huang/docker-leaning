# 部署 jenkins 技术栈
包括 bitbucket sonarque

## 部署 bitbucket
启动后访问 http://localhost:7990/ 初始化 bitbucket 这里使用免费90天的 key， 用户名 服务器地址 http://bitbucket:7990/， 用户名: bitbucket, 密码 830625

bitbucket 需要用到elastic search， 默认会在容器内部启动一个绑定的 ES, 端口 7992, 也可以配置外部的ES

## 部署 jenkins
jenkins 是有状态服务启动后需要配置插件，用户名和密码等信息