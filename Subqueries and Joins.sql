-- 01. Employee Address

SELECT TOP(5) [EmployeeID], [JobTitle], [e].[AddressID], [ad].[AddressText]
FROM [Employees]  AS [e]
LEFT JOIN [Addresses] AS [ad]
ON [e].AddressID = [ad].AddressID
ORDER BY [ad].AddressID

-- 2. Addresses with Towns

SELECT TOP(50) [FirstName], [LastName], [t].[Name], [AddressText]
FROM [Employees] AS [e]
INNER JOIN [Addresses] AS [ad]
ON [e].AddressID = [ad].AddressID
INNER JOIN [Towns] as [t]
ON [t].TownID = ad.TownID
ORDER BY [FirstName], [LastName]

-- 3. Sales Employee

    SELECT [EmployeeID], [FirstName], [LastName], [d].[Name]
	  FROM [Employees] AS [e]
INNER JOIN [Departments] AS [d]
        ON [e].DepartmentID = [d].DepartmentID
     WHERE [d].Name = 'Sales'
  ORDER BY [e].EmployeeID

-- 4. Employee Departments

SELECT TOP (5) [EmployeeID], [FirstName], [Salary], [d].[Name]
      FROM [Employees] AS [e]
INNER JOIN [Departments] AS [d]
        ON [e].DepartmentID = [d].DepartmentID
	 WHERE [e].[Salary] > 15000
  ORDER BY [d].DepartmentID

-- 5. Employees Without Project

SELECT TOP(3) [e].[EmployeeID], [e].[FirstName]
 FROM [Employees] AS [e]
 LEFT JOIN [EmployeesProjects] AS [ep]
 ON e.EmployeeID = ep.EmployeeID
 WHERE ep.ProjectID IS NULL

-- 6. Employees Hired After

 
    SELECT [FirstName], [LastName], [HireDate], [d].[Name]
      FROM [Employees] AS [e]
INNER JOIN [Departments] AS [d]
        ON [e].DepartmentID = [d].DepartmentID
	 WHERE [HireDate] > '1/1/1999' AND [d].[Name] IN ('Sales', 'Finance')
  ORDER BY [HireDate]


-- 7. Employees with Project

  SELECT TOP (5) [e].[EmployeeID], [e].[FirstName], [p].[Name]
        FROM [Employees] AS [e]
   LEFT JOIN [EmployeesProjects] AS [ep]
          ON e.EmployeeID = ep.EmployeeID
   LEFT JOIN [Projects] AS [p]
          ON [ep].ProjectID = [p].[ProjectID]
       WHERE  [p].StartDate > '08/13/2002' AND [p].[EndDate] IS NULL
	ORDER BY [e].[EmployeeID]


-- 8. Employee 24


	  SELECT [e].[EmployeeID], [e].[FirstName], [p].[Name] AS [ProjectName]
	    FROM [Employees] AS [e]
	    FULL OUTER JOIN [EmployeesProjects] AS [ep]
          ON e.EmployeeID = ep.EmployeeID
   FULL OUTER JOIN [Projects] AS [p]
          ON [ep].ProjectID = [p].[ProjectID]
       WHERE  [e].[EmployeeID] = 24 AND [p].[StartDate] >= YEAR(2005) 

-- 9. Employee Manager


  SELECT [e].[EmployeeID], [e].[FirstName], [m].[EmployeeID] AS [ManagerID], [m].[FirstName] as [ManagerName]
	    FROM [Employees] AS [e]
		INNER JOIN [Employees] as [m]
		ON [e].[ManagerID] = [m].[EmployeeID]
	WHERE [m].[EmployeeID] IN (3,7)
	ORDER BY [e].[EmployeeID] ASC


-- 10. Employee Summary      SELECT TOP (50) [e].[EmployeeID], 
	      CONCAT(e.FirstName,' ',  e.LastName) AS [EmployeeName],
	      CONCAT(m.FirstName,' ',  m.LastName) AS [ManagerName],
	        [dp].[Name] AS [DepartmentName]
	        FROM [Employees] AS [e]
	  LEFT JOIN [Employees] AS [m]
			  ON [e].[ManagerID] = [m].[EmployeeID]
	  LEFT JOIN [Departments] AS [d]
			  ON [e].ManagerID = [d].[ManagerID]
	  LEFT JOIN [Departments] AS [dp]
		      ON e.DepartmentID = dp.DepartmentID
		  
		ORDER BY [e].[EmployeeID]

