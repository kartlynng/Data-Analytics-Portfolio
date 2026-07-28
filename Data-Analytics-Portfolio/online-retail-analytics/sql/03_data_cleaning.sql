-- ============================================================================
-- DESCRIPTION: Build production analytics table by removing bad data & noise
--
-- Transform the staging dataset into a clean dataset by:
--   • Removed cancelled invoices (InvoiceNo begins with C)
--   • Removed records with non-positive quantities
--   • Removed records with non-positive unit prices
--   • Removed records with missing CustomerID
--   • Removed duplicate records using ROW_NUMBER()
--
-- ============================================================================
CREATE OR REPLACE TABLE `sql-projects-503512.uci_online_retail.online_retail_cleaned` AS
SELECT 
    InvoiceNo,
    StockCode,
    Description,
    InvoiceDate,
    Quantity,
    UnitPrice,
    TotalSales,
    CustomerID,
    Country,
    InvoiceDateOnly,
    SalesYear,
    SalesMonth,
    YearMonth,
    DayOfWeek,
    InvoiceHour
FROM `sql-projects-503512.uci_online_retail.online_retail_staging`
WHERE 
    NOT STARTS_WITH(InvoiceNo, 'C')
    AND Quantity > 0
    AND UnitPrice > 0
    AND CustomerID IS NOT NULL 
-- Deduplication step: Keep only the 1st occurrence of identical rows
    QUALIFY ROW_NUMBER() OVER (
    PARTITION BY InvoiceNo, StockCode, CustomerID, InvoiceDate, Quantity, CAST(UnitPrice AS NUMERIC) 
    ORDER BY InvoiceDate
    ) = 1;
    
    