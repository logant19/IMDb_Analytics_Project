/*
==============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
==============================================================================
Script Purpose:
	This stored procedure performs the ETL (Extract, Transform, Load) process to
	populate the silver schema tables from the bronze schema.

	It performs the following actions:
	- Truncates the silver tables before loading data.
	- Inserts transformed and cleaned data from bronze into silver tables.

Parameters:
	None.
		This stored procedure does not accept any parameters or return any values.

Usage Example:
	EXEC silver.load_silver;
==============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE()
		PRINT '========================================';
		PRINT 'Loading Silver Layer';
		PRINT '========================================';

		PRINT '----------------------------------------';
		PRINT 'Loading IMDb Tables';
		PRINT '----------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>>Truncating Table: silver.name_basics';
		TRUNCATE TABLE silver.name_basics;
		PRINT '>>Inserting Data Into: silver.name_basics';
		INSERT INTO silver.name_basics (
			nconst,
			primaryName,
			birthYear,
			deathYear,
			primaryProfession,
			knownForTitles
		)
		SELECT
			nconst,
			primaryName,
			CAST(NULLIF(birthYear, '\N') AS INT) AS birthYear,
			CAST(NULLIF(deathYear, '\N') AS INT) AS deathYear,
			NULLIF(primaryProfession, '\N') AS primaryProfession,
			NULLIF(knownForTitles, '\N') AS knownForTitles
		FROM bronze.name_basics;
		SET @end_time = GETDATE();
		PRINT '>>Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '>>-------------------------';

		SET @start_time = GETDATE();
		PRINT '>>Truncating Table: silver.title_basics';
		TRUNCATE TABLE silver.title_basics;
		PRINT '>>Inserting Data Into: silver.title_basics';
		INSERT INTO silver.title_basics (
			tconst,
			titleType,
			primaryTitle,
			originalTitle,
			isAdult,
			startYear,
			endYear,
			runtimeMinutes,
			genres
		)
		SELECT
			tconst,
			CASE titleType
				WHEN 'tvMovie' THEN 'TV movie'
				WHEN 'tvSpecial' THEN 'TV special'
				WHEN 'videoGame' THEN 'video game'
				WHEN 'tvShort' THEN 'TV short'
				WHEN 'tvEpisode' THEN 'TV episode'
				WHEN 'tvSeries' THEN 'TV series'
				WHEN 'tvPilot' THEN 'TV pilot'
				WHEN 'tvMiniSeries' THEN 'TV miniseries'
				ELSE titleType
			END AS titleType,
			primaryTitle,
			originalTitle,
			CASE
				WHEN isAdult = '0' THEN 'No'
				WHEN isAdult = '1' THEN 'Yes'
			END AS isAdult,
			CAST(NULLIF(startYear, '\N') AS INT) AS startYear,
			CAST(NULLIF(endYear, '\N') AS INT) AS endYear,
			CAST(NULLIF(runtimeMinutes, '\N') AS INT) AS runtimeMinutes,
			NULLIF(genres, '\N') AS genres
		FROM bronze.title_basics;
		SET @end_time = GETDATE();
		PRINT '>>Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '>>-------------------------';

		SET @start_time = GETDATE();
		PRINT '>>Truncating Table: silver.title_episode';
		TRUNCATE TABLE silver.title_episode;
		PRINT '>>Inserting Data Into: silver.title_episode';
		INSERT INTO silver.title_episode (
			tconst,
			parentTconst,
			seasonNumber,
			episodeNumber
		)
		SELECT
			tconst,
			parentTconst,
			CAST(NULLIF(seasonNumber, '\N') AS INT) AS seasonNumber,
			CAST(NULLIF(episodeNumber, '\N') AS INT) AS episodeNumber
		FROM bronze.title_episode;
		SET @end_time = GETDATE();
		PRINT '>>Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '>>-------------------------';

		SET @start_time = GETDATE();
		PRINT '>>Truncating Table: silver.title_principals';
		TRUNCATE TABLE silver.title_principals;
		PRINT '>>Inserting Data Into: silver.title_principals';
		INSERT INTO silver.title_principals (
			tconst,
			ordering,
			nconst,
			category,
			job,
			characters
		)
		SELECT
			tconst,
			ordering,
			nconst,
			category,
			NULLIF(job, '\N') AS job,
			NULLIF(characters, '\N') AS characters
		FROM bronze.title_principals
		SET @end_time = GETDATE();
		PRINT '>>Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '>>-------------------------';

		SET @start_time = GETDATE();
		PRINT '>>Truncating Table: silver.title_ratings';
		TRUNCATE TABLE silver.title_ratings;
		PRINT '>>Inserting Data Into: silver.title_ratings';
		INSERT INTO silver.title_ratings (
			tconst,
			averageRating,
			numVotes
		)
		SELECT
			tconst,
			averageRating,
			numVotes
		FROM bronze.title_ratings;
		
		SET @batch_end_time = GETDATE();
		PRINT '========================================';
		PRINT 'Loading Silver Layer Is Completed';
		PRINT '	-Total Load Duration: ' + CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '========================================'; 
	END TRY
	BEGIN CATCH
		PRINT '========================================';
		PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '========================================';
	END CATCH
END
