# doris 研究

1. 启动master
2. 启动初始化集群容器
3. 启动 follower
4. 启动 be



sudo docker run -it --rm --network doris_doris-net curlimages/curl sh
sudo docker run -it --rm --network doris_doris-net mysql:8.4.0 mysql -uroot -P9030 -hfe01
docker inspect --format "{{json .State.Health }}" fe01