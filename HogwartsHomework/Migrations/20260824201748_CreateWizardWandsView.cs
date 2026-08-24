using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HogwartsHomework.Migrations
{
    /// <inheritdoc />
    public partial class CreateWizardWandsView : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                CREATE VIEW dbo.vw_WizardWands
                AS
                    SELECT
                        wizard.Name,
                        wizard.House,
                        wand.CoreMaterial
                    FROM dbo.Wizards AS wizard
                    LEFT JOIN dbo.Wands AS wand
                        ON wizard.WandId = wand.Id;
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("DROP VIEW IF EXISTS dbo.vw_WizardWands;");
        }
    }
}
