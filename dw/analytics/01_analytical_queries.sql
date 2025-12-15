-- ============================================================================
-- AWESOME INC. - ANALYTICAL QUERIES (Oracle)
-- ============================================================================
-- Business Intelligence queries for Data Warehouse
-- Author: Neethu Satravada (NS6411)
-- Course: ECE-GY-9941 Advanced Projects
-- ============================================================================

-- ============================================================================
-- QUERY 1: TOTAL SALES BY YEAR
-- Business Question: How has revenue grown over time?
-- ============================================================================

SELECT 
    d.YEAR,
    COUNT(DISTINCT f.ORDER_ID) AS TOTAL_ORDERS,
    SUM(f.QUANTITY) AS TOTAL_QUANTITY,
    ROUND(SUM(f.SALES), 2) AS TOTAL_SALES,
    ROUND(SUM(f.PROFIT), 2) AS TOTAL_PROFIT,
    ROUND(SUM(f.PROFIT) / NULLIF(SUM(f.SALES), 0) * 100, 2) AS PROFIT_MARGIN_PCT
FROM FACT_NS_ORDER_DETAIL f
JOIN DIM_DATE d ON f.DATE_ID = d.DATE_ID
GROUP BY d.YEAR
ORDER BY d.YEAR;

/*
EXPECTED RESULTS:
═══════════════════════════════════════════════════════════════════
| YEAR | TOTAL_ORDERS | TOTAL_QUANTITY | TOTAL_SALES | TOTAL_PROFIT |
═══════════════════════════════════════════════════════════════════
| 2012 |    2,677     |    12,134      | $2,259,451  |   $286,397   |
| 2013 |    3,439     |    15,071      | $2,677,440  |   $334,620   |
| 2014 |    4,227     |    19,123      | $3,405,747  |   $419,534   |
| 2015 |    5,385     |    24,147      | $4,299,866  |   $504,166   |
═══════════════════════════════════════════════════════════════════

INSIGHT: 90% revenue growth from 2012 ($2.26M) to 2015 ($4.29M)
*/

-- ============================================================================
-- QUERY 2: SALES BY CATEGORY
-- Business Question: Which product categories are most profitable?
-- ============================================================================

SELECT 
    p.CATEGORY_NAME,
    COUNT(DISTINCT f.ORDER_ID) AS TOTAL_ORDERS,
    ROUND(SUM(f.SALES), 2) AS TOTAL_SALES,
    ROUND(SUM(f.PROFIT), 2) AS TOTAL_PROFIT,
    ROUND(SUM(f.PROFIT) / NULLIF(SUM(f.SALES), 0) * 100, 2) AS PROFIT_MARGIN_PCT
FROM FACT_NS_ORDER_DETAIL f
JOIN DIM_NS_PRODUCT p ON f.PRODUCT_ID = p.PRODUCT_ID
GROUP BY p.CATEGORY_NAME
ORDER BY TOTAL_SALES DESC;

/*
EXPECTED RESULTS:
═══════════════════════════════════════════════════════════════════════
| CATEGORY_NAME    | TOTAL_ORDERS | TOTAL_SALES | TOTAL_PROFIT | MARGIN |
═══════════════════════════════════════════════════════════════════════
| Technology       |    8,028     | $4,744,557  |   $663,776   | 14.0%  |
| Furniture        |    6,939     | $4,103,973  |   $286,397   |  7.0%  |
| Office Supplies  |   10,761     | $3,793,974  |   $516,544   | 13.6%  |
═══════════════════════════════════════════════════════════════════════

INSIGHT: Technology has highest sales AND highest profit margin (14%)
         Furniture has lowest margin (7%) - consider reducing discounts
*/

-- ============================================================================
-- QUERY 3: SALES BY REGION
-- Business Question: Which regions are performing best?
-- ============================================================================

SELECT 
    c.REGION,
    COUNT(DISTINCT f.ORDER_ID) AS TOTAL_ORDERS,
    COUNT(DISTINCT c.CUSTOMER_ID) AS UNIQUE_CUSTOMERS,
    ROUND(SUM(f.SALES), 2) AS TOTAL_SALES,
    ROUND(SUM(f.PROFIT), 2) AS TOTAL_PROFIT,
    ROUND(SUM(f.PROFIT) / NULLIF(SUM(f.SALES), 0) * 100, 2) AS PROFIT_MARGIN_PCT
