#!/bin/sh
echo "init user: start"
if [ -f "/var/puldar_manager_initied" ];then
    echo "init user: exit on user had inited"
    exit 0
fi

if [ ! $INIT_USER ];then
    echo "init user: exit on the envirionment INIT_USER not set"
    exit 0
fi
if [ ! $INIT_PASSWORD ];then
    echo "init user: exit on the envirionment INIT_PASSWORD not set"
    exit 0
fi

# 判断环境变量INIT_MAIL是否为空，如果为空就使用${INIT_USER}"@lo.org"
[ -z ${INIT_MAIL+x} ]&&INIT_MAIL=${INIT_USER}"@lo.org"

echo "init user: $INIT_USER, email: $INIT_MAIL"

CSRF_TOKEN=$(curl http://localhost:7750/pulsar-manager/csrf-token)
echo "init user token: $CSRF_TOKEN"
INIT_POST_DATA=$(echo {\"name\": \"${INIT_USER}\", \"password\": \"${INIT_PASSWORD}\", \"email\": \"${INIT_MAIL}\"})

curl -H 'X-XSRF-TOKEN: $CSRF_TOKEN' \
    -H 'Cookie: XSRF-TOKEN=$CSRF_TOKEN;' \
    -H 'Content-Type: application/json' \
    -X PUT http://localhost:7750/pulsar-manager/users/superuser \
    -d "$INIT_POST_DATA"
echo ${INIT_USER}","${INIT_PASSWORD}","${INIT_MAIL} > /var/puldar_manager_initied

echo "init user: ${INIT_USER}, finish"