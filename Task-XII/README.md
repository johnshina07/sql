# Task XII – Transaction Management System

## Objective
Manage order placement safely using transactions and demonstrate COMMIT, ROLLBACK, ACID principles, payment processing, and stock updates.

## Concepts Used
- START TRANSACTION
- COMMIT and ROLLBACK
- Atomic order, payment, and inventory updates
- Row locking with SELECT ... FOR UPDATE
- Transaction consistency checks

## Tables
- TaskXII_Product
- TaskXII_Orders
- TaskXII_Payment

## Execution
Run `Task-XII.sql` in MySQL Workbench using MySQL 8.0 or later. The script creates isolated sample tables, demonstrates a successful transaction, then demonstrates a rollback.

## Note
The script uses `TaskXII_` table names and does not modify earlier task tables. InnoDB is used because it supports transactions and row-level locking.

## Conclusion
This task demonstrates how transactions keep order, payment, and stock records consistent, even when an operation fails.
