-- Total Ridership & Transfers
SELECT
    SUM(ridership) AS total_riders,
    SUM(transfers) AS total_transfers
FROM gold.fact_ridership

-- Total Riders & Transfers for each payment method
SELECT
    payment_method,
    SUM(ridership) AS total_uses_riders,
    SUM(transfers) AS total_uses_transfers
FROM gold.fact_ridership
GROUP BY payment_method

-- Total Riders & Transfers for each payment method subcategory
SELECT
    payment_method,
    fare_class_category,
    SUM(ridership) AS total_uses_riders,
    SUM(transfers) AS total_uses_transfers
FROM gold.fact_ridership
GROUP BY fare_class_category, payment_method
ORDER BY payment_method, fare_class_category

-- Average Daily Riders & Transfers
SELECT
    AVG(total_riders) AS avg_daily_riders,
    AVG(total_transfers) AS avg_daily_transfers
FROM( 
    SELECT
        DATETRUNC(day, transit_timestamp) AS day,
        SUM(ridership) AS total_riders,
        SUM(transfers) AS total_transfers
    FROM gold.fact_ridership
    GROUP BY DATETRUNC(day, transit_timestamp)
) t

-- Average Weekly Riders & Transfers

WITH cte_riders_weekly AS (
SELECT
        DATETRUNC(week, transit_timestamp) AS week,
        SUM(ridership) AS total_riders,
        SUM(transfers) AS total_transfers
    FROM gold.fact_ridership
    GROUP BY DATETRUNC(week, transit_timestamp)
) 
SELECT
    AVG(total_riders) AS avg_weekly_riders,
    AVG(total_transfers) AS avg_weekly_transfers
FROM cte_riders_weekly

-- Average Monthly Riders & Tranfers
SELECT
    AVG(total_riders) AS avg_month_riders,
    AVG(total_transfers) AS avg_month_transfers
FROM( 
    SELECT
        DATETRUNC(month, transit_timestamp) AS month,
        SUM(ridership) AS total_riders,
        SUM(transfers) AS total_transfers
    FROM gold.fact_ridership
    GROUP BY DATETRUNC(month, transit_timestamp)
) t

-- Total Ridership & Transfers Per Station
SELECT
    station_complex,
    SUM(ridership) AS total_riders,
    SUM(transfers) AS total_transfers
FROM gold.fact_ridership
GROUP BY station_complex


-- Average Daily Ridership & Transfers Per Station
SELECT
    station_complex,
    AVG(ridership) AS avg_daily_riders,
    AVG(transfers) AS avg_daily_transfers
FROM (
    SELECT
        DATETRUNC(day, transit_timestamp) AS day,
        station_complex,
        SUM(ridership) AS ridership,
        SUM(transfers) AS transfers
    FROM gold.fact_ridership
    GROUP BY DATETRUNC(day, transit_timestamp), station_complex
) t
GROUP BY station_complex
ORDER BY station_complex

-- Average Monthly Ridership & Transfers Per Station

WITH cte_monthly AS (
SELECT
        DATETRUNC(month, transit_timestamp) AS month,
        station_complex,
        SUM(ridership) AS ridership,
        SUM(transfers) AS transfers
    FROM gold.fact_ridership
    GROUP BY DATETRUNC(month, transit_timestamp), station_complex
) 
SELECT
    station_complex,
    AVG(ridership) AS avg_monthly_riders,
    AVG(transfers) AS avg_monthly_transfers
FROM cte_monthly
GROUP BY station_complex
ORDER BY station_complex

-- Total Ridership & Transfers per Borough
SELECT
    c.borough,
    SUM(ridership) AS total_riders,
    SUM(transfers) AS total_transfers
FROM gold.fact_ridership r
LEFT JOIN gold.dim_complexes c
    ON r.station_complex_id = c.complex_id
GROUP BY c.borough

-- Total Ridership & Transfers per Subway Line
SELECT
    c.line,
    SUM(r.ridership) AS total_riders,
    SUM(r.transfers) AS total_transfers
FROM gold.fact_ridership r
LEFT JOIN gold.dim_complexes c
    ON r.station_complex_id = c.complex_id
GROUP BY c.line
ORDER BY c.line

-- Top 5 stations in terms of total riders
SELECT TOP 5
    station_complex,
    SUM(ridership) AS total_riders
FROM gold.fact_ridership
GROUP BY station_complex
ORDER BY total_riders DESC

-- Bottom 5 stations in terms of total riders
SELECT TOP 5
    station_complex,
    SUM(ridership) AS total_riders
FROM gold.fact_ridership
GROUP BY station_complex
ORDER BY total_riders
