###############################################################
###############################################################
-- Guided Project: Introduction to SQL Window Functions
###############################################################
###############################################################

#############################
-- Task One: Getting Started
-- In this task, we will get started with the project
-- by retrieving all the data in the project-db database
#############################

-- 1.1: Retrieve all the data in the project-db database
SELECT * FROM employees;
SELECT * FROM departments;
SELECT * FROM regions;
SELECT * FROM customers;
SELECT * FROM sales;

#############################
-- Task Two: ROW_NUMBER() - Part One
-- In this task, we will learn the ROW_NUMBER() 
-- and OVER() to assign numbers to each row
#############################

-- 2.1: Assign numbers to each row of the departments table

SELECT
	ROW_NUMBER() OVER() ROW_N
	, *
FROM	
	departments
ORDER BY ROW_N;


-- Exercise 2.1: Assign numbers to each row of 
-- the department for the Entertainment division
SELECT 
	*
	,ROW_NUMBER() OVER() AS Row_N
FROM 
	departments
WHERE
	division = 'Entertainment'
ORDER BY Row_N ASC;

#############################
-- Task Three: ROW_NUMBER() - Part Two
-- In this task, we will continue to learn how to 
-- assign numbers to each row using ROW_NUMBER() and OVER()
#############################

-- 3.1: Retrieve all the data from the employees table
SELECT * FROM employees;

-- Order by inside OVER()
-- 3.2: Retrieve a list of employee_id, first_name, 
-- hire_date, and department of all employees in the sports
-- department ordered by the hire date
SELECT
	employee_id
	, first_name
	, hire_date
	, department
	, ROW_NUMBER() OVER() AS ROW_N
FROM
	employees
WHERE
	department = 'Sports'
ORDER BY
	hire_date;
	
	
	
--3.2 ORDER BY IN THE OVER CLAUSE
SELECT
	employee_id
	, first_name
	, hire_date
	, department
	, ROW_NUMBER() OVER(ORDER BY
					   		hire_date) AS ROW_N
FROM
	employees
WHERE
	department = 'Sports';

-- 3.3: Order by multiple columns
SELECT
	employee_id
	, first_name
	, hire_date
	, department
	, ROW_NUMBER() OVER(
						ORDER BY
					   		hire_date ASC
							, salary ASC
						) AS ROW_N
FROM
	employees
WHERE
	department = 'Sports';


-- 3.4: Ordering in- and outside the OVER() clause. Outside ORDER BY supercedes
-- order by in the OVER CLAUSE
SELECT 
	employee_id
		, first_name
		, hire_date, salary
		, department
		,ROW_NUMBER() OVER(
							ORDER BY 
								hire_date ASC
								, salary DESC
							) AS Row_N
FROM 
	employees
WHERE 
	department = 'Sports'
ORDER BY
	employee_id;


#############################
-- Task Four: PARTITION BY
-- In this task, we will learn how to use
-- the PARTITION BY clause inside OVER()
#############################

-- 4.1: Retrieve the employee_id, first_name, 
-- hire_date of employees for different departments
SELECT
	employee_id
	, first_name
	, hire_date
	, department
	, ROW_NUMBER() OVER(
						PARTITION BY
							department
						) AS Row_N
FROM
	employees
ORDER BY
	department ASC;

-- Exercise 4.1: Order by the hire_date
SELECT 
	employee_id
	, first_name
	, department
	, hire_date
	,ROW_NUMBER() OVER(
						PARTITION BY 
							department
				   		ORDER BY
							hire_date
						) AS Row_N
FROM employees	


#############################
-- Task Five: PARTITION BY with CTE
-- In this task, we will learn how to write a conditional
-- statement using a single CASE clause
#############################

-- 5.1: Retrieve all data from the sales and customers tables
SELECT * FROM sales;
SELECT * FROM customers;

-- 5.2: Create a common table expression to retrieve the
-- customer_id, customer_name, segment and how many 
-- times the customer has purchased from the mall 
WITH customer_purchase AS (
	SELECT 
		s.customer_id
		, c.customer_name
		, c.segment
		,COUNT(*) AS purchase_count
	FROM 
		sales s
	JOIN 
		customers c
		ON s.customer_id = c.customer_id
	GROUP BY 
		s.customer_id
		, c.customer_name
		, c.segment
	ORDER BY 
		customer_id)

-- 5.3: Number each customer by how many purchases they've made
SELECT
	customer_id
	, customer_name
	, segment
	, purchase_count
	,ROW_NUMBER()
		OVER(
			ORDER BY 
				purchase_count DESC
			) AS Row_N
FROM
	customer_purchase
ORDER BY Row_N
		, purchase_count DESC;
				

-- Same CTE as 5.2
WITH customer_purchase AS (
	SELECT 
		s.customer_id
		, c.customer_name
		, c.segment
		,COUNT(*) AS purchase_count
	FROM 
		sales s
	JOIN 
		customers c
	ON 
		s.customer_id = c.customer_id
	GROUP BY 
		s.customer_id, c.customer_name, c.segment
	ORDER BY 
		customer_id)

-- Exercise 5.1: Number each customer partitioned by their customer segment
-- and by how many purchases they've made in descending order
SELECT 
	customer_id
	, customer_name
	, segment
	, purchase_count
	,ROW_NUMBER() OVER (
						PARTITION BY
							segment
						ORDER BY
							purchase_count DESC
				   		) AS Row_N
FROM 
	customer_purchase
