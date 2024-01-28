CREATE DATABASE Boardgames
GO
USE Boardgames

CREATE TABLE Categories
(
Id INT PRIMARY KEY IDENTITY,
Name VARCHAR(50) NOT NULL
)

CREATE TABLE Addresses
(
Id INT PRIMARY KEY IDENTITY,
StreetName NVARCHAR(100) NOT NULL,
StreetNumber INT NOT NULL,
Town VARCHAR(30) NOT NULL,
Country VARCHAR(50) NOT NULL,
ZIP INT NOT NULL
)


CREATE TABLE Publishers
(
Id INT PRIMARY KEY IDENTITY,
Name VARCHAR(30) UNIQUE NOT NULL,
AddressId INT FOREIGN KEY REFERENCES Addresses(Id) NOT NULL,
Website NVARCHAR(40) ,
Phone NVARCHAR(20)
)

CREATE TABLE PlayersRanges
(
Id INT PRIMARY KEY IDENTITY,
PlayersMin INT NOT NULL,
PlayersMax INT NOT NULL
)

CREATE TABLE Boardgames
(
Id INT PRIMARY KEY IDENTITY,
Name NVARCHAR(30) NOT NULL,
YearPublished INT NOT NULL,
Rating DECIMAL(6,2) NOT NULL,
CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
PublisherId INT FOREIGN KEY REFERENCES  Publishers(Id) NOT NULL,
PlayersRangeId INT FOREIGN KEY REFERENCES PlayersRanges(Id) NOT NULL
)


CREATE TABLE Creators
(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(30) NOT NULL,
LastName NVARCHAR(30) NOT NULL,
Email NVARCHAR(30) NOT NULL
)

CREATE TABLE CreatorsBoardgames
(
CreatorId INT FOREIGN KEY REFERENCES  Creators(Id) NOT NULL,
BoardgameId INT FOREIGN KEY REFERENCES  BoardGames(Id) NOT NULL,
PRIMARY KEY(CreatorId, BoardGameId)
)


-- 02. Insert

INSERT INTO Boardgames (Name,	YearPublished,	Rating,	CategoryId,	PublisherId,	PlayersRangeId)
VALUES
('Deep Blue',	2019,	5.67,	1,	15,	7),
('Paris',	2016,	9.78,	7,	1,	5),
('Catan: Starfarers',	2021,	9.87,	7,	13,	6),
('Bleeding Kansas',	2020,	3.25,	3,	7,	4),
('One Small Step',	2019,	5.75,	5,	9,	2)

INSERT INTO Publishers (Name,	AddressId,	Website,	Phone)
VALUES
('Agman Games',	5,	'www.agmangames.com',	'+16546135542'),
('Amethyst Games',	7,	'www.amethystgames.com',	'+15558889992'),
('BattleBooks',	13,	'www.battlebooks.com',	'+12345678907')


-- 03. Update

UPDATE PlayersRanges
   SET PlayersMax += 1
 WHERE PlayersMin = 2 AND PlayersMax = 2

UPDATE Boardgames
   SET Name = CONCAT(Name, 'V2')
 WHERE YearPublished >= 2020

-- 04. Delete

DELETE 
  FROM CreatorsBoardgames
 WHERE BoardgameId IN (
						SELECT Id
						  FROM Boardgames
						 WHERE PublisherId IN (
												SELECT Id 
												  FROM Publishers
												 WHERE AddressId IN (
																	  SELECT Id
																	    FROM Addresses
																	   WHERE Left(Town, 1) = 'L'
																    )
											  )		
				      )

			
DELETE 
  FROM Boardgames
 WHERE PublisherId IN (

						SELECT Id 
						  FROM Publishers
						 WHERE AddressId IN (
										      SELECT Id
										      FROM Addresses
										      WHERE Left(Town, 1) = 'L'
											)
					 )		



DELETE
  FROM Publishers
 WHERE AddressId IN
					(
					 SELECT Id
					   FROM Addresses
					  WHERE Left(Town,1) = 'L'
					)
														
DELETE
  FROM Addresses
 WHERE Left(Town,1) = 'L'



-- 05. Boardgames by Year of Publication

  SELECT Name, Rating
    FROM Boardgames
