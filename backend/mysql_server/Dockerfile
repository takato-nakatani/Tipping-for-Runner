FROM mysql:latest

COPY ./conf/mysqld.cnf /etc/mysql/conf.d

COPY ./sql/ /docker-entrypoint-initdb.d

