-- TASK XII: TRANSACTION MANAGEMENT SYSTEM
-- MySQL 8.0+ / InnoDB

DROP TABLE IF EXISTS TaskXII_Payment;
DROP TABLE IF EXISTS TaskXII_Orders;
DROP TABLE IF EXISTS TaskXII_Product;

CREATE TABLE TaskXII_Product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL
) ENGINE=InnoDB;

CREATE TABLE TaskXII_Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    order_status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES TaskXII_Product(product_id)
) ENGINE=InnoDB;

CREATE TABLE TaskXII_Payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    payment_amount DECIMAL(12,2) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES TaskXII_Orders(order_id)
) ENGINE=InnoDB;

INSERT INTO TaskXII_Product (product_name, price, stock) VALUES
('Laptop', 55000.00, 10),
('Headphones', 2500.00, 25),
('Webcam', 4200.00, 8);

-- TRANSACTION 1: SUCCESSFUL ORDER, PAYMENT, AND STOCK UPDATE
START TRANSACTION;

SELECT price, stock INTO @unit_price, @available_stock
FROM TaskXII_Product
WHERE product_id = 1
FOR UPDATE;

SET @order_quantity = 2;

-- Continue only when sufficient stock is available.
-- This sample has 10 units available.
INSERT INTO TaskXII_Orders
(customer_name, product_id, quantity, total_amount, order_status)
SELECT 'Diya Sharma', 1, @order_quantity,
       @unit_price * @order_quantity, 'CONFIRMED'
WHERE @available_stock >= @order_quantity;

SET @new_order_id = LAST_INSERT_ID();

INSERT INTO TaskXII_Payment (order_id, payment_amount, payment_status)
SELECT @new_order_id, @unit_price * @order_quantity, 'SUCCESS'
WHERE @available_stock >= @order_quantity;

UPDATE TaskXII_Product
SET stock = stock - @order_quantity
WHERE product_id = 1 AND @available_stock >= @order_quantity;

COMMIT;

-- Verify the committed order, payment, and stock.
SELECT * FROM TaskXII_Orders;
SELECT * FROM TaskXII_Payment;
SELECT * FROM TaskXII_Product;

-- TRANSACTION 2: DEMONSTRATE ROLLBACK
START TRANSACTION;

UPDATE TaskXII_Product
SET stock = stock - 1
WHERE product_id = 2;

-- Undo the uncommitted stock change.
ROLLBACK;

-- Stock remains unchanged by the rolled-back transaction.
SELECT * FROM TaskXII_Product WHERE product_id = 2;

-- ACID DEMONSTRATION:
-- Atomicity: order, payment, and stock changes are committed together.
-- Consistency: primary keys, foreign keys, and stock values protect valid data.
-- Isolation: SELECT ... FOR UPDATE locks the selected product row.
-- Durability: COMMIT permanently saves the transaction.
