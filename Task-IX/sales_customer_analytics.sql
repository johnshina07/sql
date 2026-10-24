-- TASK IX: SALES AND CUSTOMER ANALYTICS SYSTEM

-- STEP 1: CREATE AND SELECT A SEPARATE DATABASE

CREATE DATABASE IF NOT EXISTS task9_db;
USE task9_db;


-- STEP 2: CREATE TABLES

CREATE TABLE IF NOT EXISTS Customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS Product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

CREATE TABLE IF NOT EXISTS Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id)
        REFERENCES Customer(customer_id)
);

CREATE TABLE IF NOT EXISTS Order_Details (
    order_detail_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id)
        REFERENCES Orders(order_id),
    FOREIGN KEY (product_id)
        REFERENCES Product(product_id)
);


-- STEP 3: INSERT CUSTOMER DATA

INSERT IGNORE INTO Customer VALUES
(1, 'Arun', 'arun@example.com', 'Chennai'),
(2, 'Priya', 'priya@example.com', 'Bangalore'),
(3, 'Rahul', 'rahul@example.com', 'Hyderabad'),
(4, 'Sneha', 'sneha@example.com', 'Mumbai'),
(5, 'Kiran', 'kiran@example.com', 'Chennai');


-- STEP 4: INSERT PRODUCT DATA

INSERT IGNORE INTO Product VALUES
(101, 'Laptop', 'Electronics', 55000.00),
(102, 'Mobile', 'Electronics', 20000.00),
(103, 'Chair', 'Furniture', 5000.00),
(104, 'Desk', 'Furniture', 8000.00),
(105, 'Headphones', 'Accessories', 2000.00);


-- STEP 5: INSERT ORDER DATA

INSERT IGNORE INTO Orders VALUES
(1001, 1, '2026-01-10'),
(1002, 2, '2026-01-12'),
(1003, 1, '2026-02-05'),
(1004, 3, '2026-02-10'),
(1005, 4, '2026-03-01'),
(1006, 5, '2026-03-15');


-- STEP 6: INSERT ORDER DETAILS

INSERT IGNORE INTO Order_Details VALUES
(1, 1001, 101, 1),
(2, 1001, 105, 2),
(3, 1002, 102, 1),
(4, 1002, 103, 2),
(5, 1003, 102, 2),
(6, 1003, 105, 1),
(7, 1004, 101, 1),
(8, 1004, 104, 2),
(9, 1005, 103, 3),
(10, 1006, 105, 4);


-- STEP 7: AGGREGATE FUNCTIONS

SELECT
    COUNT(*) AS total_order_items,
    SUM(od.quantity) AS total_units_sold,
    AVG(p.price) AS average_product_price,
    MIN(p.price) AS minimum_product_price,
    MAX(p.price) AS maximum_product_price
FROM Order_Details od
JOIN Product p
    ON od.product_id = p.product_id;


-- STEP 8: TOTAL SALES REPORT

SELECT
    SUM(od.quantity * p.price) AS total_sales
FROM Order_Details od
JOIN Product p
    ON od.product_id = p.product_id;


-- STEP 9: SALES BY ORDER

SELECT
    o.order_id,
    o.order_date,
    c.customer_name,
    SUM(od.quantity * p.price) AS order_total
FROM Orders o
JOIN Customer c
    ON o.customer_id = c.customer_id
JOIN Order_Details od
    ON o.order_id = od.order_id
JOIN Product p
    ON od.product_id = p.product_id
GROUP BY
    o.order_id,
    o.order_date,
    c.customer_name
ORDER BY order_total DESC;


-- STEP 10: TOP CUSTOMERS BY PURCHASE AMOUNT

SELECT
    c.customer_id,
    c.customer_name,
    SUM(od.quantity * p.price) AS total_purchase
FROM Customer c
JOIN Orders o
    ON c.customer_id = o.customer_id
JOIN Order_Details od
    ON o.order_id = od.order_id
JOIN Product p
    ON od.product_id = p.product_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_purchase DESC;


-- STEP 11: BEST-SELLING PRODUCTS

SELECT
    p.product_id,
    p.product_name,
    COALESCE(SUM(od.quantity), 0) AS units_sold,
    COALESCE(SUM(od.quantity * p.price), 0) AS sales_amount
FROM Product p
LEFT JOIN Order_Details od
    ON p.product_id = od.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY units_sold DESC;


-- STEP 12: CATEGORY-WISE SALES ANALYSIS

SELECT
    p.category,
    SUM(od.quantity) AS total_units_sold,
    SUM(od.quantity * p.price) AS category_sales,
    AVG(p.price) AS average_product_price
FROM Product p
JOIN Order_Details od
    ON p.product_id = od.product_id
GROUP BY p.category
ORDER BY category_sales DESC;


-- STEP 13: CUSTOMER-WISE SALES REPORT

SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(od.quantity * p.price), 0) AS total_purchase
FROM Customer c
LEFT JOIN Orders o
    ON c.customer_id = o.customer_id
LEFT JOIN Order_Details od
    ON o.order_id = od.order_id
LEFT JOIN Product p
    ON od.product_id = p.product_id
GROUP BY
    c.customer_id,
    c.customer_name,
    c.city
ORDER BY total_purchase DESC;
