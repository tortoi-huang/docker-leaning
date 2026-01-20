CREATE USER biz_user WITH PASSWORD 'biz_password';
CREATE DATABASE appdb
  ENCODING 'UTF8'
  OWNER biz_user;

-- 切换数据库
\c appdb

CREATE USER cdc_user WITH REPLICATION LOGIN PASSWORD 'cdc_password';

GRANT CONNECT ON DATABASE appdb TO cdc_user;
GRANT USAGE ON SCHEMA public TO cdc_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO cdc_user;

-- 这里要逐个用户，逐个schema授权，没办法一次授权全部
ALTER DEFAULT PRIVILEGES FOR ROLE biz_user IN SCHEMA public GRANT SELECT ON TABLES TO cdc_user;

-- 所有表变更都发布
CREATE PUBLICATION flink_pub FOR ALL TABLES;

-- 切换到 appdb 和 cdc_user，否则 biz_user 没有权限
\c appdb biz_user;

-- 在 ${POSTGRES_DB} 数据库下创建演示表与测试数据
CREATE TABLE IF NOT EXISTS public.orders (
  order_id    BIGINT PRIMARY KEY,
  user_id     BIGINT NOT NULL,
  status      VARCHAR(32) NOT NULL,
  amount      NUMERIC(12,2) NOT NULL,
  order_time  TIMESTAMP NOT NULL DEFAULT now()
);

-- CDC 建议：确保 UPDATE/DELETE 时可获取旧值
ALTER TABLE public.orders REPLICA IDENTITY FULL;

-- 一些初始数据
INSERT INTO public.orders (order_id, user_id, status, amount, order_time) VALUES
  (1, 101, 'NEW',    199.99, now()),
  (2, 102, 'PAID',   329.00, now()),
  (3, 103, 'CANCEL',  59.00, now());
