-- sql retail Sales Anaysis - p1

-- Create Table
drop table if exists retail_sales;
create table retail_sales
			(
				transactions_id int,
				sale_date Date,
				sale_time Time,
				customer_id int,
				gender varchar(10),
				age int,
				category varchar(20),
				quantiy int,
				price_per_unit float,
				cogs float,
				total_sale float
			);

select * from retail_sales
limit 10;

-- Data Cleaning
select * from retail_sales
where transactions_id is null;

select * from retail_sales
where sale_date is null;

select * from retail_sales
where sale_time is null;

select * from retail_sales
where customer_id is null;

select * from retail_sales
where gender is null;

select * from retail_sales
where 
	transaction_id is null
	or
	category is null
	or
	quantiy is null
	or
	price_per_unit is null
	or
	cogs is null
	or
	total_sale is null;

delete from retail_sales
where 
	transactions_id is null
	or
	category is null
	or
	quantiy is null
	or
	price_per_unit is null
	or
	cogs is null
	or
	total_sale is null;

UPDATE retail_sales
SET age = mode_val
FROM (
    -- Calculate the single mode value using the WITH clause (CTE)
    WITH ModeCalc AS (
        SELECT age
        FROM retail_sales
        WHERE age IS NOT NULL
        GROUP BY age
        ORDER BY COUNT(*) DESC, age ASC
        LIMIT 1
    )
    SELECT age AS mode_val FROM ModeCalc
) AS SubQueryAlias
WHERE retail_sales.age IS NULL;

-- Data Exploration

-- how many sales we have?
select count(*) as Total_Sales from retail_sales;

-- how many unique customers we have?
select count(distinct customer_id) as Unique_Customers from retail_sales;

-- how many unique categories we have?
select distinct(category) from retail_sales;

--  Data Analysis and Business key problems & Answers
-- My Analysis & Findings
-- Q1 Write a sql query to retrive all columns for sales made on '2022-11-05'
-- Q2 write a sql query to retrive all transaction where the category is 'clothing' and the quantity sold is more than 10 in the month of Nov-2022
--  Q3 write a sql query to calculate total sales(Total_Sales) for each category
-- Q4 write a sql query to find the average age of the customer who purchsed item for the 'Beauty' Category.
-- Q5 write a sql query to find all the transaction where total_sales is greater than 1000
-- Q6 write a sql query to find the total number of transaction (transaction_id) made by each gender in each category.
-- Q7 write a sql query to calculate the average sales for each month. Find out best selling month on each years.
-- Q8 write a sql query to find the top 5 customer based on the highest total_sales.
-- Q9 write a sql query to find the number of unique customers who purchased item for each category.
-- Q10 write a sql query to create each shift and number of orders( example Morning <=12, afternoon 12 & 17, Evening > 17)



-- Q1 Write a sql query to retrive all columns for sales made on '2022-11-05'
select * from retail_sales
where sale_date = '2022-11-05';	

-- Q2 write a sql query to retrive all transaction where the category is 'clothing' and the quantity sold is more than 10 in the month of Nov-2022
select * from retail_sales
where category = 'Clothing'
and To_char(sale_date, 'YYYY-MM')= '2022-11'
and quantiy>= 4;

--Q3 write a sql query to calculate total sales(Total_Sales) for each category
select category, sum(total_sale) as net_sale,
count(quantiy) as total_orders from retail_sales
group by 1;

-- Q4 write a sql query to find the average age of the customer who purchsed item for the 'Beauty' Category.
select round(avg(age),2)
as average_age from retail_sales 
where category = 'Beauty';

--Q5 write a sql query to find all the transaction where total_sales is greater than 1000
select * from retail_sales
where total_sale> 1000;

-- Q6 write a sql query to find the total number of transaction (transaction_id) made by each gender in each category.
select
	category, 
	gender, 
	count(*) as Total_trans
from 
	retail_sales
group by 
	category, 
	gender
order by 1;

--Q7 write a sql query to calculate the average sales for each month. Find out best selling month on each years.
WITH MonthlySales AS (
    -- Step 1: Calculate total sales for each specific year and month
    SELECT
        EXTRACT(YEAR FROM sale_date) AS sale_year,
        EXTRACT(MONTH FROM sale_date) AS sale_month_num,
        TO_CHAR(sale_date, 'Month') AS sale_month_name,
        Avg(total_sale) AS Avg_sales_amount
    FROM
        retail_sales
    GROUP BY
        sale_year,
        sale_month_num,
        sale_month_name
),
RankedSales AS (
    -- Step 2: Rank months within each year based on total sales
    SELECT
        sale_year,
        sale_month_name,
        Avg_sales_amount,
        ROW_NUMBER() OVER(
            PARTITION BY sale_year -- Restart ranking for each year
            ORDER BY Avg_sales_amount DESC -- Rank highest sales as rank 1
        ) AS monthly_rank
    FROM
        MonthlySales
)
-- Step 3: Select only the month(s) ranked 1st for each year
SELECT
    sale_year AS Year,
    sale_month_name AS Best_Selling_Month,
    Avg_sales_amount AS Total_Sales
FROM
    RankedSales
WHERE
    monthly_rank = 1
ORDER BY
    Year DESC;

-- Q8 write a sql query to find the top 5 customer based on the highest total_sales.
select customer_id,
sum(total_sale)as Total_Sale from retail_sales
group by 1
order by Total_Sale Desc
limit 5;

-- Q9 write a sql query to find the number of unique customers who purchased item for each category.
select category, count(distinct customer_id) from retail_sales
group by category;

-- Q10 write a sql query to create each shift and number of orders( example Morning <=12, afternoon 12 & 17, Evening > 17)
SELECT 
    CASE 
        WHEN EXTRACT(HOUR FROM sale_time) <= 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) > 12 AND EXTRACT(HOUR FROM sale_time) <= 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY shift
ORDER BY MIN(sale_time);

-- End of Project