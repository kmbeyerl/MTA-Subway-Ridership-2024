CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();

		PRINT '========================================';
		PRINT 'Loading Bronze Layer';
		PRINT '========================================';

		PRINT '----------------------------------------';
		PRINT 'Loading January 2024 Ridership Table';
		PRINT '----------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.jan_ridership_2024';
		TRUNCATE TABLE bronze.jan_ridership_2024;

		PRINT '>> Inserting Date Into: bronze.jan_ridership_2024';
		BULK INSERT bronze.jan_ridership_2024
		FROM 'C:\Users\kiery\Documents\Data\SQL\Subway Ridership 2024\MTA_Subway_Hourly_Ridership_January.csv'
		WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				FORMAT = 'CSV',
				TABLOCK
		); 
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------';

		PRINT '----------------------------------------';
		PRINT 'Loading 2024 Ridership Table';
		PRINT '----------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.subway_ridership';
		TRUNCATE TABLE bronze.subway_ridership;

		PRINT '>> Inserting Date Into: bronze.subway_ridership';
		BULK INSERT bronze.subway_ridership
		FROM 'C:\Users\kiery\Documents\Data\SQL\Subway Ridership 2024\subway_hourly_ridership_2024.csv'
		WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				FORMAT = 'CSV',
				ROWTERMINATOR = '0x0a'
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------';

		PRINT '----------------------------------------';
		PRINT 'Loading Subway Stations and Complexes';
		PRINT '----------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.stations_and_complexes';
		TRUNCATE TABLE bronze.stations_and_complexes;

		PRINT '>> Inserting Date Into: bronze.stations_and_complexes';
		BULK INSERT bronze.stations_and_complexes
		FROM 'C:\Users\kiery\Documents\Data\SQL\Subway Ridership 2024\subway_stations_and_complexes.csv'
		WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				FORMAT = 'CSV',
				ROWTERMINATOR = '0x0a'
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.subway_stations';
		TRUNCATE TABLE bronze.subway_stations;

		PRINT '>> Inserting Date Into: bronze.subway_stations';
		BULK INSERT bronze.subway_stations
		FROM 'C:\Users\kiery\Documents\Data\SQL\Subway Ridership 2024\MTA_Subway_Stations_20250724.csv'
		WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				FORMAT = 'CSV',
				ROWTERMINATOR = '0x0a'
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------';

		SET @batch_end_time = GETDATE();
		PRINT '==========================================';
		PRINT 'Loading Bronze Layer is Completed';
		PRINT '		- Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '==========================================';
	END TRY
	BEGIN CATCH
		PRINT '==========================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '==========================================';
	END CATCH
END
