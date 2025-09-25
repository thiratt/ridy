using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;

namespace server.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class HelloWorldController : ControllerBase
    {
        [HttpGet]
        public async Task<IActionResult> GetStrings()
        {
            await Task.Yield();
            return Ok(new List<string> { "Hello", "World" });
        }
    }
}