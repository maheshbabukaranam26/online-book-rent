-- Mahesh Online Book Rental Management (MySQL 8+)
CREATE DATABASE IF NOT EXISTS book_rental_db; USE book_rental_db;
CREATE TABLE members (member_id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100) NOT NULL, email VARCHAR(100) UNIQUE NOT NULL, phone VARCHAR(20), plan ENUM('Basic','Premium') DEFAULT 'Basic');
CREATE TABLE books (book_id INT AUTO_INCREMENT PRIMARY KEY, title VARCHAR(150) NOT NULL, author VARCHAR(100) NOT NULL, category VARCHAR(50), copies INT NOT NULL CHECK (copies >= 0), available_copies INT NOT NULL CHECK (available_copies >= 0), rent_per_week DECIMAL(8,2) NOT NULL, rating DECIMAL(2,1), CHECK (available_copies <= copies));
CREATE TABLE rentals (rental_id INT AUTO_INCREMENT PRIMARY KEY, member_id INT NOT NULL, book_id INT NOT NULL, rent_date DATE NOT NULL, due_date DATE NOT NULL, return_date DATE NULL, weeks INT NOT NULL, rent_fee DECIMAL(8,2) NOT NULL, late_fee DECIMAL(8,2) DEFAULT 0, FOREIGN KEY (member_id) REFERENCES members(member_id), FOREIGN KEY (book_id) REFERENCES books(book_id));
DELIMITER //
CREATE TRIGGER trg_rent BEFORE INSERT ON rentals FOR EACH ROW BEGIN
  IF (SELECT available_copies FROM books WHERE book_id = NEW.book_id) < 1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No copies available'; END IF; END//
CREATE TRIGGER trg_rent_after AFTER INSERT ON rentals FOR EACH ROW BEGIN UPDATE books SET available_copies = available_copies - 1 WHERE book_id = NEW.book_id; END//
CREATE TRIGGER trg_return AFTER UPDATE ON rentals FOR EACH ROW BEGIN
  IF OLD.return_date IS NULL AND NEW.return_date IS NOT NULL THEN UPDATE books SET available_copies = available_copies + 1 WHERE book_id = NEW.book_id; END IF; END//
DELIMITER ;
INSERT INTO members (name,email,phone,plan) VALUES ('Ravi Kumar','ravi@mail.com','98480 11111','Premium'),('Sneha Reddy','sneha@mail.com','98480 22222','Basic');
INSERT INTO books (title,author,category,copies,available_copies,rent_per_week,rating) VALUES ('The Alchemist','Paulo Coelho','Fiction',6,6,25,4.6),('Atomic Habits','James Clear','Self-help',8,8,30,4.7);
-- Overdue: SELECT m.name,b.title,r.due_date,DATEDIFF(CURDATE(),r.due_date)*5 AS late_fee FROM rentals r JOIN members m USING(member_id) JOIN books b USING(book_id) WHERE r.return_date IS NULL AND r.due_date < CURDATE();
-- Monthly revenue: SELECT DATE_FORMAT(rent_date,'%Y-%m') AS month, SUM(rent_fee+late_fee) AS revenue FROM rentals GROUP BY month;
