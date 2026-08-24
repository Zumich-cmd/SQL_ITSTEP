using System.Text;
using HogwartsHomework.Data;
using HogwartsHomework.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

Console.OutputEncoding = Encoding.UTF8;
Console.InputEncoding = Encoding.UTF8;

using var context = new HogwartsDbContext();

// HW3: застосовує всі вкладені міграції до бази даних.
context.Database.Migrate();

PrintTitle("HW2-HW6: EF Core — готове рішення");

CreateRequiredWizards(context);
ReadWizardsWithWands(context);
FilterGryffindors(context);
UpdateRon(context);
DemonstrateDelete(context);
ShowAppliedMigrations(context);
ReadWizardWandsView(context);
ReadWizardsByStoredProcedure(context, "Грифіндор");

static void CreateRequiredWizards(HogwartsDbContext context)
{
    PrintSection("HW2 — CREATE: додавання п'ятьох чарівників");

    var requiredWizards = new[]
    {
        new Wizard
        {
            Name = "Гаррі Поттер",
            House = "Грифіндор",
            EnrollmentYear = 1991,
            Patronus = "Олень",
            Wand = new Wand
            {
                Wood = "Падуб",
                CoreMaterial = "Перо фенікса",
                Length = 28.0
            }
        },
        new Wizard
        {
            Name = "Герміона Грейнджер",
            House = "Грифіндор",
            EnrollmentYear = 1991,
            Patronus = "Видра",
            Wand = new Wand
            {
                Wood = "Виноградна лоза",
                CoreMaterial = "Серцеве волокно дракона",
                Length = 27.3
            }
        },
        new Wizard
        {
            Name = "Рон Візлі",
            House = "Грифіндор",
            EnrollmentYear = 1991,
            Patronus = "Джек-рассел-тер'єр",
            Wand = new Wand
            {
                Wood = "Верба",
                CoreMaterial = "Волосина єдинорога",
                Length = 35.5
            }
        },
        new Wizard
        {
            Name = "Драко Мелфой",
            House = "Слизерин",
            EnrollmentYear = 1991,
            Patronus = null,
            Wand = new Wand
            {
                Wood = "Глід",
                CoreMaterial = "Волосина єдинорога",
                Length = 25.4
            }
        },
        new Wizard
        {
            Name = "Луна Лавґуд",
            House = "Рейвенклов",
            EnrollmentYear = 1992,
            Patronus = "Заєць",
            Wand = new Wand
            {
                Wood = "Акація",
                CoreMaterial = "Волосина єдинорога",
                Length = 33.0
            }
        }
    };

    var requiredNames = requiredWizards
        .Select(wizard => wizard.Name)
        .ToList();

    var existingNames = context.Wizards
        .Where(wizard => requiredNames.Contains(wizard.Name))
        .Select(wizard => wizard.Name)
        .ToHashSet();

    var wizardsToAdd = requiredWizards
        .Where(wizard => !existingNames.Contains(wizard.Name))
        .ToList();

    context.Wizards.AddRange(wizardsToAdd);
    context.SaveChanges();

    Console.WriteLine(
        wizardsToAdd.Count == 0
            ? "Записи вже існують — дублікати не створено."
            : $"Додано чарівників: {wizardsToAdd.Count}.");
}

static void ReadWizardsWithWands(HogwartsDbContext context)
{
    PrintSection("HW2 — READ + зв'язок: Include(Wand)");

    // Include завантажує пов'язану паличку, а ?? коректно обробляє null.
    var wizards = context.Wizards
        .AsNoTracking()
        .Include(wizard => wizard.Wand)
        .OrderBy(wizard => wizard.Name)
        .ToList();

    foreach (var wizard in wizards)
    {
        var coreMaterial = wizard.Wand?.CoreMaterial ?? "не вказано";

        Console.WriteLine(
            $"{wizard.Name}; факультет: {wizard.House}; " +
            $"рік вступу: {wizard.EnrollmentYear}; " +
            $"серцевина палички: {coreMaterial}");
    }
}

