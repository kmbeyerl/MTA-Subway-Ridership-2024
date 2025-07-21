/* ===================================================================
	bronze.stations_and_complexes exploration
=================================================================== */

-- Checking primary key for duplicates or NULL values
SELECT 
	complex_id,
	COUNT(*)
FROM bronze.stations_and_complexes
GROUP BY complex_id
HAVING COUNT(*) > 1 OR complex_id IS NULL

-- Checking low cardinality columns for consistency in data
SELECT DISTINCT cbd
FROM bronze.stations_and_complexes

SELECT DISTINCT structure_type
FROM bronze.stations_and_complexes

SELECT DISTINCT ada
FROM bronze.stations_and_complexes

SELECT DISTINCT borough
FROM bronze.stations_and_complexes

-- Checking to see if high cardinality string columns have unwanted spaces
SELECT stop_name 
FROM bronze.stations_and_complexes
WHERE stop_name  <> TRIM(stop_name)

SELECT display_name
FROM bronze.stations_and_complexes
WHERE display_name   <> TRIM(display_name)

SELECT constituent_station_names
FROM bronze.stations_and_complexes
WHERE constituent_station_names   <> TRIM(constituent_station_names)
