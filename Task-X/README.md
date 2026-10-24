# Task X – Advanced SQL Query System

## Objective
Use subqueries, nested queries, and multi-table analysis to answer advanced business questions.

## Tables
- Advanced_Customer
- Advanced_Product
- Advanced_Orders
- Advanced_Order_Details

## Queries Implemented
1. Find products priced above the average product price.
2. Find customers whose spending is above the average customer spending.
3. Identify the customer or customers with the maximum purchase amount, including ties.
4. Generate an order-level report with customer details, units ordered, and order value.
5. Prepare a category-level report showing units sold, revenue, and percentage of total revenue.
6. Bonus: identify products selling above the average quantity per product.

## SQL Concepts
- Scalar and nested subqueries
- Derived tables
- Aggregate functions: AVG(), SUM(), MAX()
- JOIN, GROUP BY, HAVING, ORDER BY
- COALESCE() and NULLIF()

## Tools Used
MySQL and MySQL Workbench.

## Note
This task uses its own table names prefixed with `Advanced_` so it can be run separately from earlier tasks. Run the script once in a selected database. If you run it again, remove the existing task tables/data first or use a fresh database.

## Conclusion
The project demonstrates how advanced SQL queries can identify high-value customers, compare product prices, summarize order revenue, and support category-level business decisions.
