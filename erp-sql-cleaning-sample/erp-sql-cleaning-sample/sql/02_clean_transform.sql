IF OBJECT_ID('vw_CleanedTransactions') IS NOT NULL DROP VIEW vw_CleanedTransactions;
GO
CREATE VIEW vw_CleanedTransactions AS
WITH parsed_dates AS (
  SELECT
    TransactionID,
    PostingDateRaw,
    COALESCE(
      TRY_CONVERT(date, PostingDateRaw, 120), -- YYYY-MM-DD
      TRY_CONVERT(date, PostingDateRaw, 103), -- DD/MM/YYYY
      TRY_CONVERT(date, PostingDateRaw, 101)  -- MM/DD/YYYY
    ) AS PostingDate,
    CostCenterRaw, Debit, Credit, ProductCodeRaw, RegionRaw, Status
  FROM stg_RawTransactions
),
merged_amount AS (
  SELECT
    TransactionID,
    PostingDate,
    UPPER(REPLACE(REPLACE(REPLACE(CostCenterRaw,'-',''),'_',''),' ','')) AS CostCenter,
    COALESCE(Debit,0) - COALESCE(Credit,0) AS Amount,
    UPPER(REPLACE(REPLACE(LTRIM(RTRIM(ProductCodeRaw)),'PROD',''),' ','')) AS ProductCode,
    COALESCE(UPPER(LTRIM(RTRIM(RegionRaw))),'UNKNOWN') AS Region,
    Status
  FROM parsed_dates
)
SELECT
  TransactionID,
  PostingDate,
  CostCenter,
  Amount,
  CASE
    WHEN ProductCode LIKE 'PR-%' THEN REPLACE(ProductCode,'PR-','PR')
    WHEN ProductCode LIKE 'PR %' THEN REPLACE(ProductCode,'PR ','PR')
    ELSE ProductCode
  END AS ProductCode,
  CASE WHEN Region IN ('NORTH','SOUTH','EAST','WEST') THEN Region ELSE 'UNKNOWN' END AS Region
FROM merged_amount
WHERE Status='Posted' AND PostingDate IS NOT NULL;
GO
