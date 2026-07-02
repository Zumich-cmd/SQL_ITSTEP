USE Academy;
GO

-- 1. Аналог "повна інформація про всі товари"
CREATE OR ALTER PROCEDURE sp_GetAllTeachers
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Id, Name, Surname, IsProfessor, Salary
    FROM Teachers;
END
GO

-- 2. Аналог "товари конкретного виду (параметр)"
CREATE OR ALTER PROCEDURE sp_GetGroupsByYear
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT G.Name AS GroupName, G.Year, D.Name AS Department, F.Name AS Faculty
    FROM Groups G
    JOIN Departments D ON D.Id = G.DepartmentId
    JOIN Faculties F ON F.Id = D.FacultyId
    WHERE G.Year = @Year;
END
GO

-- ---------------------------------------------------------
-- 3. Аналог "топ-3 найстаріших клієнтів (за датою реєстрації)"
CREATE OR ALTER PROCEDURE sp_GetTop3StudentsByRating
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (3) Id, Name, Surname, Rating
    FROM Students
    ORDER BY Rating DESC;
END
GO

-- 4. Аналог "найуспішніший продавець"
CREATE OR ALTER PROCEDURE sp_GetMostActiveTeacher
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1) T.Id, T.Name, T.Surname, COUNT(L.Id) AS LectureCount
    FROM Teachers T
    JOIN Lectures L ON L.TeacherId = T.Id
    GROUP BY T.Id, T.Name, T.Surname
    ORDER BY LectureCount DESC;
END
GO