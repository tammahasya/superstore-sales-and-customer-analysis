SELECT
  `Product Name` AS product_name,
  ROUND(SUM(Sales), 2) AS total_sales
FROM `daring-glider-469510-k9.superstore.sales`
GROUP BY product_name
ORDER BY total_sales ASC
LIMIT 10;
