namespace HogwartsHomework.Models;

// HW4: SQL View не має власного первинного ключа, тому сутність є keyless.
public class WizardWandView
{
    public string Name { get; set; } = string.Empty;

    public string House { get; set; } = string.Empty;

    public string? CoreMaterial { get; set; }
}
