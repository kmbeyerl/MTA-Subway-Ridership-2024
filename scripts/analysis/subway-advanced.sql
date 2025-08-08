-- Total Riders per month
SELECT
	MONTH(transit_timestamp) AS month,
	SUM(ridership) AS total_riders
FROM gold.fact_ridership
GROUP BY MONTH(transit_timestamp)
ORDER BY MONTH(transit_timestamp)

-- Cumulative number of Riders & Transfers on each weekday of each month
SELECT
   MONTH(transit_timestamp) AS month,
   DATENAME(weekday, DATETRUNC(day, transit_timestamp)) AS weekday,
   SUM(ridership) AS total_riders,
   SUM(transfers) AS total_transfers
FROM gold.fact_ridership
GROUP BY MONTH(transit_timestamp), 
         DATENAME(weekday, DATETRUNC(day, transit_timestamp))
ORDER BY MONTH(transit_timestamp), 
        CASE DATENAME(weekday, DATETRUNC(day, transit_timestamp))
            WHEN 'Monday' THEN 1
            WHEN 'Tuesday' THEN 2
            WHEN 'Wednesday' THEN 3
            WHEN 'Thursday' THEN 4
            WHEN 'Friday' THEN 5
            WHEN 'Saturday' THEN 6
            WHEN 'Sunday' THEN 7
        END

-- Running Total Riders & Transfers by month
SELECT
    ride_date,
    total_riders,
    SUM(total_riders) OVER (ORDER BY ride_date) AS running_total_riders,
    total_transfers,
    SUM(total_transfers) OVER (ORDER BY ride_date) AS running_total_transfers
FROM (
    SELECT 
        DATETRUNC(month, transit_timestamp) AS ride_date,
        SUM(ridership) AS total_riders,
        SUM(transfers) AS total_transfers
    FROM gold.fact_ridership
    GROUP BY DATETRUNC(month, transit_timestamp)
)t

-- Difference in the total riders per month to the average monthly riders
WITH monthly_riders AS (
    SELECT
        MONTH(transit_timestamp) AS month,
        SUM(ridership) AS total_riders
    FROM gold.fact_ridership
    GROUP BY MONTH(transit_timestamp)
)

SELECT
    month,
    total_riders,
    AVG(total_riders) OVER () AS avg_riders,
    total_riders - AVG(total_riders) OVER () AS diff,
    CASE WHEN (total_riders - AVG(total_riders) OVER ()) > 0 THEN 'Above Average'
         WHEN (total_riders - AVG(total_riders) OVER ()) < 0 THEN 'Below Average'
    END
FROM monthly_riders
ORDER BY month

-- Moving Average Ridership & Transfers
WITH cte_ridership AS (
SELECT
    MONTH(transit_timestamp) AS ride_date,
    SUM(ridership) AS total_riders,
    SUM(transfers) AS total_transfers
FROM gold.fact_ridership
GROUP BY MONTH(transit_timestamp)
)

SELECT
    ride_date,
    AVG(avg_riders) OVER (ORDER BY ride_date) AS moving_avg_riders,
    AVG(avg_transfers) OVER (ORDER BY ride_date) AS moving_avg_transfers
FROM (
    SELECT
        ride_date,
        AVG(total_riders) AS avg_riders,
        AVG(total_transfers) AS avg_transfers
    FROM cte_ridership
    GROUP BY ride_date
) t
ORDER BY ride_date

-- Looking at what percentage each month contributed to the yearly total riders
WITH cte_riders AS (
SELECT
    MONTH(transit_timestamp) AS month,
    SUM(ridership) AS monthly_riders
FROM gold.fact_ridership
GROUP BY MONTH(transit_timestamp)
)

SELECT
    month,
    monthly_riders,
    SUM(monthly_riders) OVER () AS total_riders,
    ROUND((CAST(monthly_riders AS FLOAT) / SUM(monthly_riders) OVER ())*100, 2) AS pct_total
FROM cte_riders
ORDER BY month

-- ADD TITLE FOR THIS QUERY
WITH cte_payments AS (
SELECT
    payment_method,
    fare_class_category,
    SUM(ridership) AS payment_riders
FROM gold.fact_ridership
GROUP BY payment_method, fare_class_category
) 

SELECT
    payment_method,
    fare_class_category,
    payment_riders,
    SUM(payment_riders) OVER () AS total_riders,
    ROUND((CAST(payment_riders AS FLOAT) / SUM(payment_riders) OVER ())*100, 2) AS pct_total
FROM cte_payments
ORDER BY pct_total DESC

-- ADD TITLE FOR THIS QUERY
WITH cte_payments AS (
SELECT
    payment_method,
    fare_class_category,
    SUM(ridership) AS payment_riders
FROM gold.fact_ridership
GROUP BY payment_method, fare_class_category
) 

SELECT
    payment_method,
    fare_class_category,
    payment_riders,
    SUM(payment_riders) OVER (PARTITION BY payment_method) AS total_riders,
    ROUND((CAST(payment_riders AS FLOAT) / SUM(payment_riders) OVER (PARTITION BY payment_method))*100, 2) AS pct_total
FROM cte_payments
ORDER BY payment_method, pct_total DESC

-- ADD TITLE FOR THIS QUERY
WITH cte_boroughs AS (
SELECT
    c.borough,
    SUM(r.ridership) AS borough_riders
FROM gold.fact_ridership r
LEFT JOIN gold.dim_complexes c
    ON c.complex_id = r.station_complex_id
GROUP BY c.borough
)

SELECT 
    borough,
    borough_riders,
    SUM(borough_riders) OVER () AS total_riders,
    ROUND((CAST(borough_riders AS FLOAT) / SUM(borough_riders) OVER ())*100, 2) AS pct_total
FROM cte_boroughs
ORDER BY pct_total DESC

-- ADD TITLE FOR THIS QUERY
/* NOTE: total_riders has a higher number than the actual number of riders
due to the fact that a number of stations are part of multiple lines.
Meaning a single rider from one station could be counted as a rider for two or more lines*/
WITH cte_lines AS (
SELECT
    c.line,
    SUM(r.ridership) AS line_riders
FROM gold.fact_ridership r
LEFT JOIN gold.dim_complexes c
    ON c.complex_id = r.station_complex_id
GROUP BY c.line
)

SELECT 
    line,
    line_riders,
    SUM(line_riders) OVER () AS total_riders,
    ROUND((CAST(line_riders AS FLOAT) / SUM(line_riders) OVER ())*100, 2) AS pct_total
FROM cte_lines
ORDER BY pct_total DESC

-- ADD TITLE FOR THIS QUERY
WITH rider_segment AS (
SELECT
    DATETRUNC(day, transit_timestamp) AS day,
    SUM(ridership) AS total_riders,
    CASE WHEN SUM(ridership) < 2000000 THEN '<2,000,000'
         WHEN SUM(ridership) BETWEEN 2000000 AND 3000000 THEN '2,000,000 - 3,000,000'
         WHEN SUM(ridership) BETWEEN 3000000 AND 4000000 THEN '3,000,000 - 4,000,000'
         ELSE '>4,000,000'
    END AS daily_rider_range
FROM gold.fact_ridership
GROUP BY DATETRUNC(day, transit_timestamp)
)

SELECT
    daily_rider_range,
    COUNT(day) AS total_days
FROM rider_segment
GROUP BY daily_rider_range
ORDER BY total_days DESC
