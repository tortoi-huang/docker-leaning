# 测试部署 oracle cdc

## oracle

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