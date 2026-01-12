
# 选择兼容性更好的 glibc 系 Linux 作为基础镜像
FROM ubuntu:22.04

# 创建非 root 运行用户
RUN apt-get update && \
    apt-get install -y gosu && \
    groupadd -g 10001 kingbase && \
    useradd -r -u 10001 -g kingbase -d /home/kingbase -m kingbase

# 拷贝应用与入口脚本
COPY ./kingbase /opt/kingbase
COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

WORKDIR /opt/kingbase

# 确保主程序与入口脚本可执行, 这里需要先创建挂载目录并授权，否则系统自动创建会在容器首次run阶段以root身份创建
# 程序目录不是静态的， 启动时会往里面写licence文件，需要修改为启动用户kingbase权限
RUN chmod +x bin/kingbase bin/initdb bin/sys_ctl /usr/local/bin/docker-entrypoint.sh && \
    chown -R kingbase:kingbase /opt/kingbase && \
    ln -s /opt/kingbase/bin/ksql /usr/local/bin/ksql && \
    ln -s /opt/kingbase/bin/kingbase /usr/local/bin/kingbase && \
    ln -s /opt/kingbase/bin/sys_ctl /usr/local/bin/sys_ctl


# 在 ENTRYPOINT 中使用root权限完成初始化后，切换到非 root 用户运行，否则挂载卷权限不足
# USER kingbase

# 运行时环境变量（可在 docker run / compose 中覆盖）
ENV KBASE_USER="kingbase" \
    KBASE_PASSWORD="" \
    KBASE_ENCODING="UTF-8" \
    KBASE_HOST="0.0.0.0" \
    KBASE_PORT="54321" \
    KBASE_HOME="/opt/kingbase" \
    KBASE_DATA_DIR="/data/kingbase/data" \
    KBASE_EXTRA_ARGS="-c logging_collector=off -c log_destination=stderr"

# 数据与日志目录, 这里容器首次run如果没有会创建一个目录/data/kingbase/data, 拥有者是root:root
VOLUME ["${KBASE_DATA_DIR}"]

# 暴露默认端口
EXPOSE 54321

# 健康检查
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD gosu kingbase:kingbase bin/sys_ctl -D ${KBASE_DATA_DIR} status || exit 1

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD []
