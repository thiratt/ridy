using server.Models.Tables;

namespace server.Models.Response;

public class Account
{
    public Guid Id { get; set; }
    public string Firstname { get; set; } = null!;
    public string? Lastname { get; set; }
    public string PhoneNumber { get; set; } = null!;
    public string Role { get; set; } = null!;
    public string? AvatarUrl { get; set; }
    public string CreatedAt { get; set; } = null!;
    public string UpdatedAt { get; set; } = null!;

    public virtual RiderProfile? RiderProfile { get; set; }
    public virtual ICollection<UserAddress> UserAddresses { get; set; } = [];
    public virtual ICollection<UserPickupAddress> UserPickupAddresses { get; set; } = [];
}