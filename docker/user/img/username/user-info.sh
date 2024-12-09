#!/usr/bin/env sh

echo "exec entrypoint config on dockerfile"
echo "whoami: $(whoami)"
temp_user=$(whoami)
echo "id: $(id)"

echo "grep passwd"
echo $(cat /etc/passwd|grep $temp_user)

echo 'hello world!' > /data/$ENV_FILE.txt
ls -la /data
ls -la /data2
sleep 999d