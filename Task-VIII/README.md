# Task VIII – Database Relationship Analysis using Joins

## Objective

Combine Customer, Product, Orders and Payment tables using SQL joins, retrieve complete order details, display customer purchase history and generate multi-table reports.

## MySQL Code

```sql
USE ecommerce_db;

-- 1. INNER JOIN: Complete order details
-- Combines Customer, Orders, Order_Details, Product and Payment.
SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_date,
    o.status AS order_status,
    p.product_id,
    p.product_name,
    od.quantity,
    od.unit_price,
    od.subtotal,
    o.total_amount,
    pay.payment_id,
    pay.payment_mode,
    pay.payment_date,
    pay.amount AS payment_amount,
    pay.status AS payment_status,
    pay.transaction_reference
FROM Customer c
INNER JOIN Orders o
    ON c.customer_id = o.customer_id
INNER JOIN Order_Details od
    ON o.order_id = od.order_id
INNER JOIN Product p
    ON od.product_id = p.product_id
INNER JOIN Payment pay
    ON o.order_id = pay.order_id
ORDER BY o.order_id, od.order_detail_id, pay.payment_date DESC;


-- 2. LEFT JOIN: Show all customers, including customers
-- who have not placed an order.
SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_date,
    o.status AS order_status,
    p.product_name,
    od.quantity,
    od.subtotal,
    pay.payment_mode,
    pay.amount AS payment_amount,
    pay.status AS payment_status
FROM Customer c
LEFT JOIN Orders o
    ON c.customer_id = o.customer_id
LEFT JOIN Order_Details od
    ON o.order_id = od.order_id
LEFT JOIN Product p
    ON od.product_id = p.product_id
LEFT JOIN Payment pay
    ON o.order_id = pay.order_id
ORDER BY c.customer_id, o.order_date DESC;


-- 3. RIGHT JOIN: Show all products, including products
-- that have not been ordered.
SELECT
    p.product_id,
    p.product_name,
    p.price,
    od.order_id,
    od.quantity,
    od.subtotal,
    o.customer_id,
    c.customer_name,
    o.order_date
FROM Order_Details od
RIGHT JOIN Product p
    ON od.product_id = p.product_id
LEFT JOIN Orders o
    ON od.order_id = o.order_id
LEFT JOIN Customer c
    ON o.customer_id = c.customer_id
ORDER BY p.product_id, o.order_date DESC;


-- 4. Customer purchase history
SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_date,
    p.product_name,
    od.quantity,
    od.unit_price,
    od.subtotal,
    o.total_amount,
    o.status AS order_status
FROM Customer c
INNER JOIN Orders o
    ON c.customer_id = o.customer_id
INNER JOIN Order_Details od
    ON o.order_id = od.order_id
INNER JOIN Product p
    ON od.product_id = p.product_id
ORDER BY c.customer_id, o.order_date DESC;


-- 5. Customer-wise purchase summary
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(od.quantity), 0) AS total_items,
    COALESCE(SUM(od.subtotal), 0.00) AS total_purchase_amount
FROM Customer c
LEFT JOIN Orders o
    ON c.customer_id = o.customer_id
LEFT JOIN Order_Details od
    ON o.order_id = od.order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_purchase_amount DESC;


-- 6. Multi-table payment report
SELECT
    pay.payment_id,
    c.customer_name,
    o.order_id,
    p.product_name,
    od.quantity,
    pay.payment_mode,
    pay.payment_date,
    pay.amount,
    pay.status AS payment_status,
    o.status AS order_status
FROM Payment pay
INNER JOIN Orders o
    ON pay.order_id = o.order_id
INNER JOIN Customer c
    ON o.customer_id = c.customer_id
INNER JOIN Order_Details od
    ON o.order_id = od.order_id
INNER JOIN Product p
    ON od.product_id = p.product_id
ORDER BY pay.payment_date DESC;


-- 7. Order-level multi-table report
SELECT
    o.order_id,
    c.customer_name,
    COUNT(DISTINCT od.order_detail_id) AS product_lines,
    SUM(od.quantity) AS total_quantity,
    o.total_amount AS order_total,
    COALESCE(SUM(pay.amount), 0.00) AS total_paid,
    MAX(pay.payment_status) AS latest_payment_status
FROM Orders o
INNER JOIN Customer c
    ON o.customer_id = c.customer_id
INNER JOIN Order_Details od
    ON o.order_id = od.order_id
LEFT JOIN Payment pay
    ON o.order_id = pay.order_id
GROUP BY o.order_id, c.customer_name, o.total_amount
ORDER BY o.order_id;
```

## Join Types Covered

| Join | Purpose |
|---|---|
| INNER JOIN | Returns matching records from related tables |
| LEFT JOIN | Returns all records from the left table and matching records from the right table |
| RIGHT JOIN | Returns all records from the right table and matching records from the left table |

## Tables Used

- Customer
- Orders
- Order_Details
- Product
- Payment

## Requirements Covered

| Requirement | Implementation |
|---|---|
| Combine Customer, Product, Order and Payment tables | Multi-table INNER JOIN reports |
| INNER JOIN | Complete order details |
| LEFT JOIN | All customers and their purchases |
| RIGHT JOIN | All products and their order information |
| Complete order details | Customer + order + product + payment report |
| Customer purchase history | Detailed purchase history query |
| Multi-table reports | Customer summary, payment report and order-level report |
```

## Execution

Run Tasks I–V first so that the Customer, Product, Orders, Order_Details and Payment tables exist before executing Task VIII.
