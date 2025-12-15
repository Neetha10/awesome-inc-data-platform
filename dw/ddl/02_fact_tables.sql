-- ============================================================================
-- AWESOME INC. - DATA WAREHOUSE FACT TABLES (Oracle)
-- ============================================================================
-- Database: Oracle Autonomous Data Warehouse
-- Schema: Star Schema
-- Author: Neethu Satravada (NS6411)
-- Course: ECE-GY-9941 Advanced Projects
-- ============================================================================

-- ============================================================================
-- FACT TABLE 1: FACT_NS_ORDER_DETAIL (51,290 records)
-- Grain: One row per order line item
-- ============================================================================
CREATE TABLE FACT_NS_ORDER_DETAIL (
    ROW_ID              NUMBER          PRIMARY KEY,
    ORDER_ID            VARCHAR2(25)    NOT NULL,
    ORDER_DATE          DATE            NOT NULL,
    SHIP_DATE           DATE,
    SHIP_MODE           VARCHAR2(50),
    ORDER_OF_PRIORITY   VARCHAR2(20),
    
    -- Measures (Facts)
    QUANTITY            NUMBER(10)      NOT NULL,
    DISCOUNT            NUMBER(5,2)     DEFAULT 0,
    SALES               NUMBER(15,2)    NOT NULL,
    PROFIT              NUMBER(15,2),
    SHIPPING_COST       NUMBER(15,2),
    
    -- Foreign Keys to Dimensions
    DATE_ID             NUMBER(10)      NOT NULL,
    CUSTOMER_ID         VARCHAR2(20)    NOT NULL,
    PRODUCT_ID          VARCHAR2(50)    NOT NULL,
    
    -- CDC Column
    TBL_LAST_DT         TIMESTAMP       DEFAULT SYSTIMESTAMP,
    
    -- Foreign Key Constraints
    CONSTRAINT FACT_ORDER_DATE_FK 
        FOREIGN KEY (DATE_ID) REFERENCES DIM_DATE(DATE_ID),
    CONSTRAINT FACT_ORDER_CUSTOMER_FK 
        FOREIGN KEY (CUSTOMER_ID) REFERENCES DIM_NS_CUSTOMER(CUSTOMER_ID),
    CONSTRAINT FACT_ORDER_PRODUCT_FK 
        FOREIGN KEY (PRODUCT_ID) REFERENCES DIM_NS_PRODUCT(PRODUCT_ID)
);

-- Add comments
COMMENT ON TABLE FACT_NS_ORDER_DETAIL IS 'Fact table for order transactions - 51,290 records';
COMMENT ON COLUMN FACT_NS_ORDER_DETAIL.ROW_ID IS 'Surrogate key from OLTP';
COMMENT ON COLUMN FACT_NS_ORDER_DETAIL.SALES IS 'Sales amount in USD';
COMMENT ON COLUMN FACT_NS_ORDER_DETAIL.PROFIT IS 'Profit amount in USD (can be negative)';
COMMENT ON COLUMN FACT_NS_ORDER_DETAIL.DISCOUNT IS 'Discount percentage (0.00 to 1.00)';

-- ============================================================================
-- FACT TABLE 2: FACT_NS_RETURN (2,220 records)
-- Grain: One row per returned item
-- ============================================================================
CREATE TABLE FACT_NS_RETURN (
    ROW_ID              NUMBER          PRIMARY KEY,
    RETURN_ID           VARCHAR2(25)    NOT NULL,
    RETURN_REASON       VARCHAR2(100),
    RETURN_DATE         DATE,
    
    -- Measures (Facts)
    RETURN_AMOUNT       NUMBER(15,2),
    
    -- Foreign Keys
    ORDER_DETAIL_ROW_ID NUMBER          NOT NULL,
    DATE_ID             NUMBER(10),
    CUSTOMER_ID         VARCHAR2(20),
    PRODUCT_ID          VARCHAR2(50),
    
    -- CDC Column
    TBL_LAST_DT         TIMESTAMP       DEFAULT SYSTIMESTAMP,
    
    -- Foreign Key Constraints
    CONSTRAINT FACT_RETURN_ORDER_DETAIL_FK 
        FOREIGN KEY (ORDER_DETAIL_ROW_ID) REFERENCES FACT_NS_ORDER_DETAIL(ROW_ID),
    CONSTRAINT FACT_RETURN_DATE_FK 
        FOREIGN KEY (DATE_ID) REFERENCES DIM_DATE(DATE_ID),
    CONSTRAINT FACT_RETURN_CUSTOMER_FK 
        FOREIGN KEY (CUSTOMER_ID) REFERENCES DIM_NS_CUSTOMER(CUSTOMER_ID),
    CONSTRAINT FACT_RETURN_PRODUCT_FK 
        FOREIGN KEY (PRODUCT_ID) REFERENCES DIM_NS_PRODUCT(PRODUCT_ID)
);

