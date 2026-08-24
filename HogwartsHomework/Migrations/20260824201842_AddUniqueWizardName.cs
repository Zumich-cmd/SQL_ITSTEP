using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HogwartsHomework.Migrations
{
    /// <inheritdoc />
    public partial class AddUniqueWizardName : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateIndex(
                name: "IX_Wizards_Name",
                table: "Wizards",
                column: "Name",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Wizards_Name",
                table: "Wizards");
        }
    }
}
