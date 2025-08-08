IF OBJECT_ID ('gold.report_payments','V') IS NOT NULL
        DROP VIEW gold.report_payments;
GO

CREATE VIEW gold.report_payments AS

WITH base_query AS (
SELECT
	transit_timestamp,
	payment_method,
	fare_class_category,
	ridership
FROM gold.fact_ridership
)

, monthly_aggregation AS (
SELECT
	DATETRUNC(month, transit_timestamp) AS month,
	payment_method,
	fare_class_category,
	SUM(ridership) AS monthly_uses
FROM base_query
GROUP BY 
	DATETRUNC(month, transit_timestamp),
	payment_method,
	fare_class_category
)

, payment_aggregation AS (
SELECT
	payment_method,
	fare_class_category,
	SUM(monthly_uses) AS payment_uses,
	AVG(monthly_uses) AS avg_monthly_uses
FROM monthly_aggregation
GROUP BY payment_method, fare_class_category
)

SELECT
	payment_method,
	fare_class_category,
	ROUND(CAST(payment_uses AS FLOAT) / SUM(payment_uses) OVER ()*100, 2) AS pct_total_uses,
	payment_uses,
	avg_monthly_uses
FROM payment_aggregation
--ORDER BY payment_method, fare_class_category
