IF DB_ID('Academy') IS NOT NULL
BEGIN
    ALTER DATABASE Academy SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Academy;
END
GO

CREATE DATABASE Academy;
GO

USE Academy;
GO

CREATE TABLE Faculties
(
    Id   INT IDENTITY(1,1) NOT NULL,
    Name NVARCHAR(100)     NOT NULL,

    CONSTRAINT PK_Faculties PRIMARY KEY (Id),
    CONSTRAINT UQ_Faculties_Name UNIQUE (Name),
    CONSTRAINT CHK_Faculties_Name_NotEmpty CHECK (LEN(Name) > 0)
);
GO

CREATE TABLE Departments
(
    Id         INT IDENTITY(1,1) NOT NULL,
    Building   INT               NOT NULL,
    Financing  MONEY             NOT NULL DEFAULT (0),
    Name       NVARCHAR(100)     NOT NULL,
    FacultyId  INT               NOT NULL,

    CONSTRAINT PK_Departments PRIMARY KEY (Id),
    CONSTRAINT UQ_Departments_Name UNIQUE (Name),
    CONSTRAINT CHK_Departments_Building CHECK (Building BETWEEN 1 AND 5),
    CONSTRAINT CHK_Departments_Financing CHECK (Financing >= 0),
    CONSTRAINT CHK_Departments_Name_NotEmpty CHECK (LEN(Name) > 0),
    CONSTRAINT FK_Departments_Faculties FOREIGN KEY (FacultyId) REFERENCES Faculties (Id)
);
GO

CREATE TABLE Groups
(
    Id            INT IDENTITY(1,1) NOT NULL,
    Name          NVARCHAR(10)      NOT NULL,
    Year          INT               NOT NULL,
    DepartmentId  INT               NOT NULL,

    CONSTRAINT PK_Groups PRIMARY KEY (Id),
    CONSTRAINT UQ_Groups_Name UNIQUE (Name),
    CONSTRAINT CHK_Groups_Name_NotEmpty CHECK (LEN(Name) > 0),
    CONSTRAINT CHK_Groups_Year CHECK (Year BETWEEN 1 AND 5),
    CONSTRAINT FK_Groups_Departments FOREIGN KEY (DepartmentId) REFERENCES Departments (Id)
);
GO

CREATE TABLE Curators
(
    Id      INT IDENTITY(1,1) NOT NULL,
    Name    NVARCHAR(MAX)     NOT NULL,
    Surname NVARCHAR(MAX)     NOT NULL,

    CONSTRAINT PK_Curators PRIMARY KEY (Id),
    CONSTRAINT CHK_Curators_Name_NotEmpty CHECK (LEN(Name) > 0),
    CONSTRAINT CHK_Curators_Surname_NotEmpty CHECK (LEN(Surname) > 0)
);
GO

CREATE TABLE GroupsCurators
(
    Id         INT IDENTITY(1,1) NOT NULL,
    CuratorId  INT               NOT NULL,
    GroupId    INT               NOT NULL,

    CONSTRAINT PK_GroupsCurators PRIMARY KEY (Id),
    CONSTRAINT FK_GroupsCurators_Curators FOREIGN KEY (CuratorId) REFERENCES Curators (Id),
    CONSTRAINT FK_GroupsCurators_Groups FOREIGN KEY (GroupId) REFERENCES Groups (Id)
);
GO

CREATE TABLE Subjects
(
    Id   INT IDENTITY(1,1) NOT NULL,
    Name NVARCHAR(100)     NOT NULL,

    CONSTRAINT PK_Subjects PRIMARY KEY (Id),
    CONSTRAINT UQ_Subjects_Name UNIQUE (Name),
    CONSTRAINT CHK_Subjects_Name_NotEmpty CHECK (LEN(Name) > 0)
);
GO

