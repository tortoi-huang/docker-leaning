# claude java 容器

## 容器使用
```.env
ANTHROPIC_BASE_URL=https://ark.cn-beijing.volces.com/api/coding
ANTHROPIC_AUTH_TOKEN=
ANTHROPIC_MODEL=glm-5.2
ANTHROPIC_DEFAULT_OPUS_MODEL=glm-5.2
ANTHROPIC_DEFAULT_SONNET_MODEL=glm-5.2
ANTHROPIC_DEFAULT_HAIKU_MODEL=glm-5.2
CLAUDE_CODE_SUBAGENT_MODEL=glm-5.2

LANG=C.UTF-8
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

### openspec
- version: 1.3.1 or above