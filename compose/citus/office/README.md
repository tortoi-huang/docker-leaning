# citus 官方demo
这里参考了[citus官方12.1.6版本](https://github.com/citusdata/docker)
## 官方镜像
### 安装扩展
citus12.1.6 官方镜像基于 postgres 官方镜像 postgres:16.6 构建，在 postgres 镜像基础上安装了以下软件
```bash
# 安装软件源
# curl -s https://install.citusdata.com/community/deb.sh | bash
# 安装软件
apt-get install -y postgresql-16-citus-12.1=12.1.6 \
    postgresql-16-hll=2.18.citus-1 \
    postgresql-16-topn=2.6.0.citus-1
```
### 定制启动脚本
postgres 官方镜像首次启动时会执行 /docker-entrypoint-initdb.d 目录下的 sql 文件, citus 利用此特性初始化 citus 节点。

/docker-entrypoint-initdb.d/001-create-citus-extension.sql
```sql
-- wrap in transaction to ensure Docker flag always visible
BEGIN;
CREATE EXTENSION citus;

-- add Docker flag to node metadata
UPDATE pg_dist_node_metadata SET metadata=jsonb_insert(metadata, '{docker}', 'true');
COMMIT;
```

## 启动集群
```bash
# 启动集群 2 个节点
sudo docker compose up -d
sudo docker ps -a
# 扩展集群到3个节点
sudo docker compose up --scale worker=3 -d
sudo docker ps -a

# 删除集群
# sudo docker compose down -v
```
## 检查集群
sudo docker exec -it office_master psql
```sql
-- 检查 citus 是否正常启动
SELECT * FROM pg_extension WHERE extname = 'citus';
-- 查询所有 worker 的状态
SELECT * FROM master_get_active_worker_nodes();
SELECT * FROM citus_get_active_worker_nodes();
```

## manager
manager 节点用来管理 worker 节点的扩容和缩容，如果不启动此容器，则需进入 master 手工执行添加或删除 worker 指令。

manager 是一个 python 脚本编写的守护进程，需要与宿主机的 docker 进程通信，不停的监控 docker 中 worker 容器的状态变化， 如果有 health 状态的则添加容器，如果是 destroy 状态则删除容器

manager 连接到 master 容器执行 sql
```sql
-- worker 容器添加时执行扩容的 sql
SELECT master_add_node(%(host)s, %(port)s)

-- worker 容器删除时执行缩容的 sql
DELETE FROM pg_dist_placement 
WHERE groupid = (SELECT groupid FROM pg_dist_node WHERE nodename = %(host)s AND nodeport = %(port)s LIMIT 1);
SELECT master_remove_node(%(host)s, %(port)s)
```

## 创建自定义database
官方镜像会在标准的 postgres database 初始化该数据为分布式数据库, 使用标准 psql 创建的数据库默认不具备分布式能力, 需要配置.

参考: [Creating a New Database](https://docs.citusdata.com/en/v10.2/admin_guide/cluster_management.html#creating-a-new-database)

在 master 和 所有的 worker 创建数据库，并启用 citus 插件
```sql
-- 创建数据库， TODO 目前只能在默认数据库测试成功，新建数据库无法创建分布式表
create database test_db;
\c test_db
-- 启动 citus 插件
CREATE EXTENSION citus;
```
在 master 添加 worker 节点
```sql
SELECT master_add_node('office-worker-1', '5432');
SELECT master_add_node('office-worker-2', '5432');
```

## 分片和副本

### 分片
```sql
-- 创建一个非分布式表
CREATE TABLE test_tb (
    id bigint NOT NULL,
    name text NOT NULL,
    image_url text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);
ALTER TABLE test_tb ADD PRIMARY KEY (id);
-- 将表 test_tb 变成分布式表， 并指定id列为分片列
SELECT create_distributed_table('test_tb', 'id');

insert into test_tb(id,name,image_url,created_at,updated_at) values(1,'name1','image url 1',DATE '2021-01-01',DATE '2022-01-01');

-- 修改默认分片数量
show citus.shard_count;
SET citus.shard_count = 64;
ALTER SYSTEM SET citus.shard_count TO 64;
```
### 副本
```sql
-- 查看副本数量 
SHOW citus.shard_replication_factor;
-- 副本数设置为2
-- 立刻生效, 重启后失效
SET citus.shard_replication_factor = 2;
-- 重启后生效, 不会立刻生效
ALTER SYSTEM SET citus.shard_replication_factor TO 2;
```
设置副本数量会影响性能，对于高并发建议每个节点使用 postgresql 的主从复制来保证数据一致性。

## 行级授权
```sql
CREATE USER user1 with PASSWORD 'pg1234';
GRANT select, update, insert, delete
  ON test_tb TO user1;

CREATE POLICY admin_all ON test_tb
  TO citus           -- 用户，假如用户存在
  USING (true)       -- 读取删除全部数据, 如在 select 或 where 条件中
  WITH CHECK (true); -- 增改所有数据， 如在 UPDATE or DELETE 字句中

CREATE POLICY tenant_role ON test_tb
  TO user1           -- 用户，假如用户存在
  USING (current_user='user' || id::text);       -- 当前用户等于 user 拼接查询的列数据， 这里当前用户current_user是 user1 那么 'user' || id::text 只有查询id = 1是返回为true

-- 启用策略
ALTER TABLE test_tb ENABLE ROW LEVEL SECURITY;
```

## 问题
1. 如果表定义了主键，则分布列必须是主键的一部分，否则定义主键无效。

## todo
1. 每个节点做主从复制