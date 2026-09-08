# Task V – Payment Transaction Management System

## Objective

Store payment mode, date, amount and status; manage successful/failed transactions; analyze payment methods; and generate transaction reports.

## MySQL Code

```sql
USE ecommerce_db;

CREATE TABLE Payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    payment_mode ENUM('UPI', 'CREDIT_CARD', 'DEBIT_CARD', 'NET_BANKING', 'COD') NOT NULL,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(12,2) NOT NULL,
    status ENUM('SUCCESS', 'FAILED', 'PENDING', 'REFUNDED') NOT NULL,
    transaction_reference VARCHAR(100) UNIQUE,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

INSERT INTO Payment (order_id, payment_mode, payment_date, amount, status, transaction_reference) VALUES
(1, 'UPI', '2026-09-08 09:30:00', 67500.00, 'SUCCESS', 'TXN10001'),
(2, 'CREDIT_CARD', '2026-09-08 10:00:00', 30999.00, 'SUCCESS', 'TXN10002'),
(1, 'DEBIT_CARD', '2026-09-08 09:15:00', 67500.00, 'FAILED', 'TXN10003');

-- Successful transactions
SELECT * FROM Payment
WHERE status = 'SUCCESS'
ORDER BY payment_date DESC;

-- Failed transactions
SELECT * FROM Payment
WHERE status = 'FAILED'
ORDER BY payment_date DESC;

-- Payment methods used by customers
SELECT payment_mode,
       COUNT(*) AS transaction_count,
       SUM(amount) AS total_amount
FROM Payment
GROUP BY payment_mode
ORDER BY transaction_count DESC;

-- Payment transaction report
SELECT p.payment_id, c.customer_name, p.order_id,
       p.payment_mode, p.payment_date, p.amount,
       p.status, p.transaction_reference
FROM Payment p
JOIN Orders o ON p.order_id = o.order_id
JOIN Customer c ON o.customer_id = c.customer_id
ORDER BY p.payment_date DESC;
```
