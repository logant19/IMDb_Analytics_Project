
/*
==============================================================================
Analysis Script
==============================================================================
Script Purpose:
	This script explores the data imported into the gold schema.
	Data analytics is performed to find interesting information about our dataset.
==============================================================================
*/
-- First we'll explore all title types that divide titles
SELECT DISTINCT titleType FROM gold.dim_titles;

--Then we'll explore all categories for the principal roles
SELECT DISTINCT category FROM gold.fact_roles;

--Next we'll identify the earliest and latest titles
SELECT 
'earliest titles' AS releasePeriod,
title,
titleType,
startYear AS releaseYear
FROM gold.dim_titles
WHERE startYear IN (
	SELECT MIN(startYear) FROM gold.dim_titles
	)
UNION ALL
SELECT 
'latest titles' AS releasePeriod,
title,
titleType,
startYear AS releaseYear
FROM gold.dim_titles
WHERE startYear IN (
	SELECT MAX(startYear) FROM gold.dim_titles
	);

--Let's identify the earliest and latest films, specifically
SELECT 
'earliest titles' AS releaseDates,
title,
titleType,
startYear AS releaseYear
FROM gold.dim_titles
WHERE titleType = 'movie' AND startYear IN (
	SELECT MIN(startYear) FROM gold.dim_titles WHERE titleType = 'movie'
	)
UNION ALL
SELECT 
'latest titles' AS releaseDates,
title,
titleType,
startYear AS releaseYear
FROM gold.dim_titles
WHERE titleType = 'movie' AND startYear IN (
	SELECT MAX(startYear) FROM gold.dim_titles WHERE titleType = 'movie'
	);

--Now let's find how many people have directed a feature-length film
SELECT COUNT(DISTINCT r.nameKey) AS totalDirectors 
FROM gold.fact_roles r
LEFT JOIN gold.dim_titles t ON r.titleKey = t.titleKey
WHERE t.titleType = 'movie' AND t.isAdult = 'No' AND t.runtimeMinutes >= 80;

--And then we'll find the distribution of principals by category
SELECT
	category,
	COUNT(nameKey) AS totalPrincipals
FROM gold.fact_roles
GROUP BY category
ORDER BY totalPrincipals DESC;

--Next we'll find the directors with the most feature-length films
SELECT TOP 10
	r.name,
	COUNT(r.titleKey) AS films
FROM gold.fact_roles r
LEFT JOIN gold.dim_titles t ON r.titleKey = t.titleKey
WHERE t.titleType = 'movie' AND r.category = 'director' AND t.isAdult = 'No' AND t.runtimeMinutes >= 80
GROUP BY name
ORDER BY films DESC;

--Then we can analyze film production over the years
SELECT 
	startYear as releaseYear,
	COUNT(*) as filmsMade
FROM gold.dim_titles
WHERE titleType = 'movie' AND isAdult = 'No' AND startYear IS NOT NULL
GROUP BY startYear 
ORDER BY releaseYear;

--Next let's find the highest rated films
SELECT TOP 250
	title, 
	startYear as releaseYear,
	averageRating
FROM gold.dim_titles
WHERE titleType = 'movie'
ORDER by averageRating DESC;

--Now let's limit it to films that have received at least 25000 ratings
SELECT TOP 250
	title, 
	startYear as releaseYear,
	averageRating,
	numberOfVotes
FROM gold.dim_titles
WHERE titleType = 'movie' AND numberOfVotes >= 25000
ORDER by averageRating DESC;

--And now let's look at what years those films were made in
SELECT
	CAST(releaseYear/10*10 AS VARCHAR) + 's' AS decade,
	COUNT(*) AS filmCount
FROM (
	SELECT TOP 250
		title, 
		startYear as releaseYear,
		averageRating,
		numberOfVotes
	FROM gold.dim_titles
	WHERE titleType = 'movie' AND numberOfVotes >= 25000
	ORDER by averageRating DESC
	)t
GROUP BY CAST(releaseYear/10*10 AS VARCHAR) + 's'
ORDER BY CAST(releaseYear/10*10 AS VARCHAR) + 's';

--Now let's look at the top TV shows with at least 25000 votes
SELECT TOP 250
	title, 
	startYear,
	endYear,
	averageRating,
	numberOfVotes