-- Add comments
COMMENT ON TABLE FACT_NS_RETURN IS 'Fact table for returns - 2,220 records';
COMMENT ON COLUMN FACT_NS_RETURN.RETURN_AMOUNT IS 'Refund amount in USD';
COMMENT ON COLUMN FACT_NS_RETURN.RETURN_REASON IS 'Reason for return';

-- ============================================================================
-- INDEXES FOR FACT TABLES
-- ============================================================================

-- Indexes for FACT_NS_ORDER_DETAIL
CREATE INDEX IDX_FACT_ORDER_DATE ON FACT_NS_ORDER_DETAIL(DATE_ID);
CREATE INDEX IDX_FACT_ORDER_CUSTOMER ON FACT_NS_ORDER_DETAIL(CUSTOMER_ID);
CREATE INDEX IDX_FACT_ORDER_PRODUCT ON FACT_NS_ORDER_DETAIL(PRODUCT_ID);
CREATE INDEX IDX_FACT_ORDER_ORDER_DATE ON FACT_NS_ORDER_DETAIL(ORDER_DATE);
CREATE INDEX IDX_FACT_ORDER_SHIP_MODE ON FACT_NS_ORDER_DETAIL(SHIP_MODE);

-- Indexes for FACT_NS_RETURN
CREATE INDEX IDX_FACT_RETURN_DATE ON FACT_NS_RETURN(DATE_ID);
CREATE INDEX IDX_FACT_RETURN_CUSTOMER ON FACT_NS_RETURN(CUSTOMER_ID);
CREATE INDEX IDX_FACT_RETURN_PRODUCT ON FACT_NS_RETURN(PRODUCT_ID);
CREATE INDEX IDX_FACT_RETURN_ORDER_DETAIL ON FACT_NS_RETURN(ORDER_DETAIL_ROW_ID);

-- ============================================================================
-- VERIFY FACT TABLES
-- ============================================================================
SELECT 'FACT_NS_ORDER_DETAIL' AS TABLE_NAME, COUNT(*) AS RECORD_COUNT FROM FACT_NS_ORDER_DETAIL
UNION ALL
SELECT 'FACT_NS_RETURN', COUNT(*) FROM FACT_NS_RETURN;

-- ============================================================================
-- DATA WAREHOUSE SUMMARY
-- ============================================================================
/*
STAR SCHEMA SUMMARY:
════════════════════════════════════════════════════════════════════════════

                              DIM_DATE
                             (1,827 rows)
                                 │
                                 │ DATE_ID
                                 ▼
┌─────────────────┐    ┌─────────────────────────┐    ┌─────────────────┐
│ DIM_NS_CUSTOMER │    │  FACT_NS_ORDER_DETAIL   │    │ DIM_NS_PRODUCT  │
│  (17,415 rows)  │◄───│      (51,290 rows)      │───►│  (3,788 rows)   │
└─────────────────┘    └─────────────────────────┘    └─────────────────┘
                                 │
                                 │ ORDER_DETAIL_ROW_ID
                                 ▼
                       ┌─────────────────────────┐
                       │    FACT_NS_RETURN       │
                       │      (2,220 rows)       │
                       └─────────────────────────┘


TABLE COUNTS:
─────────────────────────────────────────────────────────────────────────────
| Table                  | Type      | Records | Description               |
─────────────────────────────────────────────────────────────────────────────
| DIM_DATE               | Dimension | 1,827   | Calendar (2012-2016)      |
| DIM_NS_CUSTOMER        | Dimension | 17,415  | Customers + Segment       |
| DIM_NS_PRODUCT         | Dimension | 3,788   | Products + Category       |
| FACT_NS_ORDER_DETAIL   | Fact      | 51,290  | Order line items          |
| FACT_NS_RETURN         | Fact      | 2,220   | Return line items         |
─────────────────────────────────────────────────────────────────────────────
| TOTAL                  |           | 76,540  |                           |
─────────────────────────────────────────────────────────────────────────────
*/

-- ============================================================================
-- END OF FACT TABLE DEFINITIONS
-- ============================================================================
