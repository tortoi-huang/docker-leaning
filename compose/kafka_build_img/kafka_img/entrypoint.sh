#!/bin/sh

if [ -z "${KAFKA_HOME}" ];
then
    echo "KAFKA_HOME not set"
    exit 1
fi 
cp -f ${KAFKA_HOME}/config/server.properties ${KAFKA_HOME}/config/server_docker.properties 
echo "KAFKA_HOME: ${KAFKA_HOME}"
if [ ${BROKER_ID} ];
then
    echo "update broker.id to ${BROKER_ID}"
    sed -i "s/broker.id=0/broker.id=${BROKER_ID}/" ${KAFKA_HOME}/config/server_docker.properties 
fi

if [ ${ZK} ];
then
    echo "update zookeeper.connect to ${ZK}"
    sed -i "s/zookeeper.connect=localhost:2181/zookeeper.connect=${ZK}/" ${KAFKA_HOME}/config/server_docker.properties
else
    echo "start local zookeeper server"
    nohup ${KAFKA_HOME}/bin/zookeeper-server-start.sh ${KAFKA_HOME}/config/zookeeper.properties > ${KAFKA_HOME}/logs/zkstart.log 2>&1 &
    sleep 3

    if [ -z "$(cat logs/zkstart.log |grep 2181|grep bind)" ];
    then
        sleep 5
    fi
    if [ -z "$(cat logs/zkstart.log |grep 2181|grep bind)" ];
    then
        sleep 5
    fi
    if [ -z "$(cat logs/zkstart.log |grep 2181|grep bind)" ];
    then
        exit 1
    fi
    echo "start local zookeeper server complete"
fi
echo "start local kafka server"
${KAFKA_HOME}/bin/kafka-server-start.sh ${KAFKA_HOME}/config/server_docker.properties
echo "start local kafka complete"