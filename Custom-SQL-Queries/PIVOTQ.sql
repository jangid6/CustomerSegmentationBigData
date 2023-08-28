SELECT 
	SalesCountry,M,F,M+F As TotalSales
FROM 
(
	SELECT 
		f.SalesCountry,
		f.Gender,
		sum(f.SalesAmount) as TotalSales
	FROM [AdventureWorksDW2019].[dbo].[factview] f
	GROUP BY f.SalesCountry,f.Gender
) t
PIVOT(
	SUM(TotalSales) FOR Gender IN (M,F)
) as P
ORDER BY M+F Desc
	

