# doris 研究

集群首次启动顺序
1. 启动master, 因为 新的follower启动必须通过helper参数指定 master
2. 启动 follower 命令行附带 helper 参数指向master
3. 启动 be 
4. 启动初始化集群容器, 实测如果fe还没启动完成可能会导致fe连接不到be，并且无法自动恢复

集群非首次启动顺序
1. 启动 fe, 所有fe一起启动, 并且不能附带命令行 helper 参数, 因为不知道哪个fe是master
2. 启动 be


sudo docker run -it --rm --network doris_doris-net curlimages/curl sh
sudo docker run -it --rm --network doris_doris-net mysql:8.4.0 mysql -uroot -P9030 -hfe01
docker inspect --format "{{json .State.Health }}" fe01

sudo docker run -it --rm --network doris_doris-net -e FE_SERVERS=fe01,fe02,fe03 -e BE_SERVERS=be01,be02,be03 mysql:8.4.0 sh