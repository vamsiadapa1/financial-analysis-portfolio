
-- Retail Sales & Profit Analysis SQL Project
-- Author: Vamsi Krishna Adapa

-- 1. Total Revenue, Expenses, and Profit by Department and Quarter
SELECT 
    Department,
    Quarter,
    SUM(Revenue) AS Total_Revenue,
    SUM(Expenses) AS Total_Expenses,
    SUM(Revenue - Expenses) AS Total_Profit
FROM mock_financial_data
GROUP BY Department, Quarter
ORDER BY Department, Quarter;

-- 2. Profit Margin Categories using CASE WHEN
SELECT 
    TransactionID,
    Department,
    Revenue,
    Expenses,
    ROUND(((Revenue - Expenses) / Revenue) * 100, 2) AS ProfitMargin,
    CASE 
        WHEN ((Revenue - Expenses) / Revenue) * 100 >= 25 THEN 'High'
        WHEN ((Revenue - Expenses) / Revenue) * 100 BETWEEN 10 AND 25 THEN 'Medium'
        ELSE 'Low'
    END AS Profit_Category
FROM mock_financial_data;

-- 3. Ranking Departments by Quarterly Profit using Window Functions
SELECT 
    Department,
    Quarter,
    SUM(Revenue - Expenses) AS Total_Profit,
    RANK() OVER(PARTITION BY Quarter ORDER BY SUM(Revenue - Expenses) DESC) AS Profit_Rank
FROM mock_financial_data
GROUP BY Department, Quarter
ORDER BY Quarter, Profit_Rank;
