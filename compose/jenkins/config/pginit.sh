#!/bin/bash
set -e

# psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER:-postgres}" --dbname "$POSTGRES_DB" <<-EOSQL
psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER:-postgres}" <<-EOSQL
	CREATE USER bitbucket with password 'pwd123';
	CREATE DATABASE bitbucket;
	GRANT ALL PRIVILEGES ON DATABASE bitbucket TO bitbucket;
	\c bitbucket
	GRANT ALL PRIVILEGES ON SCHEMA public TO bitbucket;
EOSQL
