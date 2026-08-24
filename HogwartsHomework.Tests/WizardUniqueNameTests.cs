using HogwartsHomework.Data;
using HogwartsHomework.Models;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace HogwartsHomework.Tests;

public class WizardUniqueNameTests
{
    [Fact]
    public void AddingTwoWizardsWithSameName_ThrowsDbUpdateException()
    {
        // SQLite in-memory створює справжню реляційну базу і перевіряє
        // унікальні індекси, на відміну від EF Core InMemory provider.
        using var connection = new SqliteConnection("Data Source=:memory:");
        connection.Open();

        var options = new DbContextOptionsBuilder<HogwartsDbContext>()
            .UseSqlite(connection)
            .Options;

        using var context = new HogwartsDbContext(options);
        context.Database.EnsureCreated();

        context.Wizards.Add(
            new Wizard
            {
                Name = "Гаррі Поттер",
                House = "Грифіндор",
                EnrollmentYear = 1991
            });

        context.SaveChanges();

        context.Wizards.Add(
            new Wizard
            {
                Name = "Гаррі Поттер",
                House = "Інший факультет",
                EnrollmentYear = 1992
            });

        Assert.Throws<DbUpdateException>(() => context.SaveChanges());
    }
}