CREATE TABLE Teachers
(
    Id           INT IDENTITY(1,1) NOT NULL,
    IsProfessor  BIT               NOT NULL DEFAULT (0),
    Name         NVARCHAR(MAX)     NOT NULL,
    Salary       MONEY             NOT NULL,
    Surname      NVARCHAR(MAX)     NOT NULL,

    CONSTRAINT PK_Teachers PRIMARY KEY (Id),
    CONSTRAINT CHK_Teachers_Salary CHECK (Salary > 0),
    CONSTRAINT CHK_Teachers_Name_NotEmpty CHECK (LEN(Name) > 0),
    CONSTRAINT CHK_Teachers_Surname_NotEmpty CHECK (LEN(Surname) > 0)
);
GO

CREATE TABLE Lectures
(
    Id         INT IDENTITY(1,1) NOT NULL,
    Date       DATE              NOT NULL,
    SubjectId  INT               NOT NULL,
    TeacherId  INT               NOT NULL,

    CONSTRAINT PK_Lectures PRIMARY KEY (Id),
    CONSTRAINT CHK_Lectures_Date CHECK (Date <= CAST(GETDATE() AS DATE)),
    CONSTRAINT FK_Lectures_Subjects FOREIGN KEY (SubjectId) REFERENCES Subjects (Id),
    CONSTRAINT FK_Lectures_Teachers FOREIGN KEY (TeacherId) REFERENCES Teachers (Id)
);
GO

CREATE TABLE GroupsLectures
(
    Id         INT IDENTITY(1,1) NOT NULL,
    GroupId    INT               NOT NULL,
    LectureId  INT               NOT NULL,

    CONSTRAINT PK_GroupsLectures PRIMARY KEY (Id),
    CONSTRAINT FK_GroupsLectures_Groups FOREIGN KEY (GroupId) REFERENCES Groups (Id),
    CONSTRAINT FK_GroupsLectures_Lectures FOREIGN KEY (LectureId) REFERENCES Lectures (Id)
);
GO

CREATE TABLE Students
(
    Id      INT IDENTITY(1,1) NOT NULL,
    Name    NVARCHAR(MAX)     NOT NULL,
    Rating  INT               NOT NULL,
    Surname NVARCHAR(MAX)     NOT NULL,

    CONSTRAINT PK_Students PRIMARY KEY (Id),
    CONSTRAINT CHK_Students_Rating CHECK (Rating BETWEEN 0 AND 5),
    CONSTRAINT CHK_Students_Name_NotEmpty CHECK (LEN(Name) > 0),
    CONSTRAINT CHK_Students_Surname_NotEmpty CHECK (LEN(Surname) > 0)
);
GO

CREATE TABLE GroupsStudents
(
    Id         INT IDENTITY(1,1) NOT NULL,
    GroupId    INT               NOT NULL,
    StudentId  INT               NOT NULL,

    CONSTRAINT PK_GroupsStudents PRIMARY KEY (Id),
    CONSTRAINT FK_GroupsStudents_Groups FOREIGN KEY (GroupId) REFERENCES Groups (Id),
    CONSTRAINT FK_GroupsStudents_Students FOREIGN KEY (StudentId) REFERENCES Students (Id)
);
GO

INSERT INTO Faculties (Name) VALUES
('Computer Science'),
('Economics'),
('Law');
GO

INSERT INTO Departments (Name, Building, Financing, FacultyId) VALUES
('Software Development', 1, 95000, (SELECT Id FROM Faculties WHERE Name = 'Computer Science')),
('Database Systems',     1, 10000, (SELECT Id FROM Faculties WHERE Name = 'Computer Science')),
('Applied Economics',    2, 25000, (SELECT Id FROM Faculties WHERE Name = 'Economics')),
('Marketing',            2, 12000, (SELECT Id FROM Faculties WHERE Name = 'Economics')),
('Civil Law',            3, 20000, (SELECT Id FROM Faculties WHERE Name = 'Law')),
('Criminal Law',         3, 90000, (SELECT Id FROM Faculties WHERE Name = 'Law'));
GO

INSERT INTO Groups (Name, Year, DepartmentId) VALUES
('P107', 1, (SELECT Id FROM Departments WHERE Name = 'Software Development')),
('P207', 5, (SELECT Id FROM Departments WHERE Name = 'Software Development')),
('P208', 5, (SELECT Id FROM Departments WHERE Name = 'Software Development')),
('D221', 3, (SELECT Id FROM Departments WHERE Name = 'Database Systems')),
('E201', 2, (SELECT Id FROM Departments WHERE Name = 'Applied Economics')),
('E305', 5, (SELECT Id FROM Departments WHERE Name = 'Applied Economics')),
('L301', 3, (SELECT Id FROM Departments WHERE Name = 'Civil Law')),
('L090', 2, (SELECT Id FROM Departments WHERE Name = 'Criminal Law'));
GO

