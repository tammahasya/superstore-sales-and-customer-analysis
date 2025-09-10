SELECT
  `Customer Name` AS customer_name,
  ROUND(SUM(Sales), 2) AS total_sales
FROM `daring-glider-469510-k9.superstore.sales`
GROUP BY customer_name
ORDER BY total_sales DESC
LIMIT 10;
