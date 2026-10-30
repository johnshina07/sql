-- TASK XV: INDUSTRY CAPSTONE PROJECT - E-COMMERCE INTELLIGENCE PLATFORM
-- MySQL 8.0+
-- Isolated Capstone_ tables. Run in a practice database.

DROP VIEW IF EXISTS Capstone_Sales_Report;
DROP PROCEDURE IF EXISTS Capstone_Place_Order;
DROP TRIGGER IF EXISTS Capstone_After_Order_Detail_Insert;
DROP TABLE IF EXISTS Capstone_Payment;
DROP TABLE IF EXISTS Capstone_Order_Details;
DROP TABLE IF EXISTS Capstone_Orders;
DROP TABLE IF EXISTS Capstone_Inventory;
DROP TABLE IF EXISTS Capstone_Product;
DROP TABLE IF EXISTS Capstone_Customer;

CREATE TABLE Capstone_Customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    city VARCHAR(80)
) ENGINE=InnoDB;

CREATE TABLE Capstone_Product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(120) NOT NULL,
    category VARCHAR(80) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0)
) ENGINE=InnoDB;

CREATE TABLE Capstone_Inventory (
    product_id INT PRIMARY KEY,
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0),
    FOREIGN KEY (product_id) REFERENCES Capstone_Product(product_id)
) ENGINE=InnoDB;

CREATE TABLE Capstone_Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    order_status VARCHAR(20) NOT NULL DEFAULT 'PLACED',
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES Capstone_Customer(customer_id)
) ENGINE=InnoDB;

CREATE TABLE Capstone_Order_Details (
    order_detail_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Capstone_Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Capstone_Product(product_id)
) ENGINE=InnoDB;

CREATE TABLE Capstone_Payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_mode VARCHAR(30) NOT NULL,
    payment_amount DECIMAL(12,2) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    transaction_reference VARCHAR(80) UNIQUE,
    FOREIGN KEY (order_id) REFERENCES Capstone_Orders(order_id)
) ENGINE=InnoDB;

-- SAMPLE BUSINESS DATA
INSERT INTO Capstone_Customer (customer_name, email, city) VALUES
('Aarav Kumar', 'aarav@example.com', 'Chennai'),
('Diya Sharma', 'diya@example.com', 'Bengaluru'),
('Kabir Mehta', 'kabir@example.com', 'Mumbai'),
('Sara Thomas', 'sara@example.com', 'Kochi');

INSERT INTO Capstone_Product (product_name, category, price) VALUES
('Laptop', 'Electronics', 55000),
('Smartphone', 'Electronics', 28000),
('Office Chair', 'Furniture', 7500),
('Keyboard', 'Accessories', 1200),
('Wireless Mouse', 'Accessories', 650);

INSERT INTO Capstone_Inventory (product_id, stock_quantity) VALUES
(1, 10), (2, 20), (3, 15), (4, 40), (5, 50);

-- INDEXES
CREATE INDEX idx_capstone_orders_customer_date
ON Capstone_Orders(customer_id, order_date);

CREATE INDEX idx_capstone_product_category
ON Capstone_Product(category);

CREATE INDEX idx_capstone_payment_status
ON Capstone_Payment(payment_status);

DELIMITER $$

-- TRIGGER: REDUCE INVENTORY WHEN AN ORDER DETAIL IS INSERTED.
CREATE TRIGGER Capstone_After_Order_Detail_Insert
AFTER INSERT ON Capstone_Order_Details
FOR EACH ROW
BEGIN
    UPDATE Capstone_Inventory
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
END$$

-- PROCEDURE: PLACE AN ORDER, UPDATE STOCK THROUGH THE TRIGGER,
-- CALCULATE THE ORDER TOTAL, AND RECORD A DEMO PAYMENT.
CREATE PROCEDURE Capstone_Place_Order(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    IN p_payment_mode VARCHAR(30)
)
BEGIN
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_stock INT;
    DECLARE v_order_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT price INTO v_price
    FROM Capstone_Product
    WHERE product_id = p_product_id;

    SELECT stock_quantity INTO v_stock
    FROM Capstone_Inventory
    WHERE product_id = p_product_id
    FOR UPDATE;

    IF v_price IS NULL OR v_stock IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product or inventory record not found';
    END IF;

    IF p_quantity <= 0 OR v_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid quantity or insufficient stock';
    END IF;

    INSERT INTO Capstone_Orders (customer_id, total_amount)
    VALUES (p_customer_id, v_price * p_quantity);

    SET v_order_id = LAST_INSERT_ID();

    INSERT INTO Capstone_Order_Details (order_id, product_id, quantity, unit_price)
    VALUES (v_order_id, p_product_id, p_quantity, v_price);

    INSERT INTO Capstone_Payment
    (order_id, payment_mode, payment_amount, payment_status, transaction_reference)
    VALUES
    (v_order_id, p_payment_mode, v_price * p_quantity, 'SUCCESS',
     CONCAT('DEMO-', v_order_id, '-', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s')));

    COMMIT;
END$$

DELIMITER ;

-- PLACE SAMPLE ORDERS (these calls also reduce inventory).
CALL Capstone_Place_Order(1, 1, 1, 'UPI');
CALL Capstone_Place_Order(2, 4, 2, 'CARD');
CALL Capstone_Place_Order(3, 2, 1, 'UPI');
CALL Capstone_Place_Order(4, 5, 3, 'COD');

-- VIEW: CONSOLIDATED SALES REPORT
CREATE VIEW Capstone_Sales_Report AS
SELECT o.order_id, o.order_date, o.order_status,
       c.customer_name, c.city,
       p.product_name, p.category,
       d.quantity, d.unit_price,
       d.quantity * d.unit_price AS line_total,
       pay.payment_mode, pay.payment_status
FROM Capstone_Orders o
JOIN Capstone_Customer c ON c.customer_id = o.customer_id
JOIN Capstone_Order_Details d ON d.order_id = o.order_id
JOIN Capstone_Product p ON p.product_id = d.product_id
LEFT JOIN Capstone_Payment pay ON pay.order_id = o.order_id;

-- BASIC REPORT: ALL ORDER DETAILS
SELECT * FROM Capstone_Sales_Report ORDER BY order_id;

-- ADVANCED REPORT: CUSTOMER SPENDING
SELECT c.customer_id, c.customer_name,
       COALESCE(SUM(o.total_amount), 0) AS total_spent,
       COUNT(o.order_id) AS order_count
FROM Capstone_Customer c
LEFT JOIN Capstone_Orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC;

-- CATEGORY-WISE REVENUE
SELECT p.category,
       SUM(d.quantity) AS units_sold,
       SUM(d.quantity * d.unit_price) AS revenue
FROM Capstone_Order_Details d
JOIN Capstone_Product p ON p.product_id = d.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- INVENTORY STATUS
SELECT p.product_name, i.stock_quantity,
       CASE WHEN i.stock_quantity < 5 THEN 'LOW STOCK' ELSE 'AVAILABLE' END AS stock_status
FROM Capstone_Product p
JOIN Capstone_Inventory i ON i.product_id = p.product_id;

-- BUSINESS INSIGHTS: TOP PRODUCTS BY REVENUE
SELECT p.product_name, SUM(d.quantity * d.unit_price) AS revenue
FROM Capstone_Product p
JOIN Capstone_Order_Details d ON d.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC;

-- VERIFY DATABASE OBJECTS
SHOW FULL TABLES;
SHOW INDEX FROM Capstone_Orders;