static void FilterGryffindors(HogwartsDbContext context)
{
    PrintSection("HW2 — FILTER: факультет Грифіндор");

    var gryffindors = context.Wizards
        .AsNoTracking()
        .Where(wizard => wizard.House == "Грифіндор")
        .OrderBy(wizard => wizard.Name)
        .Select(wizard => new
        {
            wizard.Name,
            wizard.EnrollmentYear
        })
        .ToList();

    foreach (var wizard in gryffindors)
    {
        Console.WriteLine($"{wizard.Name} — {wizard.EnrollmentYear}");
    }
}

static void UpdateRon(HogwartsDbContext context)
{
    PrintSection("HW2 — UPDATE: рік вступу Рона Візлі");

    var ron = context.Wizards
        .FirstOrDefault(wizard => wizard.Name == "Рон Візлі");

    if (ron is null)
    {
        Console.WriteLine("Рона Візлі не знайдено.");
        return;
    }

    var oldYear = ron.EnrollmentYear;
    ron.EnrollmentYear = 1992;
    context.SaveChanges();

    Console.WriteLine($"Було: {oldYear}; стало: {ron.EnrollmentYear}.");
}

static void DemonstrateDelete(HogwartsDbContext context)
{
    PrintSection("HW2 — DELETE: видалення тимчасового запису");

    const string testName = "Тестовий чарівник для DELETE";

    var existingTestWizard = context.Wizards
        .FirstOrDefault(wizard => wizard.Name == testName);

    if (existingTestWizard is not null)
    {
        context.Wizards.Remove(existingTestWizard);
        context.SaveChanges();
    }

    var testWizard = new Wizard
    {
        Name = testName,
        House = "Тестовий факультет",
        EnrollmentYear = 2026
    };

    context.Wizards.Add(testWizard);
    context.SaveChanges();

    context.Wizards.Remove(testWizard);
    context.SaveChanges();

    Console.WriteLine("Тимчасовий запис створено і видалено.");
}

static void ShowAppliedMigrations(HogwartsDbContext context)
{
    PrintSection("HW3 — застосовані міграції");

    foreach (var migration in context.Database.GetAppliedMigrations())
    {
        Console.WriteLine(migration);
    }

    Console.WriteLine(
        "Таблиця __EFMigrationsHistory створюється та ведеться EF Core автоматично.");
}

static void ReadWizardWandsView(HogwartsDbContext context)
{
    PrintSection("HW4 — SQL View: dbo.vw_WizardWands");

    var rows = context.WizardWandsView
        .AsNoTracking()
        .OrderBy(item => item.Name)
        .ToList();

    foreach (var row in rows)
    {
        Console.WriteLine(
            $"{row.Name}; {row.House}; " +
            $"серцевина: {row.CoreMaterial ?? "не вказано"}");
    }
}

static void ReadWizardsByStoredProcedure(
    HogwartsDbContext context,
    string house)
{
    PrintSection(
        $"HW5 — процедура dbo.sp_GetWizardsByHouse (факультет: {house})");

    var houseParameter = new SqlParameter("@House", house);

    var wizards = context.Wizards
        .FromSqlRaw(
            "EXEC dbo.sp_GetWizardsByHouse @House",
            houseParameter)
        .AsNoTracking()
        .ToList();

    foreach (var wizard in wizards)
    {
        Console.WriteLine(
            $"{wizard.Name} — {wizard.House}, {wizard.EnrollmentYear}");
    }
}

static void PrintTitle(string text)
{
    Console.WriteLine(new string('=', 72));
    Console.WriteLine(text);
    Console.WriteLine(new string('=', 72));
}

static void PrintSection(string text)
{
    Console.WriteLine();
    Console.WriteLine($"--- {text} ---");
}
