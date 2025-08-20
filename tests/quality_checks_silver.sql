/*
==========================================================================
Quality Checks
==========================================================================
Script Purpose:
	This script performs various quality checks for data consistency, accuracy, 
	and standardization across the silver schema. It includes checks for:
	- Null or duplicate primary keys
	- Unwanted spaces in string fields
	- Data standardization and consistency
	- Invalid date ranges
	- Data consistency between related fields

==========================================================================
*/

-- ========================================================
-- Checking 'silver.name_basics'
-- ========================================================
-- Check For Nulls or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
	nconst,
	COUNT(*)
FROM silver.name_basics
GROUP BY nconst
HAVING COUNT(*) >1 OR nconst IS NULL;

--Checking for Invalid Birth and Death Years
--Expectation: No Results
SELECT
	nconst,
	primaryName,
	CAST(CASE
		WHEN birthYear = '\N' THEN NULL
		ELSE birthYear
	END AS INT) AS birthYear
FROM silver.name_basics
WHERE	
	CASE
		WHEN birthYear = '\N' THEN NULL
		ELSE birthYear
	END  > YEAR(GETDATE())
ORDER BY birthYear;

SELECT
	nconst,
	primaryName,
	CAST(CASE
		WHEN deathYear = '\N' THEN NULL
		ELSE deathYear
	END AS INT) AS deathYear
FROM silver.name_basics
WHERE	
	CASE
		WHEN deathYear = '\N' THEN NULL
		ELSE deathYear
	END  > YEAR(GETDATE())
ORDER BY deathYear;

-- ========================================================
-- Checking 'silver.title_basics'
-- ========================================================
-- Check For Nulls or Duplicates in Primary Key
-- Expectation: No Results
SELECT
	tconst,
	COUNT(*)
FROM silver.title_basics
GROUP BY tconst
HAVING COUNT(*) > 1 OR tconst IS NULL;

-- Data Standardization & Consistency
SELECT DISTINCT 
	titleType 
FROM silver.title_basics
ORDER BY titleType;

-- Check for Invalid Start Dates
-- Expectation: No Results
SELECT *
FROM silver.title_basics
WHERE startYear <1870 OR endYear < 1870;

-- ========================================================
-- Checking 'silver.title_episode'
-- ========================================================
-- Check For Nulls or Duplicates in Primary Key
-- Expectation: No Results
SELECT
	tconst,
	COUNT(*)
FROM silver.title_episode
GROUP BY tconst
HAVING COUNT(*) > 1 OR tconst IS NULL;

SELECT
*
FROM silver.title_episode
WHERE parentTconst IS NULL;

-- ========================================================
-- Checking 'silver.title_principals'
-- ========================================================
-- Checking for Invalid Keys
-- Expectation: No Results
SELECT
*
FROM silver.title_principals
WHERE tconst NOT LIKE 'tt%' OR nconst NOT LIKE 'nm%';

-- ========================================================
-- Checking 'silver.title_ratings'
-- ========================================================
-- Check For Nulls or Duplicates in Primary Key
-- Expectation: No Results
SELECT
tconst,
COUNT(*)
FROM silver.title_ratings
GROUP BY tconst
HAVING COUNT(*) > 1 OR tconst IS NULL;
