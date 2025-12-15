-- ============================================================================
-- AWESOME INC. - DATA WAREHOUSE DIMENSION TABLES (Oracle)
-- ============================================================================
-- Database: Oracle Autonomous Data Warehouse
-- Schema: Star Schema
-- Author: Neethu Satravada (NS6411)
-- Course: ECE-GY-9941 Advanced Projects
-- ============================================================================

-- ============================================================================
-- DIMENSION 1: DIM_DATE (1,827 records)
-- Calendar dimension for time-based analysis
-- ============================================================================
CREATE TABLE DIM_DATE (
    DATE_ID             NUMBER(10)      PRIMARY KEY,
    FULL_DATE           DATE            NOT NULL,
    DAY                 NUMBER(2)       NOT NULL,
    MONTH_NUM           NUMBER(2)       NOT NULL,
    MONTH_SHORT         VARCHAR2(3)     NOT NULL,
    MONTH_LONG          VARCHAR2(15)    NOT NULL,
    DAY_OF_WEEK_SHORT   VARCHAR2(3)     NOT NULL,
    DAY_OF_WEEK_LONG    VARCHAR2(15)    NOT NULL,
    YEAR                NUMBER(4)       NOT NULL,
    QUARTER             CHAR(2)         NOT NULL,
    TBL_LAST_DT         TIMESTAMP       DEFAULT SYSTIMESTAMP
);

-- Add comments
COMMENT ON TABLE DIM_DATE IS 'Calendar dimension with 1,827 days (2012-2016)';
COMMENT ON COLUMN DIM_DATE.DATE_ID IS 'Primary key in YYYYMMDD format';
COMMENT ON COLUMN DIM_DATE.QUARTER IS 'Quarter: Q1, Q2, Q3, Q4';

-- ============================================================================
-- DIMENSION 2: DIM_NS_CUSTOMER (17,415 records)
-- Customer dimension with denormalized segment info
-- ============================================================================
CREATE TABLE DIM_NS_CUSTOMER (
    CUSTOMER_ID         VARCHAR2(20)    PRIMARY KEY,
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

-- Add comments
COMMENT ON TABLE DIM_NS_CUSTOMER IS 'Customer dimension with denormalized segment';
COMMENT ON COLUMN DIM_NS_CUSTOMER.SEGMENT_NAME IS 'Denormalized from NS_SEGMENT table';

-- ============================================================================
-- DIMENSION 3: DIM_NS_PRODUCT (3,788 records)
-- Product dimension with denormalized category info
-- ============================================================================
CREATE TABLE DIM_NS_PRODUCT (
    PRODUCT_ID          VARCHAR2(50)    PRIMARY KEY,
    PRODUCT_NAME        VARCHAR2(255)   NOT NULL,
    SUB_CATEGORY_ID     VARCHAR2(20),
    SUB_CATEGORY_NAME   VARCHAR2(50),
    CATEGORY_ID         VARCHAR2(20),
    CATEGORY_NAME       VARCHAR2(50),
    TBL_LAST_DT         TIMESTAMP       DEFAULT SYSTIMESTAMP
);

-- Add comments
COMMENT ON TABLE DIM_NS_PRODUCT IS 'Product dimension with denormalized category hierarchy';
COMMENT ON COLUMN DIM_NS_PRODUCT.CATEGORY_NAME IS 'Denormalized from NS_CATEGORY table';
COMMENT ON COLUMN DIM_NS_PRODUCT.SUB_CATEGORY_NAME IS 'Denormalized from NS_SUB_CATEGORY table';

-- ============================================================================
-- POPULATE DIM_DATE (Generate 5 years of dates: 2012-2016)
-- ============================================================================
INSERT INTO DIM_DATE (
    DATE_ID, FULL_DATE, DAY, MONTH_NUM, MONTH_SHORT, MONTH_LONG,
    DAY_OF_WEEK_SHORT, DAY_OF_WEEK_LONG, YEAR, QUARTER
)
SELECT 
    TO_NUMBER(TO_CHAR(date_val, 'YYYYMMDD')) AS DATE_ID,
    date_val AS FULL_DATE,
    EXTRACT(DAY FROM date_val) AS DAY,
    EXTRACT(MONTH FROM date_val) AS MONTH_NUM,
    TO_CHAR(date_val, 'MON') AS MONTH_SHORT,
    TO_CHAR(date_val, 'MONTH') AS MONTH_LONG,
    TO_CHAR(date_val, 'DY') AS DAY_OF_WEEK_SHORT,
    TO_CHAR(date_val, 'DAY') AS DAY_OF_WEEK_LONG,
    EXTRACT(YEAR FROM date_val) AS YEAR,
    'Q' || TO_CHAR(date_val, 'Q') AS QUARTER
FROM (
    SELECT DATE '2012-01-01' + LEVEL - 1 AS date_val
    FROM DUAL
    CONNECT BY LEVEL <= (DATE '2016-12-31' - DATE '2012-01-01' + 1)
);

COMMIT;

-- ============================================================================
-- INDEXES FOR DIMENSION TABLES
-- ============================================================================
CREATE INDEX IDX_DIM_DATE_YEAR ON DIM_DATE(YEAR);
CREATE INDEX IDX_DIM_DATE_MONTH ON DIM_DATE(MONTH_NUM);
CREATE INDEX IDX_DIM_DATE_QUARTER ON DIM_DATE(QUARTER);

CREATE INDEX IDX_DIM_CUSTOMER_SEGMENT ON DIM_NS_CUSTOMER(SEGMENT_NAME);
CREATE INDEX IDX_DIM_CUSTOMER_COUNTRY ON DIM_NS_CUSTOMER(COUNTRY);
CREATE INDEX IDX_DIM_CUSTOMER_REGION ON DIM_NS_CUSTOMER(REGION);

CREATE INDEX IDX_DIM_PRODUCT_CATEGORY ON DIM_NS_PRODUCT(CATEGORY_NAME);
CREATE INDEX IDX_DIM_PRODUCT_SUBCATEGORY ON DIM_NS_PRODUCT(SUB_CATEGORY_NAME);

-- ============================================================================
-- VERIFY DIMENSION TABLES
-- ============================================================================
SELECT 'DIM_DATE' AS TABLE_NAME, COUNT(*) AS RECORD_COUNT FROM DIM_DATE
UNION ALL
SELECT 'DIM_NS_CUSTOMER', COUNT(*) FROM DIM_NS_CUSTOMER
UNION ALL
SELECT 'DIM_NS_PRODUCT', COUNT(*) FROM DIM_NS_PRODUCT;

-- ============================================================================
-- END OF DIMENSION TABLE DEFINITIONS
-- ============================================================================
