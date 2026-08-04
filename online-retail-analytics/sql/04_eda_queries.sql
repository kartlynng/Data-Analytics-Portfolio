-- ============================================================================
-- DESCRIPTION: Exploratory Data Analysis (EDA) - Key Business Questions
-- TABLE: sql-projects-503512.uci_online_retail.online_retail_cleaned
-- ============================================================================

-- ----------------------------------------------------------------------------
-- SECTION 1: REVENUE & SALES TRENDS
-- ----------------------------------------------------------------------------
-- Q1: What is the overall business summary (Total Revenue, Orders, Active Customers, AOV)?
SELECT
    SUM(TotalSales) AS total_revenue,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    COUNT(DISTINCT CustomerID) AS active_customers,
    AVG(TotalSales) AS average_order_value,
    ROUND(SUM(Quantity) / COUNT(DISTINCT InvoiceNo), 2) AS avg_items_per_order
FROM `sql-projects-503512.uci_online_retail.online_retail_cleaned`;

-- Q2: What is the monthly revenue and order volume trend over time?
SELECT
    YearMonth,
    COUNT(DISTINCT InvoiceNo) AS monthly_orders,
    ROUND(SUM(TotalSales), 2) AS monthly_revenue,
    ROUND(AVG(TotalSales), 2) AS avg_transaction_value
FROM `sql-projects-503512.uci_online_retail.online_retail_cleaned`
GROUP BY YearMonth
ORDER BY YearMonth;

-- Q3: What is the Month-over-Month (MoM) revenue growth rate?
WITH monthly_sales AS (
    SELECT
        YearMonth,
        ROUND(SUM(TotalSales), 2) AS monthly_revenue,
        LAG(ROUND(SUM(TotalSales), 2)) OVER (ORDER BY YearMonth) AS prev_month_revenue
    FROM `sql-projects-503512.uci_online_retail.online_retail_cleaned`
    GROUP BY YearMonth
)
SELECT
    YearMonth,
    monthly_revenue,
    ROUND(
        (monthly_revenue - prev_month_revenue) / prev_month_revenue * 100, 2
    ) AS mom_growth_rate
FROM monthly_sales
ORDER BY YearMonth;

-- Q4: What days of the week and hours of the day generate the highest sales volume?
SELECT
    DayOfWeek,
    InvoiceHour,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(TotalSales), 2) AS total_revenue
FROM `sql-projects-503512.uci_online_retail.online_retail_cleaned`
GROUP BY DayOfWeek, InvoiceHour
ORDER BY total_revenue DESC;
    
-- ----------------------------------------------------------------------------
-- SECTION 2: CUSTOMER SEGMENTATION & BEHAVIOR
-- ----------------------------------------------------------------------------
-- Q5: Who are the Top 10 VIP Customers by total spend?
SELECT
    CustomerID,
    Country,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    SUM(Quantity) AS total_units_purchased,
    ROUND(SUM(TotalSales), 2) AS total_spend
FROM `sql-projects-503512.uci_online_retail.online_retail_cleaned`
GROUP BY CustomerID, Country
ORDER BY total_spend DESC
LIMIT 10;

-- Q6: How is customer lifetime value (CLV) distributed across customer percentiles (Pareto Principle / 80-20 Rule)?
WITH customer_spend AS (
    SELECT
        CustomerID,
        ROUND(SUM(TotalSales), 2) AS customer_total_spend,
        NTILE(10) OVER (ORDER BY SUM(TotalSales) DESC) AS spend_decile
    FROM `sql-projects-503512.uci_online_retail.online_retail_cleaned`
    GROUP BY CustomerID
)
SELECT
    spend_decile,
    COUNT(CustomerID) AS customer_count,
    ROUND(SUM(customer_total_spend), 2) AS decile_revenue,
    ROUND(
        SUM(customer_total_spend) / SUM(SUM(customer_total_spend)) OVER () * 100, 2) AS pct_of_total_revenue
FROM customer_spend
GROUP BY spend_decile
ORDER BY spend_decile;

-- Q7: What is the distribution of repeat buyers vs. single-purchase buyers?
WITH purchase_counts AS (
    SELECT
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS order_count
    FROM `sql-projects-503512.uci_online_retail.online_retail_cleaned`
    GROUP BY CustomerID
)
SELECT
    CASE
        WHEN order_count = 1 THEN 'Single-Purchase Buyers'
        WHEN order_count BETWEEN 2 AND 5 THEN 'Regular Buyers (2-5 Orders)'
        WHEN order_count BETWEEN 6 AND 10 THEN 'Loyal Buyers (6-10 Orders)'
        ELSE 'VIP Champions (10+ Orders)'
    END AS customer_loyalty_tier,
    COUNT(CustomerID) AS customer_count,
    ROUND(COUNT(CustomerID) / SUM(COUNT(CustomerID)) OVER () * 100, 2) AS pct_of_total_customers
