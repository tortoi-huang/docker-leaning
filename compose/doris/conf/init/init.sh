#!/bin/bash

mysql --connect-timeout 10 -h fe01 -P 9030 -uroot \
--skip-column-names --batch \
-e 'ALTER SYSTEM ADD FOLLOWER "fe02:9010";ALTER SYSTEM ADD FOLLOWER "fe03:9010";'
# mysql --connect-timeout 10 -h fe01 -P 9030 -uroot \
# --skip-column-names --batch \
# -e 'ALTER SYSTEM ADD FOLLOWER "172.20.80.203:9010";ALTER SYSTEM ADD FOLLOWER "172.20.80.204:9010";'


# mysql --connect-timeout 10 -h fe01 -P 9030 -uroot \
# --skip-column-names --batch \
# -e 'ALTER SYSTEM ADD BACKEND "be01:9050";ALTER SYSTEM ADD BACKEND "be02:9050";ALTER SYSTEM ADD BACKEND "be03:9050";'
