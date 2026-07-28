-- =============================================================================
-- PURPOSE: Table DDL Definitions (PostgreSQL Dialect)
-- PROJECT: Netflix Analytics Portfolio
-- =============================================================================

-- Drop existing tables if re-running script
DROP TABLE IF EXISTS cleaned_netflix_titles;
DROP TABLE IF EXISTS raw_netflix_titles;

-- Staging Table
CREATE TABLE raw_netflix_titles (
    show_id      VARCHAR(20) PRIMARY KEY,
    type         VARCHAR(20),
    title        VARCHAR(255),
    director     TEXT,
    cast         TEXT,
    country      VARCHAR(255),
    date_added   VARCHAR(50),
    release_year INT,
    rating       VARCHAR(20),
    duration     VARCHAR(50),
    listed_in    TEXT,
    description  TEXT
);

-- Analytics / Cleaned Table
CREATE TABLE cleaned_netflix_titles (
    show_id          VARCHAR(20) PRIMARY KEY,
    type             VARCHAR(20) NOT NULL,
    title            VARCHAR(255) NOT NULL,
    director         TEXT DEFAULT 'Unknown',
    cast             TEXT DEFAULT 'Unknown',
    country          VARCHAR(255) DEFAULT 'Unknown',
    date_added       DATE,
    release_year     INT,
    rating           VARCHAR(20),
    duration_minutes INT,
    duration_seasons INT,
    genres           TEXT,
    description      TEXT
);

-- Create Index for PostgreSQL performance optimization
CREATE INDEX idx_netflix_type ON cleaned_netflix_titles(type);
CREATE INDEX idx_netflix_release_year ON cleaned_netflix_titles(release_year);