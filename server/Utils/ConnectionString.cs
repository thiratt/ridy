namespace server.Utils;

public static class ConnectionString
{
    public static string GetMySQLConnectionString()
    {
        var host = Environment.GetEnvironmentVariable("DB_HOST") ?? "localhost";
        var port = Environment.GetEnvironmentVariable("DB_PORT") ?? "7777";
        var database = Environment.GetEnvironmentVariable("DB_NAME") ?? "ridy";
        var username = Environment.GetEnvironmentVariable("DB_USER") ?? "ridy";
        var password = Environment.GetEnvironmentVariable("DB_PASSWORD") ?? "ridy_password";

        return $"server={host};port={port};database={database};uid={username};pwd={password};";
    }
}
