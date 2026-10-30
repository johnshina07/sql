# Task XIII – Database Security and Performance Optimization

## Objective
Control database access and improve query performance using users, roles, privileges, and indexes.

## Concepts Used
- CREATE USER and CREATE ROLE
- GRANT and REVOKE
- Role-based access control
- CREATE INDEX
- EXPLAIN query plan analysis

## Tables
- TaskXIII_Customer
- TaskXIII_Orders

## Execution
1. Run the table and index section using an account with CREATE privileges.
2. Run the security section only if your MySQL account has permission to manage users and roles.
3. Replace the example password before using the user-creation statements.
4. Run the EXPLAIN statement to inspect the query plan.

## Security Note
The example account is restricted to the `localhost` host. Change the example password before execution and do not use it for a real application. GRANT and REVOKE statements may require administrator privileges.

## Conclusion
This task demonstrates basic role-based database security and the use of indexes and EXPLAIN to investigate query performance.
