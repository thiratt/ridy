namespace server.Utils;

public static class ThaiDateConvertor
{
    public static string ToThaiDateString(DateTime dateTime)
    {
        var thaiCulture = new System.Globalization.CultureInfo("th-TH");
        return dateTime.ToLocalTime().ToString("d MMMM yyyy HH:mm:ss", thaiCulture);
    }
}