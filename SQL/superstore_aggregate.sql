WITH
  -- 1. Revenue Trends
  monthly_sales AS (
    SELECT
      FORMAT_DATE("%Y-%m", DATE(`Order Date`)) AS order_month,
      ROUND(SUM(Sales), 2) AS total_sales
    FROM `daring-glider-469510-k9.superstore.sales`
    GROUP BY order_month
  ),
  
  yearly_sales AS (
    SELECT
      EXTRACT(YEAR FROM DATE(`Order Date`)) AS order_year,
      ROUND(SUM(Sales), 2) AS total_sales
    FROM `daring-glider-469510-k9.superstore.sales`
    GROUP BY order_year
  ),

  -- 2. Product Performance
  top_products AS (
    SELECT
      `Product Name` AS product_name,
      ROUND(SUM(Sales), 2) AS total_sales
    FROM `daring-glider-469510-k9.superstore.sales`
    GROUP BY product_name
    ORDER BY total_sales DESC
    LIMIT 10
  ),

  bottom_products AS (
    SELECT
      `Product Name` AS product_name,
      ROUND(SUM(Sales), 2) AS total_sales
    FROM `daring-glider-469510-k9.superstore.sales`
    GROUP BY product_name
    ORDER BY total_sales ASC
    LIMIT 10
  ),

  category_sales AS (
    SELECT
      Category,
      `Sub-Category` AS sub_category,
      ROUND(SUM(Sales), 2) AS total_sales
    FROM `daring-glider-469510-k9.superstore.sales`
    GROUP BY Category, sub_category
  ),

  -- 3. Customer Insights
  top_customers AS (
    SELECT
      `Customer Name` AS customer_name,
      ROUND(SUM(Sales), 2) AS total_sales
    FROM `daring-glider-469510-k9.superstore.sales`
    GROUP BY customer_name
    ORDER BY total_sales DESC
    LIMIT 10
  ),

  segment_sales AS (
    SELECT
      Segment,
      ROUND(SUM(Sales), 2) AS total_sales
    FROM `daring-glider-469510-k9.superstore.sales`
    GROUP BY Segment
  ),

  -- 4. Regional Performance
  region_sales AS (
    SELECT
      Region,
      ROUND(SUM(Sales), 2) AS total_sales
    FROM `daring-glider-469510-k9.superstore.sales`
    GROUP BY Region
  ),

  top_states AS (
    SELECT
      State,
      ROUND(SUM(Sales), 2) AS total_sales
    FROM `daring-glider-469510-k9.superstore.sales`
    GROUP BY State
    ORDER BY total_sales DESC
    LIMIT 10
  )

-- Final UNION ALL for consolidated output
SELECT 'Monthly Sales Trend' AS metric, order_month AS dimension, total_sales FROM monthly_sales
UNION ALL
SELECT 'Yearly Sales Trend', CAST(order_year AS STRING), total_sales FROM yearly_sales
UNION ALL
SELECT 'Top Products', product_name, total_sales FROM top_products
UNION ALL
SELECT 'Bottom Products', product_name, total_sales FROM bottom_products
UNION ALL
SELECT 'Category Sales', CONCAT(Category, ' - ', sub_category), total_sales FROM category_sales
UNION ALL
SELECT 'Top Customers', customer_name, total_sales FROM top_customers
UNION ALL
SELECT 'Segment Sales', Segment, total_sales FROM segment_sales
UNION ALL
SELECT 'Region Sales', Region, total_sales FROM region_sales
UNION ALL
SELECT 'Top States', State, total_sales FROM top_states;
