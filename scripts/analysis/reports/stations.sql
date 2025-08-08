IF OBJECT_ID ('gold.report_stations','V') IS NOT NULL
        DROP VIEW gold.report_stations;
GO

CREATE VIEW gold.report_stations AS

WITH base_query AS (
SELECT
	r.transit_timestamp,
	r.station_complex_id,
	r.station_complex,
	c.borough,
	r.ridership,
	r.transfers
FROM gold.fact_ridership r
LEFT JOIN gold.dim_complexes c
	ON r.station_complex_id = c.complex_id
--ORDER BY c.complex_id, r.transit_timestamp
)

, monthly_aggregation AS (
SELECT
	DATETRUNC(month, transit_timestamp) AS month,
	station_complex_id,
	station_complex,
	borough,
	SUM(ridership) AS monthly_riders,
	SUM(transfers) AS monthly_transfers
FROM base_query
GROUP BY 
	DATETRUNC(month, transit_timestamp), 
	station_complex, 
	station_complex_id,
	borough
--ORDER BY station_complex
)

, station_aggregations AS (
SELECT
	station_complex_id,
	station_complex,
	borough,
	SUM(monthly_riders) AS station_riders,
	SUM(monthly_transfers) AS station_transfers,
	AVG(monthly_riders) AS avg_monthly_riders,
	AVG(monthly_transfers) AS avg_monthly_transfers
FROM monthly_aggregation
GROUP BY station_complex_id, station_complex, borough
--ORDER BY total_riders DESC
)

SELECT
	station_complex_id,
	borough,
	station_complex,
	CASE WHEN station_riders > 10000000 THEN 'High Traffic'
		 WHEN station_riders < 1000000 THEN 'Low Traffic'
		 ELSE 'Medium Traffic'
	END AS station_traffic,
	ROUND(CAST(station_riders AS FLOAT) / SUM(station_riders) OVER ()*100, 3) AS pct_total_riders,
	station_riders,
	station_transfers,
	avg_monthly_riders,
	avg_monthly_transfers
FROM station_aggregations
