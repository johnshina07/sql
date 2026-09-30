# Task-VII

## SQL Query Implementation for E-Commerce Database

### Introduction
SQL Query Implementation focuses on retrieving, filtering, sorting, and analyzing data from the E-Commerce database. It helps users obtain useful information about customers, products, prices, categories, and availability.

### Functional Requirements
- Perform SELECT, WHERE, ORDER BY, and DISTINCT queries.
- Search products based on price, category, and availability.
- Retrieve customer and product information.
- Apply filtering conditions.
- Generate basic business reports.

### SQL Queries

```sql
USE ecommerce_db;

-- 1. SELECT: Display all products
SELECT * FROM Product;

-- 2. WHERE: Find products below a given price
SELECT * FROM Product
WHERE price < 1000;

-- 3. ORDER BY: Display products from highest to lowest price
SELECT * FROM Product
ORDER BY price DESC;

-- 4. DISTINCT: Display unique product categories
SELECT DISTINCT category_id
FROM Product;

-- 5. Search products by price
SELECT * FROM Product
WHERE price BETWEEN 500 AND 2000;

-- 6. Search products by category
SELECT * FROM Product
WHERE category_id = 1;

-- 7. Search available products
SELECT * FROM Product
WHERE stock > 0;

-- 8. Retrieve customer information
SELECT customer_id, name, email
FROM Customer;

-- 9. Retrieve product information
SELECT product_id, product_name, price, stock
FROM Product;

-- 10. Apply multiple filtering conditions
SELECT * FROM Product
WHERE price < 2000 AND stock > 0;

-- 11. Basic business report: product count by category
SELECT category_id, COUNT(*) AS total_products
FROM Product
GROUP BY category_id;

-- 12. Basic business report: average product price
SELECT AVG(price) AS average_product_price
FROM Product;
```

### Conclusion
These SQL queries demonstrate how to retrieve, filter, sort, and analyze E-Commerce data. They provide useful customer and product information and support basic business reporting.
