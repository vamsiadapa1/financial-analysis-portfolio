-- Creates staging tables for a raw ERP export and master data
IF OBJECT_ID('stg_RawTransactions') IS NOT NULL DROP TABLE stg_RawTransactions;
CREATE TABLE stg_RawTransactions (
  TransactionID INT,
  PostingDateRaw VARCHAR(50),   -- mixed formats
  CostCenterRaw  VARCHAR(50),
  Debit DECIMAL(18,2) NULL,
  Credit DECIMAL(18,2) NULL,
  ProductCodeRaw VARCHAR(100),    -- 'PR-001', 'pr001 ', 'Prod001'
  RegionRaw VARCHAR(100),         -- 'north ', 'SOUTH', NULL
  Status VARCHAR(20)                   -- 'Posted', 'Pending', etc.

);

IF OBJECT_ID('dim_Products') IS NOT NULL DROP TABLE dim_Products;
CREATE TABLE dim_Products (
  ProductKey INT IDENTITY(1,1) PRIMARY KEY,
  ProductCode VARCHAR(50) UNIQUE,
  ProductName VARCHAR(200)
);

IF OBJECT_ID('dim_Regions') IS NOT NULL DROP TABLE dim_Regions;
CREATE TABLE dim_Regions (
  RegionKey INT IDENTITY(1,1) PRIMARY KEY,
  RegionName VARCHAR(100) UNIQUE
);

INSERT INTO dim_Products(ProductCode, ProductName)
VALUES ('PR001','Widget A'),('PR002','Widget B'),('PR003','Widget C');

INSERT INTO dim_Regions(RegionName) VALUES ('NORTH'),('SOUTH'),('EAST'),('WEST');
