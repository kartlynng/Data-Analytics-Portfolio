-- ============================================================================
-- DESCRIPTION: Strategic Business Insights - RFM Segmentation & Cohort Analysis
-- TABLE: sql-projects-503512.uci_online_retail.online_retail_cleaned
-- ============================================================================

-- ============================================================================
-- ANALYSIS 1: RFM CUSTOMER SEGMENTATION
--
-- Objectives: 
-- 1. Calculate Recency, Frequency, and Monetary (RFM) values for each customer.
-- 2. Assign relative quintile scores (1 to 5) using NTILE.
-- 3. Segment customers into actionable business tiers (Champions, At Risk, etc.).
-- ============================================================================
WITH rfm_base AS (
    SELECT
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS frequency,
        ROUND(SUM(TotalSales), 2) AS monetary_value,
        MAX(InvoiceDateOnly) AS last_purchase_date,
        -- Recency: Days since last purchase relative to dataset max date (2011-12-10)
        DATE_DIFF(DATE('2011-12-10'), MAX(InvoiceDateOnly), DAY) AS recency_days
    FROM `sql-projects-503512.uci_online_retail.online_retail_cleaned`
    GROUP BY CustomerID
),
rfm_scores AS (
    SELECT
        CustomerID,
        recency_days,
        frequency,
        monetary_value,
        -- Convert the raw RFM values into scores from 1 to 5.

        -- How recently the customer purchased
        NTILE(5) OVER(ORDER BY recency_days DESC) AS recency_score, -- Higher recency_days = less recent -> lower score
        -- How often the customer purchased
        NTILE(5) OVER(ORDER BY frequency ASC) AS frequency_score, -- Higher frequency = more purchases -> higher score
        -- How much the customer spent
        NTILE(5) OVER(ORDER BY monetary_value ASC) AS monetary_score -- Higher monetary_value = higher spending -> higher score
    FROM rfm_base
),
rfm_segmented AS (
    SELECT
        CustomerID,
        recency_days,
        frequency,
        monetary_value,
        frequency_score,
        monetary_score,
        -- Concatenate the RFM scores to create a combined RFM score
        CONCAT(
            CAST(recency_score AS STRING), 
            CAST(frequency_score AS STRING), 
            CAST(monetary_score AS STRING)
        ) AS rfm_cell,
        -- Assign customer segments based on RFM scores
        CASE
            WHEN ( (recency_score >= 4) AND (frequency_score >= 4) AND (monetary_score >= 4) ) THEN 'Champions'
            WHEN ( (recency_score >= 3) AND (frequency_score >= 3) ) THEN 'Loyal Customers'
            WHEN ( (recency_score >= 4) AND (frequency_score < 2) ) THEN 'New / Recent Customers'
            WHEN ( (recency_score <= 2) AND (frequency_score >= 3) ) THEN 'At Risk (High-Value Lost)'
            WHEN ( (recency_score <= 2) AND (frequency_score <= 2) ) THEN 'Lost / Hibernating'
            ELSE 'Potential Loyalists'
        END AS customer_segment
    FROM rfm_scores
)
-- Summary of RFM Segments for Executive Reporting
SELECT 
    customer_segment,
    COUNT(CustomerID) AS total_customers,
    ROUND(COUNT(CustomerID) * 100.0 / SUM(COUNT(CustomerID)) OVER (), 2) AS customer_pct,
    ROUND(AVG(recency_days), 1) AS avg_recency_days,
    ROUND(AVG(frequency), 1) AS avg_frequency,
    ROUND(AVG(monetary_value), 2) AS avg_monetary_val,
    ROUND(SUM(monetary_value), 2) AS segment_total_revenue,
    ROUND(SUM(monetary_value) * 100.0 / SUM(SUM(monetary_value)) OVER (), 2) AS revenue_pct
FROM rfm_segmented
GROUP BY customer_segment
ORDER BY segment_total_revenue DESC;


-- ============================================================================
-- ANALYSIS 2: COHORT RETENTION ANALYSIS
--
-- Objectives: 
-- Track customer retention month-by-month based on their first acquisition month.
--
-- Logic:
-- 1. Identify the first purchase month for each customer (cohort_month).
-- 2. Track every month each customer purchased
-- 3. Calculate the original size of each cohort
-- 4. Count retained customers and calculate retention rate
-- ============================================================================

-- 1. When did each customer first buy? (Cohort Month)
WITH first_purchase AS (
    SELECT
        CustomerID,
        MIN(TIMESTAMP_TRUNC(InvoiceDate, MONTH)) AS cohort_month
    FROM `sql-projects-503512.uci_online_retail.online_retail_cleaned`
    GROUP BY CustomerID
),
-- 2. Group customers by cohort month to get the size of each cohort
cohort_size AS (
    SELECT
        cohort_month,
        COUNT(*) AS total_cohort_customers
    FROM first_purchase
    GROUP BY cohort_month
),
-- 3. Track activity: How many months after joining did the customer purchase?
customer_activities AS (
    SELECT
        customer.CustomerID,
        purchase.cohort_month,
        TIMESTAMP_TRUNC(customer.InvoiceDate, MONTH) AS activity_month,
        -- Calculate the number of months since the cohort month for retention analysis
        (EXTRACT(YEAR FROM customer.InvoiceDate) - EXTRACT(YEAR FROM purchase.cohort_month)) * 12 +
        (EXTRACT(MONTH FROM customer.InvoiceDate) - EXTRACT(MONTH FROM purchase.cohort_month)) AS months_since_cohort
    FROM `sql-projects-503512.uci_online_retail.online_retail_cleaned` AS customer
    JOIN first_purchase AS purchase
        ON customer.CustomerID = purchase.CustomerID
),
-- 4. Create a retention matrix: Count active customers for each cohort month and months since cohort
retention_matrix AS (
    SELECT
        cohort_month,
        months_since_cohort,
        COUNT(*) AS active_customers
    FROM customer_activities
    GROUP BY cohort_month, months_since_cohort
)
SELECT 
    FORMAT_TIMESTAMP('%Y-%m', r.cohort_month) AS cohort,
    r.months_since_cohort,
    s.total_cohort_customers,
    r.active_customers,
    ROUND(r.active_customers / s.total_cohort_customers * 100, 2) AS retention_rate_pct
FROM retention_matrix AS r
JOIN cohort_size AS s
    ON r.cohort_month = s.cohort_month
ORDER BY r.cohort_month ASC, r.months_since_cohort ASC;