--How much revenue did the company generate each month?
SELECT
    DATE_TRUNC('month', sale_date)::date AS sale_month,
    SUM(selling_price) AS total_revenue
FROM auction_sales
GROUP BY 1
ORDER BY 1;

