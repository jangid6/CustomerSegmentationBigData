USE [AdventureWorksDW2019]
GO

/****** Object:  View [dbo].[factview]    Script Date: 8/28/2023 1:03:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO













CREATE   view [dbo].[factview] AS (
SELECT
  MyOrders.SalesOrderNumber,
  DENSE_RANK() OVER(PARTITION BY cust.CustomerKey order by MyOrders.SalesOrderNumber asc) as CustOrderRank,
  ROW_NUMBER() OVER(PARTITION BY cust.CustomerKey order by MyOrders.SalesOrderNumber asc) as CRankOrderWise,
  CAST(MyOrders.CustomerKey AS INT) as CustKey,
  Product.EnglishProductName as ProductName,
  ProductSubCat.EnglishProductSubcategoryName as ProductSubcategoryName,
  ProductCat.EnglishProductCategoryName as ProductcategoryName,
  CAST(MyOrders.OrderQuantity AS INT) as OrderQuantity,
  ROUND(CAST(MyOrders.SalesAmount AS INT),2) as SalesAmount,
  ROUND(CAST((MyOrders.SalesAmount -  MyOrders.TotalProductCost) AS INT),2) as Margin,
  CONVERT(DATE, MyOrders.OrderDate) as OrderDate,
  FORMAT(OrderDate,'MMM') as MonthName,
  CONCAT('Q',Datepart(quarter,OrderDate)) as OrderQuarter,
  Datepart(quarter,OrderDate) as WeekNo,
  YEAR(OrderDate) as OrderYear,
  CONCAT(YEAR(OrderDate),'-',CONCAT('Q',Datepart(quarter,OrderDate))) as YYQQ,
  CONCAT(cust.FirstName,' ',cust.LastName) as CustomerName,
  cust.Gender as Gender,
  CONVERT(DATE, cust.Birthdate) as BirthDate,
  CONVERT(DATE, mindate.DFP) as DateFirstPurchase,
  FORMAT(DateFirstPurchase,'MMM') as CohortMonth,
  Year(mindate.DFP) as CohortYear,
  CONCAT(Year(mindate.DFP),'-',FORMAT(mindate.DFP,'MM'),'-',FORMAT(mindate.DFP,'MMM')) as CohortYYMM,
  CONCAT(YEAR(OrderDate),'-',FORMAT(OrderDate,'MM'),'-',FORMAT(OrderDate,'MMM')) as OrderYYMM,
  CONCAT(Year(CONVERT(Date,DATEADD(month, -1, OrderDate))),'-',FORMAT(CONVERT(Date,DATEADD(month, -1, OrderDate)),'MM'),'-',FORMAT(CONVERT(Date,DATEADD(month, -1, OrderDate)),'MMM')) as M1CohortYYMM,
  YEAR(GETDATE()) - YEAR(CAST(cust.Birthdate AS DATE)) as AGE,
  ROUND(CAST(cust.YearlyIncome AS INT),2) as YearlyIncome,
  CASE
      WHEN ROUND(CAST(cust.YearlyIncome AS INT),2) <= 40000 THEN 'LOW INCOME'
      WHEN ROUND(CAST(cust.YearlyIncome AS INT),2) <= 60000 THEN 'MODERATE INCOME'
      ELSE 'HIGH INCOME'
  END AS IncomeCategory,
  Geo.City as CustomerCity,
  SalesTerrority.SalesTerritoryCountry as SalesCountry,
  SalesTerrority.SalesTerritoryGroup as SalesRegion
  
FROM (
		SELECT *
		FROM [AdventureWorksDW2019].[dbo].[FactInternetSales] 
		where YEAR(OrderDate) >= 2013
	) as MyOrders
LEFT JOIN (SELECT 
	DISTINCT [CustomerKey],
	min(OrderDate) as DFP
	FROM [AdventureWorksDW2019].[dbo].[FactInternetSales]
	where YEAR(OrderDate) >= 2013
	GROUP BY [CustomerKey]
) mindate
ON MyOrders.CustomerKey  = mindate.CustomerKey
LEFT JOIN [dbo].[DimCustomer] Cust
ON MyOrders.CustomerKey  = Cust.CustomerKey
LEFT JOIN [dbo].[DimProduct] Product
ON MyOrders.ProductKey  = Product.ProductKey
LEFT JOIN [dbo].[DimProductSubcategory] ProductSubCat
ON Product.ProductSubcategoryKey  = ProductSubCat.ProductSubcategoryKey
LEFT JOIN [dbo].[DimProductCategory] ProductCat
ON ProductSubCat.ProductCategoryKey  = ProductCat.ProductCategoryKey
LEFT JOIN [dbo].DimSalesTerritory SalesTerrority
ON (MyOrders.SalesTerritoryKey = SalesTerrority.SalesTerritoryKey)
LEFT JOIN [dbo].DimGeography Geo
ON (Cust.GeographyKey = Geo.GeographyKey)
)
GO


