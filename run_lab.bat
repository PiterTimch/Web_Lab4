@echo off
echo Running SQL lab...

REM --- Налаштування користувача та шляху до MySQL
set USER=root
set MYSQL_PATH=D:\Programs\Xampp\mysql\bin\mysql.exe
set SQL_FILE=lab.sql

REM --- Запуск SQL без вказання бази (створюється у скрипті)
"%MYSQL_PATH%" -u %USER% < %SQL_FILE%

pause