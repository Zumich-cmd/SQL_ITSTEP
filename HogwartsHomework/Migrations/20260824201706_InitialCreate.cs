using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HogwartsHomework.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Wands",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Wood = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    CoreMaterial = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Length = table.Column<double>(type: "float", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Wands", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Wizards",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    House = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    EnrollmentYear = table.Column<int>(type: "int", nullable: false),
                    WandId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Wizards", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Wizards_Wands_WandId",
                        column: x => x.WandId,
                        principalTable: "Wands",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Wizards_WandId",
                table: "Wizards",
                column: "WandId",
                unique: true,
                filter: "[WandId] IS NOT NULL");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Wizards");

            migrationBuilder.DropTable(
                name: "Wands");
        }
    }
}
