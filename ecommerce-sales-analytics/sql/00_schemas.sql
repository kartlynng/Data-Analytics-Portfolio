-- ============================================================================
-- PROJECT: UCI Online Retail SQL Analytics
-- DESCRIPTION: Database schema definition for the staging table `online_retail_raw` in BigQuery.
-- ============================================================================

/*
-------------------------------------------------------------------------------
1. BIGQUERY JSON SCHEMA (online_retail_raw)
Used for BigQuery Web UI "Edit as text", bq CLI, or API ingestion:

[
  {"name": "InvoiceNo", "type": "STRING", "mode": "NULLABLE"},
  {"name": "StockCode", "type": "STRING", "mode": "NULLABLE"},
  {"name": "Description", "type": "STRING", "mode": "NULLABLE"},
  {"name": "Quantity", "type": "STRING", "mode": "NULLABLE"},
  {"name": "InvoiceDate", "type": "STRING", "mode": "NULLABLE"},
  {"name": "UnitPrice", "type": "STRING", "mode": "NULLABLE"},
  {"name": "CustomerID", "type": "STRING", "mode": "NULLABLE"},
  {"name": "Country", "type": "STRING", "mode": "NULLABLE"}
]
-------------------------------------------------------------------------------
*/

-- 2. STAGING TABLE DDL
CREATE TABLE IF NOT EXISTS `sql-projects-503512.uci_online_retail.online_retail_clean` (
    InvoiceNo   STRING,
    StockCode   STRING,
    Description STRING,
    Quantity    STRING,
    InvoiceDate STRING,
    UnitPrice   STRING,
    CustomerID  STRING,
    Country     STRING
);
