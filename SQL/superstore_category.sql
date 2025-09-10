SELECT
  Category,
  `Sub-Category` AS sub_category,
  ROUND(SUM(Sales), 2) AS total_sales
FROM `daring-glider-469510-k9.superstore.sales`
GROUP BY Category, sub_category
ORDER BY Category, total_sales DESC;
