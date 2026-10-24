-- Task X: Advanced SQL Query System
-- Standalone tables so this task can run independently of other tasks.

CREATE TABLE Advanced_Customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE Advanced_Product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

CREATE TABLE Advanced_Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Advanced_Customer(customer_id)
);

CREATE TABLE Advanced_Order_Details (
    order_detail_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES Advanced_Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Advanced_Product(product_id)
);

-- Sample customers
INSERT INTO Advanced_Customer VALUES
(1, 'Arun', 'Chennai'),
(2, 'Priya', 'Bangalore'),
(3, 'Rahul', 'Hyderabad'),
(4, 'Sneha', 'Mumbai'),
(5, 'Kiran', 'Chennai');

-- Sample products
INSERT INTO Advanced_Product VALUES
(101, 'Laptop', 'Electronics', 55000.00),
(102, 'Mobile', 'Electronics', 20000.00),
(103, 'Chair', 'Furniture', 5000.00),
(104, 'Desk', 'Furniture', 8000.00),
(105, 'Headphones', 'Accessories', 2000.00);

-- Sample orders
INSERT INTO Advanced_Orders VALUES
(1001, 1, '2026-01-10'),
(1002, 2, '2026-01-12'),
(1003, 1, '2026-02-05'),
(1004, 3, '2026-02-10'),
(1005, 4, '2026-03-01'),
(1006, 5, '2026-03-15');

-- Sample order details
INSERT INTO Advanced_Order_Details VALUES
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

-- 1. Subquery: products priced above the overall average price
SELECT product_id, product_name, category, price
FROM Advanced_Product
WHERE price > (SELECT AVG(price) FROM Advanced_Product)
ORDER BY price DESC;

-- 2. Nested query: customers whose total spending is above the average
-- spending per customer (including customers with no orders in the average).
SELECT c.customer_id, c.customer_name, COALESCE(s.total_spent, 0) AS total_spent
FROM Advanced_Customer c
LEFT JOIN (
    SELECT o.customer_id, SUM(od.quantity * p.price) AS total_spent
    FROM Advanced_Orders o
    JOIN Advanced_Order_Details od ON od.order_id = o.order_id
    JOIN Advanced_Product p ON p.product_id = od.product_id
    GROUP BY o.customer_id
) s ON s.customer_id = c.customer_id
WHERE COALESCE(s.total_spent, 0) > (
    SELECT AVG(customer_total)
    FROM (
        SELECT c2.customer_id,
               COALESCE(SUM(od2.quantity * p2.price), 0) AS customer_total
        FROM Advanced_Customer c2
        LEFT JOIN Advanced_Orders o2 ON o2.customer_id = c2.customer_id
        LEFT JOIN Advanced_Order_Details od2 ON od2.order_id = o2.order_id
        LEFT JOIN Advanced_Product p2 ON p2.product_id = od2.product_id
        GROUP BY c2.customer_id
    ) AS customer_spending
)
ORDER BY total_spent DESC;

-- 3. Identify customer(s) with the maximum purchase amount.
-- Returns ties if multiple customers share the maximum.
SELECT customer_id, customer_name, total_purchase
FROM (
    SELECT c.customer_id, c.customer_name,
           SUM(od.quantity * p.price) AS total_purchase
    FROM Advanced_Customer c
    JOIN Advanced_Orders o ON o.customer_id = c.customer_id
    JOIN Advanced_Order_Details od ON od.order_id = o.order_id
    JOIN Advanced_Product p ON p.product_id = od.product_id
    GROUP BY c.customer_id, c.customer_name
) AS customer_totals
WHERE total_purchase = (
    SELECT MAX(total_purchase)
    FROM (
        SELECT o.customer_id, SUM(od.quantity * p.price) AS total_purchase
        FROM Advanced_Orders o
        JOIN Advanced_Order_Details od ON od.order_id = o.order_id
        JOIN Advanced_Product p ON p.product_id = od.product_id
        GROUP BY o.customer_id
    ) AS totals
);

-- 4. Complex business query: order-level revenue and customer details
SELECT o.order_id, o.order_date, c.customer_name, c.city,
       SUM(od.quantity) AS units_ordered,
       SUM(od.quantity * p.price) AS order_value
FROM Advanced_Orders o
JOIN Advanced_Customer c ON c.customer_id = o.customer_id
JOIN Advanced_Order_Details od ON od.order_id = o.order_id
JOIN Advanced_Product p ON p.product_id = od.product_id
GROUP BY o.order_id, o.order_date, c.customer_name, c.city
ORDER BY order_value DESC;

-- 5. Advanced report: category revenue, units sold, and share of total revenue
SELECT category, units_sold, category_revenue,
       ROUND(100.0 * category_revenue / NULLIF((SELECT SUM(od2.quantity * p2.price)
            FROM Advanced_Order_Details od2
            JOIN Advanced_Product p2 ON p2.product_id = od2.product_id), 0), 2)
            AS revenue_percentage
FROM (
    SELECT p.category,
           SUM(od.quantity) AS units_sold,
           SUM(od.quantity * p.price) AS category_revenue
    FROM Advanced_Product p
    JOIN Advanced_Order_Details od ON od.product_id = p.product_id
    GROUP BY p.category
) AS category_summary
ORDER BY category_revenue DESC;

-- Bonus: products selling above the average quantity per product
SELECT p.product_id, p.product_name, SUM(od.quantity) AS units_sold
FROM Advanced_Product p
JOIN Advanced_Order_Details od ON od.product_id = p.product_id
GROUP BY p.product_id, p.product_name
HAVING SUM(od.quantity) > (
    SELECT AVG(product_units)
    FROM (
        SELECT SUM(quantity) AS product_units
        FROM Advanced_Order_Details
        GROUP BY product_id
    ) AS product_sales
)
ORDER BY units_sold DESC;
