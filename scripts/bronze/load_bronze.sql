/*
==============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
==============================================================================
Script Purpose:
	This stored procedure loads data into the 'bronze' schema from external TSV files.
	It performs the following actions:
	- Truncates the bronze tables before loading data.
	- Uses the `BULK INSERT` command to load data from TSV files to bronze tables.

Parameters:
	None.
		This stored procedure does not accept any parameters or return any values.

Usage Example:
	EXEC bronze.load_bronze;
==============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '========================================';
		PRINT 'Loading Bronze Layer';
		PRINT '========================================';

		PRINT '----------------------------------------';
		PRINT 'Loading IMDb Tables';
		PRINT '----------------------------------------';

		SET @start_time = GETDATE()
		PRINT '>>Truncating Table: bronze.name_basics';
		TRUNCATE TABLE bronze.name_basics;
		PRINT '>>Inserting Data Into: bronze.name_basics';
		BULK INSERT bronze.name_basics
		FROM 'C:\SQL\IMDbData\name.basics.tsv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = '\t',
			ROWTERMINATOR = '0x0a',
			CODEPAGE = '65001',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>>Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '>>-------------------------';

		SET @start_time = GETDATE();
		PRINT '>>Truncating Table: bronze.title_basics';
		TRUNCATE TABLE bronze.title_basics;
		PRINT '>>Inserting Data Into: bronze.title_basics';
		BULK INSERT bronze.title_basics
		FROM 'C:\SQL\IMDbData\title.basics.tsv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = '\t',
			ROWTERMINATOR = '0x0a',
			CODEPAGE = '65001',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>>Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '>>-------------------------';

		SET @start_time = GETDATE();
		PRINT '>>Truncating Table: bronze.title_episode';
		TRUNCATE TABLE bronze.title_episode;
		PRINT '>>Inserting Data Into: bronze.title_episode';
		BULK INSERT bronze.title_episode
		FROM 'C:\SQL\IMDbData\title.episode.tsv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = '\t',
			ROWTERMINATOR = '0x0a',
			CODEPAGE = '65001',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>>Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '>>-------------------------';

		SET @start_time = GETDATE();
		PRINT '>>Truncating Table: bronze.title_principals';
		TRUNCATE TABLE bronze.title_principals;
		PRINT '>>Inserting Data Into: bronze.title_principals';
		BULK INSERT bronze.title_principals
		FROM 'C:\SQL\IMDbData\title.principals.tsv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = '\t',
			ROWTERMINATOR = '0x0a',
			CODEPAGE = '65001',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>>Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '>>-------------------------';

		SET @start_time = GETDATE();
		PRINT '>>Truncating Table: bronze.title_ratings';
		TRUNCATE TABLE bronze.title_ratings;
		PRINT '>>Inserting Data Into: bronze.title_ratings';
		BULK INSERT bronze.title_ratings
		FROM 'C:\SQL\IMDbData\title.ratings.tsv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = '\t',
			ROWTERMINATOR = '0x0a',
			CODEPAGE = '65001',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>>Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '>>-------------------------';

		SET @batch_end_time = GETDATE()
		PRINT '========================================';
		PRINT 'Loading Bronze Layer Is Completed';
		PRINT '	-Total Load Duration: ' + CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '========================================'; 
	END TRY
	BEGIN CATCH
		PRINT '========================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '========================================';
	END CATCH
END
