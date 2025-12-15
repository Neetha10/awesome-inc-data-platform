-- ============================================================================
-- AWESOME INC. - ETL STAGING TABLES (Oracle)
-- ============================================================================
-- Transform layer - Clean and prepare data before loading to DW
-- Author: Neethu Satravada (NS6411)
-- Course: ECE-GY-9941 Advanced Projects
-- ============================================================================

-- ============================================================================
-- STAGING TABLE 1: STG_NS_CUSTOMER
-- Clean customer data from external table
-- ============================================================================
CREATE TABLE STG_NS_CUSTOMER (
    CUSTOMER_ID         VARCHAR2(20),
    FIRST_NAME          VARCHAR2(50),
    LAST_NAME           VARCHAR2(50),
    CITY                VARCHAR2(100),
    STATE               VARCHAR2(100),
    COUNTRY             VARCHAR2(100),
    REGION              VARCHAR2(50),
    MARKET              VARCHAR2(50),
    POSTAL_CODE         NUMBER(10),
    SEGMENT_ID          VARCHAR2(20),
    SEGMENT_NAME        VARCHAR2(50),
    TBL_LAST_DT         TIMESTAMP       DEFAULT SYSTIMESTAMP
);

-- ============================================================================
-- STAGING TABLE 2: STG_NS_PRODUCT
-- Clean product data from external table
-- ============================================================================
CREATE TABLE STG_NS_PRODUCT (
    PRODUCT_ID          VARCHAR2(50),
    PRODUCT_NAME        VARCHAR2(255),
    SUB_CATEGORY_ID     VARCHAR2(20),
    SUB_CATEGORY_NAME   VARCHAR2(50),
    CATEGORY_ID         VARCHAR2(20),
    CATEGORY_NAME       VARCHAR2(50),
    TBL_LAST_DT         TIMESTAMP       DEFAULT SYSTIMESTAMP
);

-- ============================================================================
-- STAGING TABLE 3: STG_NS_ORDER_DETAIL
-- Clean order data from external table
-- ============================================================================
CREATE TABLE STG_NS_ORDER_DETAIL (
    ROW_ID              NUMBER,
    ORDER_ID            VARCHAR2(25),
    ORDER_DATE          DATE,
    SHIP_DATE           DATE,
    SHIP_MODE           VARCHAR2(50),
    ORDER_OF_PRIORITY   VARCHAR2(20),
    QUANTITY            NUMBER(10),
    DISCOUNT            NUMBER(5,2),
    SALES               NUMBER(15,2),
    PROFIT              NUMBER(15,2),
    SHIPPING_COST       NUMBER(15,2),
    DATE_ID             NUMBER(10),
    CUSTOMER_ID         VARCHAR2(20),
    PRODUCT_ID          VARCHAR2(50),
    TBL_LAST_DT         TIMESTAMP       DEFAULT SYSTIMESTAMP
);

-- ============================================================================
-- STAGING TABLE 4: STG_NS_RETURN
-- Clean return data from external table
-- ============================================================================
CREATE TABLE STG_NS_RETURN (
    ROW_ID              NUMBER,
    RETURN_ID           VARCHAR2(25),
    RETURN_REASON       VARCHAR2(100),
    RETURN_DATE         DATE,
    RETURN_AMOUNT       NUMBER(15,2),
    ORDER_DETAIL_ROW_ID NUMBER,
    DATE_ID             NUMBER(10),
    CUSTOMER_ID         VARCHAR2(20),
    PRODUCT_ID          VARCHAR2(50),
    TBL_LAST_DT         TIMESTAMP       DEFAULT SYSTIMESTAMP
);

-- ============================================================================
-- TRANSFORM: LOAD STG_NS_CUSTOMER FROM EXTERNAL TABLE
-- ============================================================================
INSERT INTO STG_NS_CUSTOMER (
    CUSTOMER_ID, FIRST_NAME, LAST_NAME, CITY, STATE, 
    COUNTRY, REGION, MARKET, POSTAL_CODE, SEGMENT_ID, SEGMENT_NAME
)
SELECT DISTINCT
    CUSTOMER_ID,
    -- Split CUSTOMER_NAME into FIRST_NAME and LAST_NAME
    TRIM(SUBSTR(CUSTOMER_NAME, 1, INSTR(CUSTOMER_NAME, ' ') - 1)) AS FIRST_NAME,
    TRIM(SUBSTR(CUSTOMER_NAME, INSTR(CUSTOMER_NAME, ' ') + 1)) AS LAST_NAME,
    TRIM(CITY) AS CITY,
    TRIM(STATE) AS STATE,
    TRIM(COUNTRY) AS COUNTRY,
    TRIM(REGION) AS REGION,
    TRIM(MARKET) AS MARKET,
    -- Handle non-numeric postal codes
    CASE 
        WHEN REGEXP_LIKE(POSTAL_CODE, '^\d+$') THEN TO_NUMBER(POSTAL_CODE)
        ELSE NULL 
    END AS POSTAL_CODE,
    -- Generate SEGMENT_ID
    'SEG-' || LPAD(
        DENSE_RANK() OVER (ORDER BY SEGMENT), 3, '0'
    ) AS SEGMENT_ID,
    TRIM(SEGMENT) AS SEGMENT_NAME