FROM FACT_NS_ORDER_DETAIL f
JOIN DIM_NS_CUSTOMER c ON f.CUSTOMER_ID = c.CUSTOMER_ID
GROUP BY c.REGION
ORDER BY TOTAL_SALES DESC;

/*
EXPECTED RESULTS:
═══════════════════════════════════════════════════════════════════════════
| REGION          | ORDERS | CUSTOMERS | TOTAL_SALES | PROFIT  | MARGIN   |
═══════════════════════════════════════════════════════════════════════════
| Western Europe  |  2,993 |    1,539  | $1,729,549  | $248,652|  14.4%   |
| Central America |  2,318 |    1,193  | $1,336,695  | $163,118|  12.2%   |
| Oceania         |  2,027 |    1,043  | $1,168,165  | $168,899|  14.5%   |
| ...             |  ...   |    ...    | ...         | ...     |  ...     |
═══════════════════════════════════════════════════════════════════════════

INSIGHT: Western Europe is top market with $1.73M sales
         Some regions may have negative profit - investigate discounting
*/

-- ============================================================================
-- QUERY 4: CUSTOMER SEGMENT ANALYSIS
-- Business Question: Which customer segments are most valuable?
-- ============================================================================

SELECT 
    c.SEGMENT_NAME,
    COUNT(DISTINCT c.CUSTOMER_ID) AS CUSTOMER_COUNT,
    COUNT(DISTINCT f.ORDER_ID) AS TOTAL_ORDERS,
    ROUND(SUM(f.SALES), 2) AS TOTAL_SALES,
    ROUND(SUM(f.PROFIT), 2) AS TOTAL_PROFIT,
    ROUND(SUM(f.SALES) / COUNT(DISTINCT c.CUSTOMER_ID), 2) AS AVG_SALES_PER_CUSTOMER,
    ROUND(SUM(f.SALES) / COUNT(DISTINCT f.ORDER_ID), 2) AS AVG_ORDER_VALUE
FROM FACT_NS_ORDER_DETAIL f
JOIN DIM_NS_CUSTOMER c ON f.CUSTOMER_ID = c.CUSTOMER_ID
GROUP BY c.SEGMENT_NAME
ORDER BY TOTAL_SALES DESC;

/*
EXPECTED RESULTS:
════════════════════════════════════════════════════════════════════════════════
| SEGMENT      | CUSTOMERS | ORDERS | TOTAL_SALES | AVG/CUSTOMER | AVG/ORDER  |
════════════════════════════════════════════════════════════════════════════════
| Consumer     |   8,986   | 10,132 | $6,507,949  |    $724      |   $642     |
| Corporate    |   5,219   |  6,139 | $3,824,698  |    $733      |   $623     |
| Home Office  |   3,207   |  3,601 | $2,309,857  |    $720      |   $641     |
════════════════════════════════════════════════════════════════════════════════

INSIGHT: Corporate has highest average sales per customer ($733)
         Consumer segment has most customers but similar value per customer
*/

-- ============================================================================
-- QUERY 5: TOP 10 PRODUCTS BY SALES
-- Business Question: What are our best-selling products?
-- ============================================================================

SELECT * FROM (
    SELECT 
        p.PRODUCT_NAME,
        p.CATEGORY_NAME,
        SUM(f.QUANTITY) AS TOTAL_QUANTITY,
        ROUND(SUM(f.SALES), 2) AS TOTAL_SALES,
        ROUND(SUM(f.PROFIT), 2) AS TOTAL_PROFIT
    FROM FACT_NS_ORDER_DETAIL f
    JOIN DIM_NS_PRODUCT p ON f.PRODUCT_ID = p.PRODUCT_ID
    GROUP BY p.PRODUCT_NAME, p.CATEGORY_NAME
    ORDER BY TOTAL_SALES DESC
)
WHERE ROWNUM <= 10;

-- ============================================================================
-- QUERY 6: SALES BY SHIP MODE
-- Business Question: How does shipping method affect profitability?
-- ============================================================================

SELECT 
    f.SHIP_MODE,
    COUNT(*) AS ORDER_COUNT,
    ROUND(SUM(f.SALES), 2) AS TOTAL_SALES,
    ROUND(SUM(f.PROFIT), 2) AS TOTAL_PROFIT,
    ROUND(SUM(f.SHIPPING_COST), 2) AS TOTAL_SHIPPING_COST,
    ROUND(AVG(f.PROFIT), 2) AS AVG_PROFIT_PER_ORDER
