using HogwartsHomework.Models;
using Microsoft.EntityFrameworkCore;

namespace HogwartsHomework.Data;

public class HogwartsDbContext : DbContext
{
    public HogwartsDbContext()
    {
    }

    public HogwartsDbContext(DbContextOptions<HogwartsDbContext> options)
        : base(options)
    {
    }

    public DbSet<Wizard> Wizards => Set<Wizard>();

    public DbSet<Wand> Wands => Set<Wand>();

    public DbSet<WizardWandView> WizardWandsView => Set<WizardWandView>();

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        if (optionsBuilder.IsConfigured)
        {
            return;
        }

        var connectionString =
            Environment.GetEnvironmentVariable("HOGWARTS_CONNECTION_STRING")
            ?? @"Server=.\SQLEXPRESS;Database=HogwartsDB_HW2_HW6;Trusted_Connection=True;TrustServerCertificate=True;";

        optionsBuilder.UseSqlServer(connectionString);
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Wizard>(entity =>
        {
            entity.HasKey(wizard => wizard.Id);

            entity.Property(wizard => wizard.Name)
                .HasMaxLength(100)
                .IsRequired();

            // HW6: у базі не може бути двох чарівників з однаковим ім'ям.
            entity.HasIndex(wizard => wizard.Name)
                .IsUnique();

            entity.Property(wizard => wizard.House)
                .HasMaxLength(50)
                .IsRequired();

            entity.Property(wizard => wizard.Patronus)
                .HasMaxLength(100);

            entity.HasOne(wizard => wizard.Wand)
                .WithOne(wand => wand.Wizard)
                .HasForeignKey<Wizard>(wizard => wizard.WandId)
                .OnDelete(DeleteBehavior.SetNull);
        });

        modelBuilder.Entity<Wand>(entity =>
        {
            entity.HasKey(wand => wand.Id);

            entity.Property(wand => wand.Wood)
                .HasMaxLength(100)
                .IsRequired();

            entity.Property(wand => wand.CoreMaterial)
                .HasMaxLength(100)
                .IsRequired();
        });

        modelBuilder.Entity<WizardWandView>(entity =>
        {
            // Подання повертає результат JOIN і не має стабільного ключа.
            entity.HasNoKey();
            entity.ToView("vw_WizardWands");

            entity.Property(item => item.Name)
                .HasMaxLength(100);

            entity.Property(item => item.House)
                .HasMaxLength(50);

            entity.Property(item => item.CoreMaterial)
                .HasMaxLength(100);
        });
    }
}
