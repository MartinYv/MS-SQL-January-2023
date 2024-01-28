CREATE DATABASE [One-To-One Relationship]

GO
USE [One-To-One Relationship]
GO

CREATE TABLE [Passports]
(
[PassportID] INT PRIMARY KEY IDENTITY(101,1) ,
[PassportNumber] VARCHAR(20) NOT NULL
)


CREATE TABLE [Persons]
(
[PersonID] INT PRIMARY KEY IDENTITY(1,1),
[FirstName] NVARCHAR(50) NOT NULL,
[Salary] DECIMAL(8,2) NOT NULL,
[PassportID] INT FOREIGN KEY REFERENCES[Passports] ([PassportID]) UNIQUE NOT NULL
)



CREATE TABLE [Manufacturers]
(
[ManufacturerID] INT PRIMARY KEY IDENTITY(1,1),
[Name] VARCHAR(20) NOT NULL,
[EstablishedOn] DATE NOT NULL
)

CREATE TABLE [Models]
(
[ModelID] INT PRIMARY KEY IDENTITY(101,1),
[Name] VARCHAR(20) NOT NULL,
[ManufacturerID] INT FOREIGN KEY REFERENCES Manufacturers([ManufacturerID])  NOT NULL,
)



CREATE TABLE [Students]
(
[StudentID] INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(60) NOT NULL
)


CREATE TABLE[Exams]
(
[ExamID] INT PRIMARY KEY IDENTITY(101,1),
[Name] NVARCHAR(60) NOT NULL
)


CREATE TABLE [StudentsExams]
(
[StudentID] INT FOREIGN KEY REFERENCES [Students]([StudentID]) NOT NULL,
[ExamID] INT FOREIGN KEY REFERENCES [Exams]([ExamID]) NOT NULL,
PRIMARY KEY ([StudentID], [ExamID])
)



CREATE TABLE [Teachers]
(
[TeacherID] INT PRIMARY KEY IDENTITY(101,1),
[Name] NVARCHAR(20) NOT NULL,
[ManagerID] INT FOREIGN KEY REFERENCES [Teachers]([TeacherID])
)

-- One to many

CREATE TABLE Students(
	StudentID INT IDENTITY(1,1) PRIMARY KEY,
	[Name] VARCHAR(25)
);

CREATE TABLE Exams(
	ExamID INT IDENTITY(101,1) PRIMARY KEY,
	[Name] VARCHAR(25)
);

CREATE TABLE StudentsExams(
	StudentID INT REFERENCES Students(StudentID),
	ExamID INT REFERENCES Exams(ExamID),
	PRIMARY KEY(StudentID, ExamID)
);

INSERT INTO Students
VALUES  ('Mila'),
		('Toni'),
		('Ron');

INSERT INTO Exams
VALUES  ('SpringMVC'),
		('Neo4j'),
		('Oracle 11g');

INSERT INTO StudentsExams
VALUES  (1, 101),
		(1, 102),
		(2, 101),
		(3, 103),
		(2, 102),
		(2, 103);

-- Problem 5 

CREATE DATABASE OnlineStore;

CREATE TABLE Cities(
	CityID INT IDENTITY(1,1) PRIMARY KEY,
	[Name] VARCHAR(25)
);

CREATE TABLE Customers(
	CustomerID INT IDENTITY(1,1) PRIMARY KEY,
	[Name] VARCHAR(25),
	Birthday DATETIME2,
	CityID INT REFERENCES Cities(CityID)
);

CREATE TABLE Orders(
	OrderID INT IDENTITY(1,1) PRIMARY KEY,
	CustomerID INT REFERENCES Customers(CustomerID)
);

CREATE TABLE ItemTypes(
	ItemTypeID INT IDENTITY(1,1) PRIMARY KEY,
	[Name] VARCHAR(25)
);

CREATE TABLE Items(
	ItemID INT IDENTITY(1,1) PRIMARY KEY,
	[Name] VARCHAR(25),
	ItemTypeID INT REFERENCES ItemTypes(ItemTypeID)
);

CREATE TABLE OrderItems(
	OrderID INT REFERENCES Orders(OrderID),
	ItemID INT REFERENCES Items(ItemID),
	PRIMARY KEY (OrderID, ItemID)
);

--Problem 6

CREATE TABLE [Majors]
(
[MajorID] INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(20) NOT NULL,
)


CREATE TABLE [Subjects]
(
[SubjectID] INT PRIMARY KEY IDENTITY,
[SubjectName] NVARCHAR(40) NOT NULL,
)


CREATE TABLE [Students]
(
[StudentID] INT PRIMARY KEY IDENTITY,
[StudentName] NVARCHAR(60) NOT NULL,
[StudentNumber] NVARCHAR(60) NOT NULL,
[MajorID] INT FOREIGN KEY REFERENCES [Majors]([MajorID]) NOT NULL,
)

CREATE TABLE [Payments]
(
[PaymentID] INT PRIMARY KEY IDENTITY,
[PaymentDate] DATETIME2 NOT NULL,
[PaymentAmount] DECIMAL(6,2) NOT NULL,
[StudentID] INT FOREIGN KEY REFERENCES [Students]([StudentID]) NOT NULL,
)

CREATE TABLE [Agenda]
(
[StudentID] INT FOREIGN KEY REFERENCES [Students]([StudentID]) NOT NULL,
[SubjectID] INT FOREIGN KEY REFERENCES [Subjects]([SubjectID]) NOT NULL,
PRIMARY KEY ([StudentID], [SubjectID])
)

-- Problem 9

SELECT m.MountainRange, p.PeakName, p.Elevation
FROM Mountains AS m
JOIN Peaks AS p ON p.MountainId = m.Id AND m.MountainRange = 'Rila'
ORDER BY p.Elevation DESC;