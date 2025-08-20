/*
==============================================================================
DDL Script: Create Gold Views
==============================================================================
Script Purpose:
	This script creates views for the gold layer.
	The gold layer represents the final tables.

	Data is transformed and combined from the silver layer to produce a clean dataset.
==============================================================================
*/

-- ===========================================================================
-- Create Dimension: gold.dim_names
--============================================================================
IF OBJECT_ID('gold.dim_names', 'V') IS NOT NULL
	DROP VIEW gold.dim_names;
GO

CREATE VIEW gold.dim_names AS
SELECT
	nconst		AS nameKey,
	primaryName	AS name,
	birthYear,
	deathYear,
	primaryProfession
FROM silver.name_basics;
GO

-- ===========================================================================
-- Create Dimension: gold.dim_titles
--============================================================================
IF OBJECT_ID('gold.dim_titles', 'V') IS NOT NULL
	DROP VIEW gold.dim_titles;
GO

CREATE VIEW gold.dim_titles AS
SELECT
	t.tconst AS titleKey,
	t.primaryTitle	AS title,
	t.titleType,
	t.startYear,
	t.endYear,
	t.runtimeMinutes,
	t.averageRating,
	t.numVotes		AS numberOfVotes,
	t.genres,
	b.primaryTitle	AS seriesTitle,
	t.seasonNumber,
	t.episodeNumber,
	t.isAdult
FROM (
	SELECT
		b.tconst,
		b.primaryTitle,
		b.titleType,
		b.startYear,
		b.endYear,
		b.runtimeMinutes,
		r.averageRating,
		r.numVotes,
		b.genres,
		b.isAdult,
		e.parentTconst,
		e.seasonNumber,
		e.episodeNumber
	FROM silver.title_basics b 
	LEFT JOIN silver.title_ratings r ON b.tconst = r.tconst
	LEFT JOIN silver.title_episode e ON b.tconst = e.tconst
)t
LEFT JOIN silver.title_basics b ON t.parentTconst = b.tconst;
GO

-- ===========================================================================
-- Create Fact Table: gold.fact_roles
--============================================================================
IF OBJECT_ID('gold.fact_roles', 'V') IS NOT NULL
	DROP VIEW gold.fact_roles;
GO

CREATE VIEW gold.fact_roles AS
SELECT
	n.nconst		AS nameKey,
	n.primaryName	AS name,
	b.tconst		AS titleKey,
	b.primaryTitle	AS title,
	p.category,
	p.job,
	p.characters
FROM silver.title_principals p
LEFT JOIN silver.name_basics n ON p.nconst = n.nconst
LEFT JOIN silver.title_basics b ON p.tconst = b.tconst;
GO
