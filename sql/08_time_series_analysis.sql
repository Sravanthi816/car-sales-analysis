--How much revenue did the company generate each month?
SELECT
    DATE_TRUNC('month', sale_date)::date AS sale_month,
    SUM(selling_price) AS total_revenue
FROM auction_sales
GROUP BY 1
ORDER BY 1;

--How much did revenue increase or decrease compared to the previous month?
--to creare a CTE to calculate the total revenue for each month, and then use the LAG() window function to compare the current month's revenue with the previous month's revenue.

WITH vehicle_month_analysis AS (
    SELECT
        DATE_TRUNC('month', sale_date)::date AS sale_month,
        SUM(selling_price) AS total_revenue
    FROM auction_sales
    GROUP BY 1
),

revenue_analysis AS (
    SELECT
        sale_month,
        total_revenue,
        LAG(total_revenue)
            OVER(ORDER BY sale_month)
            AS previous_revenue
    FROM vehicle_month_analysis
)

SELECT
    sale_month,
    total_revenue,
    previous_revenue,
    total_revenue - previous_revenue AS revenue_change
FROM revenue_analysis
ORDER BY sale_month;

--Month-over-Month Growth %
WITH vehicle_month_analysis AS (
    SELECT
        DATE_TRUNC('month', sale_date)::date AS sale_month,
        SUM(selling_price) AS total_revenue
    FROM auction_sales
    GROUP BY 1
),

revenue_analysis AS (
    SELECT
        sale_month,
        total_revenue,
        LAG(total_revenue)
            OVER(ORDER BY sale_month)
            AS previous_revenue
    FROM vehicle_month_analysis
)

SELECT
    sale_month,
    total_revenue,
    previous_revenue,
    round((total_revenue - previous_revenue) / NULLIF(previous_revenue, 0) * 100, 2)
    AS revenue_change_percent
FROM revenue_analysis
ORDER BY sale_month;

--Calculate the cumulative (running) revenue over time.

WITH vehicle_month_analysis AS (
    SELECT
        DATE_TRUNC('month', sale_date)::date AS sale_month,
        SUM(selling_price) AS total_revenue
    FROM auction_sales
    GROUP BY 1
)

SELECT
    sale_month,
    total_revenue,
    SUM(total_revenue)
        OVER(ORDER BY sale_month) AS running_revenue
FROM vehicle_month_analysis
ORDER BY sale_month;

--Calculate the 3-month moving average revenue.

WITH vechile_month_analysis AS (
    SELECT
        DATE_TRUNC('month', sale_date)::date AS sale_month,
        SUM(selling_price) AS total_revenue
    FROM auction_sales
    GROUP BY 1
)

SELECT
    sale_month,
    total_revenue,
    ROUND(
        AVG(total_revenue) OVER(
            ORDER BY sale_month
            ROWS BETWEEN 2 PRECEDING
            AND CURRENT ROW
        ),
        2
    ) AS three_month_moving_average
FROM vechile_month_analysis;

--Which month had the highest revenue?

WITH vechile_month_analysis AS (
    SELECT
        DATE_TRUNC('month', sale_date)::date AS sale_month,
        SUM(selling_price) AS total_revenue
    FROM auction_sales
    GROUP BY 1
),

ranking_monthly AS (
    SELECT
        sale_month,
        total_revenue,
        DENSE_RANK() OVER(
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM vechile_month_analysis
)

SELECT *
FROM ranking_monthly;

--Which month experienced the highest positive growth rate?

WITH vehicle_month_analysis AS (
    SELECT
        DATE_TRUNC('month', sale_date)::date AS sale_month,
        SUM(selling_price) AS total_revenue
    FROM auction_sales
    GROUP BY DATE_TRUNC('month', sale_date)::date
),

growth_analysis AS (
    SELECT
        sale_month,
        total_revenue,
        LAG(total_revenue) OVER (
            ORDER BY sale_month
        ) AS previous_month_revenue
    FROM vehicle_month_analysis
),

ranking_monthly AS (
    SELECT
        sale_month,
        total_revenue,
        previous_month_revenue,
        ROUND(
            (
                (total_revenue - previous_month_revenue)
                * 100.0
            ) / previous_month_revenue,
            2
        ) AS growth_percentage
    FROM growth_analysis
)

SELECT
    sale_month,
    total_revenue,
    previous_month_revenue,
    growth_percentage,
    DENSE_RANK() OVER (
        ORDER BY growth_percentage DESC
    ) AS growth_rank
FROM ranking_monthly;

--Which vehicle make had the highest revenue growth between 
--consecutive months?
--expected output: make, sale_month, total_revenue, previous_month_revenue, growth_percentage

WITH vechile_month_analysis AS (
    SELECT
        v.make,
        DATE_TRUNC('month', sale_date)::date AS sale_month,
        SUM(selling_price) AS total_revenue
    FROM vehicles v
    JOIN auction_sales a
        ON v.vehicle_id = a.vehicle_id
    GROUP BY 1,2
),

revenue_analysis AS (
    SELECT
        make,
        sale_month,
        total_revenue,
        LAG(total_revenue)
            OVER (
                PARTITION BY make
                ORDER BY sale_month
            ) AS previous_month_revenue
    FROM vechile_month_analysis
)

SELECT
    make,
    sale_month,
    total_revenue,
    previous_month_revenue,
    ROUND(
        ((total_revenue - previous_month_revenue) * 100)
        / previous_month_revenue,
        2
    ) AS growth_percentage
FROM revenue_analysis;


