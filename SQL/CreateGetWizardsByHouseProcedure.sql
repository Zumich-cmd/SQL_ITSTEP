CREATE PROCEDURE dbo.sp_GetWizardsByHouse
    @House NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Id,
        Name,
        House,
        EnrollmentYear,
        Patronus,
        WandId
    FROM dbo.Wizards
    WHERE House = @House
    ORDER BY Name;
END;
