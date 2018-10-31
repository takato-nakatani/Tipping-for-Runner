#!/bin/bash
set -e

# initdbでdockerというユーザとデータベースを作成する
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE USER line_api_user;
    CREATE DATABASE app_db;
    GRANT ALL PRIVILEGES ON DATABASE app_db TO line_api_user;
EOSQL