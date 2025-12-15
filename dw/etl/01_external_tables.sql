-- ============================================================================
-- AWESOME INC. - ETL EXTERNAL TABLES (Oracle)
-- ============================================================================
-- Extract layer using DBMS_CLOUD and External Tables
-- Reads CSV files directly from Oracle Object Storage
-- Author: Neethu Satravada (NS6411)
-- Course: ECE-GY-9941 Advanced Projects
-- ============================================================================

-- ============================================================================
-- STEP 1: CREATE CLOUD CREDENTIAL
-- ============================================================================
-- This credential allows Oracle to access Object Storage

BEGIN
    DBMS_CLOUD.CREATE_CREDENTIAL(
        credential_name => 'OBJ_STORE_CRED',
        username        => 'my_oci_username',
        password        => 'my_auth_token'
    );
END;
/

-- ============================================================================
-- STEP 2: EXTERNAL TABLE FOR ORDERS DATA
-- ============================================================================
-- Reads orders.csv from Oracle Object Storage

BEGIN
    DBMS_CLOUD.CREATE_EXTERNAL_TABLE(
        table_name      => 'EXT_NS_ORDERS',
        credential_name => 'OBJ_STORE_CRED',
        file_uri_list   => 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/namespace/b/bucket/o/orders.csv',
        format          => JSON_OBJECT(
                            'type' VALUE 'CSV',
                            'skipheaders' VALUE '1',
                            'delimiter' VALUE ',',
                            'ignoremissingcolumns' VALUE 'true',
                            'blankasnull' VALUE 'true'
                           ),
        column_list     => '
            ROW_ID              NUMBER,
            ORDER_ID            VARCHAR2(25),
            ORDER_DATE          VARCHAR2(20),
            SHIP_DATE           VARCHAR2(20),
            SHIP_MODE           VARCHAR2(50),
            CUSTOMER_ID         VARCHAR2(20),
            CUSTOMER_NAME       VARCHAR2(100),
            SEGMENT             VARCHAR2(50),
            CITY                VARCHAR2(100),
            STATE               VARCHAR2(100),
            COUNTRY             VARCHAR2(100),
            POSTAL_CODE         VARCHAR2(20),
            MARKET              VARCHAR2(50),
            REGION              VARCHAR2(50),
            PRODUCT_ID          VARCHAR2(50),
            CATEGORY            VARCHAR2(50),
            SUB_CATEGORY        VARCHAR2(50),
            PRODUCT_NAME        VARCHAR2(255),
            SALES               VARCHAR2(20),
            QUANTITY            VARCHAR2(10),
            DISCOUNT            VARCHAR2(10),
            PROFIT              VARCHAR2(20),
            SHIPPING_COST       VARCHAR2(20),
            ORDER_PRIORITY      VARCHAR2(20)
        '
    );
END;
/

-- ============================================================================
-- STEP 3: EXTERNAL TABLE FOR RETURNS DATA
-- ============================================================================
-- Reads returns.csv from Oracle Object Storage

BEGIN
    DBMS_CLOUD.CREATE_EXTERNAL_TABLE(
        table_name      => 'EXT_NS_RETURNS',
        credential_name => 'OBJ_STORE_CRED',
        file_uri_list   => 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/namespace/b/bucket/o/returns.csv',
        format          => JSON_OBJECT(
                            'type' VALUE 'CSV',
                            'skipheaders' VALUE '1',
                            'delimiter' VALUE ',',
                            'ignoremissingcolumns' VALUE 'true',
                            'blankasnull' VALUE 'true'
                           ),
        column_list     => '
            RETURNED            VARCHAR2(10),
            ORDER_ID            VARCHAR2(25),
            MARKET              VARCHAR2(50)
        '
    );
END;
/

-- ============================================================================
-- STEP 4: VERIFY EXTERNAL TABLES
-- ============================================================================

-- Check if external tables were created
SELECT table_name, num_rows 
FROM user_tables 
WHERE table_name LIKE 'EXT_%';

-- Preview data from external tables
SELECT * FROM EXT_NS_ORDERS WHERE ROWNUM <= 10;
SELECT * FROM EXT_NS_RETURNS WHERE ROWNUM <= 10;

-- Count records
SELECT 'EXT_NS_ORDERS' AS TABLE_NAME, COUNT(*) AS RECORD_COUNT FROM EXT_NS_ORDERS
UNION ALL
SELECT 'EXT_NS_RETURNS', COUNT(*) FROM EXT_NS_RETURNS;

-- ============================================================================
-- EXTERNAL TABLE SUMMARY
-- ============================================================================
/*
WHAT ARE EXTERNAL TABLES?
═════════════════════════
External tables allow Oracle to read data directly from files in cloud storage
WITHOUT loading the data into the database first.

It's like a "window" that lets you query CSV files using SQL!


HOW IT WORKS:
═════════════

    ┌─────────────────┐                    ┌─────────────────────┐
    │  Oracle Object  │                    │   Oracle Database   │
    │    Storage      │                    │                     │
    │                 │                    │                     │
    │  ┌───────────┐  │    DBMS_CLOUD      │   ┌─────────────┐   │
    │  │orders.csv │  │◄──────────────────►│   │EXT_NS_ORDERS│   │
    │  └───────────┘  │    External Table  │   └─────────────┘   │
    │                 │                    │                     │
    │  ┌───────────┐  │                    │   ┌──────────────┐  │
    │  │returns.csv│  │◄──────────────────►│   │EXT_NS_RETURNS│  │
    │  └───────────┘  │                    │   └──────────────┘  │
    │                 │                    │                     │
    └─────────────────┘                    └─────────────────────┘
    
    CSV stays in cloud                     Query using SQL:
    No storage used                        SELECT * FROM EXT_NS_ORDERS;


EXTERNAL TABLES CREATED:
════════════════════════
| Table Name      | Source File  | Description              |
─────────────────────────────────────────────────────────────
| EXT_NS_ORDERS   | orders.csv   | Order transactions       |
| EXT_NS_RETURNS  | returns.csv  | Return transactions      |
─────────────────────────────────────────────────────────────
*/

-- ============================================================================
-- END OF EXTERNAL TABLE DEFINITIONS
-- ============================================================================
