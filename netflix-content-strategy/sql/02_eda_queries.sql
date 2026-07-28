-------------------------------------------------------------------------------
-- PROBLEM 1: Count the number of Movies vs TV Shows
-- Business Context: Evaluate the catalog mix to understand balance between single-viewing content and multi-season engagement.
-------------------------
SELECT 
  type,
  COUNT(*) AS total_content,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS catalog_percentage
FROM `sql-projects-503512.netflix_ds.cleaned_netflix_titles` 
GROUP BY type;

-------------------------------------------------------------------------------
-- PROBLEM 2: Identify the longest movie
-- Business Context: Benchmark extreme runtime outliers for operational storage and bandwidth planning.
-------------------------------------------------------------------------------
SELECT
    title,
    duration_minutes
FROM `sql-projects-503512.netflix_ds.cleaned_netflix_titles` 
WHERE type = 'Movie' 
    AND duration_minutes IS NOT NULL
ORDER BY duration_minutes DESC
LIMIT 1;

-------------------------------------------------------------------------------
-- PROBLEM 3: List all TV shows with more than 5 seasons
-- Business Context: Pinpoint long-running flagship series that drive long-term subscriber retention.
-------------------------------------------------------------------------------
SELECT 
    title,
    duration_seasons
FROM `sql-projects-503512.netflix_ds.cleaned_netflix_titles`
WHERE type = 'TV Show' 
  AND duration_seasons > 5
ORDER BY duration_seasons DESC;

-------------------------------------------------------------------------------
-- PROBLEM 4: Find all content without a director
-- Business Context: Identify metadata coverage gaps to prioritize database enrichment.
-------------------------------------------------------------------------------
SELECT  
  title,
  type,
  director
FROM `sql-projects-503512.netflix_ds.cleaned_netflix_titles`
WHERE director= 'Unknown';

-------------------------------------------------------------------------------
-- PROBLEM 5: Find the most common rating for movies and TV shows
-- Business Context: Understand target demographic distribution across media formats.
-------------------------------------------------------------------------------
WITH RatingCounts AS(
    SELECT
        type,
        rating,
        COUNT(*) AS rating_count,
        RANK() OVER(
            PARTITION BY type
            ORDER BY COUNT(*) DESC
        ) AS rank_num
    FROM `sql-projects-503512.netflix_ds.cleaned_netflix_titles`
    WHERE rating IS NOT NULL
    GROUP BY type, rating
)
SELECT
    type,
    rating as most_frequent_rating,
    rating_count
FROM RatingCounts
WHERE rank_num = 1;

-------------------------------------------------------------------------------
-- PROBLEM 6: Count the number of content items in each genre
-- Business Context: Map genre breadth to identify dominant content categories and potential supply shortages.
-------------------------------------------------------------------------------
SELECT 
    genre,
    COUNT(*) AS total_content
FROM `sql-projects-503512.netflix_ds.cleaned_netflix_titles`,
UNNEST(SPLIT(genres, ',')) AS genre
GROUP BY genre
ORDER BY total_content DESC;

-------------------------------------------------------------------------------
-- PROBLEM 7: List all movies that are documentaries
-- Business Context: Assess non-scripted educational offering size for specialized segment marketing.
-------------------------------------------------------------------------------
SELECT 
    title,
    release_year,
    rating,
    genres
FROM `sql-projects-503512.netflix_ds.cleaned_netflix_titles`
WHERE type = 'Movie' 
  AND LOWER(genres) LIKE '%documentaries%';

-------------------------------------------------------------------------------
-- PROBLEM 8: Categorize content based on safety keywords ('kill' / 'violence')
-- Business Context: Pre-flag sensitive material for content moderation and maturity tag enforcement.
-------------------------------------------------------------------------------
SELECT
    title,
    type,
    genres,
    CASE
        WHEN LOWER(description) LIKE '%kill%' 
            OR LOWER(description) LIKE '%violence%' THEN 'Sensitive'
        ELSE 'Non-Sensitive'
    END AS content_category
FROM `sql-projects-503512.netflix_ds.cleaned_netflix_titles`;

-- Count the number of sensitive vs non-sensitive content
WITH ContentCategory AS (
    SELECT
        title,
        type,
        genres,
        CASE
            WHEN LOWER(description) LIKE '%kill%' 
                OR LOWER(description) LIKE '%violence%' THEN 'Sensitive'
            ELSE 'Non-Sensitive'
        END AS content_category
    FROM `sql-projects-503512.netflix_ds.cleaned_netflix_titles`
)
SELECT
    content_category,
    COUNT(*) AS total_content
