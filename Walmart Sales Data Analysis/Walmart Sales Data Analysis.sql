create database if not exists salesDataWalmart;

-- Creating the Table with Data wrangling techniques to exclude nulls for importing the dataset

CREATE table if not exists sales(
invoice_id VARCHAR(30) NOT NULL Primary key,
branch VARCHAR(5) NOT NULL,
city VARCHAR(30) NOT NULL,
customer_type VARCHAR(30) NOT NULL,
gender VARCHAR(10) NOT NULL,
product_line VARCHAR(100) NOT NULL,
unit_price DECIMAL(10,2) NOT NULL,
quantity INT NOT NULL,
VAT FLOAT(6,4) NOT NULL,
total DECIMAL(12,4) NOT NULL,
date DATETIME NOT NULL,
time TIME NOT NULL,
payment_method VARCHAR(15) NOT NULL,
cogs DECIMAL(10,2) NOT NULL,
gross_margin_pct FLOAT(11,9) NOT NULL,
gross_income DECIMAL(10,2) NOT NULL,
rating FLOAT(2,1) NOT NULL
);

-- -----------------------------------------------------------------------------------
-- -----------------------Feature ENgineering ----------------------------------------

-- Creating a Column for time_of_day

Select time,
	(CASE 
		WHEN TIME(time) BETWEEN "00:00:00"  AND "12:00:00"  THEN "Morning"
        WHEN TIME(time) BETWEEN "12:01:00"  AND "16:00:00"  THEN "Afternoon"
        ELSE "Evening"
	 END) as time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales 
SET time_of_day = (CASE 
		WHEN TIME(time) BETWEEN "00:00:00"  AND "12:00:00"  THEN "Morning"
        WHEN TIME(time) BETWEEN "12:01:00"  AND "16:00:00"  THEN "Afternoon"
        ELSE "Evening"
	 END);
     
-- Creating a Column for day_name

Select date,
	dayname(date)
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = dayname(date);

-- Creating a Column for month_name

Select date,
	monthname(date)
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(20);

UPDATE sales
SET month_name = monthname(date);

-- ----------------------------------------------------------------------------------
-- ----------------------- Exploratory Data Analysis---------------------------------

-- Generic Questions

-- How many unique cities does the data have?

SELECT distinct(city) 
FROM sales;

-- In which city is each branch?

Select DISTINCT(city) , branch
FROM sales;

-- Product Questions

-- How many unique product lines does the data have?

Select COUNT(DISTINCT(product_line))
FROM sales;

-- What is the most common payment method?

Select payment_method, Count(payment_method) as cnt
FROM sales
group by payment_method
order by cnt desc;

-- What is the most selling product line?

Select product_line , SUM(quantity)
FROM sales
group by product_line
order by SUM(quantity) desc;

-- What is the total revenue by month?

Select month_name , SUM(total)
from sales
Group by month_name
order by SUM(total) desc;

-- What month had the largest COGS?

Select month_name , SUM(cogs) 
from sales
group by month_name
order by SUM(cogs) desc;

-- What product line had the largest revenue?

Select product_line , SUM(total) AS revenue
from sales
group by product_line
order by revenue desc;

-- What is the city with the largest revenue?

Select city , SUM(total) AS revenue
from sales
group by city
order by revenue desc;

-- What product line had the largest VAT?

Select product_line , AVG(VAT) 
from sales
group by product_line
order by AVG(VAT)  desc;

-- Which branch sold more products than average product sold?

Select branch , SUM(quantity) 
from sales 
group by branch
Having Sum(quantity) > ( Select Avg(quantity) from sales);

-- What is the most common product line by gender?

Select gender , product_line, count(gender) 
from sales
group by gender , product_line
order by count(gender) desc;

-- What is the average rating of each product line?

Select product_line , ROUND(AVG(rating), 2)
from sales
group by product_line
order by AVG(rating) desc;

-- Sales Questions

-- Number of sales made in each time of the day per weekday

Select time_of_day , count(*) as total_sales 
FROM sales
where day_name = "Sunday"
group by time_of_day;

-- Which of the customer types brings the most revenue?

Select customer_type , SUM(total) as revenue
FROM sales 
group by customer_type 
order by revenue desc;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?

Select city, AVG(VAT)
From sales
Group by city
order by AVG(VAT) DESC;

-- Which customer type pays the most in VAT?

Select customer_type, AVG(VAT)
From sales
Group by customer_type
order by AVG(VAT) DESC;

-- Customer Questions 

-- How many unique customer types does the data have?

Select DISTINCT(customer_type) 
from sales;

-- How many unique payment methods does the data have?

Select DISTINCT(payment_method) 
from sales;

-- What is the most common customer type?

Select customer_type , count(customer_type)
from sales 
group by customer_type
order by count(customer_type) desc;

-- Which customer type buys the most?

Select customer_type , count(*)
from sales 
group by customer_type
order by count(*) desc;

-- What is the gender of most of the customers?

Select Gender, count(*)
from sales 
group by Gender
order by count(*) desc;

-- What is the gender distribution per branch?

Select Branch , Gender , count(gender)
from sales
group by branch, gender 
order by Branch , count(gender) desc;

-- Which time of the day do customers give most ratings?

Select time_of_day , AVG(rating)
from sales
group by time_of_day
order by  AVG(rating) desc;

-- Which time of the day do customers give most ratings per branch?

Select branch, time_of_day , AVG(rating)
from sales
group by time_of_day, branch
order by  branch , AVG(rating) desc;

-- Which day of the week has the best avg ratings?

Select day_name , AVG(rating)
from sales
group by day_name
order by  AVG(rating) desc;

-- Which day of the week has the best average ratings per branch?

Select day_name , AVG(rating)
from sales
where branch = "B"
group by day_name
order by AVG(rating) desc;
