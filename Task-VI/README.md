# Task VI – Product Review and Rating Management System

## Objective

Store customer feedback and ratings, retrieve product review details, calculate average product ratings and identify highly rated products.

## MySQL Code

```sql
USE ecommerce_db;

CREATE TABLE Review (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    review_text VARCHAR(500),
    review_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

CREATE TABLE Rating (
    rating_id INT PRIMARY KEY AUTO_INCREMENT,
    review_id INT NOT NULL UNIQUE,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating DECIMAL(2,1) NOT NULL,
    FOREIGN KEY (review_id) REFERENCES Review(review_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    CHECK (rating BETWEEN 1 AND 5)
);

INSERT INTO Review (customer_id, product_id, review_text, review_date) VALUES
(1, 1, 'Excellent laptop with great performance.', '2026-09-01 10:00:00'),
(2, 2, 'Good smartphone and battery life.', '2026-09-02 11:00:00'),
(3, 3, 'Clear sound quality and comfortable.', '2026-09-03 12:00:00'),
(4, 4, 'Good quality and comfortable material.', '2026-09-04 13:00:00'),
(1, 2, 'Very useful phone for daily work.', '2026-09-05 14:00:00');

INSERT INTO Rating (review_id, product_id, customer_id, rating) VALUES
(1, 1, 1, 5.0),
(2, 2, 2, 4.0),
(3, 3, 3, 4.5),
(4, 4, 4, 3.5),
(5, 2, 1, 5.0);

-- Retrieve product review details
SELECT r.review_id, p.product_name, c.customer_name,
       r.review_text, rt.rating, r.review_date
FROM Review r
JOIN Product p ON r.product_id = p.product_id
JOIN Customer c ON r.customer_id = c.customer_id
JOIN Rating rt ON r.review_id = rt.review_id
ORDER BY r.review_date DESC;

-- Average product ratings using aggregate functions
SELECT p.product_id, p.product_name,
       COUNT(rt.rating_id) AS total_reviews,
       ROUND(AVG(rt.rating), 2) AS average_rating
FROM Product p
LEFT JOIN Rating rt ON p.product_id = rt.product_id
GROUP BY p.product_id, p.product_name
ORDER BY average_rating DESC;

-- Highly rated products: average rating >= 4
SELECT p.product_id, p.product_name,
       ROUND(AVG(rt.rating), 2) AS average_rating
FROM Product p
JOIN Rating rt ON p.product_id = rt.product_id
GROUP BY p.product_id, p.product_name
HAVING AVG(rt.rating) >= 4.00
ORDER BY average_rating DESC;
```
