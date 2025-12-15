-- ============================================================================
-- AWESOME INC. - ETL MERGE PROCEDURES (Oracle)
-- ============================================================================
-- Load layer - MERGE data from Staging to Dimension/Fact tables
-- Supports incremental loading with CDC (Change Data Capture)
-- Author: Neethu Satravada (NS6411)
-- Course: ECE-GY-9941 Advanced Projects
-- ============================================================================

-- ============================================================================
-- MERGE 1: LOAD DIM_NS_CUSTOMER FROM STAGING
-- ============================================================================

MERGE INTO DIM_NS_CUSTOMER target
USING STG_NS_CUSTOMER source
ON (target.CUSTOMER_ID = source.CUSTOMER_ID)

WHEN MATCHED THEN
    UPDATE SET
        target.FIRST_NAME    = source.FIRST_NAME,
        target.LAST_NAME     = source.LAST_NAME,
        target.CITY          = source.CITY,
        target.STATE         = source.STATE,
        target.COUNTRY       = source.COUNTRY,
        target.REGION        = source.REGION,
        target.MARKET        = source.MARKET,
        target.POSTAL_CODE   = source.POSTAL_CODE,
        target.SEGMENT_ID    = source.SEGMENT_ID,
        target.SEGMENT_NAME  = source.SEGMENT_NAME,
        target.TBL_LAST_DT   = SYSTIMESTAMP

WHEN NOT MATCHED THEN
    INSERT (
        CUSTOMER_ID, FIRST_NAME, LAST_NAME, CITY, STATE,
        COUNTRY, REGION, MARKET, POSTAL_CODE, 
        SEGMENT_ID, SEGMENT_NAME, TBL_LAST_DT
    )
    VALUES (
        source.CUSTOMER_ID, source.FIRST_NAME, source.LAST_NAME, 
        source.CITY, source.STATE, source.COUNTRY, source.REGION, 
        source.MARKET, source.POSTAL_CODE,
        source.SEGMENT_ID, source.SEGMENT_NAME, SYSTIMESTAMP
    );

COMMIT;

-- ============================================================================
-- MERGE 2: LOAD DIM_NS_PRODUCT FROM STAGING
-- ============================================================================

MERGE INTO DIM_NS_PRODUCT target
USING STG_NS_PRODUCT source
ON (target.PRODUCT_ID = source.PRODUCT_ID)

WHEN MATCHED THEN
    UPDATE SET
        target.PRODUCT_NAME      = source.PRODUCT_NAME,
        target.SUB_CATEGORY_ID   = source.SUB_CATEGORY_ID,
        target.SUB_CATEGORY_NAME = source.SUB_CATEGORY_NAME,
        target.CATEGORY_ID       = source.CATEGORY_ID,
        target.CATEGORY_NAME     = source.CATEGORY_NAME,
        target.TBL_LAST_DT       = SYSTIMESTAMP

WHEN NOT MATCHED THEN
    INSERT (
        PRODUCT_ID, PRODUCT_NAME, SUB_CATEGORY_ID, SUB_CATEGORY_NAME,
        CATEGORY_ID, CATEGORY_NAME, TBL_LAST_DT
    )
    VALUES (
        source.PRODUCT_ID, source.PRODUCT_NAME, 
        source.SUB_CATEGORY_ID, source.SUB_CATEGORY_NAME,
        source.CATEGORY_ID, source.CATEGORY_NAME, SYSTIMESTAMP
    );

COMMIT;

-- ============================================================================
-- MERGE 3: LOAD FACT_NS_ORDER_DETAIL FROM STAGING
-- ============================================================================

MERGE INTO FACT_NS_ORDER_DETAIL target
USING STG_NS_ORDER_DETAIL source
ON (target.ROW_ID = source.ROW_ID)

WHEN MATCHED THEN
    UPDATE SET
        target.ORDER_ID          = source.ORDER_ID,
        target.ORDER_DATE        = source.ORDER_DATE,
        target.SHIP_DATE         = source.SHIP_DATE,
        target.SHIP_MODE         = source.SHIP_MODE,
        target.ORDER_OF_PRIORITY = source.ORDER_OF_PRIORITY,
        target.QUANTITY          = source.QUANTITY,
        target.DISCOUNT          = source.DISCOUNT,
        target.SALES             = source.SALES,
        target.PROFIT            = source.PROFIT,
        target.SHIPPING_COST     = source.SHIPPING_COST,
        target.DATE_ID           = source.DATE_ID,
        target.CUSTOMER_ID       = source.CUSTOMER_ID,
        target.PRODUCT_ID        = source.PRODUCT_ID,
        target.TBL_LAST_DT       = SYSTIMESTAMP