FROM purchase_counts
GROUP BY customer_loyalty_tier
ORDER BY customer_loyalty_tier DESC;

-- Q8: What is the average time gap (days) between consecutive purchases for repeat customers?
WITH order_dates AS (
    SELECT DISTINCT 
        CustomerID, 
        InvoiceNo,
        InvoiceDateOnly AS order_date
    FROM `sql-projects-503512.uci_online_retail.online_retail_cleaned`
),
date_lags AS (
    SELECT
        CustomerID,
        order_date,
        LAG(order_date) OVER (
            PARTITION BY CustomerID
            ORDER BY order_date
        ) AS prev_order_date
    FROM order_dates
)
SELECT
    ROUND(AVG(DATE_DIFF(order_date, prev_order_date, DAY)), 3) AS avg_days_between_purchases
FROM date_lags
WHERE prev_order_date IS NOT NULL;

-- ----------------------------------------------------------------------------
-- SECTION 3: PRODUCT & INVENTORY PERFORMANCE
-- ----------------------------------------------------------------------------
-- Q9: What are the Top 10 Best-Selling Products by Revenue and Quantity?
SELECT
    StockCode,
    Description,
    SUM(Quantity) AS total_units_sold,
    COUNT(DISTINCT InvoiceNo) AS order_frequency,
    ROUND(SUM(TotalSales), 2) AS total_revenue
FROM `sql-projects-503512.uci_online_retail.online_retail_cleaned`
GROUP BY StockCode, Description
ORDER BY total_revenue DESC
LIMIT 10;

-- Q10: What are the bottom-performing products that generate negligible revenue (< $50 total)?
SELECT
    StockCode,
    Description,
    SUM(Quantity) AS total_units_sold,
    ROUND(SUM(TotalSales), 2) AS total_revenue
FROM `sql-projects-503512.uci_online_retail.online_retail_cleaned`
GROUP BY StockCode, Description
HAVING total_revenue < 50
ORDER BY total_revenue;

-- Q11: Which products are most frequently co-purchased together in the same invoice (Basket Analysis)?
SELECT 
    a.StockCode AS product_a,
    a.Description AS desc_a,
    b.StockCode AS product_b,
    b.Description AS desc_b,
    COUNT(*) AS co_purchase_count
FROM `sql-projects-503512.uci_online_retail.online_retail_cleaned` AS a
JOIN `sql-projects-503512.uci_online_retail.online_retail_cleaned` AS b
    ON a.InvoiceNo = b.InvoiceNo 
    AND a.StockCode < b.StockCode -- Avoid self-matching
GROUP BY product_a, desc_a, product_b, desc_b
ORDER BY co_purchase_count DESC
LIMIT 10;

-- ----------------------------------------------------------------------------
-- SECTION 4: GEOGRAPHIC & MARKET ANALYSIS
-- ----------------------------------------------------------------------------
-- Q12: Which international markets outside the UK generate the highest revenue?
SELECT
    Country,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    SUM(Quantity) AS total_units_sold,
    ROUND(SUM(TotalSales), 2) AS total_revenue,
    ROUND(SUM(TotalSales) / COUNT(DISTINCT InvoiceNo), 2) AS avg_order_value
FROM `sql-projects-503512.uci_online_retail.online_retail_cleaned`
WHERE Country != 'United Kingdom'
GROUP BY Country
ORDER BY total_revenue DESC
LIMIT 10;

-- Q13: What is the revenue contribution percentage of the UK vs. International markets?
SELECT
    CASE
        WHEN Country = 'United Kingdom' THEN 'Domestic (UK)'
        ELSE 'International'
    END AS market_type,
    COUNT(DISTINCT CustomerID) AS customer_count,
    ROUND(SUM(TotalSales), 2) AS total_revenue,
    ROUND(SUM(TotalSales) / SUM(SUM(TotalSales)) OVER () * 100, 2) AS revenue_share_pct
FROM `sql-projects-503512.uci_online_retail.online_retail_cleaned`
GROUP BY market_type;

-- Q14: What is the highest-spending country per active customer (Revenue per User)?
SELECT
    Country,
    COUNT(DISTINCT CustomerID) AS customer_count,
    ROUND(SUM(TotalSales), 2) AS total_revenue,
    ROUND(SUM(TotalSales) / COUNT(DISTINCT CustomerID), 2) AS revenue_per_customer
FROM `sql-projects-503512.uci_online_retail.online_retail_cleaned`
GROUP BY Country
HAVING customer_count >= 5 -- Filter out low-sample countries for statistical reliability
ORDER BY revenue_per_customer DESC
LIMIT 10;