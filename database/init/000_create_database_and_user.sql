CREATE DATABASE IF NOT EXISTS duckhat
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'duckhat_user'@'%' IDENTIFIED BY 'duckhat_pass';
GRANT ALL PRIVILEGES ON duckhat.* TO 'duckhat_user'@'%';
FLUSH PRIVILEGES;

ALTER DATABASE duckhat CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE duckhat;
