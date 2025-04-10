-- データベースを作成
CREATE DATABASE my_database;
USE my_database;

-- usersテーブルを作成
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    age INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- データベースを作成（すでに存在する場合は作成しない）
CREATE DATABASE IF NOT EXISTS my_database;
USE my_database;
