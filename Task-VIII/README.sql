-- TASK VIII: DATABASE RELATIONSHIP ANALYSIS USING JOINS

-- If ecommerce_db already exists, select it in MySQL Workbench
-- before running these queries.

-- 1. INNER JOIN: Complete order details
SELECT
    c.customer_id,
    c.name AS customer_name,
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


-- 2. LEFT JOIN: All customers, including those without orders
SELECT
    c.customer_id,
    c.name AS customer_name,
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


-- 3. RIGHT JOIN: All products, including products never ordered
SELECT
    p.product_id,
    p.product_name,
    p.price,
    od.order_id,
    od.quantity,
    od.subtotal,
    o.customer_id,
    c.name AS customer_name,
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
    c.name AS customer_name,
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
    c.name AS customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(od.quantity), 0) AS total_items,
    COALESCE(SUM(od.subtotal), 0.00) AS total_purchase_amount
FROM Customer c
LEFT JOIN Orders o
    ON c.customer_id = o.customer_id
LEFT JOIN Order_Details od
    ON o.order_id = od.order_id
GROUP BY c.customer_id, c.name
ORDER BY total_purchase_amount DESC;


-- 6. Multi-table payment report
SELECT
    pay.payment_id,
    c.name AS customer_name,
    o.order_id,
    p.product_name,
    od.quantity,
    pay.payment_mode,
    pay.payment_date,
    pay.amount AS payment_amount,
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
    c.name AS customer_name,
    COUNT(DISTINCT od.order_detail_id) AS product_lines,
    SUM(od.quantity) AS total_quantity,
    o.total_amount AS order_total,
    COALESCE(payments.total_paid, 0.00) AS total_paid,
    payments.latest_payment_status
FROM Orders o
INNER JOIN Customer c
    ON o.customer_id = c.customer_id
INNER JOIN Order_Details od
    ON o.order_id = od.order_id
LEFT JOIN (
    SELECT
        order_id,
        SUM(amount) AS total_paid,
        MAX(status) AS latest_payment_status
    FROM Payment
    GROUP BY order_id
) payments
    ON o.order_id = payments.order_id
GROUP BY
    o.order_id,
    c.name,
    o.total_amount,
    payments.total_paid,
    payments.latest_payment_status
ORDER BY o.order_id;
