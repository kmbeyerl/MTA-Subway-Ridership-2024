/*
=============================================================================
DDL Script: Create Gold Views
=============================================================================
Script Purpose:
  This script creates views for the Gold layer in the data warehouse.
  The Gold layer represents the final dimension and fact tables

  Each view performs transformations and combines data from the Silver layer
  to produce a clean, enriched, and business-ready dataset.

Usage
  - These views can be queried directly for analytics and reporting.
=============================================================================
*/

-- =============================================================================
-- Create Fact: gold.fact_ridership
-- =============================================================================

IF OBJECT_ID ('gold.fact_ridership','V') IS NOT NULL
        DROP VIEW gold.fact_ridership;
GO

CREATE VIEW gold.fact_ridership AS

SELECT
    transit_timestamp,
    station_complex_id,
    station_complex,
    payment_method,
    fare_class_category,
    ridership,
    transfers
FROM silver.subway_ridership
WHERE transit_mode <> 'staten_island_railway';

-- =============================================================================
-- Create Dimension: gold.dim_complexes_and_stations
-- =============================================================================

IF OBJECT_ID ('gold.dim_complexes', 'V') IS NOT NULL
        DROP VIEW gold.dim_complexes;
GO

CREATE VIEW gold.dim_complexes AS

SELECT 
    s.complex_id,
    sc.is_complex,
    sc.no_station_complex,
    s.line,
    s.stop_name,
    CASE WHEN sc.display_name IS NULL THEN s.stop_name
         ELSE sc.display_name
    END AS display_name,
    s.borough,
    s.cbd AS central_business_district,
    s.daytime_routes,
    s.structure,
    s.gtfs_latitude AS latitude,
    s.gtfs_longitude AS longitude,
    s.ada,
    s.ada_notes
FROM silver.subway_stations s
LEFT JOIN silver.stations_and_complexes sc
    ON s.complex_id = sc.complex_id
