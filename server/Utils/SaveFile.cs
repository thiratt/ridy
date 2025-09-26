namespace server.Utils;

public static class SaveFile
{
    private static readonly string UploadsDirectory = Path.Combine(Directory.GetCurrentDirectory(), "Uploads");

    // public static string Save(string fileName, byte[] fileData)
    // {
    //     if (!Directory.Exists(UploadsDirectory))
    //     {
    //         Directory.CreateDirectory(UploadsDirectory);
    //     }

    //     var uniqueFileName = $"{Guid.NewGuid()}_{fileName}";
    //     var filePath = Path.Combine(UploadsDirectory, uniqueFileName);
    //     File.WriteAllBytes(filePath, fileData);
    //     return filePath;
    // }

    public static string Save(IFormFile file)
    {
        if (!Directory.Exists(UploadsDirectory))
        {
            Directory.CreateDirectory(UploadsDirectory);
        }

        var fileName = Path.GetFileName(file.FileName);
        var uniqueFileName = $"{Guid.NewGuid()}_{fileName}";
        var filePath = Path.Combine(UploadsDirectory, uniqueFileName);

        using var stream = new FileStream(filePath, FileMode.Create);
        file.CopyTo(stream);

        return uniqueFileName;
    }
}