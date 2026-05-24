-- PERFORMANCE ANALYSIS
/* ANALYZE THE YEARLY PERFORMANCE OF PRODUCTS BY COMPARING THEIR SALES
TO BOTH THE AVERAGE SALES PERFORMANCE OF THE PRODUCT AND THE PREVIOUS YEAR'S SALES*/

WITH yearly_product_sales AS (
SELECT
YEAR(f.order_date) As order_year,
p.product_name,
SUM(f.sales_amount) AS current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL
GROUP BY
YEAR(f.order_date),
p.product_name
)
SELECT
order_year,
product_name,
current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) avg_sales,
current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg_sales,
CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above avg'
	 WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below avg'
	 ELSE 'Avg'
END avg_change,
-- Year-over-year-Analysis
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) previous_year_sales,
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_from_prev_year,
CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	 WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
	 ELSE 'No Change'
END prev_year_change
FROM yearly_product_sales
ORDER BY product_name, order_year