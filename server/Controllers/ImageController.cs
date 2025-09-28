using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.StaticFiles;

namespace server.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class ImageController : ControllerBase
    {
        [HttpGet("{filename}")]
        public async Task<IActionResult> GetStrings(string filename)
        {
            if (string.IsNullOrWhiteSpace(filename))
            {
                return BadRequest("Filename cannot be empty.");
            }

            var safeFilename = Path.GetFileName(filename);
            var path = Path.Combine("Uploads", safeFilename);

            if (!System.IO.File.Exists(path))
            {
                return NotFound();
            }

            var provider = new FileExtensionContentTypeProvider();
            if (!provider.TryGetContentType(safeFilename, out string? contentType) || contentType == null)
            {
                contentType = "application/octet-stream";
            }

            var fileBytes = await System.IO.File.ReadAllBytesAsync(path);
            return File(fileBytes, contentType);
        }
    }
}