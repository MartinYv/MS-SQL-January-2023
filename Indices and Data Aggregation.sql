-- 1. Records’ Count

SELECT
COUNT(FirstName) AS [Count]
FROM WizzardDeposits


-- 2. Longest Magic Wand

SELECT
Max(MagicWandSize) AS [LongestMagicWand]
FROM WizzardDeposits

-- 3. Longest Magic Wand Per Deposit Groups

SELECT
[DepositGroup],
Max(MagicWandSize) AS [LongestMagicWand]
FROM WizzardDeposits
GROUP BY DepositGroup

-- 04. Smallest Deposit Group per Magic Wand Size

SELECT TOP (2) [DepositGroup]
	   FROM
	        (
	             SELECT 
                       MIN([DepositGroup]) AS [DepositGroup],
					   AVG(MagicWandSize)  AS [AvarageMagicWand] 
			       FROM WizzardDeposits
			   GROUP BY DepositGroup
            )    AS [GroupQuery]

ORDER BY AvarageMagicWand 


-- 5. Deposits Sum

  SELECT
         [DepositGroup],
	 SUM([DepositAmount]) AS [TotalSum]
	FROM WizzardDeposits
GROUP BY DepositGroup


-- 6. Deposits Sum for Ollivander Family

  SELECT
         [DepositGroup],
	 SUM([DepositAmount]) AS [TotalSum]
	FROM WizzardDeposits
   WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup

-- 7. Deposits Filter


SELECT * FROM 
			  (
			    SELECT
			             [DepositGroup],
			  	     SUM([DepositAmount]) AS [TotalSum]
			  	    FROM WizzardDeposits
			       WHERE MagicWandCreator = 'Ollivander family' 
			    GROUP BY [DepositGroup]
			  ) AS [GroupingQuery]  
   WHERE [TotalSum] < 150000
ORDER BY [TotalSum] DESC

-- 8. Deposit Charge


  SELECT
          [DepositGroup],
		  [MagicWandCreator],
	  MIN([DepositCharge]) AS [MinDepositCharge]
     FROM [WizzardDeposits]
 GROUP BY [DepositGroup], [MagicWandCreator]
 ORDER BY [MagicWandCreator], [DepositGroup]


 -- 9. Age Groups
 SELECT [AgeGroup], COUNT(AgeGroup) AS [WizardCount]
   FROM 
       (
        SELECT [Age],
          CASE 
              WHEN [Age] BETWEEN  0 AND 10 THEN '[0-10]'
              WHEN [Age] BETWEEN 11 AND 20 THEN '[11-20]'
              WHEN [Age] BETWEEN 21 AND 30 THEN '[21-30]'
              WHEN [Age] BETWEEN 31 AND 40 THEN '[31-40]'
              WHEN [Age] BETWEEN 41 AND 50 THEN '[41-50]'
              WHEN [Age] BETWEEN 51 AND 60 THEN '[51-60]'
	          WHEN [Age] >= 61 THEN '[61+]'
	       END
	        AS [AgeGroup]
       FROM WizzardDeposits
     ) AS [GropuingQuery]
GROUP BY [AgeGroup]


-- 10. First Letter

SELECT DISTINCT LEFT([FirstName], 1)  AS [FirstLetter]
		   FROM [WizzardDeposits]
		   WHERE DepositGroup = 'Troll Chest'
	   GROUP BY [FirstName]
	   ORDER BY [FirstLetter]
	   

 -- 11. Average Interest
	  
   SELECT [DepositGroup], [IsDepositExpired], AVG([DepositInterest]) AS [AvarageInterest]
     FROM [WizzardDeposits]
    WHERE [DepositStartDate] > '01/01/1985'
 GROUP BY [DepositGroup], [IsDepositExpired]
 ORDER BY [DepositGroup] DESC, [IsDepositExpired]


  -- 12. * Rich Wizard, Poor Wizard


 -- 13. Departments Total Salaries

   SELECT [DepartmentID], SUM(Salary) AS [TotalSalary]
     FROM [Employees]
 GROUP BY [DepartmentID]
 ORDER BY [DepartmentID]

 -- 14. Employees Minimum Salaries

   SELECT [DepartmentID], MIN(Salary) AS [MinimumSalary]
     FROM [Employees]
	WHERE [DepartmentID] IN (2,5,7) AND [HireDate] > '01/01/2000'
 GROUP BY [DepartmentID]
 ORDER BY [DepartmentID]


 -- 15. Employees Average Salaries TO DO !!!

 -- 16. Employees Maximum Salaries    not true?

 SELECT [DepartmentID], MAX([Salary]) AS [MaxSalary]
 FROM Employees
 WHERE [Salary] NOT BETWEEN 30000 AND 70000
 GROUP BY [DepartmentID]


 -- 17. Employees Count Salaries

 SELECT COUNT(EmployeeID) AS [Count]
   FROM [Employees]
  WHERE [ManagerID] IS NULL


  -- 18. *3rd Highest Salary TO DO 

  SELECT [DepartmentID], MAX([Salary]) AS [MaxSalary]
 FROM Employees

 GROUP BY [DepartmentID]