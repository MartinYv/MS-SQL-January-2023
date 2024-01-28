CREATE DATABASE DDL
 GO
USE DDL
GO


CREATE TABLE Owners
(
Id INT PRIMARY KEY IDENTITY,
Name VARCHAR(50) NOT NULL,
PhoneNumber VARCHAR(15) NOT NULL,
Address VARCHAR(50)
)

CREATE TABLE AnimalTypes
(
Id INT PRIMARY KEY IDENTITY,
AnimalType VARCHAR(30) NOT NULL
)

CREATE TABLE Cages
(
Id INT PRIMARY KEY IDENTITY,
AnimalTypeId INT FOREIGN KEY REFERENCES AnimalTypes(Id) NOT NULL 
)


CREATE TABLE Animals
(
Id INT PRIMARY KEY IDENTITY,
Name VARCHAR(30) NOT NULL,
BirthDate DATE NOT NULL,
OwnerId INT FOREIGN KEY REFERENCES Owners(Id),
AnimalTypeId INT FOREIGN KEY REFERENCES AnimalTypes(Id) NOT NULL
)


CREATE TABLE AnimalsCages
(
CageId INT FOREIGN KEY REFERENCES Cages(Id) NOT NULL,
AnimalId  INT FOREIGN KEY REFERENCES Animals(Id) NOT NULL,
PRIMARY KEY(CageId, AnimalId)
)

CREATE TABLE VolunteersDepartments
(
Id INT PRIMARY KEY IDENTITY,
DepartmentName VARCHAR(30) NOT NULL
)

CREATE TABLE Volunteers
(
Id INT PRIMARY KEY IDENTITY,
Name VARCHAR(50) NOT NULL,
PhoneNumber VARCHAR(15) NOT NULL,
Address VARCHAR(50),
AnimalId INT FOREIGN KEY REFERENCES Animals(Id),
DepartmentId INT FOREIGN KEY REFERENCES VolunteersDepartments(Id) NOT NULL
)

-- 02 Insert

INSERT INTO Volunteers
VALUES
('Anita Kostova', '0896365412',	'Sofia, 5 Rosa str.' , 15, 1),
('Dimitur Stoev', '0877564223', null, 42, 4),
('Kalina Evtimova',	'0896321112', 'Silistra, 21 Breza str.', 9,	7),
('Stoyan Tomov', '0898564100', 'Montana, 1 Bor str.',	18,	8),
('Boryana Mileva', '0888112233', null,	31,	5)

INSERT INTO Animals
VALUES									 
('Giraffe', '2018-09-21', 21, 1),
('Harpy Eagle', '2015-04-17', 15, 3),
('Hamadryas Baboon', '2017-11-02', null, 1),
('Tuatara',	'2021-06-30', 2, 4)

-- 03 Update

SELECT Id
FROM Owners
WHERE Name = 'Kaloqn Stoqnov'

SELECT *
FROM Owners

UPDATE Animals
SET OwnerId =  (	
				SELECT Id
				FROM Owners
				WHERE Name = 'Kaloqn Stoqnov'
				)
WHERE OwnerId IS NULL

-- 04 Delete
=
DELETE FROM Volunteers
WHERE DepartmentId = (
			SELECT Id 
			FROM VolunteersDepartments
			WHERE DepartmentName = 'Education program assistant'
			)


SELECT * FROM VolunteersDepartments
DELETE FROM VolunteersDepartments
WHERE Id = (
			SELECT Id 
			FROM VolunteersDepartments
			WHERE DepartmentName = 'Education program assistant'
			)

-- Another solving

DELETE FROM Volunteers
WHERE DepartmentId = 2

SELECT * FROM VolunteersDepartments
DELETE FROM VolunteersDepartments
WHERE Id = 2

-- 05 Volunteers

SELECT Name, PhoneNumber, Address, AnimalId, DepartmentId
FROM Volunteers
ORDER BY Name, AnimalId, DepartmentId

-- 06 Animals data

SELECT a.Name,	at.AnimalType, FORMAT(a.BirthDate, 'dd.MM.yyyy') AS BirthDate
FROM Animals AS a
LEFT JOIN AnimalTypes AS at
ON a.AnimalTypeId = at.Id
ORDER BY a.Name

-- 07 Owners and Their Animals

SELECT TOP(5) o.Name, COUNT(a.OwnerId) AS CountOfAnimals
FROM Owners AS o
INNER JOIN Animals AS a
ON o.Id = a.OwnerId
GROUP BY o.Name,a.OwnerId
ORDER BY CountOfAnimals DESC, o.Name

-- 08 Owners, Animals and Cages

SELECT  CONCAT(o.Name, '-', a.Name) AS OwnersAnimals, o.PhoneNumber, c.Id AS CageId
FROM Owners AS o
INNER JOIN Animals AS a
ON o.Id = a.OwnerId
INNER JOIN AnimalTypes AS at
ON at.Id = a.AnimalTypeId
INNER JOIN AnimalsCages AS ac
ON ac.AnimalId = a.Id
INNER JOIN Cages AS c
ON c.Id= ac.CageId
WHERE at.AnimalType = 'Mammals'
ORDER BY o.Name, a.Name DESC

-- 09 Volunteers in Sofia

    SELECT v.Name,	v.PhoneNumber,	SUBSTRING(v.Address, CHARINDEX (',',v.Address,0)+1, LEN(v.Address)) AS Address 
	  FROM Volunteers AS v
INNER JOIN VolunteersDepartments AS vd
   	    ON v.DepartmentId = vd.Id
   	 WHERE vd.DepartmentName = 'Education program assistant' AND v.Address LIKE '%Sofia%'
  ORDER BY v.Name

-- 10 Animals for Adoption


   SELECT a.Name, YEAR(a.BirthDate) AS BirthYear, at.AnimalType
     FROM Animals AS a 
LEFT JOIN AnimalTypes AS at
       ON a.AnimalTypeId = at.Id
	WHERE at.AnimalType <> 'Birds' AND DATEDIFF(YEAR, a.BirthDate, '2022-01-01') < 5 AND a.OwnerId IS NULL
 ORDER BY a.Name

 GO


 -- 11 All Volunteers in a Department

CREATE FUNCTION udf_GetVolunteersCountFromADepartment(@VolunteersDepartment VARCHAR (30))
 RETURNS INT 
 AS 
 BEGIN
 
 RETURN (    
			 SELECT COUNT(v.Id)
		       FROM Volunteers AS v
	     INNER JOIN VolunteersDepartments AS vd
			  	 ON v.DepartmentId = vd.Id
			  WHERE vd.DepartmentName = @VolunteersDepartment
		)

 END


 -- 12 Animals with Owner or Not
 GO

 CREATE PROCEDURE usp_AnimalsWithOwnersOrNot(@AnimalName VARCHAR(30))
 AS
 BEGIN

        IF (SELECT OwnerId FROM Animals WHERE Animals.Name = @AnimalName) IS NULL
  BEGIN 
         
		   SELECT @AnimalName AS Name, 'For adoption' AS OwnersName
             FROM Animals AS a
			WHERE a.Name = @AnimalName
		 
   END

      ELSE
 BEGIN
            SELECT  @AnimalName AS Name, o.Name AS OwnersName
		      FROM Animals AS a
		INNER JOIN Owners AS o
				ON a.OwnerId= o.Id
		     WHERE @AnimalName = a.Name	
   END

END

 EXEC usp_AnimalsWithOwnersOrNot 'Pumpkinseed Sunfish'