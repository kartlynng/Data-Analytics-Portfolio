-- ============================================================================
-- DESCRIPTION: Cast raw string columns to strongly-typed data types & extract time features
-- ============================================================================
CREATE OR REPLACE TABLE `sql-projects-503512.uci_online_retail.online_retail_staging` AS
WITH parsed_data AS (
    SELECT
        TRIM(InvoiceNo) AS InvoiceNo,
        TRIM(StockCode) AS StockCode,
        TRIM(Description) AS Description,
        SAFE_CAST(TRIM(Quantity) AS INT64) AS Quantity,
        PARSE_TIMESTAMP('%m/%d/%y %H:%M', TRIM(InvoiceDate)) AS InvoiceDate,
        SAFE_CAST(TRIM(UnitPrice) AS FLOAT64) AS UnitPrice,
        TRIM(CustomerID) AS CustomerID,
        TRIM(Country) AS Country
    FROM `sql-projects-503512.uci_online_retail.online_retail_raw`
)
-- Temporal Feature Engineering
SELECT
    InvoiceNo,
    StockCode,
    Description,
    InvoiceDate,
    Quantity,
    UnitPrice,
    ROUND(Quantity * UnitPrice, 2) AS TotalSales,
    CustomerID,
    Country,
    -- New columns for temporal feature engineering (time-based features)
    DATE(InvoiceDate) AS InvoiceDateOnly,
    EXTRACT(YEAR FROM InvoiceDate) AS SalesYear,
    EXTRACT(MONTH FROM InvoiceDate) AS SalesMonth,
    FORMAT_TIMESTAMP('%Y-%m', InvoiceDate) AS YearMonth,
    FORMAT_TIMESTAMP('%A', InvoiceDate) AS DayOfWeek,
    EXTRACT(HOUR FROM InvoiceDate) AS InvoiceHour
FROM parsed_data;
