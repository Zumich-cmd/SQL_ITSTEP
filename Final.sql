-- Частина 1.

CREATE DATABASE EcoRideDB;
GO
USE EcoRideDB;
GO

CREATE TABLE dbo.Customers
(
    CustomerId          INT IDENTITY(1,1) CONSTRAINT PK_Customers PRIMARY KEY,
    FullName             NVARCHAR(100) NOT NULL,
    City                 NVARCHAR(50)  NOT NULL,
    Balance              DECIMAL(18,2) NOT NULL CONSTRAINT DF_Customers_Balance DEFAULT 0.00,
    AccountStatus_Demo   NVARCHAR(50)  NULL
);
GO

CREATE TABLE dbo.Payments
(
    PaymentId    INT IDENTITY(1,1) CONSTRAINT PK_Payments PRIMARY KEY,
    CustomerId   INT NOT NULL CONSTRAINT FK_Payments_Customers FOREIGN KEY REFERENCES dbo.Customers (CustomerId),
    Amount       DECIMAL(18,2) NOT NULL,
    PaymentDate  DATETIME NOT NULL CONSTRAINT DF_Payments_Date DEFAULT GETDATE(),
    KioskId      INT NOT NULL
);
GO

CREATE TABLE dbo.Rentals
(
    RentalId      INT IDENTITY(1,1) CONSTRAINT PK_Rentals PRIMARY KEY,
    CustomerId    INT NOT NULL CONSTRAINT FK_Rentals_Customers FOREIGN KEY REFERENCES dbo.Customers (CustomerId),
    ScooterModel  NVARCHAR(100) NOT NULL,
    RentalCost    DECIMAL(10,2) NOT NULL CONSTRAINT CK_Rentals_Cost CHECK (RentalCost >= 0),
    DistanceKm    DECIMAL(5,2) NOT NULL,
    EndStatus     NVARCHAR(30) NOT NULL,
    RentalDate    DATETIME NOT NULL
);
GO

INSERT INTO dbo.Customers (FullName, City, Balance, AccountStatus_Demo) VALUES
(N'Василь Ткачук',     N'Київ',  12500.00, 'Premium'),
(N'Олена Петрів',      N'Львів', 450.00,   'Standard'),
(N'Микола Сидоренко',  N'Київ',  32000.00, 'VIP'),
(N'Тетяна Шевченко',   N'Одеса', 150.00,   'Premium'),
(N'Андрій Бондаренко', N'Львів', 2100.00,  'Unknown');

INSERT INTO dbo.Payments (CustomerId, Amount, PaymentDate, KioskId) VALUES
(1, 5000.00,  '2026-06-01 09:15:00', 201),
(1, 6500.00,  '2026-06-03 11:40:00', 202),
(2, 300.00,   '2026-06-01 13:00:00', 201),
(3, 15000.00, '2026-06-02 17:25:00', 203),
(4, 100.00,   '2026-05-20 14:10:00', 201),
(5, 850.00,   '2026-06-04 19:30:00', 202);

INSERT INTO dbo.Rentals (CustomerId, ScooterModel, RentalCost, DistanceKm, EndStatus, RentalDate) VALUES
(1, 'Xiaomi Pro 4',  180.00, 12.40, 'Finished', '2026-06-01'),
(3, 'Ninebot Max',   290.00, 22.10, 'Finished', '2026-06-02'),
(2, 'Xiaomi Pro 4',  95.00,  4.50,  'Damaged',  '2026-06-02'),
(4, 'Bolt Base',     130.00, 8.20,  'Finished', '2026-06-03'),
(5, 'Ninebot Max',   210.00, 15.60, 'Active',   '2026-06-04');
GO

-- Блок А - Базовий рівень

USE EcoRideDB;
GO

-- Завдання 1.
SELECT
    C.FullName,
    SUM(P.Amount) AS TotalPayments
FROM dbo.Customers C
JOIN dbo.Payments P ON P.CustomerId = C.CustomerId
WHERE P.PaymentDate >= '2026-06-01' AND P.PaymentDate < '2026-07-01'
GROUP BY C.CustomerId, C.FullName
HAVING SUM(P.Amount) > 8000
ORDER BY TotalPayments DESC;
GO

-- Завдання 2.
SELECT
    RentalId,
    ScooterModel,
    RentalCost,
    CASE
        WHEN RentalCost > 200 AND DistanceKm > 15 THEN 'LongTrip'
        WHEN EndStatus = 'Damaged' THEN 'Penalty'
        ELSE 'Regular'
    END AS TripCategory
