# Library Management System using SQL Project --

## Project Overview

**Project Title**: Library Management System  
**SQL FLAVOUR**: Microsoft SQL Server 
**Database**: `library_db`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/Omotola202/Library-System-Management/blob/main/library.jpg?raw=true)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/Omotola202/Library-System-Management/blob/main/ERD.JPG?raw=true)

- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_db;

-- Creating Tables

 IF OBJECT_ID ('Books', 'U') IS NOT NULL
	DROP TABLE Books;  
CREATE TABLE Books
	(
	isbn VARCHAR(50) PRIMARY KEY,	
	book_title VARCHAR(100),	
	category VARCHAR(50),	
	rental_price DECIMAL(10,2),
	status	VARCHAR(10),
	author	VARCHAR(50),
	publisher VARCHAR(50)
	);

IF OBJECT_ID ('Branch', 'U') IS NOT NULL
	DROP TABLE Branch;
CREATE TABLE Branch
	(
	branch_id VARCHAR(10) PRIMARY KEY,
	manager_id VARCHAR(10),  --foreign key
	branch_address VARCHAR(50),
	contact_no VARCHAR(20)
	);

IF OBJECT_ID ('Employees', 'U') IS NOT NULL
	DROP TABLE Employees;
CREATE TABLE Employees
	(
	emp_id	VARCHAR(10) PRIMARY KEY,
	emp_name VARCHAR(30),
	position VARCHAR(30),
	salary DECIMAL(10,2),
	branch_id VARCHAR(10)  --foreign key
	);

IF OBJECT_ID ('Issued_status', 'U') IS NOT NULL
	DROP TABLE Issued_status;
CREATE TABLE Issued_status
	(
	issued_id VARCHAR(10) PRIMARY KEY,
	issued_member_id VARCHAR(10),	--foreign key
	issued_book_name VARCHAR(100),
	issued_date	DATE,
	issued_book_isbn VARCHAR(50),  --foreign key
	issued_emp_id VARCHAR(10) --foreign key
	);


IF OBJECT_ID ('Members', 'U') IS NOT NULL
	DROP TABLE Members;
CREATE TABLE Members
	(
	member_id	VARCHAR(10) PRIMARY KEY,
	member_name	VARCHAR(50),
	member_address	VARCHAR(50),
	reg_date DATE
	);


IF OBJECT_ID ('Return_Status', 'U') IS NOT NULL
	DROP TABLE Return_Status;
CREATE TABLE Return_Status
	(
	return_id VARCHAR(10) PRIMARY KEY,	
	issued_id VARCHAR(10),	--foreign key
	return_book_name VARCHAR(100),
	return_date DATE,
	return_book_isbn VARCHAR(50),
	);
	
```
### 1b. Database Setup
- **Creation of Foreign key constraint **
  
```sql

--Foreign Key Constraint
ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY(issued_member_id)
REFERENCES members(member_id)

ALTER TABLE issued_status
ADD CONSTRAINT fk_book
FOREIGN KEY(issued_book_isbn)
REFERENCES books(isbn)

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY(issued_emp_id)
REFERENCES employees(emp_id)


ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY(branch_id)
REFERENCES branch(branch_id)

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY(issued_id)
REFERENCES issued_status(issued_id)-- this constraint return error because issued_id in both return_status and issued_status are not consistent

SELECT issued_id
FROM dbo.return_status
WHERE issued_id NOT IN (SELECT issued_id FROM dbo.issued_status);-- this to check for the inconsistent records

--To resolve this error, delete the 3 inconsistent records

-- Delete inconsistent records from return_status
DELETE FROM return_status
WHERE issued_id IN ('IS101', 'IS105', 'IS103');

--Rerun the  foreign key constraint code 
ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY(issued_id)
REFERENCES issued_status(issued_id)

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books
    (isbn, book_title, category, rental_price, status, author, publisher)
VALUES
    ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
