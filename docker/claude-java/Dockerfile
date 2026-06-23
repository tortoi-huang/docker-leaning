# ==========================================
# 单阶段构建: Ubuntu 26.04 LTS + Bun + Claude Code + Java 25
# docker buildx build -t claude-java25:0.0.4 .
# docker run -it --rm --name claude-java25 -v $(pwd):/workspace claude-java25:0.0.4
# ==========================================
FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive
ENV BUN_INSTALL=/opt/bun
ENV JAVA_HOME=/usr/lib/jvm/java-25-openjdk-amd64
ENV PATH="${BUN_INSTALL}/bin:${JAVA_HOME}/bin:${PATH}"

# 安装基础工具与依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    iputils-ping \
    iproute2 \
    curl \
    ca-certificates \
    unzip \
    git \
    openssh-client \
    jq \
    ripgrep \
    fd-find \
    openjdk-25-jdk \
    maven \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# 声明外部传入的 UID 和 GID，默认值为 1000
ARG USER_ID=1000
ARG GROUP_ID=1000

# 核心逻辑：智能判断 UID 是否存在
RUN if getent passwd "${USER_ID}" > /dev/null; then \
        echo "UID ${USER_ID} 已经存在，对应用户为: $(getent passwd "${USER_ID}" | cut -d: -f1)" && \
        usermod -l developer -m -d /home/developer -s /bin/bash "$(getent passwd "${USER_ID}" | cut -d: -f1)"; \
    else \
        # 如果 UID 不存在，则正常创建组和用户
        groupadd -g ${GROUP_ID} developer && \
        useradd -l -u ${USER_ID} -g ${GROUP_ID} -m -s /bin/bash developer; \
    fi
# 授权执行sudo
RUN echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 从镜像中复制 Node.js 的二进制文件和全局模块，确保权限授予de
COPY --from=node:24-slim --chown=developer /usr/local/bin /usr/local/bin
COPY --from=node:24-slim --chown=developer /usr/local/lib/node_modules /usr/local/lib/node_modules

# 确保全局目录的所有者无论如何都指向重新调整后的 developer
WORKDIR /workspace
RUN mkdir -p /opt/bun && \
    chown -R ${USER_ID}:${GROUP_ID} /opt/bun /workspace /home/developer

# ==========================================
# 安全切换：此处统一使用用户名切换，永远不会出错
# ==========================================
RUN chown -R ${USER_ID}:${GROUP_ID} /usr/local/bin /usr/local/lib/node_modules
USER ${USER_ID}

RUN npm install -g @anthropic-ai/claude-code@2.1.172 @fission-ai/openspec@1.4.1 @ast-grep/cli
RUN npm install -g tree-sitter-cli tree-sitter-java

CMD ["/bin/bash"]
