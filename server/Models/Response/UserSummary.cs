namespace server.Models.Response;

public class UserSummary
{
    public Guid Id { get; set; }
    public string? Firstname { get; set; }
    public string? Lastname { get; set; }
    public string? PhoneNumber { get; set; }
    public string? AvatarUrl { get; set; }
    public string FullName { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public List<UserAddress> Addresses { get; set; } = [];
    public List<UserPickupAddress> PickupAddresses { get; set; } = [];
}