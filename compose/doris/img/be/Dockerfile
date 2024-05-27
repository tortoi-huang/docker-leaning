FROM curlimages/curl as fetch

USER root
ARG doris_dir=/opt/apache-doris

# 下载软件至镜像内，可根据需要替换
ADD https://apache-doris-releases.oss-accelerate.aliyuncs.com/apache-doris-2.1.2-bin-x64.tar.gz /opt/
RUN tar -zxvf /opt/apache-doris-2.1.2-bin-x64.tar.gz -C /opt/
RUN mv /opt/apache-doris-2.1.2-bin-x64 ${doris_dir} && rm -rf ${doris_dir}/fe ${doris_dir}/extensions 
ADD https://raw.githubusercontent.com/apache/doris/2.1.2-rc04/docker/runtime/be/resource/init_be.sh ${doris_dir}/be/bin
RUN chmod 755 ${doris_dir}/be/bin/init_be.sh
WORKDIR ${doris_dir}
RUN sed -i 's|start_be.sh|/opt/apache-doris/be/bin/start_be.sh|g' /opt/apache-doris/be/bin/init_be.sh


FROM openjdk:17-jdk-slim
ARG doris_dir=/opt/apache-doris
# 设置环境变量
ENV JAVA_OPTS_FOR_JDK_17="-XX:MaxRAMPercentage=70.0"
COPY --from=fetch ${doris_dir} ${doris_dir}
EXPOSE 9060 8040 9050 8060

ENTRYPOINT ["/opt/apache-doris/be/bin/init_be.sh"]