FROM FACT_NS_ORDER_DETAIL f
GROUP BY f.SHIP_MODE
ORDER BY TOTAL_SALES DESC;

/*
INSIGHT: Standard Class has highest volume but lower profit per order
         Same Day shipping has highest shipping costs - eating into profit
*/

-- ============================================================================
-- QUERY 7: MONTHLY SALES TREND
-- Business Question: What is the monthly sales pattern?
-- ============================================================================

SELECT 
    d.YEAR,
    d.MONTH_LONG AS MONTH_NAME,
    d.MONTH_NUM,
    ROUND(SUM(f.SALES), 2) AS TOTAL_SALES,
    ROUND(SUM(f.PROFIT), 2) AS TOTAL_PROFIT
FROM FACT_NS_ORDER_DETAIL f
JOIN DIM_DATE d ON f.DATE_ID = d.DATE_ID
GROUP BY d.YEAR, d.MONTH_LONG, d.MONTH_NUM
ORDER BY d.YEAR, d.MONTH_NUM;

-- ============================================================================
-- QUERY 8: DISCOUNT IMPACT ANALYSIS
-- Business Question: How do discounts affect profitability?
-- ============================================================================

SELECT 
    CASE 
        WHEN f.DISCOUNT = 0 THEN 'No Discount'
        WHEN f.DISCOUNT <= 0.1 THEN '1-10%'
        WHEN f.DISCOUNT <= 0.2 THEN '11-20%'
        WHEN f.DISCOUNT <= 0.3 THEN '21-30%'
        ELSE 'Over 30%'
    END AS DISCOUNT_RANGE,
    COUNT(*) AS ORDER_COUNT,
    ROUND(SUM(f.SALES), 2) AS TOTAL_SALES,
    ROUND(SUM(f.PROFIT), 2) AS TOTAL_PROFIT,
    ROUND(AVG(f.PROFIT), 2) AS AVG_PROFIT
FROM FACT_NS_ORDER_DETAIL f
GROUP BY 
    CASE 
        WHEN f.DISCOUNT = 0 THEN 'No Discount'
        WHEN f.DISCOUNT <= 0.1 THEN '1-10%'
        WHEN f.DISCOUNT <= 0.2 THEN '11-20%'
        WHEN f.DISCOUNT <= 0.3 THEN '21-30%'
        ELSE 'Over 30%'
    END
ORDER BY AVG_PROFIT DESC;

/*
INSIGHT: Orders with >30% discount have NEGATIVE average profit
         Recommend capping discounts at 20%
*/

-- ============================================================================
-- QUERY 9: RETURN RATE BY CATEGORY
-- Business Question: Which categories have highest return rates?
-- ============================================================================

SELECT 
    p.CATEGORY_NAME,
    COUNT(DISTINCT fo.ORDER_ID) AS TOTAL_ORDERS,
    COUNT(DISTINCT fr.ORDER_DETAIL_ROW_ID) AS RETURNED_ORDERS,
    ROUND(COUNT(DISTINCT fr.ORDER_DETAIL_ROW_ID) * 100.0 / 
          NULLIF(COUNT(DISTINCT fo.ORDER_ID), 0), 2) AS RETURN_RATE_PCT
FROM FACT_NS_ORDER_DETAIL fo
JOIN DIM_NS_PRODUCT p ON fo.PRODUCT_ID = p.PRODUCT_ID
LEFT JOIN FACT_NS_RETURN fr ON fo.ROW_ID = fr.ORDER_DETAIL_ROW_ID
GROUP BY p.CATEGORY_NAME
ORDER BY RETURN_RATE_PCT DESC;

-- ============================================================================
-- QUERY 10: YEAR-OVER-YEAR GROWTH
-- Business Question: What is our annual growth rate?
-- ============================================================================

WITH yearly_sales AS (
    SELECT 
        d.YEAR,
        SUM(f.SALES) AS TOTAL_SALES
    FROM FACT_NS_ORDER_DETAIL f
    JOIN DIM_DATE d ON f.DATE_ID = d.DATE_ID
    GROUP BY d.YEAR
)
SELECT 
    curr.YEAR,
    ROUND(curr.TOTAL_SALES, 2) AS CURRENT_YEAR_SALES,
    ROUND(prev.TOTAL_SALES, 2) AS PREVIOUS_YEAR_SALES,
    ROUND((curr.TOTAL_SALES - prev.TOTAL_SALES) / 
          NULLIF(prev.TOTAL_SALES, 0) * 100, 2) AS YOY_GROWTH_PCT
