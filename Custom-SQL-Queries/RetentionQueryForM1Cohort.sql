/****** Script for SelectTopNRows command from SSMS  ******/
--RETENTION COHORT QUERY 
WITH 
CTE1_RetentionQueryCohortSize AS
(
	SELECT 
		CohortYYMM,
		COUNT(distinct CustKey) as CohortMonthSize
	FROM [AdventureWorksDW2019].[dbo].[factview]
	GROUP by CohortYYMM
),
CTE2_RetentionQueryCohortSizeM1 AS
(
	SELECT 
		CohortYYMM,
		orderYYMM,
		COUNT(distinct CustKey) as CohortM1
	FROM [AdventureWorksDW2019].[dbo].[factview]
	WHERE CohortYYMM = CONCAT(
							Year(CONVERT(Date,DATEADD(month, -1, OrderDate))),
							'-',FORMAT(CONVERT(Date,DATEADD(month, -1, OrderDate)),'MM'),
							'-',FORMAT(CONVERT(Date,DATEADD(month, -1, OrderDate)),'MMM')
							)
	GROUP by CohortYYMM,orderYYMM
)

SELECT 
		CTE1.CohortYYMM as CohortMMYY,
		CTE2.orderYYMM as SalesOrderMMYY,
		CTE1.CohortMonthSize as CohortSize,
		CTE2.CohortM1 as CohortSizeM1,
		CAST(CAST(CTE2.CohortM1 AS DECIMAL(18,2))/CAST(CTE1.CohortMonthSize AS DECIMAL(7,2)) 
			AS DECIMAL(18,4)) as M1Retention
FROM CTE1_RetentionQueryCohortSize CTE1
LEFT JOIN CTE2_RetentionQueryCohortSizeM1 CTE2
ON (CTE1.CohortYYMM = CTE2.CohortYYMM)
ORDER BY CTE1.CohortYYMM


