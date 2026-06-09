--For each vehicle make, find the most expensive vehicle sold.
--Expected columns: make, model, selling_price, rank

WITH vehicle_ranking AS (
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
FROM vehicle_ranking
WHERE rn = 1
ORDER BY selling_price DESC;

--For each state, compare its revenue with the previous state’s 
--revenue after sorting by revenue descending.
--Expected columns: state, total_revenue, previous_state_revenue, difference

WITH vehicle_analysis AS (
    SELECT
        state,
        SUM(selling_price) AS total_revenue
    FROM auction_sales
    GROUP BY state
),

laging_vehicle AS (
    SELECT
        state,
        total_revenue,
        LAG(total_revenue)
            OVER(ORDER BY total_revenue DESC)
            AS previous_state_revenue
    FROM vehicle_analysis
)

SELECT
    state,
    total_revenue,
    total_revenue - previous_state_revenue AS revenue_gap
FROM laging_vehicle
ORDER BY total_revenue DESC;

--For each state, compare its revenue with the next state’s revenue.
--Expected columns: state, total_revenue, next_state_revenue, difference

WITH vehicle_analysis AS (
    SELECT
        state,
        SUM(selling_price) AS total_revenue
    FROM auction_sales
    GROUP BY state
),

leading_vehicle AS (
    SELECT
        state,
        total_revenue,
        LEAD(total_revenue)
            OVER(ORDER BY total_revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
            AS previous_state_revenue
    FROM vehicle_analysis
)

SELECT
    state,
    total_revenue,previous_state_revenue,
    total_revenue - previous_state_revenue AS next_revenue_gap
FROM leading_vehicle
ORDER BY total_revenue DESC;

--Divide all vehicle makes into 4 revenue groups (quartiles).
--Expected columns: make, total_revenue, revenue_quartile

WITH vehicle_analysis AS (
    SELECT
        v.make,
        SUM(selling_price) AS total_revenue
    FROM vehicles v
    JOIN auction_sales a
        ON v.vehicle_id = a.vehicle_id
    GROUP BY v.make
),

revenue_groups AS (
    SELECT
        make,
        total_revenue,
        NTILE(4) OVER (
            ORDER BY total_revenue desc
        ) AS revenue_quartile
    FROM vehicle_analysis
)

SELECT *
FROM revenue_groups;

--Find the top 3 highest-revenue vehicle makes.
--Expected columns: make, total_revenue, dense_rank


WITH vehicle_analysis AS (
    SELECT
        v.make,
        SUM(selling_price) AS total_revenue
    FROM vehicles v
    JOIN auction_sales a
        ON v.vehicle_id = a.vehicle_id
    GROUP BY v.make
),

ranking_vehicles AS (
    SELECT
        make,
        total_revenue,
        DENSE_RANK() OVER (
            ORDER BY total_revenue DESC
        ) AS drn
    FROM vehicle_analysis
)

SELECT *
FROM ranking_vehicles
WHERE drn <= 3;

--For each state, what percentage of the state’s revenue 
--is contributed by each vehicle make?
--Expected columns: state, make, total_revenue, state_revenue, percentage_contribution

WITH vehicles_analysis AS (
    SELECT
        v.make,
        a.state,
        SUM(a.selling_price) AS total_revenue
    FROM vehicles v
    JOIN auction_sales a
        ON v.vehicle_id = a.vehicle_id
    GROUP BY v.make, a.state
),

revenue_analysis AS (
    SELECT
        make,
        state,
        total_revenue,
        SUM(total_revenue)
            OVER(PARTITION BY state) AS state_revenue
    FROM vehicles_analysis
)

SELECT
    make,
    state,
    total_revenue,
    state_revenue,
    ROUND(
        ((total_revenue * 100) / state_revenue),
        2
    ) AS percentage_of_state_revenue
FROM revenue_analysis
ORDER BY state, percentage_of_state_revenue DESC;

--Within each state, what are the Top 3 revenue-generating 
--vehicle makes?
--Expected columns: state, make, total_revenue, rank_within_state

WITH vehicles_analysis AS (
    SELECT
        v.make,
        a.state,
        SUM(a.selling_price) AS total_revenue
    FROM vehicles v
    JOIN auction_sales a
        ON v.vehicle_id = a.vehicle_id
    GROUP BY v.make, a.state
),

ranking_vehicles AS (
    SELECT
        make,
        state,
        total_revenue,
        DENSE_RANK() OVER (
            PARTITION BY state
            ORDER BY total_revenue DESC
        ) AS rank_within_state
    FROM vehicles_analysis
)

SELECT *
FROM ranking_vehicles
WHERE rank_within_state <= 3
ORDER BY state, rank_within_state;

--



