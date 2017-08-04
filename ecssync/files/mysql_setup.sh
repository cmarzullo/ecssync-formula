# Simple script to secure db and clearn up
mysql -u root -e "UPDATE mysql.user SET Password=PASSWORD('{{ config.dbpass }}') WHERE User='root'"
mysql -u root -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
mysql -u root -e "DELETE FROM mysql.user WHERE User=''"
mysql -u root -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
mysql -u root -e "CREATE DATABASE IF NOT EXISTS ecs_sync DEFAULT CHARSET = utf8mb4 DEFAULT COLLATE = utf8mb4_bin"
mysql -u root -e "CREATE USER '{{ config.user }}'@'%' IDENTIFIED BY '{{ config.password }}'"
mysql -u root -e "GRANT ALL ON ecs_sync.* TO '{{ config.user }}'@'%'"
mysql -u root -e "FLUSH PRIVILEGES"