INSERT INTO Curators (Name, Surname) VALUES
('Olena', 'Kravchenko'),
('Serhii', 'Boyko'),
('Iryna', 'Tymoshenko');
GO

INSERT INTO GroupsCurators (CuratorId, GroupId) VALUES
((SELECT Id FROM Curators WHERE Surname = 'Kravchenko'), (SELECT Id FROM Groups WHERE Name = 'P107')),
((SELECT Id FROM Curators WHERE Surname = 'Kravchenko'), (SELECT Id FROM Groups WHERE Name = 'P207')),
((SELECT Id FROM Curators WHERE Surname = 'Boyko'),      (SELECT Id FROM Groups WHERE Name = 'P207')),
((SELECT Id FROM Curators WHERE Surname = 'Boyko'),      (SELECT Id FROM Groups WHERE Name = 'D221')),
((SELECT Id FROM Curators WHERE Surname = 'Tymoshenko'), (SELECT Id FROM Groups WHERE Name = 'E201')),
((SELECT Id FROM Curators WHERE Surname = 'Kravchenko'), (SELECT Id FROM Groups WHERE Name = 'E201'));
GO

INSERT INTO Students (Name, Surname, Rating) VALUES
('Anna', 'Blue', 4), ('Boris', 'Green', 3),        -- P107  avg 3.5
('Carl', 'White', 5), ('Dana', 'Black', 4),         -- P207  avg 4.5
('Eva', 'Brown', 3), ('Frank', 'Gray', 3),          -- P208  avg 3.0
('Gina', 'Silver', 2), ('Hank', 'Gold', 2),         -- D221  avg 2.0
('Ivy', 'Rose', 4), ('Jack', 'Stone', 3),           -- E201  avg 3.5
('Kim', 'Lake', 2), ('Leo', 'Hill', 3),             -- E305  avg 2.5
('Mia', 'Reed', 5), ('Nick', 'Ford', 4),            -- L301  avg 4.5
('Omar', 'Price', 1), ('Paul', 'Quinn', 0);         -- L090  avg 0.5
GO

INSERT INTO GroupsStudents (GroupId, StudentId)
SELECT G.Id, S.Id
FROM (VALUES
    ('P107','Blue'), ('P107','Green'),
    ('P207','White'), ('P207','Black'),
    ('P208','Brown'), ('P208','Gray'),
    ('D221','Silver'), ('D221','Gold'),
    ('E201','Rose'), ('E201','Stone'),
    ('E305','Lake'), ('E305','Hill'),
    ('L301','Reed'), ('L301','Ford'),
    ('L090','Price'), ('L090','Quinn')
) AS X(GroupName, StudentSurname)
JOIN Groups G ON G.Name = X.GroupName
JOIN Students S ON S.Surname = X.StudentSurname;
GO

INSERT INTO Subjects (Name) VALUES
('Algorithms'),
('Database Systems'),
('Microeconomics');
GO

INSERT INTO Teachers (IsProfessor, Name, Surname, Salary) VALUES
(1, 'Dave',     'McQueen',   1500),
(1, 'Jack',     'Underhill', 1700),
(1, 'Andrii',   'Sydorenko', 1000),
(0, 'Samantha', 'Adams',     1200),
(0, 'Olena',    'Kovalchuk', 1900);
GO

DECLARE @P207Lectures TABLE (Id INT);
DECLARE @P208Lectures TABLE (Id INT);
DECLARE @AlgId INT = (SELECT Id FROM Subjects WHERE Name = 'Algorithms');
DECLARE @UnderhillId INT = (SELECT Id FROM Teachers WHERE Surname = 'Underhill');

