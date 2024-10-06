SELECT * FROM books
SELECT * FROM branch
SELECT * FROM employees
SELECT * FROM issued_status
SELECT * FROM members
SELECT * FROM return_status

-- Project Task: Perform the CRUD Operations (CREATE, RETRIEVE, UPDATE & DELETE)

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books
	(
	isbn,	book_title,	category,	rental_price,	status,	author,	publisher
	)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')
SELECT * FROM books

-- Task 2: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT *
FROM issued_status
WHERE issued_emp_id = 'E101'

-- Task 3: Update an Existing Member's Address
UPDATE members
SET member_address = '345 Albama St'
WHERE member_id = 'C118'
SELECT * FROM members

-- Task 4: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

SELECT * FROM issued_status
WHERE issued_id = 'IS121'

DELETE FROM issued_status
WHERE issued_id = 'IS121'



-- Task 5: List Members Who Have being Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have being issued more than one book.

SELECT member_id, member_name
FROM members
WHERE member_id IN 
	(
	SELECT issued_member_id
	FROM issued_status
	GROUP BY issued_member_id
	HAVING COUNT (*) > 1
	)

-- Task 6: List Members (names & id) Who Have being Issued More Than One Book and the counts of books
SELECT m.member_id, m.member_name, COUNT(*) AS issued_count
FROM issued_status AS i
JOIN members AS m
ON i.issued_member_id = m.member_id
GROUP BY m.member_id, m.member_name
HAVING COUNT (*) > 1
ORDER BY issued_count DESC

---- Task 7: List employee (names & id) Who Have  Issued More Than One Book and the counts of books	issued
SELECT e.emp_id, e.emp_name, COUNT(*) AS issued_count
FROM issued_status AS i
JOIN employees AS e
ON i.issued_emp_id = e.emp_id
GROUP BY e.emp_id, e.emp_name
HAVING COUNT (*) > 1
ORDER BY e.emp_id


-- ### Project Task: CTAS (Create Table As Select)

-- Task 8: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt

SELECT b.isbn, b.book_title, COUNT(*) AS issued_count
INTO book_issued_count
FROM books AS b
JOIN issued_status AS i
ON b.isbn = i.issued_book_isbn
GROUP BY b.isbn, b.book_title;

-- ### Project Task: Data Analysis & Findings

-- Task 9. **Retrieve count of books in each Category
SELECT category, COUNT(*) as num_books
FROM books
GROUP BY category
ORDER BY num_books DESC

-- Task 10: Find Total Rental Income by Category:
SELECT b.category, SUM(b.rental_price) total_rental_income, COUNT(*) issued_count
FROM books AS b
JOIN issued_status AS i
ON b.isbn = i.issued_book_isbn
GROUP BY b.category
ORDER BY total_rental_income DESC

-- Task 11. **List Members Who Registered in the Last 180 Days**:
SELECT *
FROM members
WHERE reg_date >= DATEADD(DAY, -180, GETDATE());

-- Task 12: List Employees with Their Branch Manager's Name and their branch details**:
SELECT e.*, b.manager_id,e1.emp_name AS manager
FROM employees AS e
JOIN branch AS b 
ON e.branch_id = b.branch_id
JOIN employees e1
ON b.manager_id = e1.emp_id

-- Task 13. Create a Table of Books with Rental Price Above $10
SELECT book_title, rental_price, category
INTO book_price_morethan_five
FROM books
WHERE rental_price > 5

-- Task 14: Retrieve the List of Books Not Yet Returned
SELECT i.issued_book_name
FROM issued_status i
LEFT JOIN return_status AS r
ON i.issued_id = r.issued_id
WHERE r.return_id IS NULL
    

-- Advanced SQL Operations

/*Task 15: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's name, book title, issue date, and days overdue.*/

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

/*Task 16: Update Book Status on Return
Write a query to update the status of books in the books table to "available" when they are returned (based on entries in the return_status table).*/

UPDATE books
SET status = 'Available'
WHERE book_title IN
(SELECT *
FROM books AS b
JOIN issued_status AS i
ON b.isbn = i.issued_book_isbn
LEFT JOIN return_status AS r
ON i.issued_id = r.issued_id
WHERE r.return_id IS  NOT NULL)


/*Task 17: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.*/

SELECT br.branch_id,
	br.manager_id,
	COUNT(i.issued_id) AS book_issued,
	COUNT(r.return_id) AS book_return, 
	(COUNT(i.issued_id) - COUNT(r.return_id)) AS book_not_returned, 
	SUM(b.rental_price) AS total_revenue
INTO branch_performance
FROM issued_status i
JOIN employees e
ON i.issued_emp_id = e.emp_id
JOIN branch br 
ON br.branch_id = e.branch_id
LEFT JOIN return_status r
ON r.issued_id = i.issued_id
JOIN books AS b
ON b.isbn = i.issued_book_isbn
GROUP BY br.branch_id, br.manager_id

SELECT * FROM branch_performance


/*Task 18: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members 
who have being issued at least one book in the last 6 months.*/

SELECT 
	DISTINCT m.member_id, 
	m.member_name, m.member_address, m.reg_date
INTO active_members
FROM issued_status AS i
JOIN members AS m
ON i.issued_member_id = m.member_id
WHERE DATEDIFF(DAY, i.issued_date, GETDATE()) <= 180 
   
   SELECT * FROM active_members
   
/*Task 19: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.*/

SELECT  TOP (3) e.emp_id, e.emp_name, COUNT(i.issued_id) AS book_issed, br.branch_id
FROM issued_status AS i
JOIN employees AS e
ON i.issued_emp_id = e.emp_id
JOIN branch AS br
ON br.branch_id = e.branch_id
GROUP BY e.emp_id, e.emp_name, br.branch_id
ORDER BY book_issed DESC


/*Task 20: Create Table As Select (CTAS)
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have being issued but not returned within 30 days.
The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued to each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines */

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

SELECT * FROM over_due_books_fine
/*Task 21: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
Display the member name, book title, and the number of times they've issued damaged books.*/  


/*Task 22: Stored Procedure
Objective: Create a stored procedure to manage the status of books in a library system.
    Description: Write a stored procedure that updates the status of a book based on its issuance or return. Specifically:
    If a book is issued, the status should change to 'no'.
    If a book is returned, the status should change to 'yes'.*/



	




