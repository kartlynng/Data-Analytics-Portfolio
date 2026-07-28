CREATE OR REPLACE TABLE `netflix_ds.cleaned_netflix_titles` AS
SELECT 
    show_id,
    type,
    title,
  -- Replace nulls in text fields with 'Unknown'
  COALESCE(director, 'Unknown') AS director,
  COALESCE(`cast`, 'Unknown') AS `cast`,
  COALESCE(country, 'Unknown') AS country,
  -- Parse string date to standard DATE format (e.g., 'September 25, 2021' -> 2021-09-25)
  PARSE_DATE('%B %e, %Y', TRIM(date_added)) AS date_added,

  release_year,
  -- Replace nulls in rating with 'Not Rated'
  COALESCE(rating, 'Not Rated') AS rating,
  -- Extract numeric duration for Movies (in minutes)
  CASE
    WHEN type = 'Movie' AND duration LIKE '%min%'
    THEN CAST(SPLIT(duration, ' ')[OFFSET(0)] AS INT64)
    ELSE NULL
  END AS duration_minutes,
  -- Extract numeric season for TV shows (in seasons)
  CASE
    WHEN type = 'TV Show' AND duration LIKE '%Season%'
    THEN CAST(SPLIT(duration, ' ')[OFFSET(0)] AS INT64)
    ELSE NULL
  END AS duration_seasons,
  
  TRIM(listed_in) AS genres,
  description
FROM `sql-projects-503512.netflix_ds.raw_netflix_titles`;
