SELECT
  Segment,
  ROUND(SUM(Sales), 2) AS total_sales
FROM `daring-glider-469510-k9.superstore.sales`
GROUP BY Segment
ORDER BY total_sales DESC;
