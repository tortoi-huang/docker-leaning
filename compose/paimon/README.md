# 测试部署 paimon

## postgresql 配置

## minio 搭建
## flink 集群搭建


## flink sql
```sql
-- 注意这里创建的表是在 catalog: default_catalog 的 database: default_database 中
CREATE TABLE pg_orders_src (
  order_id BIGINT,
  user_id  BIGINT,
  status   STRING,
  amount   DECIMAL(12,2),
  order_time TIMESTAMP(3),
  PRIMARY KEY (order_id) NOT ENFORCED
) WITH (
  'connector' = 'postgres-cdc',
  'hostname' = 'postgres',
  'port' = '5432',
  'username' = 'cdc_user',
  'password' = 'cdc_password',
  'database-name' = 'appdb',
  'schema-name' = 'public',
  'table-name' = 'orders',
  'decoding.plugin.name' = 'pgoutput',
  'slot.name' = 'pg2paimon_orders_slot',
  -- 这里要和 postgresql 中配置一致, 如果不配置这项 cdc程序会尝试自己创建 PUBLICATION， 这需要超级用户权限
  'debezium.publication.name' = 'flink_pub',
  'debezium.publication.autocreate.mode' = 'disabled',
  'scan.startup.mode' = 'initial'
);


-- 注册指向 MinIO/S3 的 Paimon Catalog
CREATE CATALOG my_paimon WITH (
  'type' = 'paimon',
  'warehouse' = 's3a://sc-paimon-o4dcea/warehouse', 
  'fs.s3a.endpoint' = 'http://minio:9000',
  'fs.s3a.access.key' = 'paimon',
  'fs.s3a.secret.key' = 'MJdMWfCQnMk9cYex43WaJtXKVzupXfU2VnjjpNOe',
  'fs.s3a.path.style.access' = 'true',
  'fs.s3a.connection.ssl.enabled' = 'false'
);
USE CATALOG my_paimon;

CREATE DATABASE IF NOT EXISTS dwd;
USE dwd;

CREATE TABLE IF NOT EXISTS orders (
  order_id    BIGINT,
  user_id     BIGINT,
  status      STRING,
  amount      DECIMAL(12,2),
  order_time  TIMESTAMP(3),
  PRIMARY KEY (order_id) NOT ENFORCED
) WITH (
  'bucket' = '4',
  'changelog-producer' = 'full-compaction'
);

INSERT INTO my_paimon.dwd.orders SELECT * FROM default_catalog.default_database.pg_orders_src;

```

## 查询paimon

```sql
-- 流式观察增量（示例）
SET 'execution.runtime-mode' = 'streaming';
SET 'sql-client.execution.result-mode' = 'tableau';
SELECT * FROM orders;

-- 批式 OLAP
RESET 'execution.runtime-mode';
SET 'execution.runtime-mode' = 'batch';
SELECT status, COUNT(*) AS cnt, SUM(amount) AS amt
FROM orders
GROUP BY status
ORDER BY amt DESC;

INSERT INTO dwd.orders SELECT * FROM pg_orders_src;
```