CREATE DATABASE Bitbucket
GO
USE Bitbucket
GO

CREATE TABLE Users
( 
Id INT PRIMARY KEY IDENTITY,
Username VARCHAR(30) NOT NULL,
Password VARCHAR(30) NOT NULL,
Email VARCHAR(50) NOT NULL
)


CREATE TABLE Repositories
(
Id INT PRIMARY KEY IDENTITY,
Name VARCHAR(50) NOT NULL
)

CREATE TABLE RepositoriesContributors
(
RepositoryId INT  NOT NULL FOREIGN KEY REFERENCES Repositories(Id),
ContributorId INT  NOT NULL FOREIGN KEY REFERENCES Users(Id),
PRIMARY KEY (RepositoryId, ContributorId)
)

CREATE TABLE Issues
(
Id INT PRIMARY KEY IDENTITY,
Title VARCHAR(255) NOT NULL,
IssueStatus VARCHAR(6) NOT NULL,
RepositoryId INT NOT NULL FOREIGN KEY REFERENCES Repositories(Id),
AssigneeId INT NOT NULL FOREIGN KEY REFERENCES Users(Id)
)

CREATE TABLE Commits
(
Id INT PRIMARY KEY IDENTITY,
Message VARCHAR(255) NOT NULL,
IssueId INT FOREIGN KEY REFERENCES Issues(Id),
RepositoryId INT  NOT NULL FOREIGN KEY REFERENCES Repositories(Id),
ContributorId INT NOT NULL FOREIGN KEY REFERENCES Users(Id) 
)

CREATE TABLE Files
(
Id INT PRIMARY KEY IDENTITY,
Name VARCHAR(100) NOT NULL,
Size DECIMAL(15,2) NOT NULL,
ParentId INT FOREIGN KEY REFERENCES Files(Id),
CommitId INT  NOT NULL FOREIGN KEY REFERENCES Commits(Id)
)


INSERT INTO Files ([Name], Size, ParentId, CommitId)
     VALUES
('Trade.idk', 2598.0, 1, 1),
('menu.net', 9238.31, 2, 2),
('Administrate.soshy', 1246.93, 3, 3),
('Controller.php', 7353.15, 4, 4),
('Find.java', 9957.86, 5, 5),
('Controller.json',	14034.87, 3, 6),
('Operate.xix',	7662.92, 7, 7)


INSERT INTO Issues (Title, IssueStatus, RepositoryId, AssigneeId)
     VALUES 
('Critical Problem with HomeController.cs file', 'open', 1, 4),
('Typo fix in Judge.html', 'open',	4, 3),
('Implement documentation for UsersService.cs',	'closed', 8, 2),
('Unreachable code in Index.cs', 'open', 9,	8)

-- 03 Update

UPDATE Issues
SET IssueStatus = 'closed'
WHERE AssigneeId = 6

-- 04 Delete

--SELECT Id
--FROM Repositories
--WHERE Name = 'Softuni-Teamwork'


DELETE FROM RepositoriesContributors
WHERE RepositoryId IN (
					   SELECT Id
					   FROM Repositories
					   WHERE Name = 'Softuni-Teamwork'
					   )


--SELECT * 
--FROM Issues
--WHERE RepositoryId IN  (
--					   SELECT Id
--					   FROM Repositories
--					   WHERE Name = 'Softuni-Teamwork'
--					   )

DELETE FROM Commits
WHERE IssueId IN (
				  SELECT Id
				  FROM Issues
				  WHERE RepositoryId  =  (
										   SELECT Id
										   FROM Repositories
										   WHERE Name = 'Softuni-Teamwork'
										 )
				  )


DELETE FROM Issues 
WHERE RepositoryId IN (
						SELECT Id
						FROM Repositories
						WHERE Name = 'Softuni-Teamwork'
					  )

-- 05 Select

SELECT Id, [Message], RepositoryId, ContributorId
FROM Commits
ORDER BY Id,[Message], RepositoryId, ContributorId


-- 06 	Front-end

SELECT Id, [Name], Size
FROM Files 
WHERE Size > 1000 AND [Name] Like '%html%'
ORDER BY Size DESC, Id, [Name]

-- 07 Issue Assignment

SELECT i.Id, CONCAT(u.[Username],' : ',i.Title) AS IssueAssignee
FROM Issues AS i
LEFT JOIN Users AS u
ON i.AssigneeId = u.Id
ORDER BY i.Id DESC, i.AssigneeId 

-- 08 Single Files

SELECT f.ID, f.[Name], CONCAT(f.Size, 'KB') AS Size
FROM Files AS F
LEFT JOIN Files AS fch
ON f.Id = fch.ParentId
WHERE fch.ParentId IS NULL
ORDER BY f.Id, f.[Name], f.Size DESC


-- 09 Commits in Repositories

SELECT TOP(5) r.Id, r.Name, COUNT(c.Id) AS Commits
FROM Repositories AS r
LEFT JOIN Commits AS c
ON r.Id = c.RepositoryId
LEFT JOIN RepositoriesContributors AS rc
ON rc.RepositoryId = r.Id

GROUP BY r.Id, r.Name
ORDER BY Commits DESC, r.Id, r.Name

-- 10 Average Size


SELECT u.Username, AVG(Size) AS Size
FROM Users AS u
INNER  JOIN Commits as c
ON u.Id = c.ContributorId
INNER JOIN Files AS f
ON f.CommitId = c.Id
GROUP BY u.Username
ORDER BY Size DESC, Username


-- 11. All User Commits
GO

CREATE  FUNCTION udf_AllUserCommits(@username VARCHAR(30))
RETURNS INT
AS
BEGIN
DECLARE @UserId INT =   (
						SELECT Id
						FROM Users
						WHERE Username = @username
						)

DECLARE @CommitsCount INT = (
							 SELECT COUNT(Id)
							 FROM Commits
							 WHERE ContributorId = @UserId
							 )

RETURN @CommitsCount
END

GO

SELECT dbo.udf_AllUserCommits('UnderSinduxrein')


-- 12. Search for Files
GO

 CREATE PROCEDURE usp_SearchForFiles @fileExtension VARCHAR(98)
 AS 
 BEGIN
 
 SELECT Id, [Name], CONCAT(Size, 'KB') AS Size
 FROM Files
 WHERE [Name] LIKE CONCAT('%[.]', @fileExtension)
 ORDER BY Id, [Name], Size
END

EXEC usp_SearchForFiles 'txt'