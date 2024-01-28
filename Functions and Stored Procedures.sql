USE SoftUni
-- 01. Employees with Salary Above 35000

GO

CREATE PROCEDURE [usp_GetEmployeesSalaryAbove35000]
AS 
BEGIN
SELECT [FirstName], [LastName]
FROM [Employees]
WHERE [Salary] > 35000
END

EXECUTE [dbo].[usp_GetEmployeesSalaryAbove35000]

GO

-- 2. Employees with Salary Above Number

GO

CREATE PROCEDURE [usp_GetEmployeesSalaryAboveNumber] @salary DECIMAL(18,4)
    AS
 BEGIN
		  SELECT [FirstName], [LastName]
			FROM [Employees]
		   WHERE [Salary] >= @salary
   END

GO
 -- 3. Town Names Starting With
 GO

 CREATE PROCEDURE [usp_GetTownsStartingWith] @letter varchar(20)
 AS
 BEGIN
 SELECT [Name] AS [Town]
 FROM [Towns]
 WHERE LEFT(Name ,LEN(@letter)) = @letter
 END

 GO


 -- 4. Employees from Town

 GO

 CREATE PROCEDURE [usp_GetEmployeesFromTown] @townParameter VARCHAR(50)
 AS
 BEGIN
		SELECT [e].FirstName, [e].LastName
		  FROM [Towns] as [t]
    INNER JOIN Addresses as [a]
			ON t.TownID = a.TownID
	INNER JOIN Employees as [e]
			ON e.AddressID =a.AddressID
		 WHERE [t].[Name]= @townParameter
 END

 GO


 -- 5. Salary Level Function

 GO

 CREATE FUNCTION [ufn_GetSalaryLevel](@salary DECIMAL(18,4))
 RETURNS VARCHAR(8)
 AS
 BEGIN
 DECLARE @salaryLevel VARCHAR(8)

 IF @salary < 30000
  BEGIN
       SET @salaryLevel = 'Low'
    END

IF @salary BETWEEN 30000 AND 50000
BEGIN
     SET  @salaryLevel = 'Average'
  END

IF @salary > 50000
BEGIN
     SET @salaryLevel = 'High'
  END

RETURN @salaryLevel

END

GO

SELECT [Salary],
[dbo].[ufn_GetSalaryLevel]([Salary]) AS [Salary Level]
FROM [Employees]


-- 6. Employees by Salary Level
GO

CREATE PROC [usp_EmployeesBySalaryLevel] @levelOfSalary VARCHAR(8)
AS
BEGIN
SELECT [FirstName],[LastName]
FROM [Employees]
WHERE [dbo].[ufn_GetSalaryLevel]([Salary]) = @levelOfSalary
END

EXEC [dbo].[usp_EmployeesBySalaryLevel] 'High'


-- 7. Define Function   60/100
GO
CREATE FUNCTION [ufn_IsWordComprised](@setOfLetters VARCHAR(50), @word VARCHAR(50))
RETURNS BIT
AS
BEGIN

DECLARE @isWordExisting BIT = 0
DECLARE @i INT= 1
DECLARE @counter INT = 0

WHILE @i <= LEN(@word)
BEGIN

DECLARE @currWordLetter CHAR(1)= SUBSTRING(@word, @i, 1)
DECLARE @j INT = 1

WHILE @j <= LEN(@setOfLetters)
BEGIN
 
 DECLARE @currLetter CHAR(1) = SUBSTRING(@setOfLetters, @j, 1)

 IF @currLetter = @currWordLetter
 BEGIN
 SET @counter += 1
 END

 IF @counter = LEN(@word)
 BEGIN
 SET @isWordExisting = 1
 BREAK
 END

 SET @j += 1

END

SET @i += 1

END

IF @isWordExisting = 0
BEGIN 
RETURN 0
END

RETURN 1


END


SELECT [dbo].[ufn_IsWordComprised]('oistmiahf', 'halves')

SELECT [dbo].[ufn_IsWordComprised]('oistmiahf', 'Sofia')


-- 8. * Delete Employees and Departments
GO


CREATE PROCEDURE usp_DeleteEmployeesFromDepartment (@departmentId INT)
AS
BEGIN

DELETE FROM [EmployeesProjects] 
WHERE [EmployeeID] IN (
						SELECT [EmployeeID]
                          FROM [Employees]
						 WHERE [DepartmentID] = @departmentId
					   )

UPDATE [Employees]
   SET [ManagerID] = NULL
   WHERE [ManagerID] IN (
						SELECT [EmployeeID]
                          FROM [Employees]
						 WHERE [DepartmentID] = @departmentId
						 )

 ALTER TABLE [Departments]
ALTER COLUMN [ManagerID] INT

UPDATE [Departments]
   Set [ManagerID] = NULL
 WHERE [ManagerID] IN (
						SELECT [EmployeeID]
                          FROM [Employees]
						 WHERE [DepartmentID] = @departmentId
					   )

DELETE FROM [Employees]
WHERE [DepartmentID] = @departmentId


DELETE FROM [Departments]
WHERE [DepartmentID] = @departmentId

Select COUNT(EmployeeID)
  FROM [Employees]
 WHERE [DepartmentID] = @departmentId

END

EXEC [dbo].[usp_DeleteEmployeesFromDepartment] 2


-- 13. *Scalar Function: Cash in User Games Odd Rows
CREATE FUNCTION [ufn_CashInUsersGames] (@gameName VARCHAR (50))
RETURNS TABLE
AS RETURN (
SELECT SUM([Cash]) AS [SumCash]
FROM
(
SELECT u.Cash ,ROW_NUMBER() OVER (ORDER BY u.[Cash] DESC) AS RowNumber
FROM [UsersGames] AS [u]
LEFT JOIN [Games] AS [g]
ON u.GameId = g.Id
WHERE g.Name = @gameName
) AS [QuerySumCash]
WHERE RowNumber % 2 <> 0
)

SELECT * FROM [ufn_CashInUsersGames] ('Love in a mist')