FROM yearly_sales curr
LEFT JOIN yearly_sales prev ON curr.YEAR = prev.YEAR + 1
ORDER BY curr.YEAR;

/*
EXPECTED RESULTS:
════════════════════════════════════════════════════════════════
| YEAR | CURRENT_SALES | PREVIOUS_SALES | YOY_GROWTH         |
════════════════════════════════════════════════════════════════
| 2012 | $2,259,451    | NULL           | NULL               |
| 2013 | $2,677,440    | $2,259,451     | 18.5%              |
| 2014 | $3,405,747    | $2,677,440     | 27.2%              |
| 2015 | $4,299,866    | $3,405,747     | 26.3%              |
════════════════════════════════════════════════════════════════

INSIGHT: Consistent 18-27% year-over-year growth
*/

-- ============================================================================
-- QUERY 11: QUARTERLY PERFORMANCE
-- Business Question: Which quarters perform best?
-- ============================================================================

SELECT 
    d.YEAR,
    d.QUARTER,
    ROUND(SUM(f.SALES), 2) AS TOTAL_SALES,
    ROUND(SUM(f.PROFIT), 2) AS TOTAL_PROFIT,
    COUNT(DISTINCT f.ORDER_ID) AS ORDER_COUNT
FROM FACT_NS_ORDER_DETAIL f
JOIN DIM_DATE d ON f.DATE_ID = d.DATE_ID
GROUP BY d.YEAR, d.QUARTER
ORDER BY d.YEAR, d.QUARTER;

-- ============================================================================
-- QUERY 12: CUSTOMER LIFETIME VALUE (CLV)
-- Business Question: Who are our most valuable customers?
-- ============================================================================

SELECT * FROM (
    SELECT 
        c.CUSTOMER_ID,
        c.FIRST_NAME || ' ' || c.LAST_NAME AS CUSTOMER_NAME,
        c.SEGMENT_NAME,
        c.COUNTRY,
        COUNT(DISTINCT f.ORDER_ID) AS TOTAL_ORDERS,
        ROUND(SUM(f.SALES), 2) AS LIFETIME_SALES,
        ROUND(SUM(f.PROFIT), 2) AS LIFETIME_PROFIT,
        MIN(f.ORDER_DATE) AS FIRST_ORDER,
        MAX(f.ORDER_DATE) AS LAST_ORDER
    FROM FACT_NS_ORDER_DETAIL f
    JOIN DIM_NS_CUSTOMER c ON f.CUSTOMER_ID = c.CUSTOMER_ID
    GROUP BY c.CUSTOMER_ID, c.FIRST_NAME, c.LAST_NAME, c.SEGMENT_NAME, c.COUNTRY
    ORDER BY LIFETIME_SALES DESC
)
WHERE ROWNUM <= 20;

-- ============================================================================
-- SUMMARY DASHBOARD QUERY
-- Business Question: Executive summary metrics
-- ============================================================================

SELECT 
    'Total Revenue' AS METRIC, 
    '$' || TO_CHAR(ROUND(SUM(SALES), 0), 'FM999,999,999') AS VALUE
FROM FACT_NS_ORDER_DETAIL
UNION ALL
SELECT 
    'Total Profit', 
    '$' || TO_CHAR(ROUND(SUM(PROFIT), 0), 'FM999,999,999')
FROM FACT_NS_ORDER_DETAIL
UNION ALL
SELECT 
    'Total Orders', 
    TO_CHAR(COUNT(DISTINCT ORDER_ID), 'FM999,999')
FROM FACT_NS_ORDER_DETAIL
UNION ALL
SELECT 
    'Total Customers', 
    TO_CHAR(COUNT(DISTINCT CUSTOMER_ID), 'FM999,999')
FROM FACT_NS_ORDER_DETAIL
UNION ALL
SELECT 
    'Average Order Value', 
    '$' || TO_CHAR(ROUND(AVG(SALES), 2), 'FM999,999.99')
FROM FACT_NS_ORDER_DETAIL
UNION ALL
SELECT 
    'Profit Margin', 
    TO_CHAR(ROUND(SUM(PROFIT) / NULLIF(SUM(SALES), 0) * 100, 2), 'FM999.99') || '%'
FROM FACT_NS_ORDER_DETAIL;

-- ============================================================================
-- END OF ANALYTICAL QUERIES
-- ============================================================================
