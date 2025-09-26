using server.Models.Enum;

namespace server.Models.Response;

public class ErrorResponse
{
    public ResponseStatus Status { get; set; } = ResponseStatus.Error;
    public string Message { get; set; } = null!;
    public object? Details { get; set; }
}