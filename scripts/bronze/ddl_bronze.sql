IF OBJECT_ID ('bronze.subway_ridership', 'U') IS NOT NULL
	DROP TABLE bronze.subway_ridership;
GO

CREATE TABLE bronze.subway_ridership (
	transit_timestamp NVARCHAR(50),
	tansit_mode NVARCHAR(50),
	station_complex_id NVARCHAR(50),
	station_complex NVARCHAR(255),
	borough NVARCHAR(255),
	payment_method NVARCHAR(255),
	fare_class_category NVARCHAR(255),
	ridership INT,
	transfers INT,
	latitude DECIMAL(8,6),
	longitude DECIMAL(9,6),
	Georeference NVARCHAR(50)
);
GO

IF OBJECT_ID ('bronze.stations_and_complexes', 'U') IS NOT NULL
	DROP TABLE bronze.stations_and_complexes;
GO

CREATE TABLE bronze.stations_and_complexes (
	complex_id INT,
	is_complex NVARCHAR(50),
	no_station_complex INT,
	stop_name NVARCHAR(255),
	display_name NVARCHAR(255),
	constituent_station_names NVARCHAR(255),
	station_ids NVARCHAR(50),
	gtfs_stop_ids NVARCHAR(50),
	borough NVARCHAR(50),
	cbd NVARCHAR(50),
	daytime_routes NVARCHAR(50),
	structure_type NVARCHAR(50),
	latitude DECIMAL (8,6),
	longitude DECIMAL (9,6),
	ada INT,
	ada_notes NVARCHAR(255) NULL
);
GO

IF OBJECT_ID ('bronze.jan_ridership_2024', 'U') IS NOT NULL
	DROP TABLE bronze.jan_ridership_2024;
GO

CREATE TABLE bronze.jan_ridership_2024 (
	transit_timestamp NVARCHAR(50),
	tansit_mode NVARCHAR(50),
	station_complex_id NVARCHAR(50),
	station_complex NVARCHAR(255),
	borough NVARCHAR(255),
	payment_method NVARCHAR(255),
	fare_class_category NVARCHAR(255),
	ridership INT,
	transfers INT,
	latitude DECIMAL(8,6),
	longitude DECIMAL(9,6),
	Georeference NVARCHAR(50)
);
GO

IF OBJECT_ID ('bronze.subway_stations','U') IS NOT NULL
		DROP TABLE bronze.subway_stations;
GO

CREATE TABLE bronze.subway_stations (
	gtfs_stop_id NVARCHAR(50),
	station_id INT,
	complex_id INT,
	division NVARCHAR(50),
	line NVARCHAR(50),
	stop_name NVARCHAR(255),
	borough NVARCHAR(50),
	cbd NVARCHAR(50),
	daytime_routes NVARCHAR(50),
	structure NVARCHAR(50),
	gtfs_latitude DECIMAL(8,6),
	gtfs_longitude DECIMAL(9,6),
	north_direction_label NVARCHAR(50),
	south_direction_label NVARCHAR(50),
	ada INT,
	ada_northbound INT,
	ada_southbound INT,
	ada_notes NVARCHAR(255),
	georeference NVARCHAR(50)
);
GO
