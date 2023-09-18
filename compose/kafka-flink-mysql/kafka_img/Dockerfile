FROM openjdk:8u242-jdk
ENV KAFKA_HOME=/opt/kafka_2.13-3.5.1
EXPOSE 9092
RUN wget -qO- https://downloads.apache.org/kafka/3.5.1/kafka_2.13-3.5.1.tgz | tar xzf - -C /opt/
# COPY ./kafka_2.12-2.4.1 ${KAFKA_HOME}
COPY ./entrypoint.sh ${KAFKA_HOME}/
WORKDIR ${KAFKA_HOME}

#excute on build
#RUN sed -i 's/broker.id=0/broker.id=${BROKER_ID}/' /opt/kafka_2.12-2.4.1/config/server.properties && sed -i 's/zookeeper.connect=localhost:2181/zookeeper.connect=${ZK}/' /opt/kafka_2.12-2.4.1/config/server.properties

#excute on run
#CMD ${KAFKA_HOME}/bin/kafka-server-start.sh ${KAFKA_HOME}/config/server.properties

ENTRYPOINT [ "./entrypoint.sh" ]