-- To check
SELECT * 
FROM books;
```
**Task 2: Retrieve All Books Issued by a Specific Employee **

```sql
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT *
FROM issued_status
WHERE issued_emp_id = 'E101';
```

**Task 3: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '345 Albama St'
WHERE member_id = 'C118';
-- To check update
SELECT * 
FROM members;
```

**Task 4: Delete a Record from the Issued Status Table **
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE issued_id = 'IS121';

```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT 
    member_id, 
    member_name
FROM 
    members
WHERE 
    member_id IN (
        SELECT 
            issued_member_id
        FROM 
            issued_status
        GROUP BY 
            issued_member_id
        HAVING 
            COUNT(*) > 1
    );

```

**Task 6: List Members (names & id) Who Have being Issued More Than One Books and the count of the books**

```sql
SELECT 
    m.member_id, 
    m.member_name, 
    COUNT(*) AS issued_count
FROM 
    issued_status AS i
JOIN 
    members AS m 
    ON i.issued_member_id = m.member_id
GROUP BY 
    m.member_id, m.member_name
HAVING 
    COUNT(*) > 1
ORDER BY 
    issued_count DESC;

```


**Task 7: List employee (names & id) Who Have Issued More Than One Book and the counts of books issued**

```sql
SELECT 
    e.emp_id, 
    e.emp_name, 
    COUNT(*) AS issued_count
FROM 
    issued_status AS i
JOIN 
    employees AS e
    ON i.issued_emp_id = e.emp_id
GROUP BY 
    e.emp_id, e.emp_name
HAVING 
    COUNT(*) > 1
ORDER BY 
    e.emp_id;

```



### 3. CTAS (Create Table As Select)

- **Task 8: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
SELECT 
    b.isbn,                     
    b.book_title,               
    COUNT(*) AS issued_count     
INTO book_issued_count
FROM 
    books AS b                  
JOIN 
    issued_status AS i          
ON 
    b.isbn = i.issued_book_isbn 
GROUP BY 
    b.isbn,                     
    b.book_title;               

```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 9. **Retrieve All Books in a Specific Category**:

```sql
SELECT * FROM books
WHERE category = 'Classic';
```

**Task 10: Find Total Rental Income by Category**:

```sql
SELECT 
    b.category,                     
    SUM(b.rental_price) AS total_rental_income, 
    COUNT(*) AS issued_count         
FROM 
    books AS b                    
JOIN 
    issued_status AS i            
ON 
    b.isbn = i.issued_book_isbn  
GROUP BY 
    b.category                    
ORDER BY 
    total_rental_income DESC;     

```

11. **List Members Who Registered in the Last 180 Days**:
```sql
SELECT *
FROM members
WHERE reg_date >= DATEADD(DAY, -180, GETDATE());
```

12. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT 
    e.*, 
    b.manager_id, 
    e1.emp_name AS manager
FROM 
    employees AS e
JOIN 
    branch AS b 
ON 
    e.branch_id = b.branch_id
JOIN 
    employees AS e1 
ON 
    b.manager_id = e1.emp_id;

```

Task 13. **Create a Table of Books with Rental Price Above $5**:
```sql
SELECT 
    book_title, 
    rental_price, 
    category
INTO 
    book_price_morethan_five
FROM 
    books
WHERE 
    rental_price > 5;

```

Task 14: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT 
    i.issued_book_name
FROM 
    issued_status AS i
LEFT JOIN 
    return_status AS r 
ON 
    i.issued_id = r.issued_id
WHERE 
    r.return_id IS NULL;

