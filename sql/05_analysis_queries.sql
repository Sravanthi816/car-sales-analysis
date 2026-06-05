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

