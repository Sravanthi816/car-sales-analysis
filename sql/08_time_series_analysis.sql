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

--Which vehicle makes show the most consistent positive growth over time?
--Expected Output: make,growth_months, decline_months ,total_months_analyzed, growth_consistency_percentage

WITH vehicle_analysis AS (

    SELECT

        v.make,

        DATE_TRUNC('month', a.sale_date)::date AS sale_month,

        SUM(a.selling_price) AS total_revenue

    FROM vehicles v

    JOIN auction_sales a

        ON v.vehicle_id = a.vehicle_id

    GROUP BY v.make, DATE_TRUNC('month', a.sale_date)::date

),

revenue_growth_analysis AS (

    SELECT

        make,

        sale_month,

        total_revenue,

        LAG(total_revenue) OVER(

            PARTITION BY make

            ORDER BY sale_month

        ) AS previous_month

    FROM vehicle_analysis

),

status_analysis AS (

    SELECT

        make,

        CASE

            WHEN total_revenue > previous_month THEN 'Growth'

            WHEN total_revenue < previous_month THEN 'Decline'

            ELSE 'Constant'

        END AS month_status

    FROM revenue_growth_analysis

    WHERE previous_month IS NOT NULL

),
growth_decline_counts AS (

    SELECT

        make,

        COUNT(

            CASE

                WHEN month_status = 'Growth'

                THEN 1

            END

        ) AS growth_months,

        COUNT(

            CASE

                WHEN month_status = 'Decline'

                THEN 1

            END

        ) AS decline_months

    FROM status_analysis

    GROUP BY make

)

SELECT
    make,
    growth_months,
    decline_months,
    ROUND(
        growth_months * 100.0
        /
        (growth_months + decline_months),
        2
    ) AS growth_consistency_percentage
FROM growth_decline_counts
ORDER BY growth_consistency_percentage DESC;

--Which vehicle makes are improving their average selling 
--price over time?
--Expected Output: make, sale_month, average_selling_price, previous_month_avg_price
--price_growth_percentage

WITH vehicle_analysis AS (
    SELECT
        v.make,
        DATE_TRUNC('month', a.sale_date)::date AS sale_month,
        ROUND(AVG(a.selling_price), 2) AS average_selling_price
    FROM vehicles v
    JOIN auction_sales a
        ON v.vehicle_id = a.vehicle_id
    GROUP BY
        v.make,
        DATE_TRUNC('month', a.sale_date)::date
),

previous_month_analysis AS (
    SELECT
        make,
        sale_month,
        average_selling_price,
        LAG(average_selling_price) OVER (
            PARTITION BY make
            ORDER BY sale_month
        ) AS previous_month_avg_price
    FROM vehicle_analysis
)

SELECT
    make,
    sale_month,
    average_selling_price,
    previous_month_avg_price,
    ROUND(
        (
            (average_selling_price - previous_month_avg_price)
            * 100.0
        )
        /
        NULLIF(previous_month_avg_price, 0),
        2
    ) AS price_growth_percentage
FROM previous_month_analysis
WHERE previous_month_avg_price IS NOT NULL
ORDER BY price_growth_percentage DESC;

--Which states have the most stable revenue performance over time?

WITH vehicle_analysis AS (

    SELECT

        state,

        DATE_TRUNC('month', sale_date)::date AS sale_month,

        SUM(selling_price) AS total_revenue

    FROM auction_sales

    GROUP BY 1,2

)

SELECT

    state,

    ROUND(AVG(total_revenue),2) AS average_monthly_revenue,

    ROUND(STDDEV(total_revenue),2) AS revenue_volatility,

    DENSE_RANK() OVER(

        ORDER BY STDDEV(total_revenue)

    ) AS stability_rank

FROM vehicle_analysis

GROUP BY state

ORDER BY stability_rank;

--Which vehicle makes generate above-average revenue while 
--selling fewer vehicles than average?
--expected_output : make, vechile_count, total_revenue, average_selling_price


WITH vehicle_analysis AS (
    SELECT
        v.make,
        COUNT(*) AS total_count,
        SUM(a.selling_price) AS total_revenue,
        ROUND(AVG(a.selling_price),2) AS average_selling_price
    FROM vehicles v
    JOIN auction_sales a
        ON v.vehicle_id = a.vehicle_id
    GROUP BY v.make
)

SELECT *
FROM vehicle_analysis
WHERE total_count < (
    SELECT AVG(total_count)
    FROM vehicle_analysis
)
AND total_revenue > (
    SELECT AVG(total_revenue)
    FROM vehicle_analysis
);