FROM gold.dim_titles
WHERE titleType = 'TV series' AND numberOfVotes >= 25000
ORDER by averageRating DESC;

--And let's see what the start years for those shows are
SELECT
	CAST(startYear/10*10 AS VARCHAR) + 's' AS decade,
	COUNT(*) AS seriesCount
FROM (
	SELECT TOP 250
		title, 
		startYear,
		endYear,
		averageRating,
		numberOfVotes
	FROM gold.dim_titles
	WHERE titleType = 'TV series' AND numberOfVotes >= 25000
	ORDER by averageRating DESC
	)t
GROUP BY CAST(startYear/10*10 AS VARCHAR) + 's'
ORDER BY CAST(startYear/10*10 AS VARCHAR) + 's';

--Now let's look at what years have the best ratings for films
SELECT TOP 10
	startYear as releaseYear, 
	ROUND(AVG(averageRating),2) as avgRating
FROM gold.dim_titles
WHERE startYear IS NOT NULL AND titleType = 'movie'
GROUP BY startYear
ORDER BY avgRating DESC;

--1947 and 1948 are some pretty noticeable outliers in this group. Let's see what films from those years are so beloved.
SELECT TOP 20
	title,
	startYear as releaseYear,
	averageRating
FROM (
	SELECT
		title,
		startYear,
		averageRating,
		ROW_NUMBER() OVER(PARTITION BY startYear ORDER BY averageRating DESC) AS rn
	FROM gold.dim_titles
	WHERE titleType = 'movie' AND averageRating IS NOT NULL AND (startYear = 1947 OR startYear = 1948)
)t
WHERE rn <=10
ORDER BY releaseYear ASC, averageRating DESC

--And now let's zoom out and look at what decades have the best films ratings
SELECT TOP 10
	CAST(startYear/10*10 AS VARCHAR) + 's' AS decade,
	ROUND(AVG(averageRating),2) as avgRating
FROM gold.dim_titles
WHERE startYear IS NOT NULL AND titleType = 'movie'
GROUP BY CAST(startYear/10*10 AS VARCHAR) + 's'
ORDER BY avgRating DESC;

--Let's give some love to the hidden gems and find the highest-rated feature-length films with under 25000 votes

SELECT TOP 250
	title,
	averageRating, 
	numberOfVotes
FROM gold.dim_titles
WHERE numberOfVotes BETWEEN 1000 AND 25000 AND titleType = 'movie' AND isAdult = 'No'
ORDER BY averageRating DESC

--Next we'll see what films are the most watched using the number of votes, regardless of rating
SELECT TOP 250
	title,
	startYear AS releaseYear,
	numberOfVotes
FROM gold.dim_titles
WHERE titleType = 'movie'
ORDER BY numberOfVotes DESC

--And naturally let's look at what years those films were made in
SELECT
	CAST(releaseYear/10*10 AS VARCHAR) + 's' AS decade,
	COUNT(*) AS filmCount
FROM (
	SELECT TOP 250
		title,
		startYear AS releaseYear,
		numberOfVotes
	FROM gold.dim_titles
	WHERE titleType = 'movie'
	ORDER BY numberOfVotes DESC
	)t
GROUP BY CAST(releaseYear/10*10 AS VARCHAR) + 's'
ORDER BY CAST(releaseYear/10*10 AS VARCHAR) + 's';

--Now let's analyze how runtime affects member ratings

SELECT
  CASE
    WHEN runtimeMinutes BETWEEN 0 AND 90 THEN 'Short'
    WHEN runtimeMinutes BETWEEN 91 AND 120 THEN 'Medium'
    WHEN runtimeMinutes >= 121 THEN 'Long'
  END AS filmLength,
  ROUND(AVG(averageRating),2) AS avgRating,
  COUNT(*) AS filmCount
FROM gold.dim_titles
WHERE titleType = 'movie'
  AND runtimeMinutes IS NOT NULL
GROUP BY CASE
    WHEN runtimeMinutes BETWEEN 0 AND 90 THEN 'Short'
    WHEN runtimeMinutes BETWEEN 91 AND 120 THEN 'Medium'
    WHEN runtimeMinutes >= 121 THEN 'Long'
  END
ORDER BY avgRating DESC;

--Next let's see how average runtime has changed throughout the years.
SELECT TOP 1000
	CAST(startYear/10*10 AS NVARCHAR) + 's' AS decade,
	AVG(runtimeMinutes) AS avgRuntimeMinutes
