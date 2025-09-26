using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using server.Models.Tables;

namespace server.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class AccountController(RidyContext context) : ControllerBase
    {
        private readonly RidyContext _context = context;
        [HttpGet]
        public async Task<IActionResult> GetAccounts()
        {
            var accounts = await _context.Accounts.ToListAsync();
            return Ok(accounts);
        }
    }
}