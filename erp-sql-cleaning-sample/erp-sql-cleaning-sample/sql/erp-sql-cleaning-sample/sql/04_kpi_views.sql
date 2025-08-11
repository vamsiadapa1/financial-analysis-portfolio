IF OBJECT_ID('vw_KPI_MonthlyTotals') IS NOT NULL DROP VIEW vw_KPI_MonthlyTotals;
GO
CREATE VIEW vw_KPI_MonthlyTotals AS
SELECT
  MonthStart,
  SUM(TotalAmount) AS TotalAmount,
  AVG(SUM(TotalAmount)) OVER (
    ORDER BY MonthStart ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ) AS Rolling3MoAvg
FROM fact_Profitability
GROUP BY MonthStart;
GO

IF OBJECT_ID('vw_KPI_ProductRegion') IS NOT NULL DROP VIEW vw_KPI_ProductRegion;
GO
CREATE VIEW vw_KPI_ProductRegion AS
SELECT MonthStart, ProductCode, Region, SUM(TotalAmount) AS TotalAmount
FROM fact_Profitability
GROUP BY MonthStart, ProductCode, Region;
GO

IF OBJECT_ID('vw_KPI_CostCenterYoY') IS NOT NULL DROP VIEW vw_KPI_CostCenterYoY;
GO
CREATE VIEW vw_KPI_CostCenterYoY AS
WITH m AS (
  SELECT CostCenter, MonthStart, SUM(TotalAmount) AS TotalAmount
  FROM fact_Profitability
  GROUP BY CostCenter, MonthStart
)
SELECT
  CostCenter,
  MonthStart,
  TotalAmount,
  LAG(TotalAmount,12) OVER (PARTITION BY CostCenter ORDER BY MonthStart) AS TotalAmount_PriorYear,
  CASE WHEN LAG(TotalAmount,12) OVER (PARTITION BY CostCenter ORDER BY MonthStart) IN (NULL,0)
       THEN NULL
       ELSE ROUND(
         (TotalAmount - LAG(TotalAmount,12) OVER (PARTITION BY CostCenter ORDER BY MonthStart))
         / NULLIF(LAG(TotalAmount,12) OVER (PARTITION BY CostCenter ORDER BY MonthStart),0) * 100.0, 2)
  END AS YoY_GrowthPct
FROM m;
GO
