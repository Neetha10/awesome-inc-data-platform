-- ============================================================================
-- AWESOME INC. - SAMPLE INSERT STATEMENTS (MySQL)
-- ============================================================================
-- Sample DML for testing and demonstration
-- Author: Neethu Satravada (NS6411)
-- Course: ECE-GY-9941 Advanced Projects
-- ============================================================================

USE awesome_inc_oltp;

-- ============================================================================
-- NS_SEGMENT (3 records)
-- ============================================================================
INSERT INTO NS_SEGMENT (SEGMENT_ID, SEGMENT_NAME) VALUES
('SEG-001', 'Consumer'),
('SEG-002', 'Corporate'),
('SEG-003', 'Home Office');

-- ============================================================================
-- NS_CATEGORY (3 records)
-- ============================================================================
INSERT INTO NS_CATEGORY (CATEGORY_ID, CATEGORY_NAME) VALUES
('CAT-001', 'Technology'),
('CAT-002', 'Furniture'),
('CAT-003', 'Office Supplies');

-- ============================================================================
-- NS_SUB_CATEGORY (17 records)
-- ============================================================================
INSERT INTO NS_SUB_CATEGORY (SUB_CATEGORY_ID, SUB_CATEGORY_NAME, CATEGORY_ROW_ID) VALUES
-- Technology (CAT-001 = ROW_ID 1)
('SUBCAT-001', 'Phones', 1),
('SUBCAT-002', 'Copiers', 1),
('SUBCAT-003', 'Accessories', 1),
('SUBCAT-004', 'Machines', 1),
-- Furniture (CAT-002 = ROW_ID 2)
('SUBCAT-005', 'Chairs', 2),
('SUBCAT-006', 'Tables', 2),
('SUBCAT-007', 'Bookcases', 2),
('SUBCAT-008', 'Furnishings', 2),
-- Office Supplies (CAT-003 = ROW_ID 3)
('SUBCAT-009', 'Paper', 3),
('SUBCAT-010', 'Binders', 3),
('SUBCAT-011', 'Labels', 3),
('SUBCAT-012', 'Storage', 3),
('SUBCAT-013', 'Art', 3),
('SUBCAT-014', 'Envelopes', 3),
('SUBCAT-015', 'Fasteners', 3),
('SUBCAT-016', 'Supplies', 3),
('SUBCAT-017', 'Appliances', 3);

-- ============================================================================
-- NS_PRODUCT (Sample 10 records)
-- ============================================================================
INSERT INTO NS_PRODUCT (PRODUCT_ID, PRODUCT_NAME, SUB_CATEGORY_ROW_ID) VALUES
('PROD-001', 'Apple iPhone 15 Pro', 1),
('PROD-002', 'Samsung Galaxy S24', 1),
('PROD-003', 'HP LaserJet Pro Copier', 2),
('PROD-004', 'Canon ImageRunner', 2),
('PROD-005', 'Logitech Wireless Mouse', 3),
('PROD-006', 'Herman Miller Aeron Chair', 5),
('PROD-007', 'Standing Desk Pro', 6),
('PROD-008', 'Premium Copy Paper 5000 Sheets', 9),
('PROD-009', 'Heavy Duty Binder 3-inch', 10),
('PROD-010', 'Brother Label Maker', 11);

-- ============================================================================
-- NS_CUSTOMER (Sample 10 records)
-- ============================================================================
INSERT INTO NS_CUSTOMER (CUSTOMER_ID, FIRST_NAME, LAST_NAME, CITY, STATE, COUNTRY, REGION, MARKET, POSTAL_CODE, SEGMENT_ROW_ID) VALUES
('CUST-001', 'John', 'Smith', 'New York', 'New York', 'United States', 'East', 'US', 10001, 1),
('CUST-002', 'Emily', 'Johnson', 'Los Angeles', 'California', 'United States', 'West', 'US', 90001, 1),
('CUST-003', 'Michael', 'Williams', 'Chicago', 'Illinois', 'United States', 'Central', 'US', 60601, 2),
('CUST-004', 'Sarah', 'Brown', 'Houston', 'Texas', 'United States', 'Central', 'US', 77001, 2),
('CUST-005', 'David', 'Jones', 'Phoenix', 'Arizona', 'United States', 'West', 'US', 85001, 3),
('CUST-006', 'Emma', 'Garcia', 'London', 'England', 'United Kingdom', 'Western Europe', 'EU', NULL, 1),
('CUST-007', 'James', 'Miller', 'Paris', 'Ile-de-France', 'France', 'Western Europe', 'EU', NULL, 2),
('CUST-008', 'Olivia', 'Davis', 'Tokyo', 'Tokyo', 'Japan', 'Eastern Asia', 'APAC', NULL, 1),
('CUST-009', 'William', 'Rodriguez', 'Sydney', 'NSW', 'Australia', 'Oceania', 'APAC', NULL, 3),
('CUST-010', 'Sophia', 'Martinez', 'Toronto', 'Ontario', 'Canada', 'Canada', 'Canada', NULL, 2);

-- ============================================================================
-- NS_ORDER (Sample 10 records)
-- ============================================================================
INSERT INTO NS_ORDER (ORDER_ID, ORDER_DATE, SHIP_DATE, SHIP_MODE, ORDER_OF_PRIORITY, CUSTOMER_ROW_ID) VALUES
('ORD-2015-001', '2015-01-15', '2015-01-20', 'Standard Class', 'Medium', 1),
('ORD-2015-002', '2015-02-10', '2015-02-12', 'Second Class', 'High', 2),
('ORD-2015-003', '2015-03-05', '2015-03-06', 'First Class', 'Critical', 3),
('ORD-2015-004', '2015-04-20', '2015-04-27', 'Standard Class', 'Low', 4),
('ORD-2015-005', '2015-05-15', '2015-05-15', 'Same Day', 'Critical', 5),
('ORD-2014-001', '2014-06-10', '2014-06-15', 'Standard Class', 'Medium', 6),
('ORD-2014-002', '2014-07-22', '2014-07-25', 'Second Class', 'High', 7),
('ORD-2013-001', '2013-08-30', '2013-09-05', 'Standard Class', 'Low', 8),
('ORD-2013-002', '2013-09-15', '2013-09-18', 'First Class', 'Medium', 9),
('ORD-2012-001', '2012-10-01', '2012-10-08', 'Standard Class', 'Medium', 10);

-- ============================================================================
-- NS_ORDER_DETAIL (Sample 15 records)
-- ============================================================================
INSERT INTO NS_ORDER_DETAIL (QUANTITY, DISCOUNT, SALES, PROFIT, SHIPPING_COST, ORDER_ROW_ID, PRODUCT_ROW_ID) VALUES
(2, 0.00, 1999.98, 399.99, 25.00, 1, 1),
(1, 0.10, 899.99, 180.00, 15.00, 1, 5),
(3, 0.15, 2549.97, 382.50, 35.00, 2, 2),
(1, 0.00, 3500.00, 875.00, 100.00, 3, 3),
(5, 0.20, 39.95, 8.00, 5.00, 4, 8),
(10, 0.25, 74.90, -15.00, 10.00, 5, 9),
(1, 0.00, 1299.00, 324.75, 0.00, 5, 6),
(2, 0.05, 1899.98, 475.00, 50.00, 6, 4),
(1, 0.00, 899.00, 225.00, 45.00, 7, 7),
(20, 0.30, 69.80, -20.00, 8.00, 8, 8),
(3, 0.00, 149.97, 45.00, 12.00, 9, 10),
(1, 0.10,
