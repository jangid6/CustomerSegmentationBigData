
 /****** Script for SelectTopNRows command from SSMS  ******/
--COHORT QUERY 
WITH RetentionQueryCohortMonthplus2 AS
(
	SELECT 
		CS.CohortYYMM as CohortMonthYear,
		CS.CohortMonthSize as CohortSize,
		CM1.CohortM2 as CohortSizeM2,
		CAST(CAST(CM1.CohortM2 AS DECIMAL(18,2))/CAST(CS.CohortMonthSize AS DECIMAL(7,2)) AS DECIMAL(18,2)) as M2Retention
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
					COUNT(distinct CustKey) as CohortM2
				FROM [AdventureWorksDW2019].[dbo].[factview]
				WHERE CohortYYMM = CONCAT(Year(CONVERT(Date,DATEADD(month, -2, OrderDate))),'-',FORMAT(CONVERT(Date,DATEADD(month, -2, OrderDate)),'MM'),'-',FORMAT(CONVERT(Date,DATEADD(month, -2, OrderDate)),'MMM'))
				GROUP by CohortYYMM,orderYYMM
			) CM1
	ON (CS.CohortYYMM = CM1.CohortYYMM) 
)
SELECT * 
FROM RetentionQueryCohortMonthplus2 ORDER By CohortMonthYear