-- Problem 2

SELECT [FirstName], [LastName]
FROM Employees
WHERE [LastName] LIKE '%ei%'


-- Problem 3

SELECT [FirstName]
FROM Employees
WHERE [DepartmentID] IN (3,10) AND  Year ([HireDate]) BETWEEN 1995 and 2005


-- Problem 4

SELECT [FirstName], [LastName]
FROM Employees
WHERE [JobTitle] NOT LIKE '%engineer%'


-- Problem 5

  SELECT [Name]
    From [Towns]
   WHERE LEN([Name]) IN (5,6)
ORDER BY [Name]


-- Problem 6


  SELECT [TownID],[Name]
    From [Towns]
   WHERE LEFT([Name], 1) IN ('M', 'K', 'B', 'E')
ORDER BY [Name]


-- Problem 7


  SELECT [TownID],[Name]
    From [Towns]
   WHERE LEFT([Name], 1) NOT IN ('R', 'B', 'D')
ORDER BY [Name]

-- Problem 8

GO 

CREATE VIEW V_EmployeesHiredAfter2000  
AS  
SELECT [FirstName], [LastName]
FROM Employees
WHERE YEAR([HireDate]) > 2000

GO

-- Problem 9

SELECT [FirstName], [LastName]
FROM Employees
WHERE LEN([LastName]) = 5


-- Problem 10


SELECT [EmployeeID],[FirstName], [LastName], [Salary],
DENSE_RANK () OVER (PARTITION BY [Salary] ORDER BY EmployeeID)
FROM Employees
WHERE Salary BETWEEN 10000 AND 50000
ORDER BY Salary DESC


-- Problem 11


   SELECT * 
     FROM
      
	  (
    SELECT [EmployeeID],[FirstName], [LastName], [Salary],
DENSE_RANK () OVER (PARTITION BY [Salary] ORDER BY EmployeeID) AS [Rank]
	  FROM Employees
	 WHERE Salary BETWEEN 10000 AND 50000 
      ) AS [RankingQuery]

 	WHERE [Rank] = 2
 ORDER BY Salary DESC


 -- Problem 12

 SELECT [CountryName],[IsoCode]
 FROM Countries
 WHERE [CountryName] LIKE '%a%a%a%'
 ORDER BY [IsoCode]

-- Problem 13

SELECT [p].[PeakName], [r].[RiverName],
LOWER(CONCAT([p].[PeakName], SUBSTRING([r].[RiverName], 2, LEN([r].[RiverName])))) AS [Mix]
FROM [Rivers] AS [r], [Peaks] AS [p]
WHERE RIGHT(p.PeakName, 1) = LEFT(r.RiverName, 1)
ORDER BY [Mix]

-- Problem 14

SELECT TOP(50)  [Name], [Start]
FROM Games
WHERE YEAR(Start) IN (2011,2012) -- проблем с формата
ORDER BY [Start], [Name]


-- Problem 15

SELECT [UserName],
SUBSTRING([Email] , CHARINDEX('@', [Email]) +1, LEN([Email])) AS [EmailProvider]
FROM Users
ORDER BY [EmailProvider], [UserName]

-- Problem 16

  SELECT [UserName], [IpAddress]
    FROM [Users]
   WHERE [IpAddress] LIKE '___.1%.%.___'
ORDER BY [Username]