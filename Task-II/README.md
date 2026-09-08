# Task II – Product and Category Management System

## Objective

Create Category and Product tables, establish primary/foreign keys, maintain product details and generate category-wise reports.

## MySQL Code

```sql
USE ecommerce_db;

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

-- INSERT
INSERT INTO Product (product_name, category_id, price, stock)
VALUES ('Smart Watch', 1, 5000.00, 20);

-- UPDATE
UPDATE Product
SET price = 4800.00, stock = 22
WHERE product_name = 'Smart Watch';

-- DELETE
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
```
