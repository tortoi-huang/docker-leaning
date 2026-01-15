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
-- 查看日志大小
SHOW PARAMETER db_recovery_file_dest;
--ALTER SYSTEM SET db_recovery_file_dest_size = 1G;
-- ALTER SYSTEM SET db_recovery_file_dest      = '/opt/oracle/oradata/recovery_area' SCOPE=spfile;

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
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
-- ALTER TABLE your_schema.your_table ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;

```

### 检查日志组件是否安装
```sql
-- 仍以 SYSDBA， 有输出表示安装了
DESC DBMS_LOGMNR;
DESC DBMS_LOGMNR_D;

-- 若未安装，可执行（路径依 ORACLE_HOME 而定）：
-- @$ORACLE_HOME/rdbms/admin/dbmslm.sql
-- @$ORACLE_HOME/rdbms/admin/dbmslmd.sql

```

### 配置CDC 用户权限

```sql

-- 仍以 SYSDBA 执行；非 CDB 环境仅建一次
CREATE TABLESPACE LOGMINER_TBS
  DATAFILE '/u01/app/oracle/oradata/xe/LOGMINER_TBS01.dbf'
  SIZE 25M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;

-- 一下以普通dba角色执行(也可以以sysdba角色执行)
-- 创建角色
CREATE ROLE cdc_logminer_privs;
-- 授权，注意所有V_$*对象，它的公共同义词是没有_的，其他用户查询应该用V$* 同义词
GRANT CREATE SESSION, EXECUTE_CATALOG_ROLE, SELECT_CATALOG_ROLE,
    SELECT ANY TRANSACTION, FLASHBACK ANY TABLE, SELECT ANY TABLE,
    LOCK ANY TABLE, SELECT ANY DICTIONARY TO cdc_logminer_privs;
-- GRANT SELECT ON SYSTEM.LOGMNR_COL$ TO cdc_logminer_privs;
-- GRANT SELECT ON SYSTEM.LOGMNR_OBJ$ TO cdc_logminer_privs;
-- GRANT SELECT ON SYSTEM.LOGMNR_USER$ TO cdc_logminer_privs;
-- GRANT SELECT ON SYSTEM.LOGMNR_UID$ TO cdc_logminer_privs;
GRANT SELECT ON V_$DATABASE TO cdc_logminer_privs;
GRANT SELECT ON V_$LOGMNR_CONTENTS TO cdc_logminer_privs;
GRANT SELECT ON V_$LOG TO cdc_logminer_privs;
GRANT SELECT ON V_$ARCHIVED_LOG TO cdc_logminer_privs;
GRANT SELECT ON V_$LOGFILE TO cdc_logminer_privs;
GRANT EXECUTE ON DBMS_LOGMNR TO cdc_logminer_privs;
GRANT EXECUTE ON DBMS_LOGMNR_D TO cdc_logminer_privs;
GRANT SELECT ON V_$LOG_HISTORY          TO cdc_logminer_privs;
GRANT SELECT ON V_$ARCHIVE_DEST_STATUS  TO cdc_logminer_privs;
GRANT SELECT ON V_$LOGMNR_LOGS          TO cdc_logminer_privs;
GRANT SELECT ON V_$LOGMNR_PARAMETERS    TO cdc_logminer_privs;
GRANT SELECT ON V_$TRANSACTION          TO cdc_logminer_privs;
GRANT SELECT ON V_$MYSTAT               TO cdc_logminer_privs;
GRANT SELECT ON V_$STATNAME             TO cdc_logminer_privs;
GRANT ANALYZE ANY TO cdc_logminer_privs;
GRANT CREATE TABLE, CREATE SEQUENCE TO cdc_logminer_privs;
-- Debezium Oracle Connector（Flink CDC 底层）在 LogMiner 模式下需要一个辅助表来记录 SCN（系统变更号），用于增量日志挖掘的状态管理。
GRANT LOGMINING TO cdc_logminer_privs;  -- 仅在 12c 上必须

-- 查询已授权的权限
SELECT 'SYS_PRIV' AS TYPE, PRIVILEGE AS NAME 
FROM DBA_SYS_PRIVS WHERE GRANTEE='CDC_LOGMINER_PRIVS'
UNION ALL
SELECT 'TAB_PRIV', PRIVILEGE||' ON '||OWNER||'.'||TABLE_NAME 
FROM DBA_TAB_PRIVS WHERE GRANTEE='CDC_LOGMINER_PRIVS'
UNION ALL
SELECT 'ROLE_PRIV', GRANTED_ROLE 
FROM DBA_ROLE_PRIVS WHERE GRANTEE='CDC_LOGMINER_PRIVS';


-- 创建用户
CREATE USER cdc_logminer IDENTIFIED BY oracle1 DEFAULT TABLESPACE LOGMINER_TBS QUOTA UNLIMITED ON LOGMINER_TBS;
GRANT cdc_logminer_privs TO cdc_logminer;

```

### 测试获取主库更新日志内容
使用 cdc_logminer 用户登录测试获取日志
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
