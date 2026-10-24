-- Task IX: Sales and Customer Analytics System

CREATE TABLE Customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE Product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

CREATE TABLE Order_Details (
    order_detail_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

INSERT INTO Customer VALUES
(1, 'Arun', 'arun@example.com', 'Chennai'),
(2, 'Priya', 'priya@example.com', 'Bangalore'),
(3, 'Rahul', 'rahul@example.com', 'Hyderabad'),
(4, 'Sneha', 'sneha@example.com', 'Mumbai'),
(5, 'Kiran', 'kiran@example.com', 'Chennai');

INSERT INTO Product VALUES
(101, 'Laptop', 'Electronics', 55000.00),
(102, 'Mobile', 'Electronics', 20000.00),
(103, 'Chair', 'Furniture', 5000.00),
(104, 'Desk', 'Furniture', 8000.00),
(105, 'Headphones', 'Accessories', 2000.00);

INSERT INTO Orders VALUES
(1001, 1, '2026-01-10'),
(1002, 2, '2026-01-12'),
(1003, 1, '2026-02-05'),
(1004, 3, '2026-02-10'),
(1005, 4, '2026-03-01'),
(1006, 5, '2026-03-15');

INSERT INTO Order_Details VALUES
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

-- 1. Aggregate functions: COUNT, SUM, AVG, MIN, MAX
SELECT
    COUNT(*) AS total_order_items,
    SUM(od.quantity) AS total_units_sold,
    AVG(p.price) AS average_product_price,
    MIN(p.price) AS minimum_product_price,
    MAX(p.price) AS maximum_product_price
FROM Order_Details od
JOIN Product p ON od.product_id = p.product_id;

-- 2. Total sales report
SELECT SUM(od.quantity * p.price) AS total_sales
FROM Order_Details od
JOIN Product p ON od.product_id = p.product_id;

-- Sales by order
SELECT o.order_id, o.order_date, c.customer_name,
       SUM(od.quantity * p.price) AS order_total
FROM Orders o
JOIN Customer c ON o.customer_id = c.customer_id
JOIN Order_Details od ON o.order_id = od.order_id
JOIN Product p ON od.product_id = p.product_id
GROUP BY o.order_id, o.order_date, c.customer_name
ORDER BY order_total DESC;

-- 3. Top customers by purchase amount
SELECT c.customer_id, c.customer_name,
       SUM(od.quantity * p.price) AS total_purchase
FROM Customer c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Order_Details od ON o.order_id = od.order_id
JOIN Product p ON od.product_id = p.product_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_purchase DESC;

-- 4. Best-selling products by units sold
SELECT p.product_id, p.product_name,
       SUM(od.quantity) AS units_sold,
       SUM(od.quantity * p.price) AS sales_amount
FROM Product p
JOIN Order_Details od ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name
ORDER BY units_sold DESC;

-- 5. Category-wise sales analysis
SELECT p.category,
       SUM(od.quantity) AS total_units_sold,
       SUM(od.quantity * p.price) AS category_sales,
       AVG(p.price) AS average_product_price
FROM Product p
JOIN Order_Details od ON p.product_id = od.product_id
GROUP BY p.category
ORDER BY category_sales DESC;
