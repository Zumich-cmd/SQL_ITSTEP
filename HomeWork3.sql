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
    Id        INT IDENTITY(1,1) NOT NULL,
    Financing MONEY             NOT NULL DEFAULT (0),
    Name      NVARCHAR(100)     NOT NULL,

    CONSTRAINT PK_Faculties PRIMARY KEY (Id),
    CONSTRAINT UQ_Faculties_Name UNIQUE (Name),
    CONSTRAINT CHK_Faculties_Financing CHECK (Financing >= 0),
    CONSTRAINT CHK_Faculties_Name_NotEmpty CHECK (LEN(Name) > 0)
);
GO

CREATE TABLE Departments
(
    Id         INT IDENTITY(1,1) NOT NULL,
    Financing  MONEY             NOT NULL DEFAULT (0),
    Name       NVARCHAR(100)     NOT NULL,
    FacultyId  INT               NOT NULL,

    CONSTRAINT PK_Departments PRIMARY KEY (Id),
    CONSTRAINT UQ_Departments_Name UNIQUE (Name),
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
    Id      INT IDENTITY(1,1) NOT NULL,
    Name    NVARCHAR(MAX)     NOT NULL,
    Salary  MONEY             NOT NULL,
    Surname NVARCHAR(MAX)     NOT NULL,

    CONSTRAINT PK_Teachers PRIMARY KEY (Id),
    CONSTRAINT CHK_Teachers_Salary CHECK (Salary > 0),
    CONSTRAINT CHK_Teachers_Name_NotEmpty CHECK (LEN(Name) > 0),
    CONSTRAINT CHK_Teachers_Surname_NotEmpty CHECK (LEN(Surname) > 0)
);
GO

