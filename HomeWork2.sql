USE Academy;
GO

ALTER TABLE Teachers
ADD Position NVARCHAR(50) NOT NULL
    CONSTRAINT DF_Teachers_Position DEFAULT ('Assistant')
    CONSTRAINT CHK_Teachers_Position CHECK (Position IN ('Professor', 'Associate professor', 'Senior Lecturer', 'Assistant'));
GO

ALTER TABLE Faculties
ADD Dean NVARCHAR(100) NOT NULL
    CONSTRAINT DF_Faculties_Dean DEFAULT ('')
    CONSTRAINT CHK_Faculties_Dean_NotEmpty CHECK (LEN(Dean) > 0);
GO

INSERT INTO Faculties (Name, Dean) VALUES
('Computer Science', 'John Smith'),
('Economics', 'Anna Ivanova'),
('Law', 'Petro Kovalenko');
GO

INSERT INTO Departments (Name, Financing) VALUES
('Applied Mathematics', 27000),
('Data Science', 20000),
('Database Systems', 8000),
('Software Development', 30000),
('Web Technologies', 15000);
GO

INSERT INTO Groups (Name, Rating, Year) VALUES
('IT-21', 4, 2),
('IT-22', 3, 2),
('CS-11', 5, 1),
('EC-31', 2, 3);
GO

INSERT INTO Teachers (Surname, Name, EmploymentDate, Salary, Premium, Position) VALUES
('Ivanenko',  'Petro',  '1995-03-15', 1200, 300, 'Professor'),
('Kovalchuk', 'Olena',  '2005-09-01', 1100, 250, 'Professor'),
('Petrenko',  'Ihor',   '2000-04-18', 1000, 0,   'Professor'),
('Sydorenko', 'Andrii', '1998-06-20', 950,  200, 'Associate professor'),
('Bondarenko','Iryna',  '2010-02-10', 800,  150, 'Senior Lecturer'),
('Melnyk',    'Oksana', '2015-08-25', 600,  200, 'Assistant'),
('Tkachenko', 'Vasyl',  '2018-01-12', 550,  400, 'Assistant'),
('Marchenko', 'Nadiya', '1999-11-05', 500,  100, 'Assistant');
GO

-- 1
SELECT Name, Financing, Id
FROM Departments;
GO

-- 2
SELECT Name   AS [Group Name],
       Rating AS [Group Rating]
FROM Groups;
GO

-- 3
SELECT Surname,
       CAST(Salary AS FLOAT) / NULLIF(CAST(Premium AS FLOAT), 0) * 100          AS SalaryToPremiumPercent,
       CAST(Salary AS FLOAT) / (CAST(Salary AS FLOAT) + CAST(Premium AS FLOAT)) * 100 AS SalaryToTotalPercent
FROM Teachers;
GO

-- 4
SELECT CONCAT('The dean of faculty ', Name, ' is ', Dean, '.') AS FacultyInfo
FROM Faculties;
GO

-- 5
SELECT Surname
FROM Teachers
WHERE Position = 'Professor' AND Salary > 1050;
GO

-- 6
SELECT Name
FROM Departments
WHERE Financing < 11000 OR Financing > 25000;
GO

-- 7
SELECT Name
FROM Faculties
WHERE Name <> 'Computer Science';
GO

-- 8
SELECT Surname, Position
FROM Teachers
WHERE Position <> 'Professor';
GO

-- 9
SELECT Surname, Position, Salary, Premium
FROM Teachers
WHERE Position = 'Assistant' AND Premium BETWEEN 160 AND 550;
GO

-- 10
SELECT Surname, Salary
FROM Teachers
WHERE Position = 'Assistant';
GO

-- 11
SELECT Surname, Position
FROM Teachers
WHERE EmploymentDate < '2000-01-01';
GO

-- 12
SELECT Name AS [Name of Department]
FROM Departments
WHERE Name < 'Software Development'
ORDER BY Name;
GO