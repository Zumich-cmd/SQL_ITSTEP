using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HogwartsHomework.Migrations
{
    /// <inheritdoc />
    public partial class AddPatronusToWizards : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Patronus",
                table: "Wizards",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Patronus",
                table: "Wizards");
        }
    }
}
