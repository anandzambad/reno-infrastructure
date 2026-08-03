-- Renevo database bootstrap for existing MySQL 5.7.
-- Run only against the existing MySQL instance after a backup.
-- Do not change existing databases or server-wide configuration.
-- Replace the password placeholder before manual use, or prefer Initialize-RenevoDatabase.ps1.

CREATE DATABASE IF NOT EXISTS `reno`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'reno_app'@'localhost' IDENTIFIED BY 'REPLACE_WITH_STRONG_PASSWORD';
GRANT ALL PRIVILEGES ON `reno`.* TO 'reno_app'@'localhost';
FLUSH PRIVILEGES;
