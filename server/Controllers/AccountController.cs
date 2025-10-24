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

        [HttpPost("check-phone")]
        public async Task<IActionResult> CheckPhoneNumber([FromBody] CheckPhoneNumberRequest request)
        {
            var existingAccount = await _context.Accounts
                .FirstOrDefaultAsync(a => a.PhoneNumber == request.PhoneNumber && a.Role == request.Role);

            if (existingAccount != null)
            {
                var roleName = request.Role.ToUpper() == "USER" ? "ผู้ใช้งาน" : "ผู้ขับขี่";
                var errorResponse = new Models.Response.ErrorResponse
                {
                    Status = Models.Enum.ResponseStatus.Fail,
                    Message = $"หมายเลขโทรศัพท์นี้ถูกใช้แล้วสำหรับ{roleName}",
                    Details = new { request.PhoneNumber, Role = request.Role }
                };

                return Conflict(errorResponse);
            }

            var successResponse = new Models.Response.SuccessResponse
            {
                Status = Models.Enum.ResponseStatus.Success,
                Message = "หมายเลขโทรศัพท์นี้สามารถใช้ได้",
                Data = new { request.PhoneNumber, Role = request.Role }
            };

            return Ok(successResponse);
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            // Get all accounts with the same phone number
            var accounts = await _context.Accounts
                .Where(a => a.PhoneNumber == request.PhoneNumber)
                .ToListAsync();

            if (accounts.Count == 0)
            {
                var errorResponse = new Models.Response.ErrorResponse
                {
                    Status = Models.Enum.ResponseStatus.Fail,
                    Message = "หมายเลขโทรศัพท์หรือรหัสผ่านไม่ถูกต้อง",
                    Details = new { request.PhoneNumber }
                };

                return Unauthorized(errorResponse);
            }

            // Check which accounts have matching passwords
            var validAccounts = new List<Account>();
            foreach (var account in accounts)
            {
                if (await Argon2HashingUtil.Verify(request.Password, account.PasswordHash))
                {
                    validAccounts.Add(account);
                }
            }

            if (validAccounts.Count == 0)
            {
                var errorResponse = new Models.Response.ErrorResponse
                {
                    Status = Models.Enum.ResponseStatus.Fail,
                    Message = "หมายเลขโทรศัพท์หรือรหัสผ่านไม่ถูกต้อง",
                    Details = new { request.PhoneNumber }
                };

                return Unauthorized(errorResponse);
            }

            // If only one valid account, return it directly
            if (validAccounts.Count == 1)
            {
                var account = validAccounts.First();
                return Ok(new Models.Response.SuccessResponse
                {
                    Status = Models.Enum.ResponseStatus.Success,
                    Message = "เข้าสู่ระบบสำเร็จ",
                    Data = new
                    {
                        id = account.Id,
                        role = account.Role,
                        phoneNumber = account.PhoneNumber,
                        firstname = account.Firstname,
                        lastname = account.Lastname
                    }
                });
            }

            // If multiple valid accounts (same password for USER and RIDER), let user choose
            return Ok(new Models.Response.SuccessResponse
            {
                Status = Models.Enum.ResponseStatus.Success,
                Message = "พบบัญชีหลายบัญชี กรุณาเลือกประเภทบัญชีที่ต้องการเข้าสู่ระบบ",
                Data = new
                {
                    requireRoleSelection = true,
                    availableRoles = validAccounts.Select(a => new
                    {
                        id = a.Id,
                        role = a.Role,
                        roleDisplayName = a.Role.ToUpper() == "USER" ? "ผู้ใช้งาน" : "ผู้ขับขี่",
                        phoneNumber = a.PhoneNumber,
                        firstname = a.Firstname,
                        lastname = a.Lastname
                    }).ToList()
                }
            });
        }

        [HttpPost("login/select-role")]
        public async Task<IActionResult> LoginWithRoleSelection([FromBody] LoginWithRoleRequest request)
        {
            try
            {
                // Get all accounts with the same phone number
                var accounts = await _context.Accounts
                    .Where(a => a.PhoneNumber == request.PhoneNumber)
                    .ToListAsync();

                if (!accounts.Any())
                {
                    return Unauthorized(new Models.Response.ErrorResponse
                    {
                        Status = Models.Enum.ResponseStatus.Fail,
                        Message = "หมายเลขโทรศัพท์ไม่ถูกต้อง",
                        Details = null
                    });
                }

                // Find the account with the requested role and verify password
                var targetAccount = accounts.FirstOrDefault(a => a.Role.ToUpper() == request.Role.ToUpper());

                if (targetAccount == null)
                {
                    return BadRequest(new Models.Response.ErrorResponse
                    {
                        Status = Models.Enum.ResponseStatus.Fail,
                        Message = "ไม่พบบัญชีสำหรับบทบาทที่เลือก",
                        Details = null
                    });
                }

                // Verify password
                if (!await Argon2HashingUtil.Verify(request.Password, targetAccount.PasswordHash))
                {
                    return Unauthorized(new Models.Response.ErrorResponse
                    {
                        Status = Models.Enum.ResponseStatus.Fail,
                        Message = "รหัสผ่านไม่ถูกต้อง",
                        Details = null
                    });
                }

                return Ok(new Models.Response.SuccessResponse
                {
                    Status = Models.Enum.ResponseStatus.Success,
                    Message = "เข้าสู่ระบบสำเร็จ",
                    Data = new
                    {
                        id = targetAccount.Id,
                        role = targetAccount.Role,
                        phoneNumber = targetAccount.PhoneNumber,
                        firstname = targetAccount.Firstname,
                        lastname = targetAccount.Lastname
                    }
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                return StatusCode(500, new Models.Response.ErrorResponse
                {
                    Status = Models.Enum.ResponseStatus.Error,
                    Message = "เกิดข้อผิดพลาดในการเข้าสู่ระบบ",
                    Details = null
                });
            }
        }

        [HttpPost("register")]
        public async Task<IActionResult> CreateAccount([FromForm] CreateAccountRequest request)
        {
            try
            {
                // Check if phone number is already used for the same role
                var existingAccount = await _context.Accounts
                    .FirstOrDefaultAsync(a => a.PhoneNumber == request.PhoneNumber && a.Role == request.Role);

                if (existingAccount != null)
                {
                    var roleName = request.Role.ToUpper() == "USER" ? "ผู้ใช้งาน" : "ผู้ขับขี่";
                    var errorResponse = new Models.Response.ErrorResponse
                    {
                        Status = Models.Enum.ResponseStatus.Fail,
                        Message = $"หมายเลขโทรศัพท์นี้ถูกใช้แล้วสำหรับ{roleName}",
                        Details = new { request.PhoneNumber, Role = request.Role }
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