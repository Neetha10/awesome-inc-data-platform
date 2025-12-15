# Awesome Inc. – Universal Sales & Returns Data Platform

[![MySQL](https://img.shields.io/badge/MySQL-8.0+-blue.svg)](https://www.mysql.com/)
[![Oracle](https://img.shields.io/badge/Oracle-Autonomous%20DB-red.svg)](https://www.oracle.com/autonomous-database/)
[![Tableau](https://img.shields.io/badge/Tableau-2024-orange.svg)](https://www.tableau.com/)
[![WEKA](https://img.shields.io/badge/WEKA-3.8-green.svg)](https://www.cs.waikato.ac.nz/ml/weka/)

This repository contains the **implementation artifacts** for my capstone project completed as part of **ECE-GY-9941: Advanced Projects** at **NYU Tandon School of Engineering**.

---

## 📊 Project Metrics

| Metric | Value |
|--------|-------|
| **Total Orders** | 51,290 |
| **Total Customers** | 17,415 |
| **Total Products** | 3,788 |
| **Total Returns** | 1,079 |
| **OLTP Tables** | 9 (3NF Normalized) |
| **DW Tables** | 5 (Star Schema) |
| **Revenue Growth** | $2.26M → $4.29M (2012-2015) |
| **ML Accuracy** | 92.15% (Random Forest) |

---

## 🏗️ System Architecture

**OLTP Layer (MySQL)**
- Fully normalized schema (3NF)
- 9 tables with enforced PK/FK constraints
- Handles orders, customers, products, and returns

**Data Warehouse Layer (Oracle Autonomous DB)**
- Star schema design optimized for analytics
- Dimension tables: DIM_DATE, DIM_NS_CUSTOMER, DIM_NS_PRODUCT
- Fact tables: FACT_NS_ORDER_DETAIL, FACT_NS_RETURN

**ETL Layer**
- Oracle external tables for CSV extraction via DBMS_CLOUD
- Staging tables for cleansing and transformation
- PL/SQL MERGE procedures for incremental loads
- CDC using TBL_LAST_DT timestamps

---

## 📁 Repository Structure
```text
awesome-inc-data-platform/
│
├── README.md
│
├── oltp/
│   ├── ddl/
│   │   └── 01_create_tables.sql
│   ├── constraints/
│   │   └── 02_constraints.sql
│   ├── dml/
│   │   └── 03_sample_inserts.sql
│   └── queries/
│       └── 04_validation_queries.sql
│
├── dw/
│   ├── ddl/
│   │   ├── 01_dim_tables.sql
│   │   └── 02_fact_tables.sql
│   ├── etl/
│   │   ├── 01_external_tables.sql
│   │   ├── 02_staging_tables.sql
│   │   └── 03_merge_procedures.sql
│   └── analytics/
│       └── 01_analytical_queries.sql
│
├── ml/
│   └── weka/
│       └── results_summary.md
│
└── docs/
    ├── architecture.md
    └── data_dictionary.md
```

---

## 🛠️ Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| OLTP Database | MySQL 8.0+ | Transaction processing |
| Data Warehouse | Oracle Autonomous DB | Analytics & reporting |
| ETL | PL/SQL, DBMS_CLOUD | Data integration |
| Visualization | Tableau Desktop 2024 | Dashboards & reports |
| Machine Learning | WEKA 3.8 | Predictive analytics |

---

## 👤 Author

**Neethu Satravada**
- NYU Tandon School of Engineering
- MS Computer Engineering
- NetID: NS6411

---

## 📄 License

This project is submitted as part of ECE-GY-9941 coursework at NYU Tandon School of Engineering.
