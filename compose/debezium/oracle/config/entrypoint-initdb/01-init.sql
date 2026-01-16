

-- 引用不存在变量直接报错
SET UNDEFINED ERROR;
/*
 开启归档日志
*/
-- 查看日志大小
-- SHOW PARAMETER db_recovery_file_dest;
-- 查看是否启动归档日志
-- SELECT log_mode FROM v$database;
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

/*
 安装 LOGMNR
*/
-- 仍以 SYSDBA， 有输出表示安装了
-- DESC DBMS_LOGMNR;
-- DESC DBMS_LOGMNR_D;

-- 若未安装，可执行（路径依 ORACLE_HOME 而定）：
-- @$ORACLE_HOME/rdbms/admin/dbmslm.sql
-- @$ORACLE_HOME/rdbms/admin/dbmslmd.sql

/*
 配置用户权限
*/
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

-- 创建用户
CREATE USER cdc_logminer IDENTIFIED BY oracle1 DEFAULT TABLESPACE LOGMINER_TBS QUOTA UNLIMITED ON LOGMINER_TBS;
GRANT cdc_logminer_privs TO cdc_logminer;