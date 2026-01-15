

-- 在 SQL CLI / SQL Gateway 会话中先设置作业名
SET 'pipeline.name' = 'employees_cdc_oracle_to_kingbase';
-- SET 'execution.savepoint.path' = 'file:///flink-savepoints/savepoint-<id>';

-- 推荐在会话或作业层启用 checkpoint 和重启策略（保障流式与容错）
SET 'execution.checkpointing.interval' = '10s';
SET 'execution.checkpointing.mode' = 'EXACTLY_ONCE';
SET 'restart-strategy' = 'fixed-delay';
SET 'restart-strategy.fixed-delay.attempts' = '10';
SET 'restart-strategy.fixed-delay.delay' = '5 s';

-- 状态后端配置
-- SET 'state.backend' = 'rocksdb';
-- SET 'state.backend.incremental' = 'true';                         -- 增量检查点
-- SET 'state.checkpoints.dir' = 'file:///opt/flink/checkpoints';    -- 检查点目录
-- SET 'state.savepoints.dir' = 'file:///opt/flink/savepoints';      -- 保存点目录

-- 建表中的字段名一定要严格和oracle 元数据表中存储的大小写一致，通常都是大写,
-- 1) Oracle CDC Source：先做快照(initial)，后续实时增量(LogMiner)
CREATE TABLE oracle_employees (
  EMPLOYEE_ID     INT,
  FIRST_NAME      STRING,
  LAST_NAME       STRING,
  EMAIL           STRING,
  SALARY          DECIMAL(8,2),
  COMMISSION_PCT  DECIMAL(2,2),
  HIRE_DATE       TIMESTAMP(3),
  BIRTH_DATE      TIMESTAMP(6),
  `RESUME`          STRING,     -- Oracle CLOB
  PHOTO           BYTES,      -- Oracle BLOB
  `STATUS`          STRING,     -- CHAR(1)
  DEPARTMENT_ID   INT,
  PRIMARY KEY (EMPLOYEE_ID) NOT ENFORCED
) WITH (
  'connector' = 'oracle-cdc',
  'hostname' = 'oracle',
  'port' = '1521',
  'username' = 'cdc_logminer',
  'password' = 'oracle1',
  'database-name' = 'xe',

  'schema-name' = 'BIZ_USER',
  'table-name'  = 'EMPLOYEES',

  -- 关键：首次全量快照 + 后续增量
  'scan.startup.mode' = 'initial',

  -- 使用 LogMiner 持续增量
  'debezium.log.mining.strategy' = 'online_catalog',
  'debezium.log.mining.continuous.mine' = 'true',

  -- 性能/延迟调优（可按需改）
  'debezium.log.mining.batch.size' = '1024',
  'debezium.log.mining.sleep.time.default' = '5000',
  -- 1. Debezium 日志级别
  'debezium.logging.level' = 'DEBUG',
    
    -- 2. 包含查询语句（Oracle LogMiner 查询）
   'debezium.include.query' = 'true'

  -- 如需时区、大小写敏感控制可添加：
  -- 'debezium.database.timezone' = 'Asia/Shanghai'
  -- 'debezium.database.tablename.case.insensitive' = 'false'
);

-- 2) Kingbase JDBC Sink：Upsert（需要主键）：
--   注意：建议 Kingbase 侧物理表类型与下列逻辑类型匹配：
--   employee_id INT PRIMARY KEY
--   first_name VARCHAR(50) NOT NULL
--   last_name  VARCHAR(50) NOT NULL
--   email      VARCHAR(100) UNIQUE
--   salary     NUMERIC(8,2)
--   commission_pct NUMERIC(2,2)
--   hire_date  TIMESTAMP
--   birth_date TIMESTAMP
--   resume     TEXT
--   photo      BYTEA
--   status     CHAR(1) DEFAULT 'A'
--   department_id INT
CREATE TABLE kingbase_employees (
  EMPLOYEE_ID     INT,
  FIRST_NAME      STRING,
  LAST_NAME       STRING,
  EMAIL           STRING,
  SALARY          DECIMAL(8,2),
  COMMISSION_PCT  DECIMAL(2,2),
  HIRE_DATE       TIMESTAMP(3),
  BIRTH_DATE      TIMESTAMP(6),
  `RESUME`          STRING,
  PHOTO           BYTES,
  `STATUS`          STRING,
  DEPARTMENT_ID   INT,
  PRIMARY KEY (EMPLOYEE_ID) NOT ENFORCED
) WITH (
  'connector' = 'jdbc',
  -- 'url' = 'jdbc:kingbase8://kingbase:54321/kingbase',
  'url' = 'jdbc:postgresql://kingbase:54321/kingbase?currentSchema=app_user',
  'table-name' = 'employees',
  'username' = 'app_user',
  'password' = 'StrongP@ssw0rd',
  -- 'driver' = 'com.kingbase8.Driver',
  'driver' = 'org.postgresql.Driver',

  -- Sink 调优：降低延迟同时兼顾吞吐
  'sink.max-retries' = '3',
  'sink.buffer-flush.max-rows' = '500',
  'sink.buffer-flush.interval' = '2s'
);


-- 3) 启动实时同步（一次 SQL：快照 + 增量持续）
INSERT INTO kingbase_employees
SELECT
  EMPLOYEE_ID,
  FIRST_NAME,
  LAST_NAME,
  EMAIL,
  SALARY,
  COMMISSION_PCT,
  HIRE_DATE,
  BIRTH_DATE,
  `RESUME`,
  PHOTO,
  `STATUS`,
  DEPARTMENT_ID
FROM oracle_employees;
