namespace server.Models.Request;

public class LoginWithRoleRequest
{
    public string PhoneNumber { get; set; } = null!;
    public string Password { get; set; } = null!;
    public string Role { get; set; } = null!;
}