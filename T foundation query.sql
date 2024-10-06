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
	manager_id	VARCHAR(10),  --foreign key
	branch_address	VARCHAR(50),
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
	)


IF OBJECT_ID ('Members', 'U') IS NOT NULL
	DROP TABLE Members;
CREATE TABLE Members
	(
	member_id	VARCHAR(10) PRIMARY KEY,
	member_name	VARCHAR(50),
	member_address	VARCHAR(50),
	reg_date DATE
	)


IF OBJECT_ID ('Return_Status', 'U') IS NOT NULL
	DROP TABLE Return_Status;
CREATE TABLE Return_Status
	(
	return_id VARCHAR(10) PRIMARY KEY,	
	issued_id VARCHAR(10),	--foreign key
	return_book_name VARCHAR(100),
	return_date DATE,
	return_book_isbn VARCHAR(50),
	)
	


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


