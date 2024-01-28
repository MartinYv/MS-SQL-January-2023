CREATE DATABASE WashingMachine
GO
USE WashingMachine
GO

CREATE TABLE Vendors
(
VendorId INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) UNIQUE NOT NULL
)


CREATE TABLE Parts
(
PartId INT PRIMARY KEY IDENTITY,
SerialNumber VARCHAR(50) UNIQUE NOT NULL,
[Description] VARCHAR(255),
Price DECIMAL(6,2) NOT NULL,
VendorId INT FOREIGN KEY REFERENCES Vendors(VendorId) NOT NULL,
StockQty INT NOT NULL DEFAULT(0),
CHECK (StockQty >= 0),
CHECK (Price > 0)
)

CREATE TABLE Models
(
ModelId INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) UNIQUE NOT NULL,
)

CREATE TABLE Clients
(
ClientId INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(50)  NOT NULL,
LastName VARCHAR(50)  NOT NULL,
Phone CHAR(12) NOT NULL CHECK(LEN(Phone) = 12)
)

 
CREATE TABLE Mechanics
(
MechanicId INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(50)  NOT NULL,
LastName VARCHAR(50)  NOT NULL,
[Address] VARCHAR(255) NOT NULL
)

CREATE TABLE Jobs 
(
JobId INT PRIMARY KEY IDENTITY,
ModelId INT FOREIGN KEY REFERENCES Models(ModelId) NOT NULL,
[Status] VARCHAR(11) DEFAULT('Pending') NOT NULL   CHECK ([Status] IN ('Pending', 'In Progress', 'Finished')),
ClientId INT FOREIGN KEY REFERENCES Clients(ClientId) NOT NULL,
MechanicId INT  FOREIGN KEY REFERENCES Mechanics(MechanicId),
IssueDate DATE NOT NULL,
FinishDate DATE
)

CREATE TABLE Orders
(
OrderId INT PRIMARY KEY IDENTITY,
JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL,
IssueDate DATE,
Delivered BIT DEFAULT(0) NOT NULL
)

CREATE TABLE PartsNeeded
(
JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL,
PartId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL,
PRIMARY KEY(JobId, PartId),
Quantity INT DEFAULT(1) CHECK(Quantity > 0)
)

CREATE TABLE OrderParts
(
OrderId INT FOREIGN KEY REFERENCES Orders(OrderId) NOT NULL,
PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL,
PRIMARY KEY(OrderId, PartId),
Quantity INT DEFAULT(1) CHECK(Quantity > 0)
)
GO
-- 02 Insert

INSERT INTO Clients(FirstName, LastName, Phone)
VALUES
('Teri', 'Ennaco', '570-889-5187'),
('Merlyn', 'Lawler', '201-588-7810'),
('Georgene', 'Montezuma', '925-615-5185'),
('Jettie', 'Mconnell', '908-802-3564'),
('Lemuel', 'Latzke', '631-748-6479'),
('Melodie',	'Knipp', '805-690-1682'),
('Candida',	'Corbley', '908-275-8357')

INSERT INTO Parts(SerialNumber, [Description], Price, VendorId)
VALUES
('WP8182119',	'Door Boot Seal',	117.86,	2),
('W10780048',	'Suspension Rod',	42.81,	1),
('W10841140',	'Silicone Adhesive', 	6.77,	4),
('WPY055980',	'High Temperature Adhesive',	13.94,	3)


-- 03 Update

Update Jobs
SET MechanicId =3 
WHERE Status = 'Pending'

Update Jobs
SET Status = 'In Progress'
WHERE Status= 'Pending'

-- 04 Delete

DELETE FROM OrderParts
WHERE OrderId = 19

DELETE FROM Orders
WHERE OrderId = 19

-- 05 Mechanic Assignments

SELECT CONCAT(FirstName, ' ' , LastName) AS Mechanic, j.Status, j.IssueDate
FROM Mechanics AS m
INNER JOIN Jobs as j
ON m.MechanicId = j.MechanicId
ORDER BY m.MechanicId, j.IssueDate, j.JobId

-- 06 Current Clients

SELECT CONCAT(c.FirstName, ' ' , c.LastName) AS Client, DATEDIFF(day, j.IssueDate, '2017-04-24') AS [Days going], j.Status AS [Status]
FROM Clients AS c
INNER JOIN Jobs AS j
ON c.ClientId = j.ClientId
WHERE j.Status <> 'Finished'
ORDER BY [Days going] DESC, c.ClientId

-- 08. Available Mechanics
 CONCAT(m.FirstName, ' ' , m.LastName) AS Available


   SELECT CONCAT(m.FirstName, ' ' , m.LastName) AS Available
     FROM Mechanics AS m
FULL JOIN Jobs AS j
       ON m.MechanicId = j.MechanicId
	WHERE j.Status = 'Finished' OR j.Status IS NULL
 GROUP BY m.FirstName, m.LastName, m.MechanicId 
 ORDER BY m.MechanicId


 -- 09. Past Expenses


    SELECT j.JobId AS JobId, ISNULL(SUM(op.Quantity * p.Price),0) AS Total
      FROM Jobs AS j
 LEFT JOIN Orders AS o
        ON j.JobId = o.JobId
 LEFT JOIN OrderParts AS op
        ON o.OrderId = op.OrderId
 LEFT JOIN Parts AS p
        ON op.PartId = p.PartId
     WHERE j.Status = 'Finished'
  GROUP BY j.JobId
  ORDER BY Total DESC, j.JobId

  -- 10. Missing Parts
  SELECT * 
    FROM (
			  SELECT p.PartId AS PartId,
			  p.Description,
			  pn.Quantity AS [Required],
			  ISNULL(p.StockQty,0) AS [In Stock],
			  ISNULL(op.Quantity, 0) AS [Ordered]
			   FROM Jobs AS j
			    LEFT JOIN PartsNeeded AS pn
			   ON j.JobId = pn.JobId
			   LEFT JOIN Parts AS p
			 ON pn.PartId = p.PartId
			 LEFT JOIN Orders AS o
			 ON j.JobId = o.JobId       
			 LEFT JOIN OrderParts AS op
			        ON o.OrderId = op.OrderId
			   WHERE j.Status <> 'Finished' AND (o.Delivered = 0 OR o.Delivered IS NULL)
           ) AS asd
   WHERE [Required] > ([In Stock] + Ordered)
ORDER BY PartId


