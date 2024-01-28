CREATE DATABASE Airport
GO
USE Airport
GO

CREATE TABLE Passengers
(
Id INT PRIMARY KEY IDENTITY,
FullName VARCHAR(100) UNIQUE NOT NULL,
Email VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Pilots
(
Id INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(30) UNIQUE NOT NULL,
LastName VARCHAR(30) UNIQUE NOT NULL,
Age TINYINT CHECK(Age >= 21 AND Age <= 62) NOT NULL,
Rating FLOAT CHECK(Rating >= 0.0 AND Rating <= 10.0)
)


CREATE TABLE AircraftTypes
(
Id INT PRIMARY KEY IDENTITY,
TypeName VARCHAR(30) UNIQUE NOT NULL
)

CREATE TABLE Aircraft
(
Id INT PRIMARY KEY IDENTITY,
Manufacturer VARCHAR(25) NOT NULL,
Model VARCHAR(30) NOT NULL,
[Year] INT NOT NULL,
FlightHours  INT,
Condition CHAR(1) NOT NULL,
TypeId INT FOREIGN KEY REFERENCES AircraftTypes(Id) NOT NULL
)


CREATE TABLE PilotsAircraft
(
AircraftId INT FOREIGN KEY REFERENCES Aircraft(Id) NOT NULL,
PilotId  INT FOREIGN KEY REFERENCES Pilots(Id) NOT NULL,
PRIMARY KEY(AircraftId, PilotId)
)

CREATE TABLE Airports
(
Id INT PRIMARY KEY IDENTITY,
AirportName VARCHAR(70) UNIQUE NOT NULL,
Country VARCHAR(100) UNIQUE NOT NULL
)


CREATE TABLE FlightDestinations
(
Id INT PRIMARY KEY IDENTITY,
AirportId INT FOREIGN KEY REFERENCES Airports(Id) NOT NULL,
[Start] DATETIME2 NOT NULL,
AircraftId INT FOREIGN KEY REFERENCES Aircraft(Id) NOT NULL,
PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL,
TicketPrice DECIMAL(18,2) DEFAULT(15) NOT NULL
)

SELECT CONCAT(FirstName, ' ', LastName) AS FullName
  FROM Pilots
 WHERE Id BETWEEN 5 AND 15


INSERT INTO Passengers(FullName, Email)
					VALUES
('Krystal Cuckson', 'KrystalCuckson@gmail.com'),
('Susy Borrel','SusyBorrel@gmail.com'),
('Saxon Veldman','SaxonVeldman@gmail.com'),
('Lenore Romera','LenoreRomera@gmail.com'),
('Enrichetta Jeremiah','EnrichettaJeremiah@gmail.com'),
('Delaney Stove','DelaneyStove@gmail.com'),
('Ilaire Tomaszewicz','IlaireTomaszewicz@gmail.com'),
('Genna Jaquet','GennaJaquet@gmail.com'),
('Carlotta Dykas','CarlottaDykas@gmail.com'),
('Viki Oneal','VikiOneal@gmail.com'),
('Anthe Larne','AntheLarne@gmail.com')

-- 03 Update

UPDATE Aircraft
SET Condition = 'A'
WHERE (Condition = 'C' OR Condition = 'B') AND (FlightHours IS NULL OR FlightHours <= 100) AND [Year] >= 2013

-- 04 Delete 
DELETE FROM Passengers
      WHERE LEN(FullName) <= 10

-- 05 Aircraft

  SELECT Manufacturer, Model,	FlightHours, Condition
    FROM Aircraft
ORDER BY FlightHours DESC 

-- 06 Pilots and Aircraft

  SELECT p.FirstName,	p.LastName,	a.Manufacturer,	a.Model, a.FlightHours
    FROM Pilots AS p
INNER JOIN PilotsAircraft AS pa
	  ON pa.PilotId = p.Id
INNER JOIN Aircraft AS a
	  ON a.Id = pa.AircraftId
   WHERE  FlightHours < 304
ORDER BY a.FlightHours DESC, p.FirstName

-- 07 Top 20 Flight Destinations

  SELECT TOP(20) fd.Id AS DestinationId, fd.Start, p.FullName, a.AirportName,	fd.TicketPrice
    FROM FlightDestinations AS fd
INNER JOIN Passengers AS p
      ON fd.PassengerId = p.Id
INNER JOIN Airports AS a
      ON a.Id = fd.AirportId
   WHERE DAY(fd.Start) % 2 = 0
ORDER BY fd.TicketPrice DESC, a.AirportName

-- 08 Number of Flights for Each Aircraft

	  SELECT * 
		FROM (
			      SELECT a.Id AS AircraftId, a.Manufacturer, a.FlightHours, COUNT(fd.AircraftId) AS FlightDestinationsCount, ROUND(AVG(fd.TicketPrice),2) AS AvgPrice
			        FROM Aircraft AS a
			    INNER JOIN FlightDestinations AS fd
			          ON a.Id = fd.AircraftId
			    GROUP BY fd.AircraftId, a.Id, a.Manufacturer, a.FlightHours
			 )AS groupingQuery

		   WHERE FlightDestinationsCount >= 2
		ORDER BY FlightDestinationsCount DESC, AircraftId


 -- 09 	Regular Passengers

 SELECT *
   FROM 
        (	    
			  SELECT p.FullName AS FullName, COUNT(a.Id) AS CountOfAircraft, SUM(fd.TicketPrice) AS TotalPayed
			    FROM Passengers AS p
			INNER JOIN FlightDestinations AS fd
				  ON p.Id = fd.PassengerId
			INNER JOIN Aircraft AS a
				  ON fd.AircraftId = a.Id
			   WHERE SUBSTRING(p.FullName,2,1) = 'a'
			GROUP BY  p.FullName
		) AS GroupingQuery

    WHERE CountOfAircraft > 1
 ORDER BY FullName

 -- 10 Full Info for Flight Destinations
 SELECT airp.AirportName, fd.Start AS DayTime,	fd.TicketPrice,	p.FullName, a.Manufacturer,  a.Model 
 FROM Passengers AS p
 INNER JOIN FlightDestinations AS fd
 ON p.Id = fd.PassengerId
 INNER JOIN Airports AS airp
 ON airp.Id = fd.AirportId
 INNER JOIN Aircraft AS a
 ON a.Id = fd.AircraftId
WHERE HOUR(fd.Start) >= 6 AND  HOUR(fd.Start) <= 20 AND fd.TicketPrice > 2500
ORDER BY a.Model


-- 11 
GO

CREATE FUNCTION udf_FlightDestinationsByEmail(@email VARCHAR(50)) 
RETURNS INT
AS
BEGIN

DECLARE @count INT =
					 (
					 SELECT COUNT(fd.PassengerId)
					   FROM Passengers AS p
					  INNER JOIN FlightDestinations AS fd
					     ON p.Id = fd.PassengerId
					  WHERE p.Email = @email
					  GROUP BY fd.PassengerId
					 )

	 IF (@count > 0)
	 BEGIN

	 RETURN @count

	 END
	 

	 RETURN 0


END

-- 12 Full Info for Airports
GO

CREATE PROCEDURE usp_SearchByAirportName (@airportName VARCHAR(70))
AS
BEGIN

SELECT ap.AirportName, p.FullName, 
CASE 

	WHEN fd.TicketPrice <= 400 THEN 'Low'
	WHEN fd.TicketPrice > 400 AND fd.TicketPrice <= 1500 THEN 'Medium'
	WHEN fd.TicketPrice > 1501 THEN 'High' 

END AS LevelOfTickerPrice,

a.Manufacturer, a.Condition, at.TypeName

	  FROM Passengers AS p
 JOIN FlightDestinations AS fd
	    ON p.Id = fd.PassengerId
INNER JOIN Airports AS ap
		ON ap.Id = fd.AirportId
INNER JOIN Aircraft AS a
		ON a.Id = fd.AircraftId
INNER JOIN AircraftTypes AS at
		ON at.Id = a.TypeId

   WHERE ap.AirportName = @airportName
ORDER BY a.Manufacturer, p.FullName

END

EXEC usp_SearchByAirportName 'Sir Seretse Khama International Airport'