WHEN NOT MATCHED THEN
    INSERT (
        ROW_ID, ORDER_ID, ORDER_DATE, SHIP_DATE, SHIP_MODE,
        ORDER_OF_PRIORITY, QUANTITY, DISCOUNT, SALES, PROFIT,
        SHIPPING_COST, DATE_ID, CUSTOMER_ID, PRODUCT_ID, TBL_LAST_DT
    )
    VALUES (
        source.ROW_ID, source.ORDER_ID, source.ORDER_DATE, source.SHIP_DATE,
        source.SHIP_MODE, source.ORDER_OF_PRIORITY, source.QUANTITY,
        source.DISCOUNT, source.SALES, source.PROFIT, source.SHIPPING_COST,
        source.DATE_ID, source.CUSTOMER_ID, source.PRODUCT_ID, SYSTIMESTAMP
    );

COMMIT;

-- ============================================================================
-- MERGE 4: LOAD FACT_NS_RETURN FROM STAGING
-- ============================================================================

MERGE INTO FACT_NS_RETURN target
USING STG_NS_RETURN source
ON (target.ROW_ID = source.ROW_ID)

WHEN MATCHED THEN
    UPDATE SET
        target.RETURN_ID           = source.RETURN_ID,
        target.RETURN_REASON       = source.RETURN_REASON,
        target.RETURN_DATE         = source.RETURN_DATE,
        target.RETURN_AMOUNT       = source.RETURN_AMOUNT,
        target.ORDER_DETAIL_ROW_ID = source.ORDER_DETAIL_ROW_ID,
        target.DATE_ID             = source.DATE_ID,
        target.CUSTOMER_ID         = source.CUSTOMER_ID,
        target.PRODUCT_ID          = source.PRODUCT_ID,
        target.TBL_LAST_DT         = SYSTIMESTAMP

WHEN NOT MATCHED THEN
    INSERT (
        ROW_ID, RETURN_ID, RETURN_REASON, RETURN_DATE, RETURN_AMOUNT,
        ORDER_DETAIL_ROW_ID, DATE_ID, CUSTOMER_ID, PRODUCT_ID, TBL_LAST_DT
    )
    VALUES (
        source.ROW_ID, source.RETURN_ID, source.RETURN_REASON, 
        source.RETURN_DATE, source.RETURN_AMOUNT, source.ORDER_DETAIL_ROW_ID,
        source.DATE_ID, source.CUSTOMER_ID, source.PRODUCT_ID, SYSTIMESTAMP
    );

COMMIT;

-- ============================================================================
-- STORED PROCEDURE: FULL ETL PIPELINE
-- ============================================================================

CREATE OR REPLACE PROCEDURE SP_RUN_FULL_ETL AS
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
BEGIN
    v_start_time := SYSTIMESTAMP;
    
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('ETL PIPELINE STARTED: ' || v_start_time);
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    -- Step 1: Clear staging tables
    DBMS_OUTPUT.PUT_LINE('Step 1: Clearing staging tables...');
    EXECUTE IMMEDIATE 'TRUNCATE TABLE STG_NS_CUSTOMER';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE STG_NS_PRODUCT';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE STG_NS_ORDER_DETAIL';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE STG_NS_RETURN';
    
    -- Step 2: Load staging tables from external tables
    DBMS_OUTPUT.PUT_LINE('Step 2: Loading staging tables...');
    -- (Insert statements from 02_staging_tables.sql would go here)
    
    -- Step 3: Merge to dimension tables
    DBMS_OUTPUT.PUT_LINE('Step 3: Loading dimension tables...');
    -- (MERGE statements for DIM tables)
    
    -- Step 4: Merge to fact tables
    DBMS_OUTPUT.PUT_LINE('Step 4: Loading fact tables...');
    -- (MERGE statements for FACT tables)
    
    v_end_time := SYSTIMESTAMP;
    
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('ETL PIPELINE COMPLETED: ' || v_end_time);
    DBMS_OUTPUT.PUT_LINE('Duration: ' || (v_end_time - v_start_time));
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END SP_RUN_FULL_ETL;
/

-- ============================================================================
-- STORED PROCEDURE: INCREMENTAL ETL (CDC)
-- ============================================================================

