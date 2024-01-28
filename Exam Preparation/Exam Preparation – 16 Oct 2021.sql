CREATE DATABASE CigarShop
GO
USE CigarShop


CREATE TABLE Sizes
(
Id INT PRIMARY KEY IDENTITY,
Length INT CHECK(Length BETWEEN 10 AND 25) NOT NULL,
RingRange DECIMAL(10,2) CHECK(RingRange BETWEEN 1.5 AND 7.5) NOT NULL
)


CREATE TABLE Tastes
(
Id INT PRIMARY KEY IDENTITY,
TasteType VARCHAR(20) NOT NULL,
TasteStrength VARCHAR(15) NOT NULL,
ImageURL NVARCHAR(100) NOT NULL
)

CREATE TABLE Brands
(
Id INT PRIMARY KEY IDENTITY,
BrandName VARCHAR(30) NOT NULL,
BrandDescription VARCHAR(8000) NOT NULL
)

CREATE TABLE Cigars
(
Id INT PRIMARY KEY IDENTITY,
CigarName VARCHAR(80) NOT NULL,
BrandId INT FOREIGN KEY REFERENCES Brands(Id) NOT NULL,
TastId INT FOREIGN KEY REFERENCES Tastes(Id) NOT NULL,
SizeId INT FOREIGN KEY REFERENCES Sizes(Id) NOT NULL,
PriceForSingleCigar DECIMAL(10,2) NOT NULL,
ImageURL NVARCHAR(100) NOT NULL
)

CREATE TABLE Addresses
(
Id INT PRIMARY KEY IDENTITY,
Town VARCHAR(30) NOT NULL,
Country NVARCHAR(30) NOT NULL,
Streat NVARCHAR(100) NOT NULL,
ZIP VARCHAR(20) NOT NULL
)

CREATE TABLE Clients
(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(30) NOT NULL,
LastName NVARCHAR(30) NOT NULL,
Email NVARCHAR(50) NOT NULL,
AddressId INT FOREIGN KEY REFERENCES Addresses(Id)NOT NULL

)
CREATE TABLE ClientsCigars
(ClientId INT FOREIGN KEY REFERENCES Clients(Id) NOT NULL,
CigarId INT FOREIGN KEY REFERENCES Cigars(Id) NOT NULL,
PRIMARY KEY(ClientId, CigarId)
)


INSERT INTO Cigars(CigarName, BrandId, TastId,	SizeId,	PriceForSingleCigar, ImageURL)
			VALUES
('COHIBA ROBUSTO', 9, 1,	5, 15.50, 'cohiba-robusto-stick_18.jpg'),
('COHIBA SIGLO I', 9, 1,	10,	410.00,	'cohiba-siglo-i-stick_12.jpg'),
('HOYO DE MONTERREY LE HOYO DU MAIRE', 14, 5, 11, 7.50,	'hoyo-du-maire-stick_17.jpg'),
('HOYO DE MONTERREY LE HOYO DE SAN JUAN', 14, 4, 15, 32.00,	'hoyo-de-san-juan-stick_20.jpg'),
('TRINIDAD COLONIALES',	2, 3, 8, 85.21, 'trinidad-coloniales-stick_30.jpg')
																						 
INSERT INTO Addresses(Town,	Country, Streat, ZIP)
			VALUES
('Sofia', 'Bulgaria', '18 Bul. Vasil levski', 1000),
('Athens', 'Greece', '4342 McDonald Avenue', 10435),
('Zagreb', 'Croatia', '4333 Lauren Drive', 10000)


-- 03 Update

UPDATE Cigars 
SET PriceForSingleCigar *= 0.2
WHERE TastId IN (
				 Select t.Id
				 FROM Tastes AS t
				 FULL JOIN Cigars AS c
				 ON t.Id = c.TastId
				 WHERE t.TasteType ='Spicy'
			   )

UPDATE Brands
SET BrandDescription = 'New description'
WHERE BrandDescription IS NULL

