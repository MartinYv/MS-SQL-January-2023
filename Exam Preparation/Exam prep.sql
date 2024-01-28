CREATE DATABASE NationalTouristSitesOfBulgariaa
GO
USE NationalTouristSitesOfBulgariaa


CREATE TABLE Categories
(
Id INT PRIMARY KEY IDENTITY,
Name VARCHAR(50) NOT NULL
)

CREATE TABLE Locations
(
Id INT PRIMARY KEY IDENTITY,
Name VARCHAR(50) NOT NULL,
Municipality VARCHAR(50),
Province VARCHAR(50)
)

CREATE TABLE Sites
(
Id INT PRIMARY KEY IDENTITY,
Name VARCHAR(100) NOT NULL,
LocationId INT FOREIGN KEY REFERENCES Locations(Id) NOT NULL,
CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
Establishment VARCHAR(15) 
)

CREATE TABLE Tourists
(
Id INT PRIMARY KEY IDENTITY,
Name VARCHAR(50) NOT NULL,
Age INT NOT NULL CHECK(Age BETWEEN 0 AND 120),
PhoneNumber VARCHAR(20) NOT NULL,
Nationality VARCHAR(30) NOT NULL,
Reward VARCHAR(20) 
)

CREATE TABLE SitesTourists
(
TouristId INT FOREIGN KEY REFERENCES Tourists(Id) NOT NULL,
SiteId INT FOREIGN KEY REFERENCES Sites(Id) NOT NULL,
PRIMARY KEY(TouristId, SiteId)
)

CREATE TABLE BonusPrizes
(
Id INT PRIMARY KEY IDENTITY,
Name VARCHAR(50) NOT NULL,
)

CREATE TABLE TouristsBonusPrizes
(
TouristId INT FOREIGN KEY REFERENCES Tourists(Id) NOT NULL,
BonusPrizeId INT FOREIGN KEY REFERENCES BonusPrizes(Id) NOT NULL,
PRIMARY KEY(TouristId, BonusPrizeId)
)


-- 03 Update

UPDATE Sites
SET Establishment = '(not defined)'
WHERE Establishment IS NULL

-- 04 ⦁	Delete

SELECT Id
FROM BonusPrizes
WHERE Name = 'Sleeping bag'


DELETE FROM TouristsBonusPrizes
WHERE BonusPrizeId  IN  ( 
					   SELECT Id
					   FROM BonusPrizes
					   WHERE Name = 'Sleeping bag'
					   )

DELETE FROM BonusPrizes
WHERE Name = 'Sleeping bag' 


-- 05 ⦁	Tourists

SELECT Name,	Age,	PhoneNumber,	Nationality
FROM Tourists
ORDER BY Nationality, Age DESC, Name


-- 06. Sites with Their Location and Category

SELECT s.Name AS Site,	l.Name AS Location,	s.Establishment, c.Name AS Category
FROM Sites AS s
JOIN Locations AS l
ON s.LocationId = l.Id
JOIN Categories AS c
ON c.Id = s.CategoryId
ORDER BY c.Name DESC , l.Name, s.Name


-- 07. Count of Sites in Sofia Province

SELECT l.Province,	l.Municipality,	l.Name AS Location,	COUNT(l.Id) AS CountOfSites 
FROM Sites AS s
JOIN Locations AS l
ON s.LocationId = l.Id
WHERE l.Province = 'Sofia'
GROUP BY l.Province,	l.Municipality,	l.Name
ORDER BY CountOfSites DESC, l.Name


-- 08. Tourist Sites established BC

SELECT s.Name AS Site, l.Name AS Location, l.Municipality,	l.Province, s.Establishment
FROM Sites AS s
JOIN Locations AS l
ON s.LocationId = l.Id
WHERE LEFT(l.Name, 1) NOT IN ('B', 'M', 'D') AND s.Establishment  LIKE ('%BC')
ORDER BY s.Name


-- 09. Tourists with their Bonus Prizes

  SELECT t.Name,	t.Age,	t.PhoneNumber,	t.Nationality, 
    CASE 
		 WHEN bp.Name IS NULL THEN '(no bonus prize)' ELSE bp.Name
  END AS Reward
	FROM Tourists AS t
LEFT JOIN TouristsBonusPrizes AS tp
	  ON tp.TouristId = t.Id
LEFT JOIN BonusPrizes AS bp
	  ON bp.Id = tp.BonusPrizeId
ORDER BY t.Name