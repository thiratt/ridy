using System.Globalization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using NetTopologySuite.Geometries;
using server.Models.Request;
using server.Models.Tables;
using server.Utils;
using Soenneker.Extensions.String;
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
            var account = await _context.Accounts
                .Include(a => a.UserAddresses)
                .Include(a => a.UserPickupAddresses)
                .Include(a => a.RiderProfile)
                // .Include(a => a.RiderActiveLock)
                .AsSplitQuery()
                .FirstOrDefaultAsync(a => a.Id == id);

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

            var accountResponse = new Models.Response.Account
            {
                Id = account.Id,
                PhoneNumber = account.PhoneNumber,
                Firstname = account.Firstname,
                Lastname = account.Lastname,
                AvatarUrl = account.AvatarUrl,
                Role = account.Role,
                CreatedAt = ThaiDateConvertor.ToThaiDateString(account.CreatedAt),
                UpdatedAt = ThaiDateConvertor.ToThaiDateString(account.UpdatedAt),

                RiderProfile = account.RiderProfile is not null ? new Models.Response.RiderProfile
                {
                    RiderId = account.RiderProfile.RiderId,
                    VehiclePlate = account.RiderProfile.VehiclePlate,
                    VehiclePhotoUrl = account.RiderProfile.VehiclePhotoUrl,
                } : null,
                UserAddresses = [.. account.UserAddresses.Select(ua => new Models.Response.UserAddress
                {
                    Id = ua.Id,
                    AddressText = ua.AddressText,
                    Label = ua.Label,
                    Latitude = ua.Location.Y,
                    Longitude = ua.Location.X,
                    CreatedAt = ua.CreatedAt
                })],
                UserPickupAddresses = [.. account.UserPickupAddresses.Select(upa => new Models.Response.UserPickupAddress
                {
                    Id = upa.Id,
                    AddressText = upa.AddressText,
                    Latitude = upa.Location.Y,
                    Longitude = upa.Location.X,
                    CreatedAt = upa.CreatedAt
                })],
            };

            var successResponse = new Models.Response.SuccessResponse
            {
                Status = Models.Enum.ResponseStatus.Success,
                Message = "Account retrieved successfully",
                Data = accountResponse
            };

            return Ok(successResponse);
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            var account = await _context.Accounts
                .FirstOrDefaultAsync(a => a.PhoneNumber == request.PhoneNumber);

            if (account == null || !await Argon2HashingUtil.Verify(request.Password, account.PasswordHash))
            {
                var errorResponse = new Models.Response.ErrorResponse
                {
                    Status = Models.Enum.ResponseStatus.Fail,
                    Message = "Invalid phone number or password",
                    Details = new { request.PhoneNumber }
                };

                return Unauthorized(errorResponse);
            }

            return Ok(new Models.Response.SuccessResponse
            {
                Status = Models.Enum.ResponseStatus.Success,
                Message = "Login successful",
                Data = new
                {
                    id = account.Id,
                    role = account.Role
                }
            });
        }

        [HttpPost("register")]
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

                if (request.Role.EqualsIgnoreCase("RIDER"))
                {
                    string VehiclePlate = request.VehiclePlate ?? throw new ArgumentNullException(nameof(request.VehiclePlate));
                    IFormFile VehiclePhotoData = request.VehiclePhotoData ?? throw new ArgumentNullException(nameof(request.VehiclePhotoData));

                    string vehiclePhotoFilePath = SaveFile.Save(VehiclePhotoData);
                    string VehiclePhotoUrl = Environment.GetEnvironmentVariable("BASE_URL") + "/image/" + vehiclePhotoFilePath.Replace("\\", "/");

                    var riderProfile = new RiderProfile
                    {
                        RiderId = newAccount.Id,
                        VehiclePlate = VehiclePlate,
                        VehiclePhotoUrl = VehiclePhotoUrl
                    };

                    _context.Accounts.Add(newAccount);
                    _context.RiderProfiles.Add(riderProfile);
                    await _context.SaveChangesAsync();

                    var riderResponse = new Models.Response.SuccessResponse
                    {
                        Status = Models.Enum.ResponseStatus.Success,
                        Message = "Rider account created successfully",
                        Data = new
                        {
                            id = newAccount.Id,
                        }
                    };

                    return Ok(riderResponse);
                }

                // Handle addresses - check if multi-address data is provided, otherwise use single address for backward compatibility
                bool hasMultiAddresses = request.MainAddressTexts?.Length > 0 && request.PickupAddressTexts?.Length > 0;
                bool hasSingleAddress = !string.IsNullOrEmpty(request.AddressText) && !string.IsNullOrEmpty(request.PickupAddressText);

                if (!hasMultiAddresses && !hasSingleAddress)
                {
                    var errorResponse = new Models.Response.ErrorResponse
                    {
                        Status = Models.Enum.ResponseStatus.Fail,
                        Message = "At least one main address and one pickup address are required for User role",
                        Details = null
                    };

                    return BadRequest(errorResponse);
                }

                _context.Accounts.Add(newAccount);

                if (hasMultiAddresses)
                {
                    if (request.MainAddressTexts!.Length != request.MainAddressLabels?.Length ||
                        request.MainAddressTexts.Length != request.MainAddressLatitudes?.Length ||
                        request.MainAddressTexts.Length != request.MainAddressLongitudes?.Length)
                    {
                        return BadRequest(new Models.Response.ErrorResponse
                        {
                            Status = Models.Enum.ResponseStatus.Fail,
                            Message = "Main address arrays must have the same length",
                            Details = null
                        });
                    }

                    if (request.PickupAddressTexts!.Length != request.PickupAddressLatitudes?.Length ||
                        request.PickupAddressTexts.Length != request.PickupAddressLongitudes?.Length)
                    {
                        return BadRequest(new Models.Response.ErrorResponse
                        {
                            Status = Models.Enum.ResponseStatus.Fail,
                            Message = "Pickup address arrays must have the same length",
                            Details = null
                        });
                    }

                    for (int i = 0; i < request.MainAddressTexts.Length; i++)
                    {
                        var userAddress = new UserAddress
                        {
                            UserId = newAccount.Id,
                            AddressText = request.MainAddressTexts[i],
                            Label = request.MainAddressLabels?[i] ?? $"บ้าน {i + 1}",
                            Location = new Point(new Coordinate(request.MainAddressLongitudes![i], request.MainAddressLatitudes![i])) { SRID = 4326 },
                            CreatedAt = DateTime.UtcNow
                        };
                        _context.UserAddresses.Add(userAddress);
                    }

                    for (int i = 0; i < request.PickupAddressTexts.Length; i++)
                    {
                        var userPickupAddress = new UserPickupAddress
                        {
                            UserId = newAccount.Id,
                            AddressText = request.PickupAddressTexts[i],
                            Location = new Point(new Coordinate(request.PickupAddressLongitudes![i], request.PickupAddressLatitudes![i])) { SRID = 4326 },
                            CreatedAt = DateTime.UtcNow
                        };
                        _context.UserPickupAddresses.Add(userPickupAddress);
                    }
                }
                else
                {
                    if (string.IsNullOrEmpty(request.AddressLabel) ||
                        request.AddressLatitude == null ||
                        request.AddressLongitude == null ||
                        request.PickupAddressLatitude == null ||
                        request.PickupAddressLongitude == null)
                    {
                        return BadRequest(new Models.Response.ErrorResponse
                        {
                            Status = Models.Enum.ResponseStatus.Fail,
                            Message = "Missing required address fields",
                            Details = null
                        });
                    }

                    var userAddress = new UserAddress
                    {
                        UserId = newAccount.Id,
                        AddressText = request.AddressText!,
                        Label = request.AddressLabel,
                        Location = new Point(new Coordinate(request.AddressLongitude.Value, request.AddressLatitude.Value)) { SRID = 4326 },
                        CreatedAt = DateTime.UtcNow
                    };

                    var userPickupAddress = new UserPickupAddress
                    {
                        UserId = newAccount.Id,
                        AddressText = request.PickupAddressText!,
                        Location = new Point(new Coordinate(request.PickupAddressLongitude.Value, request.PickupAddressLatitude.Value)) { SRID = 4326 },
                        CreatedAt = DateTime.UtcNow
                    };

                    _context.UserAddresses.Add(userAddress);
                    _context.UserPickupAddresses.Add(userPickupAddress);
                }

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
            catch (ArgumentNullException ex)
            {
                var errorResponse = new Models.Response.ErrorResponse
                {
                    Status = Models.Enum.ResponseStatus.Fail,
                    Message = ex.Message,
                    Details = null
                };

                return BadRequest(errorResponse);
            }
            catch (System.Exception ex)
            {
                Console.WriteLine(ex);
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