```

## Advanced SQL Operations

**Task 15: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT 
    i.issued_member_id,
    m.member_name,
    b.book_title,
    i.issued_date,
    -- r.return_date,
    DATEDIFF(DAY, i.issued_date, GETDATE()) AS over_dues_days
FROM issued_status AS i
JOIN members AS m
    ON m.member_id = i.issued_member_id
JOIN books AS b
    ON b.isbn = i.issued_book_isbn
LEFT JOIN return_status AS r
    ON r.issued_id = i.issued_id
WHERE 
    r.return_date IS NULL
    AND
    DATEDIFF(DAY, i.issued_date, GETDATE()) > 30
ORDER BY i.issued_member_id;
```


**Task 16: Update Book Status on Return**  
Write a query to update the status of books in the books table to "available" when they are returned (based on entries in the return_status table).


```sql

UPDATE books
SET status = 'Available'
WHERE book_title IN
(
    SELECT 
        b.book_title
    FROM 
        books AS b
    JOIN 
        issued_status AS i ON b.isbn = i.issued_book_isbn
    LEFT JOIN 
        return_status AS r ON i.issued_id = r.issued_id
    WHERE 
        r.return_id IS NOT NULL
);

```

**Task 17: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
SELECT 
    br.branch_id,
    br.manager_id,
    COUNT(i.issued_id) AS book_issued,
    COUNT(r.return_id) AS book_return, 
    (COUNT(i.issued_id) - COUNT(r.return_id)) AS book_not_returned, 
    SUM(b.rental_price) AS total_revenue
INTO 
    branch_performance
FROM 
    issued_status AS i
JOIN 
    employees AS e ON i.issued_emp_id = e.emp_id
JOIN 
    branch AS br ON br.branch_id = e.branch_id
LEFT JOIN 
    return_status AS r ON r.issued_id = i.issued_id
JOIN 
    books AS b ON b.isbn = i.issued_book_isbn
GROUP BY 
    br.branch_id, 
    br.manager_id;

SELECT * FROM branch_performance;
```

**Task 18: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 6 months.

```sql
SELECT 
    DISTINCT m.member_id, 
    m.member_name, 
    m.member_address, 
    m.reg_date
INTO 
    active_members
FROM 
    issued_status AS i
JOIN 
    members AS m ON i.issued_member_id = m.member_id
WHERE 
    DATEDIFF(DAY, i.issued_date, GETDATE()) <= 180;


SELECT * FROM active_members;

```

**Task 19: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
SELECT 
    TOP (3) e.emp_id, 
    e.emp_name, 
    COUNT(i.issued_id) AS book_issued, 
    br.branch_id
FROM 
    issued_status AS i
JOIN 
    employees AS e ON i.issued_emp_id = e.emp_id
JOIN 
    branch AS br ON br.branch_id = e.branch_id
GROUP BY 
    e.emp_id, 
    e.emp_name, 
    br.branch_id
ORDER BY 
    book_issued DESC;

```
**Task 20: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines

```sql
SELECT m.member_id, 
       m.member_name, 
       COUNT(i.issued_id) AS books_per_membs, 
       COUNT(i.issued_id) - COUNT(r.return_id) AS count_of_overdue_books,
       SUM(
           CASE
               WHEN r.return_id IS NULL AND DATEDIFF(DAY, i.issued_date, GETDATE()) > 30
               THEN (DATEDIFF(DAY, i.issued_date, GETDATE()) - 30) * 0.50
               ELSE 0
           END
       ) AS over_due_fine
INTO over_due_books_fine
FROM members AS m
JOIN issued_status AS i
    ON m.member_id = i.issued_member_id
LEFT JOIN return_status AS r
    ON r.issued_id = i.issued_id
GROUP BY m.member_id, m.member_name;
```

## Reports

- **Database Schema**: Comprehensive overview of table structures and their relationships.
- **Data Analysis**: Insights into book categories, employee salaries, trends in member registrations, and issued books.
- **Summary Reports**: Aggregated data on popular books and employee performance metrics.

## Conclusion

This project showcases the use of SQL skills in developing and managing a library management system. It encompasses database setup, data manipulation, and advanced querying techniques, offering a robust foundation for effective data management and analysis.
