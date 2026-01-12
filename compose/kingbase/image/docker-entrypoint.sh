#!/usr/bin/env bash

set -euo pipefail

# 是否需要初始化的标记文件
KBASE_MARK_FILE="${KBASE_DATA_DIR}/initdb.conf"

cd "${KBASE_HOME}"

# 目录准备与权限
chown -R kingbase:kingbase ${KBASE_DATA_DIR}

# 首次初始化（标记文件不存在时执行）
if [[ ! -f "${KBASE_MARK_FILE}" ]]; then
  if [[ -z "${KBASE_PASSWORD:-}" ]]; then
    echo "[ERROR] KBASE_PASSWORD 未设置。请在 docker run/docker-compose 中通过 -e KBASE_PASSWORD=... 提供该环境变量。"
    exit 1
  fi
  echo "[INFO] Detected first run. Initializing database into ${KBASE_DATA_DIR}..."

  INIT_ARGS=( "-U" "${KBASE_USER}" "-x" "${KBASE_PASSWORD}" "-D" "${KBASE_DATA_DIR}" "-E" "${KBASE_ENCODING}" )
  if [[ -n "${KBASE_INIT_ARGS:-}" ]]; then
    # 注意：KBASE_INIT_ARGS 需要按空格分隔，例如：-c logging_collector=off -c log_destination=stderr
    # shellcheck disable=SC2206
    INIT_ARGS=( ${KBASE_INIT_ARGS} )
    INIT_ARGS+=( "${INIT_ARGS[@]}" )
  fi

  echo "[INFO] Running: bin/initdb ${INIT_ARGS[*]}"
  gosu kingbase:kingbase bin/initdb "${INIT_ARGS[@]}"

  echo "[INFO] Init completed."
else
  echo "[INFO] Existing data detected. Skip initdb."
fi

# 组装主服务启动参数
ARGS=( "-h" "${KBASE_HOST}" "-p" "${KBASE_PORT}" "-D" "${KBASE_DATA_DIR}" )
if [[ -n "${KBASE_EXTRA_ARGS:-}" ]]; then
  # 注意：KBASE_EXTRA_ARGS 需要按空格分隔，例如：-c logging_collector=off -c log_destination=stderr
  # shellcheck disable=SC2206
  EXTRA_ARR=( ${KBASE_EXTRA_ARGS} )
  ARGS+=( "${EXTRA_ARR[@]}" )
fi

echo "[INFO] Starting kingbase with args: ${ARGS[*]}"
echo "[INFO] KBASE_USER=${KBASE_USER}"

# 切换到 kingbase 用户执行主程序， 这里会替换当前主进程id， 使得下面执行的程序为主进程，进程号为1
exec gosu kingbase:kingbase bin/kingbase "${ARGS[@]}"
