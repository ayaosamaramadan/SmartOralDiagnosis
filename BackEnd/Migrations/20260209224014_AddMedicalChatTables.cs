using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MedicalManagement.API.Migrations
{
    /// <inheritdoc />
    public partial class AddMedicalChatTables : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "MedicalChats",
                columns: table => new
                {
                    Id = table.Column<string>(type: "TEXT", nullable: false),
                    PatientId = table.Column<string>(type: "TEXT", nullable: false),
                    DoctorId = table.Column<string>(type: "TEXT", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    LastMessageAt = table.Column<DateTime>(type: "TEXT", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MedicalChats", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "MedicalMessages",
                columns: table => new
                {
                    Id = table.Column<string>(type: "TEXT", nullable: false),
                    ChatId = table.Column<string>(type: "TEXT", nullable: false),
                    SenderId = table.Column<string>(type: "TEXT", nullable: false),
                    SenderRole = table.Column<int>(type: "INTEGER", nullable: false),
                    Content = table.Column<string>(type: "TEXT", maxLength: 4000, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MedicalMessages", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MedicalMessages_MedicalChats_ChatId",
                        column: x => x.ChatId,
                        principalTable: "MedicalChats",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_MedicalChats_PatientId_DoctorId",
                table: "MedicalChats",
                columns: new[] { "PatientId", "DoctorId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_MedicalMessages_ChatId_CreatedAt",
                table: "MedicalMessages",
                columns: new[] { "ChatId", "CreatedAt" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "MedicalMessages");

            migrationBuilder.DropTable(
                name: "MedicalChats");
        }
    }
}
