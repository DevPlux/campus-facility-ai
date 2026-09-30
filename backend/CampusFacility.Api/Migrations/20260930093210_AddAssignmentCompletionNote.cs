using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CampusFacility.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddAssignmentCompletionNote : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "CompletionNote",
                table: "Assignments",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CompletionNote",
                table: "Assignments");
        }
    }
}
