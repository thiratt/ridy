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

    // User specific - Single address (for backward compatibility)
    public string? AddressLabel { get; set; }
    public string? AddressText { get; set; }
    public double? AddressLatitude { get; set; }
    public double? AddressLongitude { get; set; }
    public string? PickupAddressText { get; set; }
    public double? PickupAddressLatitude { get; set; }
    public double? PickupAddressLongitude { get; set; }

    // User specific - Multiple addresses (new functionality)
    public string[]? MainAddressLabels { get; set; }
    public string[]? MainAddressTexts { get; set; }
    public double[]? MainAddressLatitudes { get; set; }
    public double[]? MainAddressLongitudes { get; set; }
    public string[]? PickupAddressTexts { get; set; }
    public double[]? PickupAddressLatitudes { get; set; }
    public double[]? PickupAddressLongitudes { get; set; }

    // Rider specific
    public string? VehiclePlate { get; set; }
    public IFormFile? VehiclePhotoData { get; set; }
}