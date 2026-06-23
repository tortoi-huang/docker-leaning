# TMS(transport manager system)

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
```
bun add -g @ast-grep/cli tree-sitter-cli ripgrep
# npm install -g @ast-grep/cli tree-sitter-cli ripgrep
```

```
# claude code 提示词
安装skill到当前项目: https://github.com/ratacat/claude-skills/tree/main/skills/ripgrep

/plugin marketplace add ast-grep/agent-skill
/plugin install ast-grep


```

### openspec
- version: 1.3.1 or above