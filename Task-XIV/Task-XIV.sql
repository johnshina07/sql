-- TASK XIV: BUSINESS INTELLIGENCE AND AI DATA PREPARATION
-- MySQL 8.0+ (window functions required)

DROP VIEW IF EXISTS TaskXIV_Customer_Features;
DROP TABLE IF EXISTS TaskXIV_Order_Details;
DROP TABLE IF EXISTS TaskXIV_Orders;
DROP TABLE IF EXISTS TaskXIV_Product;
DROP TABLE IF EXISTS TaskXIV_Customer;

CREATE TABLE TaskXIV_Customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(80)
);

CREATE TABLE TaskXIV_Product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(80) NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

CREATE TABLE TaskXIV_Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES TaskXIV_Customer(customer_id)
);

CREATE TABLE TaskXIV_Order_Details (
    detail_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES TaskXIV_Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES TaskXIV_Product(product_id)
);

INSERT INTO TaskXIV_Customer (customer_name, city) VALUES
('Aarav Kumar', 'Chennai'),
('Diya Sharma', 'Bengaluru'),
('Kabir Mehta', 'Mumbai'),
('Sara Thomas', 'Chennai'),
('Ishaan Roy', 'Hyderabad');

INSERT INTO TaskXIV_Product (product_name, category, price) VALUES
('Laptop', 'Electronics', 55000),
('Mouse', 'Accessories', 650),
('Phone', 'Electronics', 28000),
('Chair', 'Furniture', 7500),
('Keyboard', 'Accessories', 1200);

INSERT INTO TaskXIV_Orders (customer_id, order_date) VALUES
(1, '2026-01-05'), (1, '2026-02-10'), (2, '2026-01-12'),
(3, '2026-02-01'), (4, '2026-02-15'), (2, '2026-03-02');

INSERT INTO TaskXIV_Order_Details (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 55000), (1, 2, 2, 650), (2, 3, 1, 28000),
(3, 5, 2, 1200), (4, 4, 1, 7500), (5, 2, 3, 650),
(6, 3, 1, 28000);

-- 1. ANALYTICAL SALES REPORT BY PRODUCT CATEGORY
SELECT p.category,
       SUM(d.quantity) AS units_sold,
       SUM(d.quantity * d.unit_price) AS revenue
FROM TaskXIV_Order_Details d
JOIN TaskXIV_Product p ON p.product_id = d.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- 2. RANK PRODUCTS BY REVENUE
SELECT product_id, product_name, revenue,
       RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM (
    SELECT p.product_id, p.product_name,
           COALESCE(SUM(d.quantity * d.unit_price), 0) AS revenue
    FROM TaskXIV_Product p
    LEFT JOIN TaskXIV_Order_Details d ON d.product_id = p.product_id
    GROUP BY p.product_id, p.product_name
) AS product_sales;

-- 3. NUMBER EACH CUSTOMER'S ORDERS FROM NEWEST TO OLDEST
SELECT order_id, customer_id, order_date,
       ROW_NUMBER() OVER (
           PARTITION BY customer_id
           ORDER BY order_date DESC, order_id DESC
       ) AS order_number
FROM TaskXIV_Orders;

-- 4. CUSTOMER SEGMENTATION AND FEATURE EXTRACTION
CREATE VIEW TaskXIV_Customer_Features AS
SELECT c.customer_id,
       c.customer_name,
       c.city,
       COUNT(DISTINCT o.order_id) AS order_count,
       COALESCE(SUM(d.quantity * d.unit_price), 0) AS total_spent,
       COALESCE(AVG(d.quantity * d.unit_price), 0) AS average_line_value,
       COALESCE(SUM(d.quantity), 0) AS total_units,
       MAX(o.order_date) AS last_order_date,
       CASE
           WHEN COALESCE(SUM(d.quantity * d.unit_price), 0) >= 50000 THEN 'HIGH VALUE'
           WHEN COALESCE(SUM(d.quantity * d.unit_price), 0) >= 10000 THEN 'MEDIUM VALUE'
           WHEN COUNT(o.order_id) > 0 THEN 'LOW VALUE'
           ELSE 'NO PURCHASE'
       END AS customer_segment
FROM TaskXIV_Customer c
LEFT JOIN TaskXIV_Orders o ON o.customer_id = c.customer_id
LEFT JOIN TaskXIV_Order_Details d ON d.order_id = o.order_id
GROUP BY c.customer_id, c.customer_name, c.city;

SELECT * FROM TaskXIV_Customer_Features
ORDER BY total_spent DESC;

-- 5. PREPARE A SIMPLE NUMERIC FEATURE DATASET FOR EXPORT/AI EXPERIMENTS
SELECT customer_id,
       order_count,
       total_spent,
       average_line_value,
       total_units,
       CASE customer_segment
           WHEN 'HIGH VALUE' THEN 3
           WHEN 'MEDIUM VALUE' THEN 2
           WHEN 'LOW VALUE' THEN 1
           ELSE 0
       END AS segment_label
FROM TaskXIV_Customer_Features;