FROM EXT_NS_ORDERS
WHERE CUSTOMER_ID IS NOT NULL;

COMMIT;

-- ============================================================================
-- TRANSFORM: LOAD STG_NS_PRODUCT FROM EXTERNAL TABLE
-- ============================================================================
INSERT INTO STG_NS_PRODUCT (
    PRODUCT_ID, PRODUCT_NAME, SUB_CATEGORY_ID, SUB_CATEGORY_NAME,
    CATEGORY_ID, CATEGORY_NAME
)
SELECT DISTINCT
    PRODUCT_ID,
    TRIM(PRODUCT_NAME) AS PRODUCT_NAME,
    -- Generate SUB_CATEGORY_ID
    'SUBCAT-' || LPAD(
        DENSE_RANK() OVER (ORDER BY SUB_CATEGORY), 3, '0'
    ) AS SUB_CATEGORY_ID,
    TRIM(SUB_CATEGORY) AS SUB_CATEGORY_NAME,
    -- Generate CATEGORY_ID
    'CAT-' || LPAD(
        DENSE_RANK() OVER (ORDER BY CATEGORY), 3, '0'
    ) AS CATEGORY_ID,
    TRIM(CATEGORY) AS CATEGORY_NAME
FROM EXT_NS_ORDERS
WHERE PRODUCT_ID IS NOT NULL;

COMMIT;

-- ============================================================================
-- TRANSFORM: LOAD STG_NS_ORDER_DETAIL FROM EXTERNAL TABLE
-- ============================================================================
INSERT INTO STG_NS_ORDER_DETAIL (
    ROW_ID, ORDER_ID, ORDER_DATE, SHIP_DATE, SHIP_MODE, ORDER_OF_PRIORITY,
    QUANTITY, DISCOUNT, SALES, PROFIT, SHIPPING_COST,
    DATE_ID, CUSTOMER_ID, PRODUCT_ID
)
SELECT
    ROW_ID,
    ORDER_ID,
    -- Convert string date to DATE type
    TO_DATE(ORDER_DATE, 'MM/DD/YYYY') AS ORDER_DATE,
    TO_DATE(SHIP_DATE, 'MM/DD/YYYY') AS SHIP_DATE,
    TRIM(SHIP_MODE) AS SHIP_MODE,
    TRIM(ORDER_PRIORITY) AS ORDER_OF_PRIORITY,
    -- Convert string numbers to NUMBER type
    TO_NUMBER(QUANTITY) AS QUANTITY,
    TO_NUMBER(DISCOUNT) AS DISCOUNT,
    TO_NUMBER(SALES) AS SALES,
    TO_NUMBER(PROFIT) AS PROFIT,
    TO_NUMBER(SHIPPING_COST) AS SHIPPING_COST,
    -- Generate DATE_ID in YYYYMMDD format
    TO_NUMBER(TO_CHAR(TO_DATE(ORDER_DATE, 'MM/DD/YYYY'), 'YYYYMMDD')) AS DATE_ID,
    CUSTOMER_ID,
    PRODUCT_ID
FROM EXT_NS_ORDERS
WHERE ROW_ID IS NOT NULL;

COMMIT;

-- ============================================================================
-- TRANSFORM: LOAD STG_NS_RETURN FROM EXTERNAL TABLE
-- ============================================================================
INSERT INTO STG_NS_RETURN (
    ROW_ID, RETURN_ID, RETURN_REASON, RETURN_DATE, RETURN_AMOUNT,
    ORDER_DETAIL_ROW_ID, DATE_ID, CUSTOMER_ID, PRODUCT_ID
)
SELECT
    ROWNUM AS ROW_ID,
    'RET-' || LPAD(ROWNUM, 5, '0') AS RETURN_ID,
    'Returned' AS RETURN_REASON,
    NULL AS RETURN_DATE,
    NULL AS RETURN_AMOUNT,
    o.ROW_ID AS ORDER_DETAIL_ROW_ID,
    o.DATE_ID,
    o.CUSTOMER_ID,
    o.PRODUCT_ID
FROM EXT_NS_RETURNS r
JOIN STG_NS_ORDER_DETAIL o ON r.ORDER_ID = o.ORDER_ID
WHERE r.RETURNED = 'Yes';

COMMIT;

-- ======================
