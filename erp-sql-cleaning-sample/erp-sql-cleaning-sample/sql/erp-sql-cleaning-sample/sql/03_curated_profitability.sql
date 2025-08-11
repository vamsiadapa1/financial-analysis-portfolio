IF OBJECT_ID('fact_Profitability') IS NOT NULL DROP TABLE fact_Profitability;
CREATE TABLE fact_Profitability(
  CostCenter VARCHAR(50),
  MonthStart DATE,
  ProductCode VARCHAR(50),
  Region VARCHAR(100),
  TotalAmount DECIMAL(18,2),
  PRIMARY KEY (CostCenter, MonthStart, ProductCode, Region)
);

WITH x AS (
  SELECT
    c.CostCenter,
    DATEFROMPARTS(YEAR(c.PostingDate), MONTH(c.PostingDate), 1) AS MonthStart,
    COALESCE(p.ProductCode, REPLACE(c.ProductCode,'-','')) AS ProductCode,
    COALESCE(r.RegionName, c.Region) AS Region,
    c.Amount
  FROM vw_CleanedTransactions c
  LEFT JOIN dim_Products p ON p.ProductCode = REPLACE(c.ProductCode,'-','')
  LEFT JOIN dim_Regions r ON r.RegionName = c.Region
)
INSERT INTO fact_Profitability(CostCenter,MonthStart,ProductCode,Region,TotalAmount)
SELECT CostCenter, MonthStart, ProductCode, Region, SUM(Amount)
FROM x
GROUP BY CostCenter, MonthStart, ProductCode, Region;