ORDER BY 
	segment
	, purchase_count DESC;

#############################
-- Task Six: Fetching: LEAD() & LAG()
-- In this task, we will learn how to fetch data
-- using the LEAD() and LAG() clauses
#############################

-- 6.1: Retrieve all employees first name, department, salary
-- and the salary after that employee

SELECT
	first_name
	,department
	,salary
	,LEAD(salary) OVER() AS next_salary
FROM
	employees



-- 6.2: Retrieve all employees first name, department, salary
-- and the salary before that employee
SELECT
	first_name
	,department
	,salary
	,LAG(salary) OVER() AS next_salary
FROM
	employees

-- 6.3: Retrieve all employees first name, department, salary
-- and the salary after that employee in order of their salaries
SELECT
	first_name
	,department
	,salary
	,LEAD(salary) OVER(
						ORDER BY
							salary DESC
						) AS next_salary
FROM
	employees

-- Exercise 6.1: Retrieve all employees first name, department, salary
-- and the salary before that employee in order of their salaries in
-- descending order. Call the new column closest_higher_salary
SELECT 
	first_name
	, department
	, salary
	,LAG(salary) 
		OVER(
				ORDER BY 
					salary DESC 
			) AS closest_higher_salary
FROM employees;

-- Exercise 6.2: Retrieve all employees first name, department, salary
-- and the salary after that employee for each department in descending order
-- of their salaries. Call the new column closest_lower_salary 
SELECT 
	first_name
		, department
		, salary	
		, LEAD(salary)
			OVER (
				PARTITION BY
					department
				ORDER BY 
					salary DESC
				) next_lower_salary
FROM employees;

-- What do you think this query will return?
SELECT 
	first_name
	, department
	, salary
	,LEAD(salary, 1) 
		OVER 
			(ORDER BY 
				salary DESC
			) closest_salary
	,LEAD(salary, 2) 
		OVER 
			(ORDER BY 
				salary DESC
			) next_closest_salary
FROM 
	employees
WHERE 
	department = 'Clothing';

#############################
-- Task Seven: FIRST_VALUE() - Part One
-- In this task, we will learn how to use the
-- FIRST_VALUE() clause with the OVER() clause
#############################

-- 7.1: Retrieve the first_name, last_name, department, and 
-- hire_date of all employees. Add a new column called first_emp_date 
-- that returns the hire date of the first hired employee
SELECT
	first_name
	,department
	,hire_date
	,FIRST_VALUE(hire_date) 
		OVER(
			ORDER BY
				hire_date ASC
			) first_emp_date
FROM
	employees;
	

-- 7.2: Find the difference between the hire date of the first employee
-- hired and every other employees
SELECT
	first_name
	,department
	,hire_date
	,FIRST_VALUE(hire_date) 
		OVER(
			ORDER BY
				hire_date ASC
			) first_emp_date
	,hire_date - FIRST_VALUE(hire_date) 
						OVER(
							ORDER BY
								hire_date ASC
							) AS difference_between_first_and_hire_date
FROM
	employees;
	
-- A better solution:
SELECT
	*
	,AGE(hire_date, first_emp_date) hiredate_diff
FROM(
	SELECT
		first_name
		,department
		,hire_date
		,FIRST_VALUE(hire_date)
			OVER(
				ORDER BY
					hire_date
				) first_emp_date
	FROM
		employees
		) a
ORDER BY 
	hire_date;
	

-- Exercise 7.1: Partition by department
SELECT 
	first_name
	, last_name
	, department	
	, hire_date
	,FIRST_VALUE(hire_date)
		OVER (
				PARTITION BY
					department
				ORDER BY 
					hire_date
				) AS first_emp_date
FROM 
	employees;

-- Exercise 7.2: Find the difference between the hire date of the 
-- first employee hired and every other employees partitioned by department
SELECT 
	*
	, AGE(hire_date, first_emp_date)
FROM 
	(
	SELECT 
		first_name
		, last_name
		, department
		, hire_date
		,FIRST_VALUE(hire_date) OVER (
										PARTITION BY
											department
							 			ORDER BY 
											hire_date
										) AS first_emp_date
FROM 
	employees
	) a;
		

#############################
-- Task Eight: FIRST_VALUE() - Part Two
-- In this task, we will continue to learn how to 
-- use the FIRST_VALUE() clause with the OVER() clause
#############################

-- Exercise 8.1: Return the first salary for different departments
-- Order by the salary in descending order
SELECT 
	first_name
	, email
	, department
	, salary
	, FIRST_VALUE(salary)
		OVER(
			PARTITION BY
				department
			ORDER BY
				salary DESC
				) first_salary
FROM 
	employees;

-- OR
SELECT 
	first_name
	, email
	, department
	, salary
	,MAX(salary) 
		OVER(
			PARTITION BY 
				department
			ORDER BY
				salary DESC
			) first_salary
FROM 
	employees;

-- Exercise 8.2: Return the first salary for different departments
-- Order by the first_name in ascending order
SELECT 
	first_name
	, email
	, department
	, salary
	,FIRST_VALUE(salary) 
		OVER(
			PARTITION BY
				department
			ORDER BY 
				first_name 
			)
FROM 
	employees;

-- 8.1: Return the fifth salary for different departments
-- Order by the first_name in ascending order
SELECT
	first_name
	,email
	,department
	,salary
	, NTH_VALUE(salary, 5)
		OVER(
			PARTITION BY
				department
			ORDER BY
				first_name
			) 
FROM
	employees;