FROM ContentCategory
GROUP BY content_category;

-------------------------------------------------------------------------------
-- PROBLEM 9: Find the top 5 countries with the most content on Netflix
-- Business Context: Highlight primary production hubs to support localization and licensing teams.
-------------------------------------------------------------------------------
SELECT
    country,
    COUNT(*) AS total_content
FROM `sql-projects-503512.netflix_ds.cleaned_netflix_titles`,
UNNEST(SPLIT(country, ',')) AS country
WHERE country != 'Unknown'
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;

-------------------------------------------------------------------------------
-- PROBLEM 10: Find all the movies/TV shows by director 'Rajiv Chilaka'
-- Business Context: Measure creator-specific catalog presence for targeted licensing renewals.
-------------------------------------------------------------------------------
SELECT 
    title,
    release_year,
    type,
    director
FROM `sql-projects-503512.netflix_ds.cleaned_netflix_titles`,
UNNEST(SPLIT(director, ',')) AS single_director
WHERE TRIM(single_director) = 'Rajiv Chilaka';

-------------------------------------------------------------------------------
-- PROBLEM 11: Find annual content additions in the United States and identify top 5 peak supply years
-- Business Context: Track growth cadence in key strategic expansion markets like the United States.
-------------------------------------------------------------------------------
WITH UnitedStatesReleases AS (
    SELECT 
        EXTRACT(YEAR FROM date_added) AS year_added_to_netflix,
        COUNT(*) AS year_content_count
    FROM `sql-projects-503512.netflix_ds.cleaned_netflix_titles`,
    UNNEST(SPLIT(country, ',')) AS country_name
    WHERE TRIM(country_name) = 'United States' 
      AND date_added IS NOT NULL
    GROUP BY year_added_to_netflix
)
SELECT 
    year_added_to_netflix,
    year_content_count,
    ROUND(year_content_count / (SELECT SUM(year_content_count) FROM UnitedStatesReleases), 4) AS annual_share
FROM UnitedStatesReleases
ORDER BY year_content_count DESC
LIMIT 5;

-------------------------------------------------------------------------------
-- PROBLEM 12: Count movies starring actor 'Adam Sandler' in the last 10 years
-- Business Context: Assess star power inventory longevity in major international regional markets.
-------------------------------------------------------------------------------
SELECT
    COUNT(*) AS adam_sandler_movies_count
FROM `sql-projects-503512.netflix_ds.cleaned_netflix_titles`,
UNNEST(SPLIT(`cast`, ',')) AS actor
WHERE TRIM(actor) = 'Adam Sandler'
    AND type = 'Movie'
    AND release_year >= EXTRACT(YEAR FROM DATE_SUB(CURRENT_DATE(), INTERVAL 10 YEAR));

-------------------------------------------------------------------------------
-- PROBLEM 13: Top 10 actors appearing in United States-produced movies
-- Business Context: Identify top-performing talent in the United States for prospective original film partnerships.
-------------------------------------------------------------------------------
SELECT 
    TRIM(actor) AS actor_name,
    COUNT(*) AS total_united_states_movies
FROM `sql-projects-503512.netflix_ds.cleaned_netflix_titles`,
UNNEST(SPLIT(country, ',')) AS country_name,
UNNEST(SPLIT(`cast`, ',')) AS actor
WHERE TRIM(country_name) = 'United States'
  AND type = 'Movie'
  AND TRIM(actor) != 'Unknown'
GROUP BY actor_name
ORDER BY total_united_states_movies DESC
LIMIT 10;

-------------------------------------------------------------------------------
-- PROBLEM 14: List all movies released in a specific year (e.g., 2020)
-- Business Context: Perform vintage release year audits for catalog balance.
-------------------------------------------------------------------------------
SELECT 
    title,
    director
FROM `sql-projects-503512.netflix_ds.cleaned_netflix_titles`
WHERE release_year = 2020
    AND type = 'Movie';

-------------------------------------------------------------------------------
-- PROBLEM 15: Find content added in the last 5 years
-- Business Context: Measure recent acquisition velocity to present fresh content metrics to leadership.
-------------------------------------------------------------------------------
SELECT 
    title,
    type,
    date_added
FROM `sql-projects-503512.netflix_ds.cleaned_netflix_titles`
WHERE date_added >= DATE_SUB(CURRENT_DATE(), INTERVAL 5 YEAR)
ORDER BY date_added DESC;