# Task I – Requirement Analysis and Customer Database Module

## Objective

Analyze the requirements of an E-Commerce Order Management System and create the customer database module.

### Functional Requirements

1. Store customer details.
2. Maintain unique customer email addresses.
3. Support customer insertion and retrieval.
4. Provide customer information for orders and reviews.
5. Maintain relationships with future order/review modules.

## MySQL Code

```sql
DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

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

SELECT customer_id, customer_name, email, phone, address
FROM Customer
ORDER BY customer_id;
```

## Run

Execute this task first. It creates the `ecommerce_db` database and the `Customer` table.
