namespace server.Models.Request;

public class CheckPhoneNumberRequest
{
    public string PhoneNumber { get; set; } = null!;
    public string Role { get; set; } = null!;
}