CREATE DATABASE Bakery
GO
USE Bakery

CREATE TABLE Countries
(
Id INT PRIMARY KEY IDENTITY,
Name NVARCHAR(50) UNIQUE
)

CREATE TABLE Customers
(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(25),
LastName NVARCHAR(25),
Gender CHAR(1) CHECK (Gender IN ('F', 'M')),
Age INT,
PhoneNumber VARCHAR(10) CHECK (LEN(PhoneNumber) = 10),
CountryId INT FOREIGN KEY REFERENCES Countries(Id)
)

CREATE TABLE Products
(
Id INT PRIMARY KEY IDENTITY,
Name NVARCHAR(25) UNIQUE,
Description NVARCHAR(250),
Recipe NVARCHAR(4000),
Price DECIMAL CHECK(PRICE >=0)
)

CREATE TABLE Feedbacks
(
Id INT PRIMARY KEY IDENTITY,
Description NVARCHAR(255),
Rate DECIMAL(4,2) CHECK (Rate BETWEEN 0 AND 10),
ProductId INT FOREIGN KEY REFERENCES Products(Id),
CustomerId INT FOREIGN KEY REFERENCES Customers(Id)
)


CREATE TABLE Distributors
(
Id INT PRIMARY KEY IDENTITY,
Name NVARCHAR(25) UNIQUE,
AddressText NVARCHAR(30),
Summary NVARCHAR(200),
CountryId INT FOREIGN KEY REFERENCES Countries(Id)
)


CREATE TABLE Ingredients
(
Id INT PRIMARY KEY IDENTITY,
Name NVARCHAR(30),
Description NVARCHAR(200),
OriginCountryId INT FOREIGN KEY REFERENCES Countries(Id),
DistributorId INT FOREIGN KEY REFERENCES Distributors(Id)
)

CREATE TABLE ProductsIngredients
(
ProductId INT FOREIGN KEY REFERENCES Products(Id) NOT NULL,
IngredientId INT FOREIGN KEY REFERENCES Ingredients(Id) NOT NULL,
PRIMARY KEY(ProductId, IngredientId)
)

-- 02 Insert

INSERT INTO Distributors (Name,	CountryId, AddressText,	Summary)
VALUES
('Deloitte & Touche',	2,	'6 Arch St #9757',	'Customizable neutral traveling'),
('Congress Title',	13,	'58 Hancock St', 'Customer loyalty'),
('Kitchen People',	1,	'3 E 31st St #77',	'Triple-buffered stable delivery'),
('General Color Co Inc',	21,	'6185 Bohn St #72',	'Focus group'),
('Beck Corporation',	23,	'21 E 64th Ave', 'Quality-focused 4th generation hardware')


INSERT INTO Customers (FirstName,	LastName,	Age,	Gender,	PhoneNumber,	CountryId)
VALUES
('Francoise', 'Rautenstrauch', 15,	'M', '0195698399',	5),
('Kendra',	'Loud',	22,	'F', '0063631526',	11),
('Lourdes',	'Bauswell',	50,	'M', '0139037043',	8),
('Hannah',	'Edmison',	18,	'F', '0043343686',	1),
('Tom',	'Loeza', 31,	'M', '0144876096',	23),
('Queenie',	'Kramarczyk',	30,	'F', '0064215793',	29),
('Hiu',	'Portaro',	25,	'M', '0068277755',	16),
('Josefa', 'Opitz', 43,	'F', '0197887645',	17)


-- 03 Update

UPDATE Ingredients
SET DistributorId = 35
WHERE Name IN ('Bay Leaf', 'Paprika', 'Poppy')

UPDATE Ingredients
SET OriginCountryId = 14
WHERE OriginCountryId = 8

-- 04 Delete 
--Delete all Feedbacks which relate to Customer with Id 14 or to Product with Id 5.

DELETE FROM Feedbacks
WHERE CustomerId = 14

DELETE FROM Feedbacks
WHERE ProductId = 5


-- 05 Products By Price

  SELECT Name, Price, Description
    FROM Products
ORDER BY Price DESC, Name ASC


-- 06. Negative Feedback

SELECT f.ProductId, f.Rate,	f.Description,	f.CustomerId,	c.Age,	c.Gender
FROM Customers AS c
INNER JOIN Feedbacks AS f
ON c.Id = f.CustomerId
WHERE f.Rate < 5.0
ORDER BY f.ProductId DESC, f.Rate ASC


-- 07. Customers without Feedback

SELECT CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName, c.PhoneNumber,	c.Gender
FROM Customers AS c
FULL JOIN Feedbacks AS f
ON c.Id = f.CustomerId
WHERE f.CustomerId IS NULL
ORDER BY c.Id


-- 08. Customers by Criteria

SELECT FirstName, Age, PhoneNumber
FROM Customers AS c
INNER JOIN Countries AS cs
ON c.CountryId = cs.Id
WHERE Age >= 21 AND (FirstName LIKE '%an%' OR PhoneNumber LIKE '%38') AND cs.Name <> 'Greece'
ORDER BY FirstName ASC, Age DESC


-- 09. Middle Range Distributors

    SELECT d.Name AS DistributorName,	i.Name AS IngredientName,	p.Name AS ProductName, AVG(f.Rate) AS AverageRate  
      FROM Distributors AS d
LEFT JOIN Ingredients AS i
		ON d.Id = i.DistributorId
LEFT JOIN ProductsIngredients AS pi
		ON pi.IngredientId = i.Id
LEFT JOIN Products AS p
		ON p.Id = pi.ProductId
LEFT JOIN Feedbacks AS f
		ON f.ProductId = p.Id
     WHERE f.Rate BETWEEN 5 AND 8
  GROUP BY d.Name, i.Name, p.Name
  ORDER BY d.Name,i.Name, p.Name


  -- 10. Country Representative
  --SELECT CountryName, DisributorName FROM (
 
  SELECT c.Name AS CountryName, d.Name	AS DisributorName, COUNT(i.Id) AS [Count] -- не е вярна 
  FROM Distributors AS d
  JOIN Ingredients AS i
  ON d.Id = i.DistributorId
  JOIN Countries AS c
  ON c.Id = d.CountryId
  JOIN ProductsIngredients AS pi
  ON pi.IngredientId = i.Id
  JOIN Products AS p
  ON p.Id = pi.ProductId
  
  GROUP BY c.Name, d.Name
 
  ORDER BY [Count] DESC , CountryName, DisributorName


  -- 