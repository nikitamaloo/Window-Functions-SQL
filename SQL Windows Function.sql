select * from sqlbank3;


---SELECT, FROM, WHERE, GROUP BY, HAVING, ORDER BY, LIMIT
select Quantity, count(*) as Quantity_Counts
from sqlbank3
where UnitPrice >= 5
group by Quantity
having Quantity_Counts < 450 
order by Quantity_Counts desc
limit 10;


----1.PARTITION BY CLAUSE (AVG, SUM)
SELECT InvoiceNo, 
       AVG(UnitPrice) OVER(PARTITION BY InvoiceNo) AS AvgUnitPrice, 
       SUM(Quantity) OVER(PARTITION BY InvoiceNo) TotalQuantity
FROM sqlbank3;


----2.PARTITION BY CLUSE (AVG, SUM, COUNT, MAX, MIN)
SELECT InvoiceNo, StockCode, Description,UnitPrice,
       AVG(UnitPrice) OVER(PARTITION BY InvoiceNo) AS AvgUnitPrice, 
       SUM(Quantity) OVER(PARTITION BY InvoiceNo) TotalQuantity,
       COUNT(StockCode) OVER(PARTITION BY InvoiceNo) AS Number_Of_Items_Per_Invoice,
       MAX(UnitPrice) OVER(PARTITION BY InvoiceNo) AS Max_UnitPrice_Per_Invoice,
       MIN(UnitPrice) OVER(PARTITION BY InvoiceNo) AS Min_UnitPrice_Per_Invoice     
FROM sqlbank3;


----3.PARTITION BY CLAUSE (ROW_NUMBER)
SELECT InvoiceNo, StockCode, Description, UnitPrice,
        ROW_NUMBER() OVER(PARTITION BY InvoiceNo ORDER BY UnitPrice Desc ,StockCode DESC) AS Rank_of_UnitPrice_Per_Invoice ,   
        COUNT(StockCode) OVER(PARTITION BY InvoiceNo) AS Number_Of_Items
FROM sqlbank3;


----4.PARTITION BY ROW_NUMBER (Top Five)
WITH CTE AS (
SELECT InvoiceNo, StockCode, Description,UnitPrice,  
        ROW_NUMBER() OVER(PARTITION BY InvoiceNo ORDER BY UnitPrice Desc ,StockCode DESC) AS Rank_of_UnitPrice_Per_Invoice 
FROM sqlbank3)
SELECT * FROM CTE
WHERE Rank_of_UnitPrice_Per_Invoice <= 5;


----5.PARTITION BY ROW_NUMBER, RANK and DENSE_RANK
SELECT InvoiceNo, StockCode, Description, UnitPrice,
ROW_NUMBER() OVER(PARTITION BY InvoiceNo ORDER BY UnitPrice Desc) AS RowNumber_of_UnitPrice_Per_Invoice , 
RANK() OVER(PARTITION BY InvoiceNo ORDER BY UnitPrice Desc) AS Rank_of_UnitPrice_Per_Invoice , 
DENSE_RANK() OVER(PARTITION BY InvoiceNo ORDER BY UnitPrice Desc) AS DenseRank_of_UnitPrice_Per_Invoice,
AVG(UnitPrice) OVER(PARTITION BY InvoiceNo) AS AvgUnitPrice, 
COUNT(StockCode) OVER(PARTITION BY InvoiceNo) AS Number_Of_Items
FROM sqlbank3;


--6.PARTITION BY LAG AND LEAD
SELECT CustomerID, date_trunc('MONTH', InvoiceDate) AS Month, sum(Revenue) AS Monthly_Revenue,
LAG(Monthly_Revenue, 1) OVER (PARTITION BY CustomerID ORDER BY Month) AS Previous_Month_Revenue,
LEAD(Monthly_Revenue, 1) OVER (PARTITION BY CustomerID ORDER BY Month) AS Next_Month_Revenue
from sqlbank3
group by CustomerID, Month
order by CustomerID, Month;


--7.PARTITION BY RUNNING TOTAL
with CTE as (
SELECT CustomerID, 
date_trunc('MONTH', InvoiceDate) AS Month, 
sum(Revenue) AS Monthly_Revenue
from sqlbank3
group by CustomerID, Month
order by CustomerID, Month
)
select
  CustomerID, Month, Monthly_Revenue,
  sum(Monthly_Revenue) over (partition by CustomerID order by Month asc ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RUNNING_TOTAL_REVENUE_PER_CUSTOMER
from CTE
order by CustomerID, Month;


--8.NTILE
with CTE as (
SELECT CustomerID, SUM(Revenue) AS TOTAL_REVENUE
from sqlbank3
group by CustomerID
order by CustomerID,TOTAL_REVENUE
)
SELECT CustomerID, TOTAL_REVENUE,
NTILE(4) OVER(ORDER BY TOTAL_REVENUE) AS EVENUE_QUARTILES
from CTE