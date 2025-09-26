namespace server.Models.Response;

public class RiderProfile
{
    public Guid RiderId { get; set; }
    public string VehiclePlate { get; set; } = null!;
    public string VehiclePhotoUrl { get; set; } = null!;
}