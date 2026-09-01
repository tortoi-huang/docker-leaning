# claude java 容器

## 容器使用
```.env
# 禁止上传遥测数据, 自动更新, 工具查询. 
# 需要注意的是关闭后提示词和云端工具不会自动更新. 不能使用官方最新优化的工具和提示词, 也无法使用互联网搜索功能
CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=true
# 关闭自动更新, 上述 CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=true 也会关闭自动更新, 包括了下面4条, 但为了保险起见, 这里再加4条
# 关闭遥测（Telemetry）上传: 使用频率, 功能调用统计, 工具使用情况, 性能指标, 匿名行为数据
CLAUDE_CODE_DISABLE_TELEMETRY=true
# 关闭错误报告（Error Reporting）上传
CLAUDE_CODE_DISABLE_ERROR_REPORTING=true
# 关闭用户反馈上传: 这个回答不好, 这个工具行为异常, 这个功能建议改进
CLAUDE_CODE_DISABLE_FEEDBACK=true
# 关闭自动更新（Auto Updater）: 定期检查更新, 自动下载新版本, 自动应用补丁, 拉取最新工具库版本包括 提示词模板（prompt templates）与工具提示词（tool manifest）的自动更新
CLAUDE_CODE_DISABLE_AUTOUPDATER=true

# 配置模型
ANTHROPIC_BASE_URL=https://ark.cn-beijing.volces.com/api/coding
ANTHROPIC_AUTH_TOKEN=
ANTHROPIC_MODEL=glm-5.2
ANTHROPIC_DEFAULT_OPUS_MODEL=glm-5.2
ANTHROPIC_DEFAULT_SONNET_MODEL=glm-5.2
ANTHROPIC_DEFAULT_HAIKU_MODEL=glm-5.2
CLAUDE_CODE_SUBAGENT_MODEL=glm-5.2

docker shell支持中文
LANG=C.UTF-8
```

配置 ~/.claude.json, 不用登录和新手指引
```json
{
  "hasCompletedOnboarding": true
}
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