INSERT INTO Lectures (Date, SubjectId, TeacherId)
OUTPUT INSERTED.Id INTO @P207Lectures
SELECT DATEADD(DAY, (N - 1) % 7, '2026-02-02'), @AlgId, @UnderhillId
FROM (SELECT TOP (12) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N FROM sys.all_objects) AS Nums;

INSERT INTO Lectures (Date, SubjectId, TeacherId)
OUTPUT INSERTED.Id INTO @P208Lectures
SELECT DATEADD(DAY, (N - 1) % 7, '2026-02-02'), @AlgId, @UnderhillId
FROM (SELECT TOP (3) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N FROM sys.all_objects) AS Nums;

INSERT INTO GroupsLectures (GroupId, LectureId)
SELECT (SELECT Id FROM Groups WHERE Name = 'P207'), Id FROM @P207Lectures;

INSERT INTO GroupsLectures (GroupId, LectureId)
SELECT (SELECT Id FROM Groups WHERE Name = 'P208'), Id FROM @P208Lectures;

DECLARE @LateLectureId INT;
INSERT INTO Lectures (Date, SubjectId, TeacherId) VALUES ('2026-02-15', @AlgId, @UnderhillId);
SET @LateLectureId = SCOPE_IDENTITY();

INSERT INTO GroupsLectures (GroupId, LectureId) VALUES
((SELECT Id FROM Groups WHERE Name = 'P207'), @LateLectureId),
((SELECT Id FROM Groups WHERE Name = 'P208'), @LateLectureId);
GO

-- 1
SELECT Building
FROM Departments
GROUP BY Building
HAVING SUM(Financing) > 100000;
GO

-- 2
SELECT G.Name
FROM Groups G
JOIN Departments D ON D.Id = G.DepartmentId
WHERE D.Name = 'Software Development'
  AND G.Year = 5
  AND (
        SELECT COUNT(*)
        FROM GroupsLectures GL
        JOIN Lectures L ON L.Id = GL.LectureId
        WHERE GL.GroupId = G.Id
          AND L.Date BETWEEN (SELECT MIN(Date) FROM Lectures)
                          AND DATEADD(DAY, 6, (SELECT MIN(Date) FROM Lectures))
      ) > 10;
GO

-- 3
SELECT G.Name
FROM Groups G
WHERE (
        SELECT AVG(CAST(S.Rating AS FLOAT))
        FROM GroupsStudents GS
        JOIN Students S ON S.Id = GS.StudentId
        WHERE GS.GroupId = G.Id
      ) > (
        SELECT AVG(CAST(S2.Rating AS FLOAT))
        FROM GroupsStudents GS2
        JOIN Students S2 ON S2.Id = GS2.StudentId
        JOIN Groups G2 ON G2.Id = GS2.GroupId
        WHERE G2.Name = 'D221'
      );
GO

-- 4
SELECT Surname, Name
FROM Teachers
WHERE Salary > (SELECT AVG(Salary) FROM Teachers WHERE IsProfessor = 1);
GO

-- 5
SELECT G.Name
FROM Groups G
WHERE (SELECT COUNT(*) FROM GroupsCurators GC WHERE GC.GroupId = G.Id) > 1;
GO

-- 6
SELECT G.Name
FROM Groups G
WHERE (
        SELECT AVG(CAST(S.Rating AS FLOAT))
        FROM GroupsStudents GS
        JOIN Students S ON S.Id = GS.StudentId
        WHERE GS.GroupId = G.Id
      ) < (
        SELECT MIN(GroupAvg)
        FROM (
            SELECT AVG(CAST(S2.Rating AS FLOAT)) AS GroupAvg
            FROM Groups G2
            JOIN GroupsStudents GS2 ON GS2.GroupId = G2.Id
            JOIN Students S2 ON S2.Id = GS2.StudentId
            WHERE G2.Year = 5
            GROUP BY G2.Id
        ) AS FifthYearAverages
      );
GO

-- 7
SELECT F.Name
FROM Faculties F
WHERE (SELECT SUM(D.Financing) FROM Departments D WHERE D.FacultyId = F.Id)
    > (
        SELECT SUM(D2.Financing)
        FROM Departments D2
        JOIN Faculties F2 ON F2.Id = D2.FacultyId
        WHERE F2.Name = 'Computer Science'
      );
GO