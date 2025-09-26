using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using NetTopologySuite.Geometries;
using server.Models.Request;
using server.Models.Tables;
using server.Utils;
using Soenneker.Hashing.Argon2;

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

        [HttpPost]
        public async Task<IActionResult> CreateAccount([FromForm] CreateAccountRequest request)
        {
            try
            {
                if (await _context.Accounts.AnyAsync(a => a.PhoneNumber == request.PhoneNumber))
                {
                    var errorResponse = new Models.Response.ErrorResponse
                    {
                        Status = Models.Enum.ResponseStatus.Fail,
                        Message = "Phone number already in use",
                        Details = new { request.PhoneNumber }
                    };

                    return Conflict(errorResponse);
                }

                var avatarFilePath = SaveFile.Save(request.AvatarFileData);

                var newAccount = new Account
                {
                    Id = Guid.NewGuid(),
                    PhoneNumber = request.PhoneNumber,
                    PasswordHash = await Argon2HashingUtil.Hash(request.Password),
                    Firstname = request.Firstname,
                    Lastname = request.Lastname,
                    AvatarUrl = Environment.GetEnvironmentVariable("BASE_URL") + "/image/" + avatarFilePath.Replace("\\", "/"),
                    Role = request.Role,
                    CreatedAt = DateTime.UtcNow
                };

                if (request.Role == "Rider")
                {
                    string VehiclePlate = request.VehiclePlate ?? throw new ArgumentNullException("VehiclePlate is required for Rider role");
                    IFormFile VehiclePhotoData = request.VehiclePhotoData ?? throw new ArgumentNullException(nameof(request));

                    string vehiclePhotoFilePath = SaveFile.Save(VehiclePhotoData);
                    string VehiclePhotoUrl = Environment.GetEnvironmentVariable("BASE_URL") + "/image/" + vehiclePhotoFilePath.Replace("\\", "/");

                    newAccount.RiderProfile = new RiderProfile
                    {
                        RiderId = newAccount.Id,
                        VehiclePlate = VehiclePlate,
                        VehiclePhotoUrl = VehiclePhotoUrl
                    };

                    _context.Accounts.Add(newAccount);
                    _context.RiderProfiles.Add(newAccount.RiderProfile);
                    await _context.SaveChangesAsync();

                    var riderResponse = new Models.Response.SuccessResponse
                    {
                        Status = Models.Enum.ResponseStatus.Success,
                        Message = "Rider account created successfully",
                        Data = newAccount
                    };

                    return CreatedAtAction(nameof(GetAccountById), new { id = newAccount.Id }, riderResponse);
                }

                if (
                    string.IsNullOrEmpty(request.AddressText) ||
                    string.IsNullOrEmpty(request.AddressLabel) ||
                    request.AddressLatitude == null ||
                    request.AddressLongitude == null ||
                    string.IsNullOrEmpty(request.PickupAddressText) ||
                    request.PickupAddressLatitude == null ||
                    request.PickupAddressLongitude == null
                )
                {
                    var errorResponse = new Models.Response.ErrorResponse
                    {
                        Status = Models.Enum.ResponseStatus.Fail,
                        Message = "Missing user-specific fields for User role",
                        Details = null
                    };

                    return BadRequest(errorResponse);
                }

                var userAddress = new UserAddress
                {
                    UserId = newAccount.Id,
                    AddressText = request.AddressText,
                    Label = request.AddressLabel,
                    Location = new Point(new Coordinate(request.AddressLongitude.Value, request.AddressLatitude.Value)) { SRID = 4326 },
                };

                var userPickupAddress = new UserPickupAddress
                {
                    UserId = newAccount.Id,
                    AddressText = request.PickupAddressText,
                    Location = new Point(new Coordinate(request.PickupAddressLongitude.Value, request.PickupAddressLatitude.Value)) { SRID = 4326 },
                };

                _context.Accounts.Add(newAccount);
                _context.UserAddresses.Add(userAddress);
                _context.UserPickupAddresses.Add(userPickupAddress);

                await _context.SaveChangesAsync();

                var successResponse = new Models.Response.SuccessResponse
                {
                    Status = Models.Enum.ResponseStatus.Success,
                    Message = "Account created successfully",
                    Data = new
                    {
                        id = newAccount.Id,
                    }
                };

                return Ok(successResponse);
            }
            catch (System.Exception)
            {

                var errorResponse = new Models.Response.ErrorResponse
                {
                    Status = Models.Enum.ResponseStatus.Error,
                    Message = "An error occurred while creating the account",
                    Details = null
                };

                return StatusCode(500, errorResponse);
            }
        }
    }
}