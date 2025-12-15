-- ============================================================================
-- AWESOME INC. - OLTP VALIDATION QUERIES (MySQL)
-- ============================================================================
-- Queries for data validation and testing
-- Author: Neethu Satravada (NS6411)
-- Course: ECE-GY-9941 Advanced Projects
-- ============================================================================

USE awesome_inc_oltp;

-- ============================================================================
-- 1. TABLE RECORD COUNTS
-- ============================================================================
SELECT 'NS_SEGMENT' AS TABLE_NAME, COUNT(*) AS RECORD_COUNT FROM NS_SEGMENT
UNION ALL SELECT 'NS_CATEGORY', COUNT(*) FROM NS_CATEGORY
UNION ALL SELECT 'NS_SUB_CATEGORY', COUNT(*) FROM NS_SUB_CATEGORY
UNION ALL SELECT 'NS_PRODUCT', COUNT(*) FROM NS_PRODUCT
UNION ALL SELECT 'NS_CUSTOMER', COUNT(*) FROM NS_CUSTOMER
UNION ALL SELECT 'NS_ORDER', COUNT(*) FROM NS_ORDER
UNION ALL SELECT 'NS_ORDER_DETAIL', COUNT(*) FROM NS_ORDER_DETAIL
UNION ALL SELECT 'NS_RETURN', COUNT(*) FROM NS_RETURN
UNION ALL SELECT 'NS_RETURN_DETAIL', COUNT(*) FROM NS_RETURN_DETAIL;

-- ============================================================================
-- 2. DATA DICTIONARY - LIST ALL TABLES
-- ============================================================================
SELECT 
    TABLE_NAME,
    TABLE_ROWS,
    CREATE_TIME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'awesome_inc_oltp'
ORDER BY TABLE_NAME;

-- ============================================================================
-- 3. DATA DICTIONARY - LIST ALL COLUMNS
-- ============================================================================
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH AS MAX_LENGTH,
    IS_NULLABLE,
    COLUMN_KEY
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'awesome_inc_oltp'
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- ============================================================================
-- 4. DATA DICTIONARY - LIST ALL CONSTRAINTS
-- ============================================================================
SELECT 
    TABLE_NAME,
    CONSTRAINT_NAME,
    CONSTRAINT_TYPE
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = 'awesome_inc_oltp'
ORDER BY TABLE_NAME, CONSTRAINT_TYPE;

-- ============================================================================
-- 5. DATA DICTIONARY - LIST FOREIGN KEYS
-- ============================================================================
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'awesome_inc_oltp'
AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME;

-- ============================================================================
-- 6. CUSTOMERS BY SEGMENT
-- ============================================================================
SELECT 
    s.SEGMENT_NAME,
    COUNT(c.ROW_ID) AS CUSTOMER_COUNT
FROM NS_CUSTOMER c
JOIN NS_SEGMENT s ON c.SEGMENT_ROW_ID = s.ROW_ID
GROUP BY s.SEGMENT_NAME
ORDER BY CUSTOMER_COUNT DESC;

-- ============================================================================
-- 7. ORDERS BY YEAR
-- ============================================================================
SELECT 
    YEAR(ORDER_DATE) AS ORDER_YEAR,
    COUNT(*) AS ORDER_COUNT
FROM NS_ORDER
GROUP BY YEAR(ORDER_DATE)
ORDER BY ORDER_YEAR;

-- ============================================================================
-- 8. TOTAL SALES BY CATEGORY
-- ============================================================================
SELECT 
    cat.CATEGORY_NAME,
    SUM(od.SALES) AS TOTAL_SALES,
    SUM(od.PROFIT) AS TOTAL_PROFIT
FROM NS_ORDER_DETAIL od
JOIN NS_PRODUCT p ON od.PRODUCT_ROW_ID = p.ROW_ID
JOIN NS_SUB_CATEGORY sc ON p.SUB_CATEGORY_ROW_ID = sc.ROW_ID
JOIN NS_CATEGORY cat ON sc.CATEGORY_ROW_ID = cat.ROW_ID
GROUP BY cat.CATEGORY_NAME
ORDER BY TOTAL_SALES DESC;

