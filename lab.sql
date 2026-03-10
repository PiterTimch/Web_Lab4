-- 0. Створюємо базу
CREATE DATABASE IF NOT EXISTS navchalny_plan;
USE navchalny_plan;

-- 00. Таблиці для лабораторної
CREATE TABLE IF NOT EXISTS teachers(
    id INT AUTO_INCREMENT PRIMARY KEY,
    surname VARCHAR(50),
    name VARCHAR(50),
    birth_date DATE,
    phone VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS departments(
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS subjects(
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    teacher_id INT,
    hours INT,
    credits INT,
    created_at DATE,
    added_to_plan DATE,
    department_id INT,
    FOREIGN KEY (teacher_id) REFERENCES teachers(id),
    FOREIGN KEY (department_id) REFERENCES departments(id)
);

-- таблиці для тригерів
CREATE TABLE IF NOT EXISTS delete_log(
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_name VARCHAR(100),
    delete_time DATETIME
);

CREATE TABLE IF NOT EXISTS update_log(
    id INT AUTO_INCREMENT PRIMARY KEY,
    old_name VARCHAR(255)
);

-- 01. Тестові дані
INSERT INTO teachers(surname,name,birth_date,phone) VALUES
('Ivanenko','Ivan','1980-03-15','123456789'),
('Shevchenko','Taras','1975-06-09','987654321'),
('Petrenko','Olena','1990-12-01','555666777');

INSERT INTO departments(name) VALUES
('Mathematics'),('Physics'),('Computer Science');

INSERT INTO subjects(name,teacher_id,hours,credits,created_at,added_to_plan,department_id) VALUES
('Calculus',1,120,5,'2018-09-01','2019-09-01',1),
('Linear Algebra',1,100,4,'2017-09-01','2018-09-01',1),
('Quantum Mechanics',2,150,6,'2016-09-01','2017-09-01',2),
('Programming 101',3,80,3,'2020-09-01','2021-09-01',3),
('Data Structures',3,90,4,'2019-09-01','2020-09-01',3);

-- ==============================
-- 1–21. Твої запити (не змінював логіку)
-- ==============================
-- 1. Вивести список дисциплін певного викладача
SELECT t.surname AS Teacher, s.name AS Subject
FROM subjects s
JOIN teachers t ON s.teacher_id = t.id
WHERE t.surname = 'Ivanenko';

-- 2. Дисципліни з найбільшою та найменшою кількістю годин
SELECT name, hours
FROM subjects
WHERE hours = (SELECT MAX(hours) FROM subjects)
   OR hours = (SELECT MIN(hours) FROM subjects);

-- 3. Дисципліна з найдовшою назвою
SELECT name
FROM subjects
ORDER BY LENGTH(name) DESC
LIMIT 1;

-- 4. Скільки дисциплін веде кожен викладач
SELECT t.surname, COUNT(s.id) AS subject_count
FROM teachers t
LEFT JOIN subjects s ON t.id = s.teacher_id
GROUP BY t.surname;

-- 5. На яку букву припадає найбільше прізвищ викладачів
SELECT LEFT(surname,1) AS letter, COUNT(*) AS cnt
FROM teachers
GROUP BY letter
ORDER BY cnt DESC
LIMIT 1;

-- 6. Викладачі, прізвища яких закінчуються на "ко"
SELECT *
FROM teachers
WHERE surname LIKE '%ко';

-- 7. Викладачі, у яких сьогодні день народження
SELECT *
FROM teachers
WHERE DAY(birth_date) = DAY(CURDATE())
AND MONTH(birth_date) = MONTH(CURDATE());

-- 8. Дисципліни, додані до навчального плану більше ніж через 4 роки після створення
SELECT name
FROM subjects
WHERE added_to_plan >= DATE_ADD(created_at, INTERVAL 4 YEAR);

-- 9. Дисципліни, створені у високосний рік
SELECT *
FROM subjects
WHERE YEAR(created_at) % 4 = 0;

-- 10. Назва дисципліни та скільки років минуло з моменту створення
SELECT name,
TIMESTAMPDIFF(YEAR, created_at, CURDATE()) AS Years_old
FROM subjects;

-- 11. Додати нового викладача (себе)
INSERT INTO teachers(surname,name,birth_date,phone)
VALUES('Petrenko','Ivan','2003-01-01','123456789');

-- 12. Додати 3 нові поля до таблиці дисциплін
ALTER TABLE subjects
ADD COLUMN semester INT,
ADD COLUMN classroom VARCHAR(50),
ADD COLUMN control_type VARCHAR(50);

-- 13. Видалити дисципліни певного викладача
DELETE s
FROM subjects s
JOIN teachers t ON s.teacher_id = t.id
WHERE t.surname = 'Petrenko';

-- 14. Скільки дисциплін у кожній кафедрі
SELECT d.name, COUNT(s.id) AS subject_count
FROM departments d
LEFT JOIN subjects s ON d.id = s.department_id
GROUP BY d.name;

-- 15. Список всіх дисциплін
SELECT s.id, s.name, t.surname
FROM subjects s
JOIN teachers t ON s.teacher_id = t.id;

-- 16. Представлення для викладачів
CREATE OR REPLACE VIEW teacher_view AS
SELECT 
id,
surname,
CONCAT(LEFT(name,1),'.') AS initials,
CONCAT(birth_date,' ',phone) AS personal_data
FROM teachers;

-- 17. Представлення статистики дисциплін
CREATE OR REPLACE VIEW subjectstat AS
SELECT s.id,
s.name,
COUNT(*) OVER (PARTITION BY teacher_id) AS cnt
FROM subjects s;

-- 18. Процедура показує всі дисципліни
DELIMITER //
CREATE PROCEDURE show_subjects()
BEGIN
SELECT * FROM subjects;
END //
DELIMITER ;

-- 19. Кількість дисциплін викладача
DELIMITER //
CREATE PROCEDURE subjects_by_teacher(IN tid INT)
BEGIN
SELECT COUNT(*)
FROM subjects
WHERE teacher_id = tid;
END //
DELIMITER ;

-- 20. Дисципліни у діапазоні кредитів
DELIMITER //
CREATE PROCEDURE subjects_credits(IN minc INT, IN maxc INT)
BEGIN
SELECT *
FROM subjects
WHERE credits BETWEEN minc AND maxc;
END //
DELIMITER ;

-- 21. Категорії дисциплін за кількістю годин
SELECT name,
CASE
WHEN hours < 60 THEN 'Light'
WHEN hours BETWEEN 60 AND 120 THEN 'Medium'
ELSE 'Heavy'
END AS category
FROM subjects;

-- 23. Тригер DELETE
DELIMITER //
CREATE TRIGGER before_delete_subject
BEFORE DELETE ON subjects
FOR EACH ROW
BEGIN
INSERT INTO delete_log(user_name, delete_time)
VALUES(USER(), NOW());
END //
DELIMITER ;

-- 24. тригер INSERT
DELIMITER //
CREATE TRIGGER after_insert_subject
AFTER INSERT ON subjects
FOR EACH ROW
BEGIN
SET @cnt = (SELECT COUNT(*) FROM subjects);
END //
DELIMITER ;

-- тригер UPDATE
DELIMITER //
CREATE TRIGGER before_update_subject
BEFORE UPDATE ON subjects
FOR EACH ROW
BEGIN
INSERT INTO update_log(old_name)
VALUES(OLD.name);
END //
DELIMITER ;