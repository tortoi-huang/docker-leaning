-- 1. 创建基础用户（最简版）
CREATE USER biz_user 
IDENTIFIED BY "StrongPass123!" 
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
-- 无限配额
QUOTA UNLIMITED ON users 
-- PASSWORD EXPIRE
;

-- 2. 授予基本权限
GRANT CREATE SESSION TO biz_user;
GRANT CONNECT TO biz_user;

-- 3. 授予资源权限（允许创建表等对象）
GRANT RESOURCE TO biz_user;

-- 4. 设置账户解锁
ALTER USER biz_user ACCOUNT UNLOCK;

-- 切换到 biz_user 登录
-- 基本表结构
CREATE TABLE employees (
    -- 主键列
    employee_id   NUMBER(6)       CONSTRAINT pk_employees PRIMARY KEY,
    -- 字符串类型
    first_name    VARCHAR2(50)    NOT NULL,
    last_name     VARCHAR2(50)    NOT NULL,
    email         VARCHAR2(100)   CONSTRAINT uq_employees_email UNIQUE,
    -- 数值类型
    salary        DECIMAL(8,2),     -- 8位数字，2位小数
    commission_pct NUMBER(2,2),    -- 百分比
    -- 日期时间类型
    hire_date     DATE            DEFAULT SYSDATE,
    birth_date    TIMESTAMP,
    -- 大文本类型
    resume        CLOB,
    -- 二进制类型
    photo         BLOB,
    
    -- 其他类型
    status        CHAR(1)         DEFAULT 'A',  -- A:Active, I:Inactive
    department_id INT
);

CREATE TABLE emp (
    -- 主键列
    employee_id   NUMBER(6)       CONSTRAINT pk_emp PRIMARY KEY,
    -- 字符串类型
    first_name    VARCHAR2(50)    NOT NULL,
    last_name     VARCHAR2(50)    NOT NULL
);

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS';


INSERT INTO employees (employee_id,first_name,last_name,email,salary,commission_pct,hire_date,birth_date,resume,photo,status,department_id) 
VALUES ( 1, 'hello', 'world', 'aaa@gmail.com', 10000.52, 0.5, '2026-01-01', '2000-12-30 23:59:59', 'i am hello world', null, 'A', 1235 );

INSERT INTO employees (employee_id,first_name,last_name,email,salary,commission_pct,hire_date,birth_date,resume,photo,status,department_id) 
VALUES ( 2, 'hello2', 'world2', 'aaa2@gmail.com', 10000.52, 0.5, '2026-01-01', '2000-12-30 23:59:59', 'i am hello world', UTL_RAW.CAST_TO_RAW('it should ba a photo here'), 'A', 1235 );


INSERT INTO emp (employee_id,first_name,last_name) 
VALUES ( 1, 'hello', 'world');

INSERT INTO emp (employee_id,first_name,last_name) 
VALUES ( 2, 'hello2', 'world2');




----------------kingbase

CREATE USER app_user WITH PASSWORD 'StrongP@ssw0rd';
CREATE SCHEMA app_user AUTHORIZATION app_user;
GRANT USAGE ON SCHEMA public TO app_user;

CREATE TABLE app_user.employees (
    -- 主键列
    employee_id   NUMBER(6)       CONSTRAINT pk_employees PRIMARY KEY,
    -- 字符串类型
    first_name    VARCHAR2(50)    NOT NULL,
    last_name     VARCHAR2(50)    NOT NULL,
    email         VARCHAR2(100)   CONSTRAINT uq_employees_email UNIQUE,
    -- 数值类型
    salary        DECIMAL(8,2),     -- 8位数字，2位小数
    commission_pct NUMBER(2,2),    -- 百分比
    -- 日期时间类型
    hire_date     DATE            DEFAULT SYSDATE,
    birth_date    TIMESTAMP,
    -- 大文本类型
    resume        CLOB,
    -- 二进制类型
    photo         BLOB,
    
    -- 其他类型
    status        CHAR(1)         DEFAULT 'A',  -- A:Active, I:Inactive
    department_id INT
);

CREATE TABLE app_user.emp (
    -- 主键列
    employee_id   NUMBER(6)       CONSTRAINT pk_emp PRIMARY KEY,
    -- 字符串类型
    first_name    VARCHAR2(50)    NOT NULL,
    last_name     VARCHAR2(50)    NOT NULL
);