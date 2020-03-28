FROM openjdk:8u242-jdk
ENV HADOOP_HOME=/opt/hadoop-3.2.1
EXPOSE 8088
EXPOSE 9870
COPY ./hadoop-3.2.1 ${HADOOP_HOME}
COPY ./entrypoint.sh ${HADOOP_HOME}/
WORKDIR ${HADOOP_HOME}

ENTRYPOINT [ "./entrypoint.sh" ]