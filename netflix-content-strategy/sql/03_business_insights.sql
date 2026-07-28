-------------------------------------------------------------------------------
-- STRATEGIC INSIGHT 1: Year-over-Year (YoY) Growth & Addition Trajectory
-- Business Context: Executive leadership requires visibility into catalog acquisition velocity over time, broken down by format.
-------------------------------------------------------------------------------
WITH YearlyAdditions AS (
    SELECT 
        EXTRACT(YEAR FROM date_added) AS year_added,
        COUNT(CASE WHEN type = 'Movie' THEN 1 END) AS movies_added,
        COUNT(CASE WHEN type = 'TV Show' THEN 1 END) AS tv_shows_added,
        COUNT(*) AS total_added
    FROM `sql-projects-503512.netflix_ds.cleaned_netflix_titles`
    WHERE date_added IS NOT NULL
    GROUP BY year_added
),
YearlyComparison AS (
    SELECT
        *,
        LAG(total_added) OVER (
            ORDER BY year_added) AS prev_year_added
    FROM YearlyAdditions
)

SELECT 
    *,
    ROUND((total_added - prev_year_added) * 100.0 / NULLIF(prev_year_added, 0), 2) AS yoy_growth_percentage
FROM YearlyComparison
ORDER BY year_added DESC;

-------------------------------------------------------------------------------
-- STRATEGIC INSIGHT 2: Licensing Lag Analysis (Release Year vs. Netflix Addition)
-- Business Context: Content strategy teams need to differentiate between fresh theatrical releases and library/archival licensing acquisitions.
-------------------------------------------------------------------------------
SELECT 
    type,
    ROUND(AVG(EXTRACT(YEAR FROM date_added) - release_year), 1) AS avg_licensing_lag_years,
    MIN(EXTRACT(YEAR FROM date_added) - release_year) AS min_lag_years,
    MAX(EXTRACT(YEAR FROM date_added) - release_year) AS max_lag_years
FROM `sql-projects-503512.netflix_ds.cleaned_netflix_titles`
WHERE date_added IS NOT NULL 
  AND EXTRACT(YEAR FROM date_added) >= release_year
GROUP BY type;

-------------------------------------------------------------------------------
-- STRATEGIC INSIGHT 3: Genre Market Concentration & Cross-Country Share
-- Business Context: Evaluate dominant genre offerings within top international production hubs (USA, India, UK).
-------------------------------------------------------------------------------
WITH CountryGenreMatrix AS (
    SELECT 
        TRIM(country_name) AS country,
        TRIM(genre_name) AS genre,
        COUNT(*) AS title_count
    FROM `sql-projects-503512.netflix_ds.cleaned_netflix_titles`,
    UNNEST(SPLIT(country, ',')) AS country_name,
    UNNEST(SPLIT(genres, ',')) AS genre_name
    WHERE TRIM(country_name) IN ('United States', 'India', 'United Kingdom')
    GROUP BY country, genre
)
-- Genre market share within each country, ordered by country and genre share
SELECT
    country,
    genre,
    title_count,
    ROUND(title_count / SUM(title_count) OVER (PARTITION BY country), 4) AS genre_share
FROM CountryGenreMatrix
ORDER BY country, genre_share DESC;
-- Top 3 most common genres in each country
SELECT 
    country,
    genre,
    title_count,
    RANK() OVER (
        PARTITION BY country 
        ORDER BY title_count DESC) AS genre_rank_in_country
FROM CountryGenreMatrix
QUALIFY genre_rank_in_country <= 3
ORDER BY country, genre_rank_in_country;