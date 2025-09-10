SELECT
  EXTRACT(YEAR FROM DATE(`Order Date`)) AS order_year,
  ROUND(SUM(Sales), 2) AS total_sales
FROM `daring-glider-469510-k9.superstore.sales`
GROUP BY order_year
ORDER BY order_year;