CREATE OR REPLACE PROCEDURE SP_RUN_INCREMENTAL_ETL(
    p_last_run_date IN TIMESTAMP DEFAULT NULL
) AS
    v_last_run TIMESTAMP;
    v_start_time TIMESTAMP;
    v_records_processed NUMBER := 0;
BEGIN
    v_start_time := SYSTIMESTAMP;
    
    -- Use provided date or get from last ETL run
    v_last_run := NVL(p_last_run_date, SYSTIMESTAMP - INTERVAL '1' DAY);
    
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('INCREMENTAL ETL STARTED: ' || v_start_time);
    DBMS_OUTPUT.PUT_LINE('Processing records since: ' || v_last_run);
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    -- Only process records where TBL_LAST_DT > last run date
    -- This is the CDC (Change Data Capture) logic
    
    -- Merge customers changed since last run
    MERGE INTO DIM_NS_CUSTOMER target
    USING (SELECT * FROM STG_NS_CUSTOMER WHERE TBL_LAST_DT > v_last_run) source
    ON (target.CUSTOMER_ID = source.CUSTOMER_ID)
    WHEN MATCHED THEN
        UPDATE SET
            target.FIRST_NAME = source.FIRST_NAME,
            target.LAST_NAME = source.LAST_NAME,
            target.CITY = source.CITY,
            target.TBL_LAST_DT = SYSTIMESTAMP
    WHEN NOT MATCHED THEN
        INSERT (CUSTOMER_ID, FIRST_NAME, LAST_NAME, CITY, TBL_LAST_DT)
        VALUES (source.CUSTOMER_ID, source.FIRST_NAME, source.LAST_NAME, 
                source.CITY, SYSTIMESTAMP);
    
    v_records_processed := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('Customers processed: ' || v_records_processed);
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('INCREMENTAL ETL COMPLETED');
    DBMS_OUTPUT.PUT_LINE('========================================');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END SP_RUN_INCREMENTAL_ETL;
/

-- ============================================================================
-- VERIFY DATA WAREHOUSE TABLES
-- ============================================================================

SELECT 'DIM_DATE' AS TABLE_NAME, COUNT(*) AS RECORD_COUNT FROM DIM_DATE
UNION ALL
SELECT 'DIM_NS_CUSTOMER', COUNT(*) FROM DIM_NS_CUSTOMER
UNION ALL
SELECT 'DIM_NS_PRODUCT', COUNT(*) FROM DIM_NS_PRODUCT
UNION ALL
SELECT 'FACT_NS_ORDER_DETAIL', COUNT(*) FROM FACT_NS_ORDER_DETAIL
UNION ALL
SELECT 'FACT_NS_RETURN', COUNT(*) FROM FACT_NS_RETURN;

-- ============================================================================
-- MERGE STATEMENT SUMMARY
-- ============================================================================
/*
WHAT IS MERGE?
══════════════
MERGE is a SQL statement that combines INSERT and UPDATE in one operation.
Also called "UPSERT" (Update + Insert)


HOW MERGE WORKS:
════════════════

    For each record in source:
        │
        ▼
    Does record exist in target?
        │
        ├── YES ──► UPDATE the existing record
        │
        └── NO ───► INSERT as new record


EXAMPLE:
════════

    Customer "CUST-001" exists in DIM_NS_CUSTOMER?
        │
        ├── YES ──► UPDATE: Change city from "NYC" to "LA"
        │
        └── NO ───► INSERT: Add new customer "CUST-001"


MERGE ORDER (Important!):
═════════════════════════

    1. DIM_NS_CUSTOMER   (Dimensions first!)
    2. DIM_NS_PRODUCT    (Dimensions first!)
    3. FACT_NS_ORDER_DETAIL (Facts after dimensions)
    4. FACT_NS_RETURN    (Facts after dimensions)

    Why? Because FACT tables have foreign keys to DIM tables.
         DIM records must exist before FACT records can reference them.


CDC (Change Data Capture):
══════════════════════════

    Full Load:        Load ALL records every time (slow)
    Incremental Load: Load only CHANGED records (fast)
    
    We use TBL_LAST_DT column to identify changed records:
    
    SELECT * FROM STG_NS_CUSTOMER
    WHERE TBL_LAST_DT > '2025-12-14';  -- Only records changed since Dec 14
    
    This is CDC - Change Data Capture!
*/

-- ============================================================================
-- END OF MERGE PROCEDURES
-- ============================================================================
