/*
=================================================
Create Database and Schemas
=================================================
Script Purpose:
	This script creates a new database named 'NYSubway' after checking if it already exists.
	If the data exists, it is dropped and recreated. Additionally, the script sets up three schemas
	within the database: 'bronze', 'silver', and 'gold'.

WARNING:
	Running this script will drop the entire 'NYSubway' database if it exists.
	All data in the database will be permanently deleted. Proceed with caution
	and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'NYSubway' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'NYSubway')
BEGIN
		ALTER DATABASE NYSubway SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
		DROP DATABASE NYSubway
END;
GO

-- Create the 'NYSubway' database
CREATE DATABASE NYSubway;

USE NYSubway;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
