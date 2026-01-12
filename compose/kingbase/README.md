# 创建 kingbase 测试集群
官方没有发布docker 镜像仓库，但是提供了镜像tar下载。

截止 V9R1C10 版本, 官方下载的 kingbaseES 镜像不能使用，启动直接报错sudo: pam_open_session: Permission denied，主要原因是启动脚本中使用了sudo, 需要特殊的模式启动

## 重新构建镜像
### 获取构建文件
手动下载 kingbaseES docker镜像，假定镜像文件为 temp/kingbase-V9R1C10.tar
```bash
# 提取镜像层，通常需要额外安装 skopeo
skopeo copy docker-archive:temp/kingbase-V9R1C10.tar oci:temp/oci_store:kingbase

# 构建镜像文件系统, 构建后可以在 ./bundle/rootfs/看到整个镜像根目录， kingbase 安装文件位于 /home/kingbase/install/kingbase
# 通常需要额外安装 umoci
sudo umoci unpack --image temp/oci_store:kingbase temp/bundle

# 提取数据文件并更改为当前用户
sudo cp -r temp/bundle/rootfs/home/kingbase/install/kingbase image/
id -un | xargs -I{u} sudo chown -R {u} image/kingbase

sudo docker
```

### kingbase 备注
+ 程序目录不是静态的，启动时会写入licence文件，需要可写权限
+ kingbase启动的关键两个命令为：
```bash
# 首次启动初始化
bin/initdb -U kingbase -x mypassword -D /data/kingbase/data -E UTF-8
# 启动进程
bin/kingbase -D /data/kingbase/data
```


```sql
select * from all_all_tables;

SELECT version();

SELECT name, setting, short_desc
FROM sys_settings
WHERE name = 'database_mode';

SHOW database_mode;

CREATE USER app_user WITH PASSWORD 'StrongP@ssw0rd';

-- 注意oracle模式下创建数据库无法切换
-- CREATE DATABASE mydb;
-- drop database mydb;

SELECT datname FROM pg_database;

-- 偶发bug，app_schema没有成功授权 app_user， 再为app_user添加其他app_schema时会一起授权
CREATE SCHEMA app_schema AUTHORIZATION app_user;

-- 授予连接指定数据库的权限（如数据库名为 mydb）
GRANT CONNECT ON DATABASE kingbase TO app_user;

GRANT USAGE ON SCHEMA public TO app_user;

SELECT n.nspname, r.rolname AS owner, n.nspacl
FROM pg_namespace n
JOIN pg_roles r ON r.oid = n.nspowner
WHERE n.nspname IN ('app_schema'); 

create table app_schema.hello_world (
    id number primary key,
    message varchar2(100)
);

INSERT INTO app_schema.hello_world (id, message) VALUES (1, 'Hello, KingbaseES!');
INSERT INTO app_schema.hello_world (id, message) VALUES (2, 'Iello, KingbaseES!');

select * from app_schema.hello_world;

```