ORDER BY YearPublished, Name DESC


-- 06. Boardgames by Category

  SELECT bg.Id,	bg.Name, bg.YearPublished, c.Name AS CategoryName  
    FROM Boardgames AS bg
    JOIN Categories AS c
      ON bg.CategoryId = c.Id
   WHERE c.Name = 'Strategy Games' OR c.Name = 'Wargames'
ORDER BY YearPublished DESC



-- 07. Creators without Boardgames

   SELECT c.Id,	CONCAT(c.FirstName, ' ', c.LastName) AS CreatorName, c.Email
	 FROM Creators AS c
LEFT JOIN CreatorsBoardgames AS cb
	   ON c.Id = cb.CreatorId
LEFT JOIN Boardgames AS bg
	   ON bg.Id = cb.BoardgameId
    WHERE bg.Name IS NULL
 ORDER BY CreatorName

-- 08. First 5 Boardgames

  SELECT TOP(5) bg.Name, bg.Rating, c.Name AS CategoryName
	FROM Boardgames AS bg
	JOIN PlayersRanges AS pr
	  ON bg.PlayersRangeId = pr.Id
	JOIN Categories AS c
	  ON bg.CategoryId = c.Id
   WHERE Rating > 7 AND bg.Name LIKE ('%a%') OR Rating > 7.5 AND pr.PlayersMin = 2 AND pr.PlayersMax = 5
ORDER BY bg.Name, Rating DESC


-- 09. Creators with Emails

  SELECT  CONCAT(c.FirstName, ' ', c.LastName) AS FullName, c.Email, MAX(bg.Rating) 
    FROM Creators AS c
    JOIN CreatorsBoardgames AS cb
	  ON c.Id = cb.CreatorId
    JOIN Boardgames AS bg
      ON bg.Id = cb.BoardgameId
   WHERE c.Email LIKE '%.com'
GROUP BY c.FirstName, c.LastName, c.Email
ORDER BY FullName

-- 10. Creators by Rating

SELECT  c.LastName,	CEILING(AVG(bg.Rating)) AS AverageRating, p.Name AS PublisherName 
  FROM Creators AS c
 JOIN CreatorsBoardgames AS cb
    ON c.Id = cb.CreatorId
 JOIN Boardgames AS bg
	ON bg.Id = cb.BoardgameId
 JOIN Publishers AS p
	ON p.Id = bg.PublisherId
 WHERE p.Name = 'Stonemaier Games'
 GROUP BY c.LastName, p.Name
 ORDER BY AVG(bg.Rating) DESC


 -- 11. Creator with Boardgames
 GO

 CREATE FUNCTION udf_CreatorWithBoardgames(@name NVARCHAR(30)) 
 RETURNS INT
 AS
 BEGIN

		RETURN (
				 SELECT COUNT(cb.CreatorId)
				 FROM Creators AS c
				 JOIN CreatorsBoardgames AS cb
				 ON c.Id = cb.CreatorId
				 JOIN Boardgames AS bg
				 ON bg.Id = cb.BoardgameId
				 WHERE c.FirstName = @name
				)

 END


 -- 12. Search for Boardgame with Specific Category
 GO


 CREATE PROCEDURE usp_SearchByCategory(@category VARCHAR(50)) 
 AS
 BEGIN
	
	      SELECT DISTINCT bg.Name, bg.YearPublished, bg.Rating,
						  ct.Name AS CategoryName, p.Name AS PublisherName,
						  CONCAT(pr.PlayersMin, ' people') AS MinPlayers,
						  CONCAT(pr.PlayersMax, ' people') AS MaxPlayers
			FROM Creators AS c
			JOIN CreatorsBoardgames AS cb
			  ON c.Id = cb.CreatorId
			JOIN Boardgames AS bg
			  ON bg.Id = cb.BoardgameId
			JOIN Publishers AS p
			  ON p.Id = bg.PublisherId
			JOIN Categories AS ct
			  ON ct.Id = bg.CategoryId
			JOIN PlayersRanges AS pr
			  ON pr.Id = bg.PlayersRangeId
		   WHERE ct.Name = @category
		ORDER BY p.Name ASC, bg.YearPublished DESC
		

 END


