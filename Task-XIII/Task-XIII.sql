-- TASK XIII: DATABASE SECURITY AND PERFORMANCE OPTIMIZATION
-- MySQL 8.0+
-- Run user/role statements only with an authorized administrative account.

DROP TABLE IF EXISTS TaskXIII_Orders;
DROP TABLE IF EXISTS TaskXIII_Customer;

CREATE TABLE TaskXIII_Customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    city VARCHAR(80)
) ENGINE=InnoDB;

CREATE TABLE TaskXIII_Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES TaskXIII_Customer(customer_id)
) ENGINE=InnoDB;

INSERT INTO TaskXIII_Customer (customer_name, email, city) VALUES
('Ananya Rao', 'ananya@example.com', 'Chennai'),
('Rohan Das', 'rohan@example.com', 'Bengaluru'),
('Meera Nair', 'meera@example.com', 'Kochi');

INSERT INTO TaskXIII_Orders (customer_id, order_date, total_amount, status) VALUES
(1, '2026-01-10', 2500.00, 'PAID'),
(2, '2026-01-12', 7200.00, 'PAID'),
(1, '2026-02-05', 1800.00, 'PENDING'),
(3, '2026-02-11', 4500.00, 'PAID');

-- INDEXES FOR COMMON SEARCHES
CREATE INDEX idx_taskxiii_customer_city
ON TaskXIII_Customer(city);

CREATE INDEX idx_taskxiii_orders_customer_date
ON TaskXIII_Orders(customer_id, order_date);

CREATE INDEX idx_taskxiii_orders_status
ON TaskXIII_Orders(status);

-- BEFORE/AFTER PLAN INSPECTION: use EXPLAIN to inspect index selection.
EXPLAIN
SELECT order_id, order_date, total_amount
FROM TaskXIII_Orders
WHERE customer_id = 1
ORDER BY order_date;

-- ROLE AND USER SETUP
-- Change the example password before running.
CREATE ROLE IF NOT EXISTS 'taskxiii_readonly';
GRANT SELECT ON TaskXIII_Customer TO 'taskxiii_readonly';
GRANT SELECT ON TaskXIII_Orders TO 'taskxiii_readonly';

CREATE USER IF NOT EXISTS 'taskxiii_viewer'@'localhost'
IDENTIFIED BY 'ChangeThis_StrongPassword_123!';

GRANT 'taskxiii_readonly' TO 'taskxiii_viewer'@'localhost';
SET DEFAULT ROLE 'taskxiii_readonly' TO 'taskxiii_viewer'@'localhost';

-- Demonstrate REVOKE (removes a privilege from the role).
GRANT INSERT ON TaskXIII_Orders TO 'taskxiii_readonly';
REVOKE INSERT ON TaskXIII_Orders FROM 'taskxiii_readonly';

-- Verify indexes and grants (run with suitable privileges).
SHOW INDEX FROM TaskXIII_Orders;
SHOW GRANTS FOR 'taskxiii_viewer'@'localhost';

-- Optional cleanup of the demo account:
-- DROP USER 'taskxiii_viewer'@'localhost';
-- DROP ROLE 'taskxiii_readonly';
