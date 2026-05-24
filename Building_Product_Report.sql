/*
==================================================
Product Report
===================================================
Purpose:
	- This report consolidates key product metrics and behaviors

Highlights:
	1. Gather essential fields such as names, category, subcategory and cost.
	2. Segments product by revenue to identify high-performers, mid-range or low performers.
	3. Aggregates product-level metrics:
		- total orders
		- total sales
		- total quantity sold
		- total customers (unique)
		- lifespan (in months)
	4. Calculates valuable KPIs:
		- recency (months since last order)
		- average order revenue (AOR)
=======================================================
*/
WITH base_query AS (
    /*.............................................................
    1) Base Query: Retrieves core columns from sales and product dimensions
    ...............................................................*/
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON p.product_key = f.product_key
    WHERE f.order_date IS NOT NULL
),

product_aggregation AS (
    /*.............................................................
    2) Product Aggregation: Summarizes metrics at the product level
    ...............................................................*/
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT customer_key) AS total_customers,
        MAX(order_date) AS last_order_date,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
    FROM base_query
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)

SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    -- Product Performance Segmentation by Revenue
    CASE 
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales BETWEEN 10000 AND 50000 THEN 'Mid-Range'
        ELSE 'Low Performer'
    END AS product_segment,
    last_order_date,
    -- Recency: Months since the product was last ordered
    DATEDIFF(month, last_order_date, GETDATE()) AS recency,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    lifespan,
    -- Compute Average Order Revenue (AOR)
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders 
    END AS avg_order_revenue
FROM product_aggregation;