FROM gold.dim_titles
WHERE startYear IS NOT NULL AND titleType = 'movie'
GROUP BY CAST(startYear/10*10 AS NVARCHAR) + 's'
ORDER BY CAST(startYear/10*10 AS NVARCHAR) + 's';

--Next let's find the 10 most common genres
WITH genreSplit AS (
    SELECT 
        LTRIM(RTRIM(s.value)) AS genre
    FROM gold.dim_titles
    CROSS APPLY STRING_SPLIT(genres, ',') s
    WHERE titleType = 'movie'
      AND genres IS NOT NULL
)
SELECT TOP 10
    genre,
    COUNT(*) AS genreCount
FROM genreSplit
GROUP BY genre
ORDER BY COUNT(*) DESC;

--And then let's find which of the most popular genres are rated the highest
WITH genreRatings AS (
    SELECT 
        t.titleKey,
        LTRIM(RTRIM(s.value)) AS genre,
        t.averageRating
    FROM gold.dim_titles t
    CROSS APPLY STRING_SPLIT(t.genres, ',') s
    WHERE t.titleType = 'movie'
      AND t.genres IS NOT NULL
),
genreStats AS (
    SELECT
        genre,
        COUNT(*) AS numFilms,
        CAST(AVG(averageRating) AS DECIMAL(4,2)) AS avgRating
    FROM genreRatings
    WHERE genre <> ''
    GROUP BY genre
),
top10 AS (
    SELECT TOP 10 *
    FROM genreStats
    ORDER BY numFilms DESC
)
SELECT genre, avgRating
FROM top10
ORDER BY avgRating DESC;

--Next let's see which genres tend to be the longest

WITH genreLength AS (
	SELECT 
		LTRIM(RTRIM(s.value)) AS genre, 
		ROUND(AVG(t.runtimeMinutes),2) as avgRuntime
	FROM gold.dim_titles t
	CROSS APPLY STRING_SPLIT(t.genres, ',') s
	WHERE titleType = 'movie'
	AND t.genres IS NOT NULL
	GROUP BY LTRIM(RTRIM(s.value))
)
SELECT TOP 10 
	genre, 
	avgRuntime
FROM genreLength
ORDER BY avgRuntime DESC;

--Let's hone in on one genre and find the average runtime and rating of animated film
SELECT 
	ROUND(AVG(runtimeMinutes),2) as animationAvgRuntime,
	ROUND(AVG(averageRating),2) as animationAvgRating, 
	COUNT(*) as animationCount
FROM gold.dim_titles
WHERE genres LIKE '%Animation%'
	AND titleType = 'movie';

--Now let's see who the best-rated film directors are
SELECT TOP 250
	r.name,
	CAST(AVG(t.averageRating) AS DECIMAL(4,2)) AS avgRating
FROM gold.fact_roles r
LEFT JOIN gold.dim_titles t ON r.titleKey = t.titleKey
WHERE t.titleType = 'movie' AND t.numberOfVotes >=25000 AND category = 'director' 
GROUP BY r.name
HAVING AVG(t.averageRating) IS NOT NULL
ORDER BY avgRating DESC;

--Let's limit this to directors who have made at least 3 films
SELECT TOP 250
	r.name as director,
	CAST(AVG(t.averageRating) AS DECIMAL(4,2)) AS avgRating
FROM gold.fact_roles r
LEFT JOIN gold.dim_titles t ON r.titleKey = t.titleKey
WHERE t.titleType = 'movie' AND t.numberOfVotes >=25000 AND category = 'director' 
GROUP BY r.name
HAVING AVG(t.averageRating) IS NOT NULL AND COUNT(r.name) > 3
ORDER BY avgRating DESC;

--And of course let's do the same for actors and actresses!
SELECT TOP 250
	r.name as actor,
	CAST(AVG(t.averageRating) AS DECIMAL(4,2)) AS avgRating
FROM gold.fact_roles r
LEFT JOIN gold.dim_titles t ON r.titleKey = t.titleKey
WHERE t.titleType = 'movie' AND t.numberOfVotes >=25000 AND (category = 'actor' OR category = 'actress') 
GROUP BY r.name
HAVING AVG(t.averageRating) IS NOT NULL AND COUNT(r.name) > 3
ORDER BY avgRating DESC;
