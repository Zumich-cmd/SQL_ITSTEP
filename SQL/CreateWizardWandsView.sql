CREATE VIEW dbo.vw_WizardWands
AS
    SELECT
        wizard.Name,
        wizard.House,
        wand.CoreMaterial
    FROM dbo.Wizards AS wizard
    LEFT JOIN dbo.Wands AS wand
        ON wizard.WandId = wand.Id;
