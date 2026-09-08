# Task III – Seller and Inventory Management System

## Objective

Manage sellers, seller-product relationships, stock quantities and inventory availability.

## MySQL Code

```sql
USE ecommerce_db;

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
SELECT s.seller_name, p.product_name, i.quantity,
       i.status, i.last_updated
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
```
