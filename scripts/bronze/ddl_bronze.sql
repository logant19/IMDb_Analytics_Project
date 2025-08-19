/*
===========================================================
DDL Script: Create Bronze Tables
===========================================================
Script Purpose:
	This script creates tables in the 'bronze' schema, dropping existing tables 
	if they already exist.
		Run this script to redefine the DDL structure of 'bronze' tables.
===========================================================
*/

IF OBJECT_ID('bronze.name_basics', 'U') IS NOT NULL
	DROP TABLE bronze.name_basics;
GO

CREATE TABLE bronze.name_basics (
	nconst				NVARCHAR(50),
	primaryName			NVARCHAR(MAX),
	birthYear			NVARCHAR(50),
	deathYear			NVARCHAR(50),
	primaryProfession	NVARCHAR(MAX),
	knownForTitles		NVARCHAR(MAX)
);
GO
	
IF OBJECT_ID('bronze.title_basics', 'U') IS NOT NULL
	DROP TABLE bronze.title_basics;
GO

CREATE TABLE bronze.title_basics (
	tconst			NVARCHAR(50),
	titleType		NVARCHAR(50),
	primaryTitle	NVARCHAR(MAX),
	originalTitle	NVARCHAR(MAX),
	isAdult			NVARCHAR(50),
	startYear		NVARCHAR(50),
	endYear			NVARCHAR(50),
	runtimeMinutes	NVARCHAR(50),
	genres			NVARCHAR(MAX)
);
GO

IF OBJECT_ID('bronze.title_episode', 'U') IS NOT NULL
	DROP TABLE bronze.title_episode;
GO

CREATE TABLE bronze.title_episode (
	tconst			NVARCHAR(50),
	parentTconst	NVARCHAR(50),
	seasonNumber	NVARCHAR(50),
	episodeNumber	NVARCHAR(50)
);
GO

IF OBJECT_ID('bronze.title_principals', 'U') IS NOT NULL
	DROP TABLE bronze.title_principals;
GO

CREATE TABLE bronze.title_principals (
	tconst		NVARCHAR(50),
	ordering	INT,
	nconst		NVARCHAR(50),
	category	NVARCHAR(50),
	job			NVARCHAR(MAX),
	characters	NVARCHAR(MAX)
);
GO

IF OBJECT_ID('bronze.title_ratings', 'U') IS NOT NULL
	DROP TABLE bronze.title_ratings;
GO

CREATE TABLE bronze.title_ratings (
	tconst			NVARCHAR(50),
	averageRating	FLOAT,
	numVotes		INT
);
GO
