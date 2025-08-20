/*
===========================================================
DDL Script: Create Silver Tables
===========================================================
Script Purpose:
	This script creates tables in the 'silver' schema, dropping existing tables 
	if they already exist.
		Run this script to redefine the DDL structure of 'silver' tables.
===========================================================
*/

IF OBJECT_ID('silver.name_basics', 'U') IS NOT NULL
	DROP TABLE silver.name_basics;
GO

CREATE TABLE silver.name_basics (
	nconst				NVARCHAR(50),
	primaryName			NVARCHAR(200),
	birthYear			INT,
	deathYear			INT,
	primaryProfession	NVARCHAR(100),
	knownForTitles		NVARCHAR(50)
);
GO

IF OBJECT_ID('silver.title_akas', 'U') IS NOT NULL
	DROP TABLE silver.title_akas;
GO

IF OBJECT_ID('silver.title_basics', 'U') IS NOT NULL
	DROP TABLE silver.title_basics;
GO

CREATE TABLE silver.title_basics (
	tconst			NVARCHAR(10),
	titleType		NVARCHAR(20),
	primaryTitle	NVARCHAR(MAX),
	originalTitle	NVARCHAR(MAX),
	isAdult			NVARCHAR(5),
	startYear		INT,
	endYear			INT,
	runtimeMinutes	INT,
	genres			NVARCHAR(100)
);
GO

IF OBJECT_ID('silver.title_crew', 'U') IS NOT NULL
	DROP TABLE silver.title_crew;
GO

IF OBJECT_ID('silver.title_episode', 'U') IS NOT NULL
	DROP TABLE silver.title_episode;
GO

CREATE TABLE silver.title_episode (
	tconst			NVARCHAR(10),
	parentTconst	NVARCHAR(10),
	seasonNumber	INT,
	episodeNumber	INT
);
GO

IF OBJECT_ID('silver.title_principals', 'U') IS NOT NULL
	DROP TABLE silver.title_principals;
GO

CREATE TABLE silver.title_principals (
	tconst		NVARCHAR(10),
	ordering	INT,
	nconst		NVARCHAR(10),
	category	NVARCHAR(20),
	job			NVARCHAR(MAX),
	characters	NVARCHAR(MAX)
);
GO

IF OBJECT_ID('silver.title_ratings', 'U') IS NOT NULL
	DROP TABLE silver.title_ratings;
GO

CREATE TABLE silver.title_ratings (
	tconst			NVARCHAR(10),
	averageRating	FLOAT,
	numVotes		INT
);
GO