-- ============================================================================
-- 9. TOP 10 PRODUCTS BY SALES
-- ============================================================================
SELECT 
    p.PRODUCT_NAME,
    SUM(od.QUANTITY) AS TOTAL_QUANTITY,
    SUM(od.SALES) AS TOTAL_SALES
FROM NS_ORDER_DETAIL od
JOIN NS_PRODUCT p ON od.PRODUCT_ROW_ID = p.ROW_ID
GROUP BY p.PRODUCT_NAME
ORDER BY TOTAL_SALES DESC
LIMIT 10;

-- ============================================================================
-- 10. ORDERS BY SHIP MODE
-- ============================================================================
SELECT 
    SHIP_MODE,
    COUNT(*) AS ORDER_COUNT,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM NS_ORDER), 2) AS PERCENTAGE
FROM NS_ORDER
GROUP BY SHIP_MODE
ORDER BY ORDER_COUNT DESC;

-- ============================================================================
-- 11. RETURN RATE BY CATEGORY
-- ============================================================================
SELECT 
    cat.CATEGORY_NAME,
    COUNT(DISTINCT o.ROW_ID) AS TOTAL_ORDERS,
    COUNT(DISTINCT r.ROW_ID) AS RETURNED_ORDERS,
    ROUND(COUNT(DISTINCT r.ROW_ID) * 100.0 / COUNT(DISTINCT o.ROW_ID), 2) AS RETURN_RATE
FROM NS_ORDER o
JOIN NS_ORDER_DETAIL od ON o.ROW_ID = od.ORDER_ROW_ID
JOIN NS_PRODUCT p ON od.PRODUCT_ROW_ID = p.ROW_ID
JOIN NS_SUB_CATEGORY sc ON p.SUB_CATEGORY_ROW_ID = sc.ROW_ID
JOIN NS_CATEGORY cat ON sc.CATEGORY_ROW_ID = cat.ROW_ID
LEFT JOIN NS_RETURN r ON o.ROW_ID = r.ORDER_ROW_ID
GROUP BY cat.CATEGORY_NAME
ORDER BY RETURN_RATE DESC;

-- ============================================================================
-- 12. CHECK FOR ORPHANED RECORDS
-- ============================================================================
-- Orders without valid customer
SELECT COUNT(*) AS ORPHANED_ORDERS 
FROM NS_ORDER o
WHERE NOT EXISTS (SELECT 1 FROM NS_CUSTOMER c WHERE c.ROW_ID = o.CUSTOMER_ROW_ID);

-- Order details without valid order
SELECT COUNT(*) AS ORPHANED_ORDER_DETAILS
FROM NS_ORDER_DETAIL od
WHERE NOT EXISTS (SELECT 1 FROM NS_ORDER o WHERE o.ROW_ID = od.ORDER_ROW_ID);

-- Order details without valid product
SELECT COUNT(*) AS ORPHANED_PRODUCTS
FROM NS_ORDER_DETAIL od
WHERE NOT EXISTS (SELECT 1 FROM NS_PRODUCT p WHERE p.ROW_ID = od.PRODUCT_ROW_ID);

-- ============================================================================
-- 13. CHECK FOR NEGATIVE PROFIT
-- ============================================================================
SELECT 
    COUNT(*) AS NEGATIVE_PROFIT_COUNT,
    SUM(PROFIT) AS TOTAL_NEGATIVE_PROFIT
FROM NS_ORDER_DETAIL
WHERE PROFIT < 0;

-- ============================================================================
-- 14. SALES SUMMARY
-- ============================================================================
SELECT 
    'Total Sales' AS METRIC,
    CONCAT('$', FORMAT(SUM(SALES), 2)) AS VALUE
FROM NS_ORDER_DETAIL
UNION ALL
SELECT 
    'Total Profit',
    CONCAT('$', FORMAT(SUM(PROFIT), 2))
FROM NS_ORDER_DETAIL
UNION ALL
SELECT 
    'Total Orders',
    FORMAT(COUNT(DISTINCT ORDER_ROW_ID), 0)
FROM NS_ORDER_DETAIL
UNION ALL
SELECT 
    'Average Order Value',
    CONCAT('$', FORMAT(AVG(SALES), 2))
FROM NS_ORDER_DETAIL;

-- ============================================================================
-- END OF VALIDATION QUERIES
-- ============================================================================
