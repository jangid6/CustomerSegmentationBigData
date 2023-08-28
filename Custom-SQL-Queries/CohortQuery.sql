/****** Script for SelectTopNRows command from SSMS  ******/
--COHORT QUERY 
WITH RetentionQueryCohortMonthplus1 AS
(
	SELECT 
		CS.CohortYYMM as CohortMonthYear,
		CS.CohortMonthSize as CohortSize,
		CM1.CohortM1 as CohortSizeM1,
		CAST(CAST(CM1.CohortM1 AS DECIMAL(18,2))/CAST(CS.CohortMonthSize AS DECIMAL(7,2)) AS DECIMAL(18,2)) as M1Retention
	FROM		
			(
				SELECT 
					CohortYYMM,
					COUNT(distinct CustKey) as CohortMonthSize
				FROM [AdventureWorksDW2019].[dbo].[factview]
				GROUP by CohortYYMM
			) CS
   LEFT JOIN
			(
				SELECT 
					CohortYYMM,
					orderYYMM,
					COUNT(distinct CustKey) as CohortM1
				FROM [AdventureWorksDW2019].[dbo].[factview]
				WHERE CohortYYMM = M1CohortYYMM
				GROUP by CohortYYMM,orderYYMM
			) CM1
	ON (CS.CohortYYMM = CM1.CohortYYMM) 
)
SELECT * 
FROM RetentionQueryCohortMonthplus1 ORDER By CohortMonthYear



--SELECT 
--DISTINCT CustKey
--FROM [AdventureWorksDW2019].[dbo].[factview]
--WHERE CohortYYMM = '2013-01-Jan' AND orderYYMM   = '2013-02-Feb'


--SELECT 
--*
--FROM [AdventureWorksDW2019].[dbo].[factview] where [SalesOrderNumber] =  'SO53237' 