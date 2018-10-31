create role line_api_user login password 'line_api_pass';
create database app_db;
grant all privileges on database app_db to line_api_user;