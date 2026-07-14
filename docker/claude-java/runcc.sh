#!/bin/bash

# 1. 严格模式：一旦某行命令出错立即停止执行，避免带着错误继续跑 Docker
set -e

if [ $# -eq 0 ]; then
    echo "错误: 请传入第一个参数为工作项目目录"
    exit 1
else
    echo "项目目录是：$1"
fi

WORK_PRJ=$1

# 检查是否为目录
if [ ! -d "$WORK_PRJ" ]; then
    echo "错误: '$WORK_PRJ' 不是一个有效的目录"
    exit 1
fi

echo "work project is $WORK_PRJ"

# 安全地获取绝对路径
ABSOLUTE_PATH=$(cd "$WORK_PRJ" && pwd)
MNT_DIR=$(basename "$ABSOLUTE_PATH")
MNT_USER_HOME="$(pwd)/user_home"
MNT2HOME="$MNT_USER_HOME/${MNT_DIR}"

# 2. 确保宿主机目录和必要的文件存在，防止被 Docker 误识别为文件夹
mkdir -p "$MNT2HOME/.claude"
touch "$MNT2HOME/.claude.json"
touch "$MNT2HOME/.bash_aliases"

# 注释保留
# rm -rf ~/.m2/repository/com/freedomscm
c_home="/home/developer"

echo "$ABSOLUTE_PATH:               /workspace/${MNT_DIR}"
echo "$HOME/.m2:                    ${c_home}/.m2"
echo "$HOME/.ssh:                   ${c_home}/.ssh"
echo "$HOME/.gitconfig:             ${c_home}/.gitconfig"
echo "$MNT_USER_HOME/.claude:       ${c_home}/.claude"
echo "$MNT_USER_HOME/.claude.json:  ${c_home}/.claude.json"
echo "$MNT_USER_HOME/.bash_aliases: ${c_home}/.bash_aliases"

# 3. 运行 Docker（对所有挂载路径加了双引号，防止空格引发的解析错误）
docker run -it --rm \
    -v "$ABSOLUTE_PATH":"/workspace/${MNT_DIR}" \
    -v "$HOME/.m2":"${c_home}/.m2" \
    -v "$HOME/.ssh":"${c_home}/.ssh" \
    -v "$HOME/.gitconfig":"${c_home}/.gitconfig" \
    -v "$HOME/.cache/uv":"${c_home}/.cache/uv" \
    -v "$MNT_USER_HOME/.claude":"${c_home}/.claude" \
    -v "$MNT_USER_HOME/.claude.json":"${c_home}/.claude.json" \
    -v "$MNT_USER_HOME/.bash_aliases":"${c_home}/.bash_aliases" \
    --env-file .env \
    claude-java25:0.0.6