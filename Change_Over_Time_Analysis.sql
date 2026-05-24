
-- CHANGE OVER TIME ANALYSIS
-- TOTAL SALES PER MONTH AND YEAR
-- TOTAL CUSTOMERS PER MONTH AND YEAR

SELECT
YEAR(order_date) as order_year,
MONTH(order_date) as order_month,
SUM(sales_amount) as total_Sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date)

SELECT
DATETRUNC(month, order_date) as order_date,
SUM(sales_amount) as total_Sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date)

SELECT
FORMAT(order_date, 'yyyy-MMM') as order_date,
SUM(sales_amount) as total_Sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM')
