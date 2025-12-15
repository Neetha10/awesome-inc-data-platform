-- ============================================================================
-- AWESOME INC. - OLTP DATABASE SCHEMA (MySQL)
-- ============================================================================
-- Database: MySQL 8.0+
-- Schema: 3NF Normalized
-- Tables: 9
-- Total Records: 101,543
-- Author: Neethu Satravada (NS6411)
-- Course: ECE-GY-9941 Advanced Projects
-- ============================================================================

CREATE DATABASE IF NOT EXISTS awesome_inc_oltp;
USE awesome_inc_oltp;

-- ============================================================================
-- TABLE 1: NS_SEGMENT (3 records)
-- ============================================================================
CREATE TABLE NS_SEGMENT (
    ROW_ID              INT             PRIMARY KEY AUTO_INCREMENT,
    SEGMENT_ID          VARCHAR(20)     NOT NULL UNIQUE,
    SEGMENT_NAME        VARCHAR(50)     NOT NULL,
    TBL_LAST_DT         TIMESTAMP       DEFAULT CURRENT_TIMESTAMP 
                                        ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================================
-- TABLE 2: NS_CATEGORY (3 records)
-- ============================================================================
CREATE TABLE NS_CATEGORY (
    ROW_ID              INT             PRIMARY KEY AUTO_INCREMENT,
    CATEGORY_ID         VARCHAR(20)     NOT NULL UNIQUE,
    CATEGORY_NAME       VARCHAR(50)     NOT NULL,
    TBL_LAST_DT         TIMESTAMP       DEFAULT CURRENT_TIMESTAMP 
                                        ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================================
-- TABLE 3: NS_SUB_CATEGORY (17 records)
-- ============================================================================
CREATE TABLE NS_SUB_CATEGORY (
    ROW_ID              INT             PRIMARY KEY AUTO_INCREMENT,
    SUB_CATEGORY_ID     VARCHAR(20)     NOT NULL UNIQUE,
    SUB_CATEGORY_NAME   VARCHAR(50)     NOT NULL,
    CATEGORY_ROW_ID     INT             NOT NULL,
    TBL_LAST_DT         TIMESTAMP       DEFAULT CURRENT_TIMESTAMP 
                                        ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================================
-- TABLE 4: NS_PRODUCT (3,788 records)
-- ============================================================================
CREATE TABLE NS_PRODUCT (
    ROW_ID              INT             PRIMARY KEY AUTO_INCREMENT,
    PRODUCT_ID          VARCHAR(50)     NOT NULL UNIQUE,
    PRODUCT_NAME        VARCHAR(255)    NOT NULL,
    SUB_CATEGORY_ROW_ID INT             NOT NULL,
    TBL_LAST_DT         TIMESTAMP       DEFAULT CURRENT_TIMESTAMP 
                                        ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================================
-- TABLE 5: NS_CUSTOMER (17,415 records)
-- ============================================================================
CREATE TABLE NS_CUSTOMER (
    ROW_ID              INT             PRIMARY KEY AUTO_INCREMENT,
    CUSTOMER_ID         VARCHAR(20)     NOT NULL UNIQUE,
    FIRST_NAME          VARCHAR(50),
    LAST_NAME           VARCHAR(50),
    CITY                VARCHAR(100),
    STATE               VARCHAR(100),
    COUNTRY             VARCHAR(100),
    REGION              VARCHAR(50),
    MARKET              VARCHAR(50),
    POSTAL_CODE         INT,
    SEGMENT_ROW_ID      INT             NOT NULL,
    TBL_LAST_DT         TIMESTAMP       DEFAULT CURRENT_TIMESTAMP 
                                        ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================================
-- TABLE 6: NS_ORDER (25,728 records)
-- ============================================================================
CREATE TABLE NS_ORDER (
    ROW_ID              INT             PRIMARY KEY AUTO_INCREMENT,
    ORDER_ID            VARCHAR(25)     NOT NULL UNIQUE,
    ORDER_DATE          DATE            NOT NULL,
    SHIP_DATE           DATE,
    SHIP_MODE           VARCHAR(50),
    ORDER_OF_PRIORITY   VARCHAR(20),
    CUSTOMER_ROW_ID     INT             NOT NULL,
    TBL_LAST_DT         TIMESTAMP       DEFAULT CURRENT_TIMESTAMP 
                                        ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================================
-- TABLE 7: NS_ORDER_DETAIL (51,290 records)
-- ============================================================================
CREATE TABLE NS_ORDER_DETAIL (
    ROW_ID              INT             PRIMARY KEY AUTO_INCREMENT,
    QUANTITY            INT             NOT NULL,
    DISCOUNT            DECIMAL(5,2)    DEFAULT 0,
    SALES               DECIMAL(15,2)   NOT NULL,
    PROFIT              DECIMAL(15,2),
    SHIPPING_COST       DECIMAL(15,2),
    ORDER_ROW_ID        INT             NOT NULL,
    PRODUCT_ROW_ID      INT             NOT NULL,
    TBL_LAST_DT         TIMESTAMP       DEFAULT CURRENT_TIMESTAMP 
                                        ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================================
-- TABLE 8: NS_RETURN (1,079 records)
-- ============================================================================
CREATE TABLE NS_RETURN (
    ROW_ID              INT             PRIMARY KEY AUTO_INCREMENT,
    RETURN_ID           VARCHAR(25)     NOT NULL UNIQUE,
    RETURN_REASON       VARCHAR(100),
    RETURN_DATE         DATE,
    ORDER_ROW_ID        INT             NOT NULL,
    TBL_LAST_DT         TIMESTAMP       DEFAULT CURRENT_TIMESTAMP 
                                        ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================================
-- TABLE 9: NS_RETURN_DETAIL (2,220 records)
-- ============================================================================
CREATE TABLE NS_RETURN_DETAIL (
    ROW_ID              INT             PRIMARY KEY AUTO_INCREMENT,
    RETURN_AMOUNT       DECIMAL(15,2),
    RETURN_ROW_ID       INT             NOT NULL,
    ORDER_DETAIL_ROW_ID INT             NOT NULL,
    TBL_LAST_DT         TIMESTAMP       DEFAULT CURRENT_TIMESTAMP 
                                        ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================================
-- END OF OLTP TABLE DEFINITIONS
-- ============================================================================
