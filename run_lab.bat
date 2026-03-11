@echo off
chcp 65001 >nul

echo Running SQL lab...

set USER=root
set MYSQL_PATH=D:\Programs\Xampp\mysql\bin\mysql.exe
set SQL_FILE=lab.sql

"%MYSQL_PATH%" --default-character-set=utf8mb4 -u %USER% < %SQL_FILE%

pause