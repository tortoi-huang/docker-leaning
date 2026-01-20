#!/bin/bash
set -x
# set -euo pipefail

# mc除了可以连接本地minio，还可以连接远程的s3兼容服务器集群，这里设置要操作的集群，别名为 local, 避免从事输入用户名和密码
mc alias set local ${MINIO_ENDPOINT} ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD}
# 查看预设值的别名和相关信息
# mc alias ls

# 创建自定义策略
mc admin policy create local self-owned-buckets /svracct-policy.json
mc admin policy ls local

mc ls local/${MINIO_BUCKET_PAIMON}
if [ $? -eq 0 ]; then
    echo "${MINIO_BUCKET_PAIMON} aleady exists"
    # mc rm -r --force local/flink;
else
    mc mb local/${MINIO_BUCKET_PAIMON}
fi

mc ls local/${MINIO_BUCKET_FLINK}
if [ $? -eq 0 ]; then
    echo "${MINIO_BUCKET_FLINK} aleady exists"
    # mc rm -r --force local/flink;
else
    mc mb local/${MINIO_BUCKET_FLINK};
    # mc mb local/${MINIO_BUCKET_FLINK}/checkpoints;
    # mc mb local/${MINIO_BUCKET_FLINK}/savepoints;
    # mc mb local/${MINIO_BUCKET_FLINK}/ha;
fi

# mc admin user svcacct， 维护用户的服务账号，这里查询用户服务账号信息,服务账号可以理解为Access Key， 但是包含其他属性，Access Keys是它的标识符
mc admin user svcacct info local "${MINIO_FLINK_AK}"
if [ $? -eq 0 ]; then
    echo "access key aleady exists"
else
    # 添加服务账号(ak/sk)，--access-key和--secret-key如果不指定会随机生成
    mc admin user svcacct add local "${MINIO_ROOT_USER}" --access-key "${MINIO_FLINK_AK}" --secret-key "${MINIO_FLINK_SK}";
fi
mc admin user svcacct info local "${MINIO_PAIMON_AK}"
if [ $? -eq 0 ]; then
    echo "access key aleady exists"
else
    # 添加服务账号(ak/sk)，--access-key和--secret-key如果不指定会随机生成
    mc admin user svcacct add local "${MINIO_ROOT_USER}" --access-key "${MINIO_PAIMON_AK}" --secret-key "${MINIO_PAIMON_SK}";
fi


# 等待3秒确保创建过程执行完成
sleep 3

mc ls local