-- 11. Min Average Salary
SELECT TOP(1) * FROM(
Select [Salary] AS [MinAvarageSalary],
DENSE_RANK() OVER (PARTITION BY [d].[Name] ORDER BY AVG([Salary])) AS [SalaryDepartment]
FROM [Employees] as [e]
LEFT JOIN [Departments] [d]
ON [e].DepartmentID = [d].[DepartmentID]
GROUP BY d.Name
) AS [RANKING]

ORDER BY ranking.SalaryDepartment


-- 12. Highest Peaks in Bulgaria


    SELECT [mc].[CountryCode], [m].[MountainRange], [p].[PeakName], [p].[Elevation]
      FROM [Peaks] AS [p]
INNER JOIN [Mountains] AS [m]
	    ON [p].MountainId = [m].Id
INNER JOIN [MountainsCountries] AS [mc]
        ON [mc].MountainId = [m].Id
     WHERE [mc].CountryCode = 'BG' AND [p].Elevation > 2835
  ORDER BY [p].[Elevation] DESC

  -- 13. Count Mountain Ranges
 
	 SELECT [mc].[CountryCode], COUNT([m].MountainRange) AS [MountainRange]
	   FROM [Countries] AS [c]
  LEFT JOIN [MountainsCountries] AS [mc]
	     ON [c].[CountryCode] = [mc].[CountryCode]
 INNER JOIN [Mountains] AS [m]
         ON [m].[Id] = [mc].[MountainId]
      WHERE [mc].[CountryCode] IN ('BG', 'US', 'RU')
   GROUP BY  [mc].[CountryCode]


 -- 14. Countries with Rivers

SELECT TOP(5)[c].[CountryName], [r].RiverName
	  FROM [Countries] AS [c]
 LEFT JOIN [CountriesRivers] AS [cr]
	    ON [c].[CountryCode] = [cr].[CountryCode]
 LEFT JOIN [Rivers] AS [r]
	    ON [r].[Id] = [cr].[RiverId]
     WHERE [c].[ContinentCode] = 'AF'
  ORDER BY [c].[CountryName] 

  -- 15. *Continents and Currencies
      SELECT [ContinentCode],  [CurrencyCode], [CurrencyUsage]
        FROM 
             (
			   SELECT *,
			   DENSE_RANK() OVER(PARTITION BY [ContinentCode] ORDER BY [CurrencyUsage] DESC) AS [Ranking]
			  
		 FROM
			 (
				   SELECT [co].[ContinentCode], [c].[CurrencyCode],
				    COUNT([c].[CurrencyCode]) AS [CurrencyUsage]
					 
					 FROM [Continents] AS [co]
			   INNER JOIN [Countries] AS [c]
			           ON [c].[ContinentCode] = [co].[ContinentCode]

				 GROUP BY [co].[ContinentCode], [c].[CurrencyCode]

			 ) AS [CurrencyQuery]

	   WHERE [CurrencyUsage] > 1

			 ) AS [RankingQuery]

	   WHERE [Ranking] = 1
	ORDER BY [ContinentCode]

--16. Countries Without Any Mountains -- 

SELECT SUM(mc.MountainId) AS [Countriesss]
  FROM Countries AS [c]
LEFT JOIN [MountainsCountries] AS [mc]
	   ON mc.CountryCode = c.CountryCode
LEFT JOIN [Peaks] as [p]
	   ON p.MountainId = mc.MountainId
		
 GROUP BY c.CountryName
		


 -- 17. Highest Peak and Longest River by Country


 SELECT TOP(5) [c].[CountryName],
		       MAX(p.Elevation)  AS [HighestPeakElevation],
			   MAX(r.Length)     AS [LongestRiverLength]
	       FROM [Countries] AS [c]
      LEFT JOIN [CountriesRivers] AS [cr]
			 ON c.CountryCode = cr.CountryCode
      LEFT JOIN [Rivers] AS [r]
			 ON r.Id = cr.RiverId
      LEFT JOIN [MountainsCountries] AS [mc]
			 ON mc.CountryCode = c.CountryCode
      LEFT JOIN [Peaks] as [p]
			 ON p.MountainId = mc.MountainId
       GROUP BY [c].[CountryName]

	   ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC