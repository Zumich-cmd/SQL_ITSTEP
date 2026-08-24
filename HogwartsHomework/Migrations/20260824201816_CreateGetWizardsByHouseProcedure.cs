using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HogwartsHomework.Migrations
{
    /// <inheritdoc />
    public partial class CreateGetWizardsByHouseProcedure : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
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
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                "DROP PROCEDURE IF EXISTS dbo.sp_GetWizardsByHouse;");
        }
    }
}
