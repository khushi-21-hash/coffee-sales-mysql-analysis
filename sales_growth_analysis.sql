-- Q.1 Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT 
    `city name`,
    ROUND((population * 0.25), 0) AS 'coffee_population',
    `city rank`
FROM
    city
ORDER BY population DESC;



-- Q.2
-- Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

SELECT 
    city.`city name`, 
    SUM(sales.total) AS sale
FROM
    city
        JOIN
    customers ON city.`city id` = customers.`city id`
        JOIN
    sales ON customers.`customer id` = sales.`customer id`
WHERE
    sales.`sale date` BETWEEN '2023-10-01' AND '2023-12-31'
     group by city.`city name`;
     


-- Q.3
-- Sales Count for Each Product
-- How many units of each coffee product have been sold?

SELECT 
    products.`product name`,
    COUNT(sales.`sale id`) AS total_product_sold
FROM
    products
        JOIN
    sales ON products.`product id` = sales.`product id`
GROUP BY products.`product name`
ORDER BY total_product_sold DESC ;



-- Q.4
-- Average Sales Amount per City
-- What is the average sales amount per customer in each city?

with first_cte as(
	select count(distinct customers.`customer id`) as total_customers ,
	city.`city name`as city_name,
	sum(sales.total) as total_sales
from city
join customers on customers.`city id`= city.`city id`
join sales on customers.`customer id`= sales.`customer id`
group by city.`city name`
) 
select 
	city_name,
	round(total_sales/total_customers,2) as avg_sales_per_customer
from first_cte;



 -- Q.5
-- City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated coffee consumers.
-- return city_name, total current customer, estimated coffee consumers (25%)

SELECT 
    city.`city name`,
    COUNT(customers.`customer id`) AS total_customers,
    ROUND((0.25 / 1000000 * (city.population)), 2) AS coffee_consumers_in_millions
FROM
    city
        JOIN
    customers ON city.`city id` = customers.`city id`
GROUP BY city.`city name` , coffee_consumers_in_millions
ORDER BY coffee_consumers_in_millions DESC;



 -- Q6
-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?  

 WITH product_sales AS (
    SELECT
        city.`city name`,
        products.`product name`,
        COUNT(sales.`product id`) AS total_product_sold,
        RANK() OVER (
          PARTITION BY city.`city name`
            ORDER BY COUNT(sales.`product id`) DESC
        ) AS rnk
    FROM city
    JOIN customers
        ON city.`city id` = customers.`city id`
    JOIN sales
        ON customers.`customer id` = sales.`customer id`
    JOIN products
        ON sales.`product id` = products.`product id`
    GROUP BY city.`city name`, products.`product name`
)
SELECT *
FROM product_sales
WHERE rnk <= 3
ORDER BY `city name`, rnk;



-- Q.7
-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

SELECT 
    city.`city name`,
    COUNT(DISTINCT (customers.`customer id`)) AS total_customer
FROM
    city
        JOIN
    customers ON city.`city id` = customers.`city id`
        JOIN
    sales ON customers.`customer id` = sales.`customer id`
        JOIN
    products ON sales.`product id` = products.`product id`
WHERE
    products.`product name` LIKE '%coffee%'
GROUP BY city.`city name`
ORDER BY total_customer DESC;



-- Q.8
-- Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer

SELECT 
    city.`city name`,
    ROUND(SUM(sales.total) / (COUNT(DISTINCT customers.`customer id`)),
            2) AS avg_sales_per_customer,
    ROUND(MAX(city.`estimated rent`) / (COUNT(DISTINCT customers.`customer id`)),
            2) AS avg_rent_per_customer
FROM
    city
        JOIN
    customers ON city.`city id` = customers.`city id`
        JOIN
    sales ON sales.`customer id` = customers.`customer id`
GROUP BY city.`city name`;



-- Q.9
-- Monthly Sales Growth
-- Sales growth rate:
-- Calculate the percentage growth (or decline) in sales over different time periods (monthly)
-- by each city

with monthly_sales as(
	select city.`city name` as city_name , 
	extract(month from sales.`sale date`) as sale_month,
	sum(sales.total) as total_monthly_sales
from city
	join customers on city.`city id`= customers.`city id`
	join sales on sales.`customer id`=customers.`customer id`
	group by sale_month, city.`city name`
),
sales_growth as(
select 
	city_name, 
    sale_month , 
    total_monthly_sales,
lag(total_monthly_sales)
OVER (
	partition by city_name
	ORDER BY sale_month) 
AS previous_month_sales
from monthly_sales
)
SELECT * ,
    ( total_monthly_sales - previous_month_sales
        ) * 100.0
        / previous_month_sales as growth_percent
        from sales_growth
ORDER BY city_name, sale_month;



-- Q.10
-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, 
-- total sale, total rent, total customers, estimated coffee consumer

SELECT
    city.`city name`,
    SUM(sales.total) AS total_sale,
    MAX(city.`estimated rent`) AS total_rent,
    COUNT(DISTINCT customers.`customer id`) AS total_customers,
    ROUND(city.population * 0.25) AS estimated_coffee_consumers
FROM city
JOIN customers
    ON city.`city id` = customers.`city id`
JOIN sales
    ON customers.`customer id` = sales.`customer id`
GROUP BY
    city.`city id`,
    city.`city name`,
    city.population
ORDER BY total_sale DESC
LIMIT 3;


-- Recomendation
City 1: Pune
	1.Average rent per customer is very low.
	2.Highest total revenue.
	3.Average sales per customer is also high.

City 2: Delhi
	1.Highest estimated coffee consumers at 7.7 million.
	2.Highest total number of customers, which is 68.
	3.Average rent per customer is 330 (still under 500).

City 3: Jaipur
	1.Highest number of customers, which is 69.
	2.Average rent per customer is very low at 156.
	3.Average sales per customer is better at 11.6k.