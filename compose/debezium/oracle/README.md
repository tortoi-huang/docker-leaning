# 测试部署 oracle cdc

## oracle
oracle日志分为联机(实时)日志和归档日志。 默认归档日志是不启动的，联机日志容易丢失，启动归档日志后联机日志超出大小会报错到归档日志中。
### 启用 ARCHIVELOG
sys 用户以 sysdba 角色登录执行， 这段sql放在 /container-entrypoint-initdb.d 中执行了, /container-entrypoint-initdb.d 中的sql会以sys用户sysdba角色运行

```sql
SELECT log_mode FROM v$database;
-- 如果不是 ARCHIVELOG，需要 DBA 执行：
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;
```

### 配置 ARCHIVELOG
```sql
-- 开启所有表和列的变更日志, 只能在CDB$ROOT容器执行，默认容器可能不是这个
SELECT property_value FROM DATABASE_PROPERTIES WHERE property_name = 'LOCAL_UNDO_ENABLED'; 
-- 查看所有容器
SELECT CON_ID, NAME, OPEN_MODE FROM V$CONTAINERS;

ALTER SESSION SET CONTAINER = CDB$ROOT;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;


-- 建议开启 FORCE LOGGING（避免直写/批量装载绕过 redo）
ALTER DATABASE FORCE LOGGING;

-- 配置归档日志目录与容量（避免因空间不足导致归档失败）

-- 查看归档状态与目录
-- ARCHIVE LOG LIST;
-- SHOW PARAMETER log_archive_dest;
-- SHOW PARAMETER db_recovery_file_dest;
-- SHOW PARAMETER db_recovery_file_dest_size;

-- 配置归档日志大小，注意这个参数很重要，超出会被删除，需要确保在这个时间内cdc数据被订阅完，如使用 FRA（快速恢复区），考虑适当增大
ALTER SYSTEM SET db_recovery_file_dest_size = 40G SCOPE=BOTH;
-- SHOW PARAMETER db_recovery_file_dest_size;
```
### 配置查询日志用用户权限
需要在CDB$ROOT容器执行，如果每个容器配置不同才需要在具体容器覆盖
```sql
-- 创建 CDC 用户并授权
CREATE USER C##CDC IDENTIFIED BY "Cdc@123";

GRANT CREATE SESSION TO C##CDC CONTAINER=ALL;
GRANT SELECT ANY TABLE TO C##CDC CONTAINER=ALL;
GRANT SELECT ANY DICTIONARY TO C##CDC CONTAINER=ALL;
GRANT EXECUTE_CATALOG_ROLE TO C##CDC CONTAINER=ALL;

GRANT LOGMINING TO C##CDC CONTAINER=ALL;

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