CREATE TABLE Lectures
(
    Id           INT IDENTITY(1,1) NOT NULL,
    LectureRoom  NVARCHAR(MAX)     NOT NULL,
    SubjectId    INT               NOT NULL,
    TeacherId    INT               NOT NULL,

    CONSTRAINT PK_Lectures PRIMARY KEY (Id),
    CONSTRAINT CHK_Lectures_LectureRoom_NotEmpty CHECK (LEN(LectureRoom) > 0),
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

INSERT INTO Faculties (Name, Financing) VALUES
('Computer Science', 40000),
('Economics', 30000),
('Law', 50000);
GO

INSERT INTO Departments (Name, Financing, FacultyId) VALUES
('Software Development', 45000, (SELECT Id FROM Faculties WHERE Name = 'Computer Science')),
('Database Systems',     10000, (SELECT Id FROM Faculties WHERE Name = 'Computer Science')),
('Applied Economics',    25000, (SELECT Id FROM Faculties WHERE Name = 'Economics')),
('Civil Law',            20000, (SELECT Id FROM Faculties WHERE Name = 'Law')),
('Criminal Law',         55000, (SELECT Id FROM Faculties WHERE Name = 'Law'));
GO

INSERT INTO Groups (Name, Year, DepartmentId) VALUES
('P107', 1, (SELECT Id FROM Departments WHERE Name = 'Software Development')),
('P108', 2, (SELECT Id FROM Departments WHERE Name = 'Database Systems')),
('E201', 2, (SELECT Id FROM Departments WHERE Name = 'Applied Economics')),
('L301', 3, (SELECT Id FROM Departments WHERE Name = 'Civil Law')),
('L302', 1, (SELECT Id FROM Departments WHERE Name = 'Criminal Law'));
GO

INSERT INTO Curators (Name, Surname) VALUES
('Olena', 'Kravchenko'),
('Serhii', 'Boyko'),
('Iryna', 'Tymoshenko');
GO

INSERT INTO GroupsCurators (CuratorId, GroupId) VALUES
((SELECT Id FROM Curators WHERE Surname = 'Kravchenko'), (SELECT Id FROM Groups WHERE Name = 'P107')),
((SELECT Id FROM Curators WHERE Surname = 'Boyko'),      (SELECT Id FROM Groups WHERE Name = 'P108')),
((SELECT Id FROM Curators WHERE Surname = 'Tymoshenko'), (SELECT Id FROM Groups WHERE Name = 'E201')),
((SELECT Id FROM Curators WHERE Surname = 'Kravchenko'), (SELECT Id FROM Groups WHERE Name = 'L301')),
((SELECT Id FROM Curators WHERE Surname = 'Boyko'),      (SELECT Id FROM Groups WHERE Name = 'L302'));
GO

INSERT INTO Subjects (Name) VALUES
('Database Systems'),
('Web Development'),
('Microeconomics'),
('Constitutional Law'),
('Criminal Procedure');
GO

INSERT INTO Teachers (Name, Surname, Salary) VALUES
('Samantha', 'Adams',      1200),
('Petro',    'Ivanenko',   1300),
('Olena',    'Kovalchuk',  1100),
('Andrii',   'Sydorenko',  1000);
GO

INSERT INTO Lectures (LectureRoom, SubjectId, TeacherId) VALUES
('101', (SELECT Id FROM Subjects WHERE Name = 'Database Systems'),   (SELECT Id FROM Teachers WHERE Surname = 'Adams')),
('102', (SELECT Id FROM Subjects WHERE Name = 'Web Development'),    (SELECT Id FROM Teachers WHERE Surname = 'Adams')),
('103', (SELECT Id FROM Subjects WHERE Name = 'Database Systems'),   (SELECT Id FROM Teachers WHERE Surname = 'Ivanenko')),
('201', (SELECT Id FROM Subjects WHERE Name = 'Microeconomics'),     (SELECT Id FROM Teachers WHERE Surname = 'Ivanenko')),
('301', (SELECT Id FROM Subjects WHERE Name = 'Constitutional Law'), (SELECT Id FROM Teachers WHERE Surname = 'Kovalchuk')),
('302', (SELECT Id FROM Subjects WHERE Name = 'Criminal Procedure'), (SELECT Id FROM Teachers WHERE Surname = 'Sydorenko'));
GO

INSERT INTO GroupsLectures (GroupId, LectureId) VALUES
((SELECT Id FROM Groups WHERE Name = 'P107'), (SELECT Id FROM Lectures WHERE LectureRoom = '101')),
((SELECT Id FROM Groups WHERE Name = 'P107'), (SELECT Id FROM Lectures WHERE LectureRoom = '102')),
((SELECT Id FROM Groups WHERE Name = 'P108'), (SELECT Id FROM Lectures WHERE LectureRoom = '103')),
((SELECT Id FROM Groups WHERE Name = 'E201'), (SELECT Id FROM Lectures WHERE LectureRoom = '201')),
((SELECT Id FROM Groups WHERE Name = 'L301'), (SELECT Id FROM Lectures WHERE LectureRoom = '301')),
((SELECT Id FROM Groups WHERE Name = 'L302'), (SELECT Id FROM Lectures WHERE LectureRoom = '302'));
GO

-- 1
SELECT *
FROM Teachers
CROSS JOIN Groups;
GO

-- 2
SELECT F.Name
FROM Faculties F
JOIN Departments D ON D.FacultyId = F.Id
GROUP BY F.Id, F.Name, F.Financing
HAVING SUM(D.Financing) > F.Financing;
GO

-- 3
SELECT C.Surname, G.Name AS GroupName
FROM Curators C
JOIN GroupsCurators GC ON GC.CuratorId = C.Id
JOIN Groups G ON G.Id = GC.GroupId;
GO

-- 4
SELECT DISTINCT T.Surname
FROM Teachers T
JOIN Lectures L ON L.TeacherId = T.Id
JOIN GroupsLectures GL ON GL.LectureId = L.Id
JOIN Groups G ON G.Id = GL.GroupId
WHERE G.Name = 'P107';
GO

-- 5
SELECT DISTINCT T.Surname, F.Name AS FacultyName
FROM Teachers T
JOIN Lectures L ON L.TeacherId = T.Id
JOIN GroupsLectures GL ON GL.LectureId = L.Id
JOIN Groups G ON G.Id = GL.GroupId
JOIN Departments D ON D.Id = G.DepartmentId
JOIN Faculties F ON F.Id = D.FacultyId;
GO

-- 6
SELECT D.Name AS DepartmentName, G.Name AS GroupName
FROM Departments D
JOIN Groups G ON G.DepartmentId = D.Id;
GO

-- 7
SELECT DISTINCT S.Name
FROM Subjects S
JOIN Lectures L ON L.SubjectId = S.Id
JOIN Teachers T ON T.Id = L.TeacherId
WHERE T.Name = 'Samantha' AND T.Surname = 'Adams';
GO