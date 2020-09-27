SELECT * FROM sqlbank3;


---SELECT, FROM, WHERE, GROUP BY, HAVING, ORDER BY, LIMIT
SELECT Quantity, COUNT(*) AS Quantity_Counts
FROM sqlbank3
WHERE UnitPrice >= 5
GROUP BY Quantity
HAVING Quantity_Counts < 450 
ORDER BY Quantity_Counts DESC
limit 10;


---1.AVG(), SUM()
SELECT InvoiceNo, 
       AVG(UnitPrice) OVER(PARTITION BY InvoiceNo) AS AvgUnitPrice, 
       SUM(Quantity) OVER(PARTITION BY InvoiceNo) TotalQuantity
FROM sqlbank3;


---2.AVG(), SUM(), COUNT(), MAX(), MIN()
SELECT InvoiceNo, StockCode, Description,UnitPrice,
       AVG(UnitPrice) OVER(PARTITION BY InvoiceNo) AS AvgUnitPrice, 
       SUM(Quantity) OVER(PARTITION BY InvoiceNo) AS TotalQuantity,
       COUNT(StockCode) OVER(PARTITION BY InvoiceNo) AS Number_Of_Items_Per_Invoice,
       MAX(UnitPrice) OVER(PARTITION BY InvoiceNo) AS Max_UnitPrice_Per_Invoice,
       MIN(UnitPrice) OVER(PARTITION BY InvoiceNo) AS Min_UnitPrice_Per_Invoice     
FROM sqlbank3;


---3.ROW_NUMBER()
SELECT InvoiceNo, StockCode, Description, UnitPrice,
        ROW_NUMBER() OVER(PARTITION BY InvoiceNo ORDER BY UnitPrice DESC ,StockCode DESC) AS Rank_of_UnitPrice_Per_Invoice,
        COUNT(StockCode) OVER(PARTITION BY InvoiceNo) AS Number_Of_Items
FROM sqlbank3;


---4.ROW_NUMBER() (Top Five)
WITH CTE AS (
        SELECT InvoiceNo, StockCode, Description,UnitPrice,
        ROW_NUMBER() OVER(PARTITION BY InvoiceNo ORDER BY UnitPrice DESC ,StockCode DESC) AS Rank_of_UnitPrice_Per_Invoice
FROM sqlbank3)
SELECT * FROM CTE
WHERE Rank_of_UnitPrice_Per_Invoice <= 5;


---5.ROW_NUMBER(), RANK(), DENSE_RANK()
SELECT InvoiceNo, StockCode, Description, UnitPrice,
        ROW_NUMBER() OVER(PARTITION BY InvoiceNo ORDER BY UnitPrice DESC) AS RowNumber_of_UnitPrice_Per_Invoice,
        RANK() OVER(PARTITION BY InvoiceNo ORDER BY UnitPrice DESC) AS Rank_of_UnitPrice_Per_Invoice, 
        DENSE_RANK() OVER(PARTITION BY InvoiceNo ORDER BY UnitPrice DESC) AS DenseRank_of_UnitPrice_Per_Invoice,
        AVG(UnitPrice) OVER(PARTITION BY InvoiceNo) AS AvgUnitPrice, 
        COUNT(StockCode) OVER(PARTITION BY InvoiceNo) AS Number_Of_Items
FROM sqlbank3;


---6.NTILE()
WITH CTE AS (
SELECT CustomerID, SUM(Revenue) AS TOTAL_REVENUE
FROM sqlbank3
GROUP BY CustomerID
ORDER BY CustomerID,TOTAL_REVENUE
)
SELECT CustomerID, TOTAL_REVENUE,
        NTILE(4) OVER(ORDER BY TOTAL_REVENUE) AS REVENUE_QUARTILES
FROM CTE;


---7.PERCENT_RANK(), CUME_DIST()
SELECT InvoiceNo, StockCode, Description, UnitPrice,
        RANK() OVER(PARTITION BY InvoiceNo ORDER BY UnitPrice DESC) AS Rank_of_UnitPrice_Per_Invoice, 
        COUNT(StockCode) OVER(PARTITION BY InvoiceNo) AS Number_Of_Items,
        PERCENT_RANK() OVER(PARTITION BY InvoiceNo ORDER BY UnitPrice DESC) * 100  AS Percent_Rank,
        CUME_DIST() OVER(PARTITION BY InvoiceNo ORDER BY UnitPrice DESC) AS Cume_Dist
FROM sqlbank3;


---8.LAG(), LEAD()
SELECT CustomerID, date_trunc('MONTH', InvoiceDate) AS Month, SUM(Revenue) AS Monthly_Revenue,
        LAG(Monthly_Revenue, 1) OVER (PARTITION BY CustomerID ORDER BY Month) AS Previous_Month_Revenue,
        LEAD(Monthly_Revenue, 1) OVER (PARTITION BY CustomerID ORDER BY Month) AS Next_Month_Revenue
FROM sqlbank3
GROUP BY CustomerID, Month
ORDER BY CustomerID, Month;


---9.PARTITION BY (RUNNING TOTAL)
WITH CTE AS (
SELECT CustomerID, date_trunc('MONTH', InvoiceDate) AS Month, SUM(Revenue) AS Monthly_Revenue
FROM sqlbank3
GROUP BY CustomerID, Month
ORDER BY CustomerID, Month
)
SELECT
        CustomerID, Month, Monthly_Revenue,
        SUM(Monthly_Revenue) OVER (PARTITION BY CustomerID ORDER BY Month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RUNNING_TOTAL_REVENUE_PER_CUSTOMER
FROM CTE
ORDER BY CustomerID, Month;
