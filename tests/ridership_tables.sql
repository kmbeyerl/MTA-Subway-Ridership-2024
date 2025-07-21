/* ===================================================================
	bronze.subway_ridership & bronze.jan_ridership_2024 exploration 
=================================================================== */

-- Checking for NULLs or Negative Numbers
SELECT ridership
FROM bronze.subway_ridership
WHERE ridership < 0 OR ridership IS NULL

SELECT transfers
FROM bronze.subway_ridership
WHERE transfers < 0 OR transfers IS NULL

-- Checking for consistency in low cardinality columns
SELECT DISTINCT transit_mode
FROM bronze.subway_ridership

SELECT DISTINCT borough
FROM bronze.subway_ridership

SELECT DISTINCT payment_method
FROM bronze.subway_ridership

SELECT DISTINCT fare_class_category
FROM bronze.subway_ridership

-- Checking for unwanted spaces
SELECT station_complex
FROM bronze.subway_ridership
WHERE station_complex  <> TRIM(station_complex)
