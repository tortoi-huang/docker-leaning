# opencode java 容器

## 容器使用
```.env
# docker shell支持中文
LANG=C.UTF-8
# 设定时区, 避免使用utc
TZ=Asia/Tokyo
```

```bash
#!/bin/bash

c_home=/home/developer

docker run -it --rm \
    --name claude-sb \
    -v ./freedomscm-scm-tms-claude:/workspace/tms \
    -v ~/.m2:${c_home}/.m2 \
    -v ./user_home/.claude:${c_home}/.claude \
    -v ~/.ssh:${c_home}/.ssh \
    -v ~/.gitconfig:${c_home}/.gitconfig \
    -v ~/dubbo-resolve.properties:${c_home}/dubbo-resolve.properties \
    -v ./user_home/.claude.json:${c_home}/.claude.json \
    -v ./user_home/.bash_aliases:${c_home}/.bash_aliases \
    --env-file .env \
    claude-java25:0.0.6
```

## develop environment setting

### claude code
- version: 2.1.159 or above

#### plugin & skill
add claude-code marketplace if not exists
```
/plugin marketplace add anthropics/claude-code
```
- plugin: jdtls-lsp
- plugin: superpowers
- plugin: code-review

提升代码查询效率
```bash
# bun add -g @ast-grep/cli tree-sitter-cli ripgrep
npm install -g @ast-grep/cli tree-sitter-cli ripgrep
```

```
# claude code 提示词
安装skill到当前项目: https://github.com/ratacat/claude-skills/tree/main/skills/ripgrep

/plugin marketplace add ast-grep/agent-skill
/plugin install ast-grep


```

#### ast-grep-server mcp server安装
```bash
# 依赖先安装uv, 通过uv编译安装 ast-grep-server 二进制
uvx --from git+https://github.com/ast-grep/ast-grep-mcp ast-grep-server

# 找到编译的二进制代码
find ~/.cache/uv -type f -name "ast-grep-server"

# 通过docker 命令挂载 ast-grep-server到容器
```

### openspec
- version: 1.3.1 or above


## 待改进
### npm 安装包缓存
docker file中 npm install 经常更新的软件时, 更新经常打包docker 镜像可以修改为挂载宿主机目录缓存安装包方式:
1. 容器挂载文件: ${HOME}/.npmrc, 并配置内容: prefix=${HOME}/.local/npm. 命令: npm config set prefix '${HOME}/.local/npm'
2. 配置path: export PATH="$HOME/.local/npm/bin:$PATH"
3. 挂载目录: ${HOME}/.local