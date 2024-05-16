FROM alpine as fetch

ARG doris_dir=/opt/apache-doris

# 下载软件至镜像内，可根据需要替换
ADD https://apache-doris-releases.oss-accelerate.aliyuncs.com/apache-doris-2.1.2-bin-x64.tar.gz /opt/
RUN tar -zxvf /opt/apache-doris-2.1.2-bin-x64.tar.gz -C /opt/
RUN mv /opt/apache-doris-2.1.2-bin-x64 ${doris_dir}
ADD https://raw.githubusercontent.com/apache/doris/2.1.2-rc04/docker/runtime/fe/resource/init_fe.sh ${doris_dir}/fe/bin
RUN chmod 755 ${doris_dir}/fe/bin/init_fe.sh
WORKDIR ${doris_dir}


FROM openjdk:17-jdk-slim
ARG doris_dir=/opt/apache-doris
# 设置环境变量
# ENV JAVA_HOME="/usr/local/openjdk-8/"
# ENV PATH="${doris_dir}/fe/bin:$PATH"
ENV JAVA_OPTS_FOR_JDK_17="-XX:MaxRAMPercentage=70.0"
COPY --from=fetch ${doris_dir} ${doris_dir}
EXPOSE 8030 9020 9030 9010

ENTRYPOINT ["fe/bin/init_fe.sh"]