CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '===============================================';
		PRINT 'Loading Silver Layer';
		PRINT '===============================================';

		PRINT '----------------------------------------';
		PRINT 'Loading January 2024 Ridership Table';
		PRINT '----------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.jan_ridership_2024';
		TRUNCATE TABLE silver.jan_ridership_2024;

		PRINT '>> Inserting Data Into: silver.jan_ridership_2024';
		INSERT INTO silver.jan_ridership_2024 (
            transit_timestamp,
            transit_mode,
            station_complex_id,
            station_complex,
            borough,
            payment_method,
            fare_class_category,
            ridership,
            transfers,
            latitude,
            longitude,
            georeference)

        SELECT
           CONVERT(DATETIME, transit_timestamp, 120) AS transit_timestamp,
           transit_mode,
           station_complex_id,
           station_complex,
           borough,
           CASE WHEN payment_method = 'metrocard' THEN 'Metrocard'
                WHEN payment_method = 'omny' THEN 'OMNY'
           END AS payment_method,
           fare_class_category,
           ridership,
           transfers,
           latitude,
           longitude,
           Georeference
        FROM (
            SELECT *
            FROM bronze.jan_ridership_2024
            WHERE transit_mode <> 'tram'
        )t;
        SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------';

        PRINT '----------------------------------------';
		PRINT 'Loading 2024 Ridership Table';
		PRINT '----------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncatig Table: silver.subway_ridership';
        TRUNCATE TABLE silver.subway_ridership;
        PRINT '>> Inserting Data Into: silver.subway_ridership';

        INSERT INTO silver.subway_ridership (
            transit_timestamp,
            transit_mode,
            station_complex_id,
            station_complex,
            borough,
            payment_method,
            fare_class_category,
            ridership,
            transfers,
            latitude,
            longitude,
            georeference)

        SELECT
           CONVERT(DATETIME, transit_timestamp, 120) AS transit_timestamp,
           transit_mode,
           station_complex_id,
           station_complex,
           borough,
           CASE WHEN payment_method = 'metrocard' THEN 'Metrocard'
                WHEN payment_method = 'omny' THEN 'OMNY'
           END AS payment_method,
           fare_class_category,
           ridership,
           transfers,
           latitude,
           longitude,
           Georeference
        FROM (
            SELECT *
            FROM bronze.subway_ridership
            WHERE transit_mode <> 'tram'
        )t;
        SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------';

        PRINT '----------------------------------------';
		PRINT 'Loading Subway Stations and Complexes';
		PRINT '----------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.stations_and_complexes';
        TRUNCATE TABLE silver.stations_and_complexes;

        PRINT '>> Inserting Data Into: silver.stations_and_complexes';
        INSERT INTO silver.stations_and_complexes (
            complex_id,
            is_complex,
            no_station_complex,
            stop_name,
            display_name,
            constituent_station_names,
            station_ids,
            gtfs_stop_ids,
            borough,
            cbd,
            daytime_routes,
            structure_type,
            latitude,
            longitude,
            ada,
            ada_notes)

        SELECT
            complex_id,
            is_complex,
            no_station_complex,
            stop_name,
            display_name,
            constituent_station_names,
            station_ids,
            gtfs_stop_ids,
            CASE WHEN borough = 'M' THEN 'Manhattan'
                 WHEN borough = 'Bx' THEN 'Bronx'
                 WHEN borough = 'B' THEN 'Brooklyn'
                 WHEN borough = 'Q' THEN 'Queens'
                 WHEN borough = 'SI' THEN 'Staten Island'
            END AS borough,
            cbd,
            daytime_routes,
            structure_type,
            latitude,
            longitude,
            CASE WHEN ada = 0 THEN 'Not ADA-accessible'
                 WHEN ada = 1 THEN 'Fully Accessible'
                 WHEN ada = 2 THEN 'Partially Accessible'
            END AS ada,
            ada_notes
        FROM bronze.stations_and_complexes;
        SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------';

        SET @batch_end_time = GETDATE();
		PRINT '==========================================';
		PRINT 'Loading Silver Layer is Completed';
		PRINT '		- Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '==========================================';
    END TRY
    BEGIN CATCH
        PRINT '==========================================';
		PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '==========================================';
    END CATCH
END
