CREATE DATABASE app_db DEFAULT CHARACTER SET = utf8mb4;

CREATE USER 'admin_user'@'%' IDENTIFIED BY 'line_api_pass';

GRANT ALL ON app_db.* TO 'admin_user'@'%';

-- 必要があれば、初期DB設定を流し込む。

CHARACTER SET = utf8mb4,
--COLLATE utf8mb4_general_ci;