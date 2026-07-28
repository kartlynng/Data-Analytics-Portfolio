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




-- Q6: How is customer lifetime value (CLV) distributed across customer percentiles (Pareto Principle / 80-20 Rule)?



-- Q7: What is the distribution of repeat buyers vs. single-purchase buyers?




-- Q8: What is the average time gap (days) between consecutive purchases for repeat customers?


-- ----------------------------------------------------------------------------
-- SECTION 3: PRODUCT & INVENTORY PERFORMANCE
-- ----------------------------------------------------------------------------
-- Q9: What are the Top 10 Best-Selling Products by Revenue and Quantity?



-- Q10: What are the bottom-performing products that generate negligible revenue (< $50 total)?


-- Q11: Which products are most frequently co-purchased together in the same invoice (Basket Analysis)?


-- ----------------------------------------------------------------------------
-- SECTION 4: GEOGRAPHIC & MARKET ANALYSIS
-- ----------------------------------------------------------------------------
-- Q12: Which international markets outside the UK generate the highest revenue?



-- Q13: What is the revenue contribution percentage of the UK vs. International markets?



-- Q14: What is the highest-spending country per active customer (Revenue per User)?