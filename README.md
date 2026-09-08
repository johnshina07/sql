# E-Commerce Order Management System

SQL implementation for Tasks I–VI using **MySQL 8.0+**.

## Tasks Covered

- **Task I:** Requirement Analysis and Customer Database Module
- **Task II:** Product and Category Management System
- **Task III:** Seller and Inventory Management System
- **Task IV:** Order Management System
- **Task V:** Payment Transaction Management System
- **Task VI:** Product Review and Rating Management System

## How to Execute

1. Open MySQL Workbench or MySQL CLI.
2. Copy the SQL below into a new query window.
3. Execute the complete script.
4. The script creates the database, tables, sample data, and reports.

```sql
DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

-- ============================================================
-- TASK I: CUSTOMER DATABASE MODULE
-- ============================================================
CREATE TABLE Customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    address VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO Customer (customer_name, email, phone, address) VALUES
('Arun Kumar', 'arun@gmail.com', '9876543210', 'Chennai'),
('Priya Sharma', 'priya@gmail.com', '9876543211', 'Bangalore'),
('Rahul Das', 'rahul@gmail.com', '9876543212', 'Hyderabad'),
('Sneha Roy', 'sneha@gmail.com', '9876543213', 'Mumbai');

SELECT * FROM Customer;

-- ============================================================
-- TASK II: PRODUCT AND CATEGORY MANAGEMENT
-- ============================================================
CREATE TABLE Category (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255)
);

CREATE TABLE Product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(150) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

INSERT INTO Category (category_name, description) VALUES
('Electronics', 'Electronic devices and accessories'),
('Fashion', 'Clothing and fashion products'),
('Home', 'Home and kitchen products');

INSERT INTO Product (product_name, category_id, price, stock) VALUES
('Laptop', 1, 65000.00, 10),
('Smartphone', 1, 30000.00, 25),
('Headphones', 1, 2500.00, 40),
('T-Shirt', 2, 999.00, 50),
('Coffee Maker', 3, 4500.00, 15);

-- Product insertion
INSERT INTO Product (product_name, category_id, price, stock)
VALUES ('Smart Watch', 1, 5000.00, 20);

-- Product updating
UPDATE Product
SET price = 4800.00, stock = 22
WHERE product_name = 'Smart Watch';

-- Product deletion example
DELETE FROM Product
WHERE product_name = 'Smart Watch';

-- Category-wise product report
SELECT c.category_name,
       COUNT(p.product_id) AS product_count,
       COALESCE(SUM(p.stock), 0) AS total_stock,
       COALESCE(AVG(p.price), 0) AS average_price
FROM Category c
LEFT JOIN Product p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
ORDER BY c.category_name;

-- ============================================================
-- TASK III: SELLER AND INVENTORY MANAGEMENT
-- ============================================================
CREATE TABLE Seller (
    seller_id INT PRIMARY KEY AUTO_INCREMENT,
    seller_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20)
);

CREATE TABLE Inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    seller_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    status ENUM('AVAILABLE', 'UNAVAILABLE') NOT NULL DEFAULT 'AVAILABLE',
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE (seller_id, product_id),
    FOREIGN KEY (seller_id) REFERENCES Seller(seller_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

INSERT INTO Seller (seller_name, email, phone) VALUES
('Tech World', 'techworld@gmail.com', '9000000001'),
('Fashion Hub', 'fashionhub@gmail.com', '9000000002'),
('Home Store', 'homestore@gmail.com', '9000000003');

INSERT INTO Inventory (seller_id, product_id, quantity, status) VALUES
(1, 1, 5, 'AVAILABLE'),
(1, 2, 12, 'AVAILABLE'),
(1, 3, 0, 'UNAVAILABLE'),
(2, 4, 30, 'AVAILABLE'),
(3, 5, 0, 'UNAVAILABLE');

-- Inventory status report
SELECT s.seller_name,
       p.product_name,
       i.quantity,
       i.status,
       i.last_updated
FROM Inventory i
JOIN Seller s ON i.seller_id = s.seller_id
JOIN Product p ON i.product_id = p.product_id
ORDER BY s.seller_name, p.product_name;

-- Available products
SELECT p.product_name, s.seller_name, i.quantity
FROM Inventory i
JOIN Product p ON i.product_id = p.product_id
JOIN Seller s ON i.seller_id = s.seller_id
WHERE i.status = 'AVAILABLE' AND i.quantity > 0;

-- Unavailable products
SELECT p.product_name, s.seller_name, i.quantity
FROM Inventory i
JOIN Product p ON i.product_id = p.product_id
JOIN Seller s ON i.seller_id = s.seller_id
WHERE i.status = 'UNAVAILABLE' OR i.quantity = 0;

-- ============================================================
-- TASK IV: ORDER MANAGEMENT SYSTEM
-- ============================================================
CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    status ENUM('PENDING', 'CONFIRMED', 'SHIPPED', 'DELIVERED', 'CANCELLED')
           NOT NULL DEFAULT 'PENDING',
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

CREATE TABLE Order_Details (
    order_detail_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- Order insertion
INSERT INTO Orders (customer_id, total_amount, status)
VALUES (1, 67500.00, 'CONFIRMED');

INSERT INTO Order_Details (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 65000.00),
(1, 3, 1, 2500.00);

INSERT INTO Orders (customer_id, total_amount, status)
VALUES (2, 30999.00, 'DELIVERED');

INSERT INTO Order_Details (order_id, product_id, quantity, unit_price) VALUES
(2, 2, 1, 30000.00),
(2, 4, 1, 999.00);

-- Order modification
UPDATE Orders
SET status = 'SHIPPED'
WHERE order_id = 1;

-- Recalculate order totals from order details
UPDATE Orders o
SET total_amount = (
    SELECT COALESCE(SUM(od.subtotal), 0)
    FROM Order_Details od
    WHERE od.order_id = o.order_id
);

-- Customer order history report
SELECT c.customer_name,
       o.order_id,
       o.order_date,
       o.status,
       p.product_name,
       od.quantity,
       od.unit_price,
       od.subtotal,
       o.total_amount
FROM Customer c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Order_Details od ON o.order_id = od.order_id
JOIN Product p ON od.product_id = p.product_id
ORDER BY c.customer_id, o.order_date DESC;

-- ============================================================
-- TASK V: PAYMENT TRANSACTION MANAGEMENT
-- ============================================================
CREATE TABLE Payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    payment_mode ENUM('UPI', 'CREDIT_CARD', 'DEBIT_CARD', 'NET_BANKING', 'COD') NOT NULL,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(12,2) NOT NULL,
    status ENUM('SUCCESS', 'FAILED', 'PENDING', 'REFUNDED') NOT NULL,
    transaction_reference VARCHAR(100) UNIQUE,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

INSERT INTO Payment (order_id, payment_mode, payment_date, amount, status, transaction_reference) VALUES
(1, 'UPI', '2026-09-08 09:30:00', 67500.00, 'SUCCESS', 'TXN10001'),
(2, 'CREDIT_CARD', '2026-09-08 10:00:00', 30999.00, 'SUCCESS', 'TXN10002');

INSERT INTO Payment (order_id, payment_mode, payment_date, amount, status, transaction_reference) VALUES
(1, 'DEBIT_CARD', '2026-09-08 09:15:00', 67500.00, 'FAILED', 'TXN10003');

-- Successful transactions
SELECT * FROM Payment
WHERE status = 'SUCCESS'
ORDER BY payment_date DESC;

-- Failed transactions
SELECT * FROM Payment
WHERE status = 'FAILED'
ORDER BY payment_date DESC;

-- Payment methods used by customers
SELECT payment_mode,
       COUNT(*) AS transaction_count,
       SUM(amount) AS total_amount
FROM Payment
GROUP BY payment_mode
ORDER BY transaction_count DESC;

-- Payment transaction report
SELECT p.payment_id,
       c.customer_name,
       p.order_id,
       p.payment_mode,
       p.payment_date,
       p.amount,
       p.status,
       p.transaction_reference
FROM Payment p
JOIN Orders o ON p.order_id = o.order_id
JOIN Customer c ON o.customer_id = c.customer_id
ORDER BY p.payment_date DESC;

-- ============================================================
-- TASK VI: PRODUCT REVIEW AND RATING MANAGEMENT
-- ============================================================
CREATE TABLE Review (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    review_text VARCHAR(500),
    review_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

CREATE TABLE Rating (
    rating_id INT PRIMARY KEY AUTO_INCREMENT,
    review_id INT NOT NULL UNIQUE,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating DECIMAL(2,1) NOT NULL,
    FOREIGN KEY (review_id) REFERENCES Review(review_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    CHECK (rating BETWEEN 1 AND 5)
);

INSERT INTO Review (customer_id, product_id, review_text, review_date) VALUES
(1, 1, 'Excellent laptop with great performance.', '2026-09-01 10:00:00'),
(2, 2, 'Good smartphone and battery life.', '2026-09-02 11:00:00'),
(3, 3, 'Clear sound quality and comfortable.', '2026-09-03 12:00:00'),
(4, 4, 'Good quality and comfortable material.', '2026-09-04 13:00:00'),
(1, 2, 'Very useful phone for daily work.', '2026-09-05 14:00:00');

INSERT INTO Rating (review_id, product_id, customer_id, rating) VALUES
(1, 1, 1, 5.0),
(2, 2, 2, 4.0),
(3, 3, 3, 4.5),
(4, 4, 4, 3.5),
(5, 2, 1, 5.0);

-- Retrieve product review details
SELECT r.review_id,
       p.product_name,
       c.customer_name,
       r.review_text,
       rt.rating,
       r.review_date
FROM Review r
JOIN Product p ON r.product_id = p.product_id
JOIN Customer c ON r.customer_id = c.customer_id
JOIN Rating rt ON r.review_id = rt.review_id
ORDER BY r.review_date DESC;

-- Average product ratings using aggregate functions
SELECT p.product_id,
       p.product_name,
       COUNT(rt.rating_id) AS total_reviews,
       ROUND(AVG(rt.rating), 2) AS average_rating
FROM Product p
LEFT JOIN Rating rt ON p.product_id = rt.product_id
GROUP BY p.product_id, p.product_name
ORDER BY average_rating DESC;

-- Highly rated products (average rating >= 4)
SELECT p.product_id,
       p.product_name,
       ROUND(AVG(rt.rating), 2) AS average_rating
FROM Product p
JOIN Rating rt ON p.product_id = rt.product_id
GROUP BY p.product_id, p.product_name
HAVING AVG(rt.rating) >= 4.00
ORDER BY average_rating DESC;

-- ============================================================
-- FINAL SUMMARY REPORT
-- ============================================================
SELECT
    (SELECT COUNT(*) FROM Customer) AS total_customers,
    (SELECT COUNT(*) FROM Product) AS total_products,
    (SELECT COUNT(*) FROM Seller) AS total_sellers,
    (SELECT COUNT(*) FROM Orders) AS total_orders,
    (SELECT COUNT(*) FROM Payment) AS total_payments,
    (SELECT COUNT(*) FROM Review) AS total_reviews;
```

## Database Relationships

```text
Customer 1 -------- N Orders
Orders   1 -------- N Order_Details
Product  1 -------- N Order_Details
Category 1 -------- N Product
Seller   1 -------- N Inventory
Product  1 -------- N Inventory
Customer 1 -------- N Review
Product  1 -------- N Review
Review   1 -------- 1 Rating
Customer 1 -------- N Rating
Product  1 -------- N Rating
Orders   1 -------- N Payment
```

## Requirements Covered

| Task | Main Features |
|---|---|
| I | Customer table, customer records and retrieval |
| II | Category/Product tables, CRUD operations, category reports |
| III | Seller/Inventory tables, stock status and inventory reports |
| IV | Orders/Order_Details, insertion, modification and order history |
| V | Payment table, successful/failed transactions, method analysis and reports |
| VI | Review/Rating tables, feedback, average ratings and highly rated products |

## Notes

- Tested design is intended for **MySQL 8.0+**.
- `DROP DATABASE IF EXISTS ecommerce_db` removes the previous database before rebuilding it. Use it only when you want a clean reset.
- Foreign keys maintain relationships between customers, products, sellers, orders, payments, reviews and ratings.
