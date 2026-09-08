# Task IV – Order Management System

## Objective

Manage customer orders and order details, including order date, quantity, totals, insertion, modification and customer order history.

## MySQL Code

```sql
USE ecommerce_db;

CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    status ENUM('PENDING', 'CONFIRMED', 'SHIPPED', 'DELIVERED', 'CANCELLED') NOT NULL DEFAULT 'PENDING',
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
VALUES (1, 0, 'CONFIRMED');

INSERT INTO Order_Details (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 65000.00),
(1, 3, 1, 2500.00);

INSERT INTO Orders (customer_id, total_amount, status)
VALUES (2, 0, 'DELIVERED');

INSERT INTO Order_Details (order_id, product_id, quantity, unit_price) VALUES
(2, 2, 1, 30000.00),
(2, 4, 1, 999.00);

-- Calculate totals from order details
UPDATE Orders o
SET total_amount = (
    SELECT COALESCE(SUM(od.subtotal), 0)
    FROM Order_Details od
    WHERE od.order_id = o.order_id
);

-- Order modification
UPDATE Orders
SET status = 'SHIPPED'
WHERE order_id = 1;

-- Customer order history report
SELECT c.customer_name, o.order_id, o.order_date, o.status,
       p.product_name, od.quantity, od.unit_price,
       od.subtotal, o.total_amount
FROM Customer c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Order_Details od ON o.order_id = od.order_id
JOIN Product p ON od.product_id = p.product_id
ORDER BY c.customer_id, o.order_date DESC;
```
