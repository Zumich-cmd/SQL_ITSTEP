namespace HogwartsHomework.Models;

public class Wizard
{
    public int Id { get; set; }

    public string Name { get; set; } = string.Empty;

    public string House { get; set; } = string.Empty;

    public int EnrollmentYear { get; set; }

    // HW3: поле додано окремою міграцією AddPatronusToWizards.
    public string? Patronus { get; set; }

    public int? WandId { get; set; }

    public Wand? Wand { get; set; }
}
