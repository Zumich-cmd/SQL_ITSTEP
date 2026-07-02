USE HogwartsDB;
GO

-- ЗАВДАННЯ 1
ALTER TABLE dbo.Wizards
ALTER COLUMN BloodStatus ADD MASKED WITH (FUNCTION = 'partial(0,"XXXXX",0)');
GO

GRANT SELECT ON dbo.Wizards TO HStudentRole;
GO

EXECUTE AS USER = 'HarryPotter';

SELECT WizardId, [Name], House, BloodStatus
FROM dbo.Wizards;

REVERT;
GO

SELECT WizardId, [Name], House, BloodStatus
FROM dbo.Wizards;
GO

-- ЗАВДАННЯ 2.

CREATE TABLE MaraudersMapLogs
(
	TrackId       INT IDENTITY(1, 1) PRIMARY KEY,
	WizardName    NVARCHAR(100) NOT NULL,
	[Location]    NVARCHAR(100) NOT NULL,
	MovementTime  DATETIME      NOT NULL
);
GO

INSERT INTO MaraudersMapLogs (WizardName, [Location], MovementTime) VALUES
(N'Гаррі Поттер',        N'Заборонений ліс',   '2026-06-01 22:15:00'),
(N'Герміона Грейнджер',  N'Бібліотека',        '2026-06-15 20:00:00'),
(N'Драко Мелфой',        N'Підземелля',        '2026-05-30 23:45:00'), -- поза червнем -- не має потрапити у вибірку
(N'Луна Лавґуд',         N'Вежа Рейвенклову',  '2026-06-20 06:30:00'),
(N'Седрик Діґорі',       N'Квідичне поле',     '2026-07-01 08:00:00'); -- поза червнем -- не має потрапити у вибірку
GO

SELECT TrackId, WizardName, [Location], MovementTime
FROM MaraudersMapLogs
WHERE MovementTime >= '2026-06-01'
  AND MovementTime <  '2026-07-01';
GO