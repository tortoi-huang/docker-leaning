#!/bin/sh

if [ -z "${HADOOP_HOME}" ];
then
    echo "HADOOP_HOME not set"
    exit 1
fi 
${HADOOP_HOME}/sbin/start-all.sh