FROM dbo.Rentals;
GO

-- Блок Б - Просунутий рівень

-- Завдання 3.
SELECT
    C.City,
    R.ScooterModel,
    R.RentalCost,
    ROW_NUMBER() OVER (PARTITION BY C.City ORDER BY R.RentalCost DESC) AS RankInCity
FROM dbo.Rentals R
JOIN dbo.Customers C ON C.CustomerId = R.CustomerId
ORDER BY C.City, RankInCity;
GO

-- Завдання 4.
CREATE OR ALTER PROCEDURE dbo.sp_RegisterRentalPayment
    @CustomerId INT,
    @Amount     DECIMAL(18,2),
    @KioskId    INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;  -- гарантує автоматичний rollback при непередбаченій помилці

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CurrentBalance DECIMAL(18,2);

        SELECT @CurrentBalance = Balance
        FROM dbo.Customers WITH (UPDLOCK, HOLDLOCK)
        WHERE CustomerId = @CustomerId;

        IF @CurrentBalance IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR(N'Клієнта з Id=%d не знайдено.', 16, 1, @CustomerId);
            RETURN;
        END

        IF @CurrentBalance < @Amount
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR(N'Недостатньо коштів на балансі клієнта %d.', 16, 1, @CustomerId);
            RETURN;
        END

        UPDATE dbo.Customers
        SET Balance = Balance - @Amount
        WHERE CustomerId = @CustomerId;

        INSERT INTO dbo.Payments (CustomerId, Amount, KioskId)
        VALUES (@CustomerId, @Amount, @KioskId);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;  -- кинути помилку виклику далі (наприклад, застосунку)
    END CATCH
END
GO

-- Блок В

-- Завдання 5
--
-- Оригінал коду -
-- SELECT * FROM dbo.Payments WHERE YEAR(PaymentDate) = 2026 AND MONTH(PaymentDate) = 6;
--
-- Тут проблема в тому, що до PaymentDate застосовуються функції
-- YEAR() і MONTH(). Через це SQL Server вже не може нормально
-- використати індекс по цьому стовпцю.
--
-- Замість того щоб одразу знайти потрібні записи, йому потрібно
-- пройтись по всіх рядках таблиці, для кожного визначити рік
-- і місяць, а вже потім перевірити умову.
--
-- Такий запит називається NON-SARGable, тому що умова WHERE
-- не дозволяє нормально використовувати індекс.
--
-- Якщо ж використовувати не YEAR() і MONTH(), а діапазон дат,
-- тоді SQL Server зможе одразу знайти потрібний проміжок через
-- індекс. Такий запит вже буде SARGable.
--
-- У плані виконання це буде виглядати приблизно так:
-- NON-SARGable -> Index Scan або Table Scan
-- SARGable     -> Index Seek
--
-- Тому на великих таблицях краще не використовувати функції
-- для індексованих стовпців у WHERE, тому що через це запит
-- може виконуватись набагато довше.

SELECT PaymentId, CustomerId, Amount, PaymentDate, KioskId
FROM dbo.Payments
WHERE PaymentDate >= '2026-06-01'
  AND PaymentDate <  '2026-07-01';

-- PaymentDate тепер використовується без функцій,
-- тому SQL Server може скористатися індексом.
-- Через це він одразу знаходить потрібні записи
-- за допомогою Index Seek, а не переглядає всю
-- таблицю через Index Scan або Table Scan.


CREATE NONCLUSTERED INDEX IX_Payments_PaymentDate_Covering
ON dbo.Payments (PaymentDate)
INCLUDE (Amount, CustomerId, KioskId);
GO

-- Чому саме так:
-- PaymentDate знаходиться в KEY, тому що саме по цьому стовпцю
-- відбувається пошук у WHERE. Через це SQL Server може швидко
-- знайти потрібні записи за допомогою Index Seek.
--
-- Amount, CustomerId і KioskId знаходяться в INCLUDE, тому що
-- вони теж потрібні запиту. Завдяки цьому SQL Server не потрібно
-- додатково звертатись до таблиці, щоб отримати ці значення.
--
-- Виходить, що всі потрібні дані вже є в самому індексі,
-- тому запит виконується швидше.
--
-- Такий індекс називається covering index, тому що він
-- повністю покриває запит і не потребує додаткового читання
-- даних із таблиці.