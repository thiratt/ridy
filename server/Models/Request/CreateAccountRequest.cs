using NetTopologySuite.Geometries;

namespace server.Models.Request;

public class CreateAccountRequest
{
    public string PhoneNumber { get; set; } = null!;
    public string Password { get; set; } = null!;
    public string Firstname { get; set; } = null!;
    public string? Lastname { get; set; }
    public IFormFile AvatarFileData { get; set; } = null!;
    public string Role { get; set; } = null!;

    // User specific
    public string? AddressLabel { get; set; }
    public string? AddressText { get; set; }
    public double? AddressLatitude { get; set; }
    public double? AddressLongitude { get; set; }
    public string? PickupAddressText { get; set; }
    public double? PickupAddressLatitude { get; set; }
    public double? PickupAddressLongitude { get; set; }

    // Rider specific
    public string? VehiclePlate { get; set; }
    public IFormFile? VehiclePhotoData { get; set; }
}