-- ============================================================================
-- DESCRIPTION:
--
-- Evaluate the quality of the staging dataset by identifying
-- missing values, duplicate records, invalid values, and
-- cancelled transactions before creating the cleaned dataset.
-- ============================================================================
SELECT 
    COUNT(*) AS total_records,
    COUNT(DISTINCT InvoiceNo) AS unique_invoices,
    COUNT(DISTINCT StockCode) AS unique_products,
    COUNT(DISTINCT Country) AS unique_countries,
    COUNTIF(CustomerID IS NULL) AS missing_customers,
    COUNTIF(Quantity <= 0) AS invalid_quantity_rows,
    COUNTIF(UnitPrice <= 0) AS invalid_price_rows,
    COUNTIF(STARTS_WITH(InvoiceNo, 'C')) AS cancelled_transactions
FROM `sql-projects-503512.uci_online_retail.online_retail_staging`;