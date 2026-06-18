# 介绍
这里演示docker sandbox中如何使用kit 配置虚拟机环境

##

```bash
# config 指向配置
sbx run claude --name test-sb --kit config

# 进入沙箱
sbx exec -it test-sb -- bash
```