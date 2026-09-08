# E-Commerce Order Management System

MySQL 8.0+ implementation of Tasks I–VI. Each task is kept in a separate folder with its own `README.md` containing the SQL code and execution notes.

## Project Structure

- [Task I – Requirement Analysis & Customer Database](./Task-I/README.md)
- [Task II – Product & Category Management](./Task-II/README.md)
- [Task III – Seller & Inventory Management](./Task-III/README.md)
- [Task IV – Order Management](./Task-IV/README.md)
- [Task V – Payment Transaction Management](./Task-V/README.md)
- [Task VI – Product Review & Rating Management](./Task-VI/README.md)

## Execution Order

Run the tasks in order: **I → II → III → IV → V → VI** because later tasks use tables created by earlier tasks.

### MySQL

Open MySQL Workbench or the MySQL CLI and execute each task's `README.md` SQL code in order.

> **Important:** Task I creates and resets the database. Do not run its `DROP DATABASE` statement if you need to preserve existing data.

## Database Relationships

```text
Customer 1 ─── N Orders
Orders   1 ─── N Order_Details
Category 1 ─── N Product
Seller   1 ─── N Inventory
Product  1 ─── N Inventory
Product  1 ─── N Order_Details
Orders   1 ─── N Payment
Customer 1 ─── N Review
Product  1 ─── N Review
Review   1 ─── 1 Rating
Customer 1 ─── N Rating
Product  1 ─── N Rating
```

## Requirements Covered

| Task | Coverage |
|---|---|
| I | Business requirements, customer table and customer records |
| II | Category/Product tables, keys, CRUD and category-wise reports |
| III | Seller/Inventory tables, relationships and stock status reports |
| IV | Orders/Order_Details, insertion, modification and order history |
| V | Payments, successful/failed transactions, method analysis and reports |
| VI | Reviews/Ratings, feedback, average ratings and highly-rated products |
