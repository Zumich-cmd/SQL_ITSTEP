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
    Id             INT IDENTITY(1,1) NOT NULL,
    Name           NVARCHAR(10)      NOT NULL,
    Year           INT               NOT NULL,
    DepartmentId   INT               NOT NULL,
    StudentsCount  INT               NOT NULL DEFAULT (0),

    CONSTRAINT PK_Groups PRIMARY KEY (Id),
    CONSTRAINT UQ_Groups_Name UNIQUE (Name),
    CONSTRAINT CHK_Groups_Name_NotEmpty CHECK (LEN(Name) > 0),
    CONSTRAINT CHK_Groups_Year CHECK (Year BETWEEN 1 AND 5),
    CONSTRAINT CHK_Groups_StudentsCount CHECK (StudentsCount >= 0),
    CONSTRAINT FK_Groups_Departments FOREIGN KEY (DepartmentId) REFERENCES Departments (Id)
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
    DayOfWeek    INT               NOT NULL,
    LectureRoom  NVARCHAR(MAX)     NOT NULL,
    SubjectId    INT               NOT NULL,
    TeacherId    INT               NOT NULL,

    CONSTRAINT PK_Lectures PRIMARY KEY (Id),
    CONSTRAINT CHK_Lectures_DayOfWeek CHECK (DayOfWeek BETWEEN 1 AND 7),
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

INSERT INTO Faculties (Name) VALUES
('Computer Science'),
('Economics');
GO

INSERT INTO Departments (Name, Financing, FacultyId) VALUES
('Software Development', 45000, (SELECT Id FROM Faculties WHERE Name = 'Computer Science')),
('Database Systems',     10000, (SELECT Id FROM Faculties WHERE Name = 'Computer Science')),
('Applied Economics',    25000, (SELECT Id FROM Faculties WHERE Name = 'Economics'));
GO

INSERT INTO Groups (Name, Year, DepartmentId, StudentsCount) VALUES
('P107', 1, (SELECT Id FROM Departments WHERE Name = 'Software Development'), 25),
('P109', 2, (SELECT Id FROM Departments WHERE Name = 'Software Development'), 18),
('P108', 2, (SELECT Id FROM Departments WHERE Name = 'Database Systems'), 20),
('E201', 2, (SELECT Id FROM Departments WHERE Name = 'Applied Economics'), 30);
GO

INSERT INTO Subjects (Name) VALUES
('Database Systems'),
('Web Development'),
('Algorithms'),
('Microeconomics');
GO

INSERT INTO Teachers (Name, Surname, Salary) VALUES
('Dave',     'McQueen',   1200),
('Jack',     'Underhill', 1300),
('Samantha', 'Adams',     1100),
('Olena',    'Kovalchuk', 1000);
GO

INSERT INTO Lectures (DayOfWeek, LectureRoom, SubjectId, TeacherId) VALUES
(1, 'D201', (SELECT Id FROM Subjects WHERE Name = 'Database Systems'), (SELECT Id FROM Teachers WHERE Surname = 'McQueen')),
(2, 'D201', (SELECT Id FROM Subjects WHERE Name = 'Web Development'),  (SELECT Id FROM Teachers WHERE Surname = 'McQueen')),
(3, 'A101', (SELECT Id FROM Subjects WHERE Name = 'Algorithms'),       (SELECT Id FROM Teachers WHERE Surname = 'Underhill')),
(4, 'A101', (SELECT Id FROM Subjects WHERE Name = 'Microeconomics'),   (SELECT Id FROM Teachers WHERE Surname = 'Kovalchuk')),
(5, 'D201', (SELECT Id FROM Subjects WHERE Name = 'Web Development'),  (SELECT Id FROM Teachers WHERE Surname = 'Adams'));
GO

INSERT INTO GroupsLectures (GroupId, LectureId)
SELECT G.Id, L.Id
FROM (VALUES
    ('P107', 1, 'D201'),   -- P107 -> McQueen, DB Systems
    ('P108', 1, 'D201'),   -- P108 -> McQueen, DB Systems
    ('P107', 2, 'D201'),   -- P107 -> McQueen, Web Dev
    ('P107', 3, 'A101'),   -- P107 -> Underhill, Algorithms
    ('P109', 3, 'A101'),   -- P109 -> Underhill, Algorithms
    ('E201', 4, 'A101'),   -- E201 -> Kovalchuk, Microeconomics
    ('P108', 5, 'D201')    -- P108 -> Adams, Web Dev
) AS X(GroupName, DayOfWeek, Room)
JOIN Groups G ON G.Name = X.GroupName
JOIN Lectures L ON L.DayOfWeek = X.DayOfWeek AND L.LectureRoom = X.Room;
GO

-- 1
SELECT COUNT(DISTINCT T.Id) AS TeacherCount
FROM Teachers T
JOIN Lectures L ON L.TeacherId = T.Id
JOIN GroupsLectures GL ON GL.LectureId = L.Id
JOIN Groups G ON G.Id = GL.GroupId
JOIN Departments D ON D.Id = G.DepartmentId
WHERE D.Name = 'Software Development';
GO

-- 2
SELECT COUNT(*) AS LectureCount
FROM Lectures L
JOIN Teachers T ON T.Id = L.TeacherId
WHERE T.Name = 'Dave' AND T.Surname = 'McQueen';
GO

-- 3
SELECT COUNT(*) AS LectureCount
FROM Lectures
WHERE LectureRoom = 'D201';
GO

-- 4
SELECT LectureRoom, COUNT(*) AS LectureCount
FROM Lectures
GROUP BY LectureRoom;
GO

-- 5
SELECT SUM(StudentsCount) AS TotalStudents
FROM Groups
WHERE Id IN (
    SELECT DISTINCT GL.GroupId
    FROM GroupsLectures GL
    JOIN Lectures L ON L.Id = GL.LectureId
    JOIN Teachers T ON T.Id = L.TeacherId
    WHERE T.Name = 'Jack' AND T.Surname = 'Underhill'
);
GO

-- 6
SELECT AVG(Salary) AS AvgSalary
FROM Teachers
WHERE Id IN (
    SELECT DISTINCT T.Id
    FROM Teachers T
    JOIN Lectures L ON L.TeacherId = T.Id
    JOIN GroupsLectures GL ON GL.LectureId = L.Id
    JOIN Groups G ON G.Id = GL.GroupId
    JOIN Departments D ON D.Id = G.DepartmentId
    JOIN Faculties F ON F.Id = D.FacultyId
    WHERE F.Name = 'Computer Science'
);
GO

-- 7
SELECT MIN(StudentsCount) AS MinStudents,
       MAX(StudentsCount) AS MaxStudents
FROM Groups;
GO