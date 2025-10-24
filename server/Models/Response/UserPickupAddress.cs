namespace server.Models.Response;

public class UserPickupAddress
{
    public long Id { get; set; }
    public string Label { get; set; } = null!;
    public string AddressText { get; set; } = null!;
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public DateTime CreatedAt { get; set; }
}