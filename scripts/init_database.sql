/*
=========================================================
Create Database and Schemas
=========================================================
Script Purpose:
	This script creates a new database named 'IMDbData' after checking if it already exists.
	If the database exists, it is dropped and recreated. Additionally, the script sets up three 
	schemas within the database: 'bronze', 'silver', and 'gold'.

WARNING:
	Running this script will drop the entire 'IMDbData' database if it exists. 
	All data in the database will be permanently deleted.
*/

USE master;
GO

--Drop and recreate the 'IMDbData' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'IMDbData')
BEGIN
	ALTER DATABASE IMDbData SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE IMDbData;
END;
GO

--Create the 'IMDbData' database
CREATE DATABASE IMDbData;
GO

USE IMDbData;
GO

--Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
