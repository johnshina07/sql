-- TASK XI: DATABASE AUTOMATION USING VIEWS AND PROCEDURES
-- MySQL 8.0+
-- Uses TaskXI_ prefixed tables to avoid changing earlier tasks.

DROP VIEW IF EXISTS TaskXI_Order_Report;
DROP PROCEDURE IF EXISTS TaskXI_Add_Order;
DROP FUNCTION IF EXISTS TaskXI_Calculate_Sales;
DROP TABLE IF EXISTS TaskXI_Order_Details;
DROP TABLE IF EXISTS TaskXI_Orders;
DROP TABLE IF EXISTS TaskXI_Product;

CREATE TABLE TaskXI_Product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0)
);

CREATE TABLE TaskXI_Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE TaskXI_Order_Details (
    detail_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES TaskXI_Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES TaskXI_Product(product_id)
);

INSERT INTO TaskXI_Product (product_name, price, stock) VALUES
('Keyboard', 1200.00, 30),
('Mouse', 650.00, 50),
('Monitor', 9500.00, 12);

DELIMITER $$

CREATE FUNCTION TaskXI_Calculate_Sales(p_quantity INT, p_price DECIMAL(10,2))
RETURNS DECIMAL(12,2)
DETERMINISTIC
NO SQL
BEGIN
    RETURN p_quantity * p_price;
END$$

CREATE PROCEDURE TaskXI_Add_Order(
    IN p_customer_name VARCHAR(100),
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_stock INT;
    DECLARE v_order_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT price, stock INTO v_price, v_stock
    FROM TaskXI_Product
    WHERE product_id = p_product_id
    FOR UPDATE;

    IF v_stock IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product not found';
    END IF;

    IF p_quantity <= 0 OR v_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid quantity or insufficient stock';
    END IF;

    INSERT INTO TaskXI_Orders (customer_name) VALUES (p_customer_name);
    SET v_order_id = LAST_INSERT_ID();

    INSERT INTO TaskXI_Order_Details (order_id, product_id, quantity, unit_price)
    VALUES (v_order_id, p_product_id, p_quantity, v_price);

    UPDATE TaskXI_Product
    SET stock = stock - p_quantity
    WHERE product_id = p_product_id;

    COMMIT;
END$$

DELIMITER ;

CREATE VIEW TaskXI_Order_Report AS
SELECT
    o.order_id,
    o.customer_name,
    o.order_date,
    p.product_name,
    d.quantity,
    d.unit_price,
    TaskXI_Calculate_Sales(d.quantity, d.unit_price) AS line_total
FROM TaskXI_Orders o
JOIN TaskXI_Order_Details d ON d.order_id = o.order_id
JOIN TaskXI_Product p ON p.product_id = d.product_id;

-- TEST THE FUNCTION
SELECT TaskXI_Calculate_Sales(2, 1200.00) AS calculated_sales;

-- TEST THE PROCEDURE (creates an order and reduces stock)
CALL TaskXI_Add_Order('Aarav Kumar', 1, 2);

-- TEST THE VIEW
SELECT * FROM TaskXI_Order_Report;

-- VERIFY UPDATED STOCK
SELECT * FROM TaskXI_Product;
