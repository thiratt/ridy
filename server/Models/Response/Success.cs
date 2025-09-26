using server.Models.Enum;

namespace server.Models.Response;

public class SuccessResponse
{
    public ResponseStatus Status { get; set; } = ResponseStatus.Success;
    public string Message { get; set; } = null!;
    public object? Data { get; set; }
}