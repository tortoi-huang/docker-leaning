#!/bin/bash

# mysql 连接到工作的节点
WORK_NODE=
# 设置数组分隔符号为逗号
IFS=','
read -ra fe_arr <<< "$FE_SERVERS"
for val in "${fe_arr[@]}"; 
do 
    mysql --connect-timeout 10 -P $QUERY_PORT -uroot -h $val --skip-column-names --batch -e 'show frontends;'
    if [[ $?==0 ]]; then
        WORK_NODE=$val
        break
    fi
done

if [[ ! $WORK_NODE ]]; then 
    exit 1
fi

for val in "${fe_arr[@]}"; 
do 
    FE_TMP=$(mysql --connect-timeout 10 -P $QUERY_PORT -uroot -h $WORK_NODE --skip-column-names --batch -e 'show frontends;'|awk '{print $2}'|grep $val)
    if [[ ! $FE_TMP ]]; then
        mysql --connect-timeout 10 -h $WORK_NODE -P $QUERY_PORT -uroot --skip-column-names --batch -e "ALTER SYSTEM ADD FOLLOWER \"$val:$EDIT_LOG_PORT\";"
    fi
done

read -ra be_arr <<< "$BE_SERVERS"
for val in "${be_arr[@]}"; 
do 
    FE_TMP=$(mysql --connect-timeout 10 -P $QUERY_PORT -uroot -h $WORK_NODE --skip-column-names --batch -e 'show backends;'|awk '{print $2}'|grep $val)
    if [[ ! $FE_TMP ]]; then
        mysql --connect-timeout 10 -h $WORK_NODE -P $QUERY_PORT -uroot --skip-column-names --batch -e "ALTER SYSTEM ADD BACKEND \"$val:$HEARTBEAT_PORT\";"
    fi
done

read -ra ob_arr <<< "$OB_SERVERS"
for val in "${ob_arr[@]}"; 
do 
    FE_TMP=$(mysql --connect-timeout 10 -P $QUERY_PORT -uroot -h $WORK_NODE --skip-column-names --batch -e 'show frontends;'|awk '{print $2}'|grep $val)
    if [[ ! $FE_TMP ]]; then
        mysql --connect-timeout 10 -h $WORK_NODE -P $QUERY_PORT -uroot --skip-column-names --batch -e "ALTER SYSTEM ADD OBSERVER \"$val:$EDIT_LOG_PORT\";"
    fi
done


# mysql --connect-timeout 10 -h fe01 -P 9030 -uroot \
# --skip-column-names --batch \
# -e 'ALTER SYSTEM ADD FOLLOWER "fe02:9010";ALTER SYSTEM ADD FOLLOWER "fe03:9010";'


# mysql --connect-timeout 10 -h fe01 -P 9030 -uroot \
# --skip-column-names --batch \
# -e 'ALTER SYSTEM ADD BACKEND "be01:9050";ALTER SYSTEM ADD BACKEND "be02:9050";ALTER SYSTEM ADD BACKEND "be03:9050";'
