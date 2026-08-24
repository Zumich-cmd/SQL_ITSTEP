namespace HogwartsHomework.Models;

public class Wand
{
    public int Id { get; set; }

    public string Wood { get; set; } = string.Empty;

    public string CoreMaterial { get; set; } = string.Empty;

    public double Length { get; set; }

    public Wizard? Wizard { get; set; }
}
