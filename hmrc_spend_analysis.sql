CREATE DATABASE SPEND_ANALYTICS;
USE SPEND_ANALYTICS

CREATE TABLE hmrc_spend (
Department VARCHAR(20),
Entity VARCHAR(20),
Dateon DATE,
ExpenseType VARCHAR(200),
ExpenseArea VARCHAR(200),
Supplier VARCHAR(200),
TransactionNumber BIGINT, 
Amount DECIMAL,
Description VARCHAR(400),
PostCode VARCHAR(50) 
)

DROP TABLE hmrc_spend 

CREATE TABLE hmrc_spend (
Department VARCHAR(20),
Entity VARCHAR(20),
TransactionDate DATE,
ExpenseType VARCHAR(200),
ExpenseArea VARCHAR(200),
Supplier VARCHAR(200),
TransactionNumber BIGINT, 
Amount DECIMAL,
Description VARCHAR(400),
PostCode VARCHAR(50) 
)

DROP TABLE hmrc_spend 

CREATE TABLE hmrc_spend (
Department VARCHAR(20),
Entity VARCHAR(20),
TransactionDate VARCHAR(20),
ExpenseType VARCHAR(200),
ExpenseArea VARCHAR(200),
Supplier VARCHAR(200),
TransactionNumber BIGINT, 
Amount DECIMAL,
Description VARCHAR(400),
PostCode VARCHAR(50) 
)

ALTER TABLE hmrc_spend MODIFY Amount VARCHAR(50)

DROP TABLE hmrc_spend 

CREATE TABLE hmrc_spend (
Department VARCHAR(20),
Entity VARCHAR(20),
TransactionDate VARCHAR(20),
ExpenseType VARCHAR(200),
ExpenseArea VARCHAR(200),
Supplier VARCHAR(200),
TransactionNumber BIGINT, 
Amount DECIMAL,
Description VARCHAR(400),
PostCode VARCHAR(50),
SupplierType VARCHAR(200),
ContractNumber VARCHAR(200),
ProjectCode VARCHAR(100) 
)

ALTER TABLE hmrc_spend
MODIFY Amount VARCHAR(50);

SELECT * FROM hmrc_spend

SELECT TransactionDate
FROM hmrc_spend
ORDER BY TransactionDate;

ALTER TABLE hmrc_spend
ADD CleanDate DATE;

SET SQL_SAFE_UPDATES = 0;

UPDATE hmrc_spend
SET CleanDate = str_to_date( REPLACE(TransactionDate,'-','/'),'%d/%m/%Y');

ALTER TABLE hmrc_spend
ADD CleanAmount Decimal(15,2);

UPDATE hmrc_spend
SET CleanAmount = cast(
replace(
replace(Amount,'£',''),
',','')
AS DECIMAL(15,2)
);

SELECT count(*)
AS MissingSuppliers
FROM hmrc_spend
WHERE Supplier IS NULL
OR trim(Supplier) = ''; 

SELECT *
FROM hmrc_spend
LIMIT 4080,10; 

SELECT Supplier, SUM(CleanAmount) AS TotalSpend
FROM hmrc_spend
WHERE CleanAmount IS NOT NULL
GROUP BY Supplier
ORDER BY TotalSpend DESC
LIMIT 10;

SELECT ExpenseType, SUM(CleanAmount) AS TotalSpend
FROM hmrc_spend
WHERE CleanAmount IS NOT NULL
GROUP BY ExpenseType
Order BY TotalSpend DESC
LIMIT 10; 

SELECT ExpenseArea, SUM(CleanAmount) AS TotalSpend
FROM hmrc_spend
WHERE CleanAmount IS NOT NULL
GROUP BY ExpenseArea
Order BY TotalSpend DESC
LIMIT 10;

SELECT month(CleanDate) AS MonthNo,
SUM(CleanAmount) AS MonthlySpend
FROM hmrc_spend
WHERE CleanAmount IS NOT NULL
GROUP BY Month(CleanDate) 
ORDER BY MonthlySpend DESC
LIMIT 10;

SELECT Supplier, SUM(CleanAmount) AS TotalSpend,
COUNT(*) AS TransactionsCount
FROM hmrc_spend
GROUP BY Supplier
ORDER BY TotalSpend DESC
LIMIT 10; 

SELECT Supplier, SUM(CleanAmount) AS TotalSpend,
RANK() OVER( ORDER BY SUM(CleanAmount) DESC) AS SupplierRank
FROM hmrc_spend
WHERE CleanAmount IS NOT NULL
GROUP BY Supplier; 

SELECT Supplier, SUM(CleanAmount) AS TotalSpend,
DENSE_RANK() OVER( ORDER BY SUM(CleanAmount) DESC) AS SupplierRank
FROM hmrc_spend
WHERE CleanAmount IS NOT NULL
GROUP BY Supplier;

SELECT ExpenseArea,
ExpenseType,
SUM(CleanAmount) AS TotalSpend,
RANK() OVER(PARTITION BY ExpenseArea ORDER BY SUM(CleanAmount) DESC) 
AS ExpenseRank
FROM hmrc_spend
WHERE CleanAmount IS NOT NULL
GROUP BY ExpenseArea, ExpenseType;


SELECT *
FROM (
SELECT 
ExpenseArea, Supplier, TransactionNumber, CleanAmount,

ROW_NUMBER() OVER( PARTITION BY ExpenseArea ORDER BY CleanAmount DESC) AS rn
FROM hmrc_spend
WHERE CleanAmount IS NOT NULL
) t
where rn =1;

SELECT 
Month(CleanDate) AS MonthNo,
SUM(CleanAmount) AS MonthlySpend,
SUM(SUM(CleanAmount))
OVER( ORDER BY Month(CleanDate)) AS RunningTotal
FROM hmrc_spend
WHERE CleanAmount IS NOT NULL
GROUP BY Month(CleanDate)
ORDER BY MonthNo;  

SELECT SUPPLIER, sum(CleanAmount) AS TotalSpend, (SUM(CleanAmount)/(SELECT SUM(CleanAmount) FROM hmrc_spend)*100 )AS PctOfTotal
FROM hmrc_spend
GROUP BY Supplier
ORDER BY TotalSpend DESC
LIMIT 3;   




