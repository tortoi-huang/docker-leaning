# 测试部署 oracle cdc

## oracle 配置
oracle日志分为联机(实时)日志和归档日志。 默认归档日志是不启动的，联机日志容易丢失，启动归档日志后联机日志超出大小会报错到归档日志中。

这里镜像truevoly/oracle-12c不支持开启主从同步，需要启动后进入容器手工配置oracle.
### 启用 ARCHIVELOG
sys 用户以 sysdba 角色登录执行， 这段sql放在 /container-entrypoint-initdb.d 中执行了, /container-entrypoint-initdb.d 中的sql会以sys用户sysdba角色运行

进入docker 容器并切换到oracle 使用sql plus执行， 容器外部sql执行无法关闭数据库
执行sqlplus通常不需要密码
/u01/app/oracle/product/12.1.0/xe/bin/sqlplus / as sysdba
```sql
SELECT log_mode FROM v$database;
-- 或者 
-- ARCHIVE LOG LIST;

-- 如果不是 ARCHIVELOG，需要按以下步骤开启
SHUTDOWN IMMEDIATE;
-- 查看启动状态: STARTED: 数据库实例启动但是未加载数据库, MOUNTED: 数据库已加载但未打开, OPEN: 数据库已经打开正常运行
--SELECT STATUS FROM V$INSTANCE;
-- SELECT OPEN_MODE FROM V$DATABASE;

-- 启动到 MOUNT 状态
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;

-- 建议开启 FORCE LOGGING（避免直写/批量装载绕过 redo）
ALTER DATABASE FORCE LOGGING;

-- 开启数据库及表级补充日志，确保 OLR 能捕获行级数据变化
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
-- ALTER TABLE your_schema.your_table ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;

```

### 配置查询日志用用户权限

```sql

-- 创建角色
CREATE ROLE cdc_logminer_privs;
GRANT CREATE SESSION, EXECUTE_CATALOG_ROLE, SELECT ANY TRANSACTION,
      FLASHBACK ANY TABLE, SELECT ANY TABLE, LOCK ANY TABLE,
      SELECT ANY DICTIONARY TO cdc_logminer_privs;
GRANT SELECT ON SYSTEM.LOGMNR_COL$ TO cdc_logminer_privs;
GRANT SELECT ON SYSTEM.LOGMNR_OBJ$ TO cdc_logminer_privs;
GRANT SELECT ON SYSTEM.LOGMNR_USER$ TO cdc_logminer_privs;
GRANT SELECT ON SYSTEM.LOGMNR_UID$ TO cdc_logminer_privs;
GRANT SELECT ON V_$DATABASE TO cdc_logminer_privs;
GRANT SELECT_CATALOG_ROLE TO cdc_logminer_privs;
GRANT LOGMINING TO cdc_logminer_privs;  -- 仅在 12c 上必须

-- 创建用户
CREATE USER cdc_logminer IDENTIFIED BY oracle1 DEFAULT TABLESPACE users;
GRANT cdc_logminer_privs TO cdc_logminer;
ALTER USER cdc_logminer QUOTA UNLIMITED ON users;

```
### 获取主库更新日志内容
```sql

-- 查询在线(实时)日志文件
SELECT MEMBER FROM V$LOGFILE;
-- 使用dba 和切换联机日志文件名，立刻归档，否则测试需要等一段时间才会归档
ALTER SYSTEM SWITCH LOGFILE;

-- 查询归档日志文件
SELECT MIN(FIRST_TIME) AS OLDEST_LOG,
       MAX(NEXT_TIME)  AS NEWEST_LOG,
       COUNT(*) AS LOG_COUNT
FROM   V$ARCHIVED_LOG
WHERE  DELETED = 'NO';


-- 启动 LogMiner（注意：这里使用的是 =>，不是 &gt;）
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';
BEGIN
  DBMS_LOGMNR.START_LOGMNR(
    STARTTIME => TO_DATE('2026-01-07 15:00:00','YYYY-MM-DD HH24:MI:SS'),
    ENDTIME   => TO_DATE('2026-01-09 16:30:00','YYYY-MM-DD HH24:MI:SS'),
    OPTIONS   => DBMS_LOGMNR.DICT_FROM_ONLINE_CATALOG + DBMS_LOGMNR.COMMITTED_DATA_ONLY
  );
END;
/

-- 查询日志
SELECT TIMESTAMP, SEG_OWNER, TABLE_NAME, OPERATION, SQL_REDO
FROM   V$LOGMNR_CONTENTS
WHERE  OPERATION IN ('INSERT','UPDATE','DELETE')
ORDER  BY TIMESTAMP DESC
FETCH FIRST 20 ROWS ONLY;

-- 结束 LogMiner 会话（释放资源）， 这是全局资源不会随着会话结束而结束，考虑每次START_LOGMNR前先执行结束会话
BEGIN
  DBMS_LOGMNR.END_LOGMNR();
END;
/

```

## kingbase
kingbase 不提供镜像源，没有开源镜像源， 官方提供的容器 tar下载，但是无法使用，需要自行构建镜像，参考目录 [kingbase](compose/kingbase/README.md)
