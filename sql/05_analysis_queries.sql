-- Which car manufacturers (make) generated 
--the highest total sales revenue?

SELECT
    v.make,
    SUM(a.selling_price) AS total_sales
FROM vehicles v
JOIN auction_sales a
    ON v.vehicle_id = a.vehicle_id
GROUP BY v.make
ORDER BY total_sales DESC
LIMIT 10;

--Which states have the highest average selling price?

SELECT
    a.state,
    AVG(a.selling_price) AS avg_selling_price
FROM auction_sales a
GROUP BY a.state
ORDER BY avg_selling_price DESC
LIMIT 10;

--Which vehicle makes generated the highest average selling price?

SELECT
    v.make,
    AVG(a.selling_price) AS average_selling_price
FROM vehicles v
JOIN auction_sales a
    ON v.vehicle_id = a.vehicle_id
GROUP BY v.make
ORDER BY average_selling_price DESC;

--Which states generated the highest total sales revenue?

SELECT
    a.state,
    SUM(a.selling_price) AS total_sales
FROM auction_sales a
GROUP BY a.state
ORDER BY total_sales DESC
LIMIT 10;

--Which vehicle makes have the highest median selling price?

SELECT
    v.make,
    PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY a.selling_price) AS median_selling_price
FROM vehicles v
JOIN auction_sales a
    ON v.vehicle_id = a.vehicle_id
GROUP BY v.make;

--Which vehicles sold for more than their MMR value?

WITH vechile_date AS (
    SELECT 
        v.make, 
        v.model, 
        ROUND(AVG(a.selling_price), 2) AS average_selling_price, 
        ROUND(AVG(a.mmr), 2) AS average_mmr, 
        ROUND((AVG(a.selling_price) - AVG(a.mmr)), 2) AS difference 
    FROM vehicles v
    JOIN auction_sales a ON v.vehicle_id = a.vehicle_id
    GROUP BY v.make, v.model
)
SELECT 
    make, 
    model, 
    difference,
    'vehicle sold above mmr' AS mmr_analysis 
FROM vechile_date
WHERE difference > 0 
LIMIT 10;

--Which vehicle makes have an average selling price above the overall 
--average selling price of all vehicles?

SELECT
    v.make,
    ROUND(AVG(a.selling_price),2) AS average_selling_price
FROM vehicles v
JOIN auction_sales a
    ON v.vehicle_id = a.vehicle_id
GROUP BY v.make
HAVING ROUND(AVG(a.selling_price),2) >
(
    SELECT AVG(selling_price)
    FROM auction_sales
);

--Which vehicle makes generate high revenue but have low sales volume?

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

SELECT make, total_count, total_revenue, average_selling_price
FROM vehicle_analysis
WHERE total_count < (
    SELECT AVG(total_count)
    FROM vehicle_analysis
)
AND total_revenue > (
    SELECT AVG(total_revenue)
    FROM vehicle_analysis
);

--Show the most expensive vehicle sold.

WITH sale_analysis AS (
    SELECT
        v.make,
        v.model,
        a.selling_price,
        RANK() OVER (
            PARTITION BY v.make
            ORDER BY a.selling_price DESC
        ) AS rn
    FROM vehicles v
    JOIN auction_sales a
        ON v.vehicle_id = a.vehicle_id
)

SELECT *
FROM sale_analysis
WHERE rn = 1;

--For each vehicle make, show:
--* Total revenue
--* Revenue rank among all makes
--* Percentage contribution to total company revenue

WITH vehicle_analysis AS (
    SELECT
        v.make,
        SUM(a.selling_price) AS total_revenue
    FROM vehicles v
    JOIN auction_sales a
        ON v.vehicle_id = a.vehicle_id
    GROUP BY v.make
)

SELECT
    make,
    total_revenue,

    RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank,

    ROUND(
        total_revenue * 100.0 /
        SUM(total_revenue) OVER (),
        2
    ) AS revenue_percentage

FROM vehicle_analysis

ORDER BY revenue_rank;


-- Write a query that returns:state,total_revenue,revenue_rank
--Requirements:* Use SUM(selling_price), Use a window function, Rank states by revenue


WITH vehicle_total_revenue AS (
    SELECT
        state,
        SUM(selling_price) AS total_revenue
    FROM auction_sales
    GROUP BY state
)
SELECT
    state,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS rn
FROM vehicle_total_revenue;

--Which states contribute the most to total company revenue?state, 
--total_revenue, revenue_percentage

WITH company_revenue AS (
    SELECT
        state,
        SUM(selling_price) AS total_revenue
    FROM auction_sales
    GROUP BY state
)
SELECT
    state,
    total_revenue,
    ROUND(
        ((total_revenue * 100) / SUM(total_revenue) OVER()),
        2
    ) as revenue_percentage
FROM company_revenue
ORDER BY revenue_percentage DESC;

--Do a small number of states contribute most of the company’s revenue? State, Revenue, Revenue% , Cumulative Revenue %

with company_revenue AS (
    SELECT
        state,
        SUM(selling_price) AS total_revenue
    FROM auction_sales
    GROUP BY state
),
revenue_analysis AS (
    SELECT
        state,
        total_revenue,
        ROUND(
            ((total_revenue * 100) / SUM(total_revenue) OVER()),
            2
        ) AS revenue_percentage,
        SUM(ROUND(
            ((total_revenue * 100) / SUM(total_revenue) OVER()),
            2
        )) OVER (ORDER BY total_revenue DESC) AS cumulative_revenue_percentage
    FROM company_revenue
)
SELECT *
FROM revenue_analysis
ORDER BY revenue_percentage DESC;   

--Build a query that identifies:make, vehicle_count ,total_revenue ,average_selling_price, revenue_percentage
--and then classify each make into: star, cash_cow, low_performer
--STAR: Above-average revenue Above-average volume
--CASH_COW: Above-average revenue Below-average volume
--LOW_PERFORMER: Below-average revenue Below-average volume
WITH vehicle_analysis AS (
    SELECT
        v.make,
        COUNT(*) AS vehicle_count,
        SUM(a.selling_price) AS total_revenue,
        ROUND(AVG(a.selling_price),2) AS average_selling_price
    FROM vehicles v
    JOIN auction_sales a
        ON v.vehicle_id = a.vehicle_id
    GROUP BY v.make
),
performance_analysis AS (
    SELECT
        make,
        vehicle_count,
        total_revenue,
        average_selling_price,
        ROUND((total_revenue * 100.0) / SUM(total_revenue) OVER (), 2) AS revenue_percentage,
        CASE
            WHEN total_revenue > (SELECT AVG(total_revenue) FROM vehicle_analysis) AND vehicle_count > (SELECT AVG(vehicle_count) FROM vehicle_analysis) THEN 'STAR'
            WHEN total_revenue > (SELECT AVG(total_revenue) FROM vehicle_analysis) AND vehicle_count <= (SELECT AVG(vehicle_count) FROM vehicle_analysis) THEN 'CASH_COW'
            ELSE 'LOW_PERFORMER'
        END AS performance_category
    FROM vehicle_analysis
)
SELECT *
FROM performance_analysis
ORDER BY total_revenue DESC;   


