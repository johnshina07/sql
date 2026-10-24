DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

CREATE TABLE Customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15)
);

CREATE TABLE Category (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL
);

CREATE TABLE Product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category_id INT,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

INSERT INTO Customer (name, email, phone)
VALUES
('John', 'john@gmail.com', '9876543210'),
('Rahul', 'rahul@gmail.com', '9876543211'),
('Priya', 'priya@gmail.com', '9876543212'),
('Anitha', 'anitha@gmail.com', '9876543213');

INSERT INTO Category (category_name)
VALUES
('Electronics'),
('Clothing'),
('Books'),
('Home Appliances');

INSERT INTO Product (product_name, category_id, price, stock)
VALUES
('Laptop', 1, 55000.00, 10),
('Smartphone', 1, 25000.00, 15),
('Headphones', 1, 1500.00, 25),
('T-Shirt', 2, 800.00, 30),
('Jeans', 2, 1800.00, 20),
('Database Book', 3, 650.00, 12),
('Novel', 3, 450.00, 0),
('Mixer Grinder', 4, 3200.00, 8);

SELECT * FROM Product;

SELECT * FROM Product
WHERE price < 2000;

SELECT * FROM Product
ORDER BY price DESC;

SELECT DISTINCT category_id
FROM Product;

SELECT * FROM Product
WHERE price BETWEEN 500 AND 2000;

SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    p.price,
    p.stock
FROM Product p
JOIN Category c ON p.category_id = c.category_id
WHERE c.category_name = 'Electronics';

SELECT * FROM Product
WHERE stock > 0;

SELECT customer_id, name, email, phone
FROM Customer;

SELECT product_id, product_name, price, stock
FROM Product;

SELECT * FROM Product
WHERE price < 2000
AND stock > 0;

SELECT
    c.category_name,
    COUNT(p.product_id) AS total_products
FROM Category c
LEFT JOIN Product p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name;

SELECT AVG(price) AS average_product_price
FROM Product;

SELECT product_name, price
FROM Product
ORDER BY price DESC
LIMIT 1;

SELECT product_name, price
FROM Product
ORDER BY price ASC
LIMIT 1;

SELECT
    product_name,
    stock,
    CASE
        WHEN stock > 0 THEN 'Available'
        ELSE 'Unavailable'
    END AS availability
FROM Product;

SELECT
    c.category_name,
    p.product_name,
    p.price
FROM Product p
JOIN Category c ON p.category_id = c.category_id
ORDER BY c.category_name, p.price DESC;

SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    p.price,
    p.stock
FROM Product p
JOIN Category c ON p.category_id = c.category_id
ORDER BY p.product_id;
