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

        [HttpGet("{id:guid}")]
        public async Task<IActionResult> GetAccountById(Guid id)
        {
            var account = await _context.Accounts.FirstOrDefaultAsync(a => a.Id == id);

            if (account == null)
            {
                var errorResponse = new Models.Response.ErrorResponse
                {
                    Status = Models.Enum.ResponseStatus.Fail,
                    Message = "Account not found",
                    Details = new { AccountId = id }
                };

                return NotFound(errorResponse);
            }
            
            var successResponse = new Models.Response.SuccessResponse
            {
                Status = Models.Enum.ResponseStatus.Success,
                Message = "Account retrieved successfully",
                Data = account
            };

            return Ok(successResponse);
        }
    }
}