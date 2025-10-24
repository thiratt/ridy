using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using server.Models.Tables;
using server.Models.Response;
using server.Models.Enum;

namespace server.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class DeliveryController(RidyContext context) : ControllerBase
    {
        private readonly RidyContext _context = context;

        [HttpGet("user/{userId:guid}")]
        public async Task<IActionResult> GetUserDeliveries(Guid userId)
        {
            try
            {
                var deliveries = await _context.Deliveries
                    .Include(d => d.PickupAddress)
                    .Include(d => d.DropoffAddress)
                    .Include(d => d.Sender)
                    .Include(d => d.Receiver)
                    .Include(d => d.Rider)
                    .Where(d => d.SenderId == userId || d.ReceiverId == userId)
                    .OrderByDescending(d => d.CreatedAt)
                    .AsSplitQuery()
                    .ToListAsync();

                var deliveryResponses = deliveries.Select(d => new
                {
                    id = d.Id,
                    senderId = d.SenderId,
                    receiverId = d.ReceiverId,
                    pickupAddressId = d.PickupAddressId,
                    dropoffAddressId = d.DropoffAddressId,
                    riderId = d.RiderId,
                    baseStatus = d.BaseStatus,
                    createdAt = d.CreatedAt.ToString("yyyy-MM-ddTHH:mm:ss.fffZ"),
                    updatedAt = d.UpdatedAt.ToString("yyyy-MM-ddTHH:mm:ss.fffZ"),
                    pickupAddress = d.PickupAddress != null ? new
                    {
                        id = d.PickupAddress.Id,
                        userId = d.PickupAddress.UserId,
                        addressText = d.PickupAddress.AddressText,
                        latitude = d.PickupAddress.Location.Y,
                        longitude = d.PickupAddress.Location.X,
                        createdAt = d.PickupAddress.CreatedAt.ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                    } : null,
                    dropoffAddress = d.DropoffAddress != null ? new
                    {
                        id = d.DropoffAddress.Id,
                        userId = d.DropoffAddress.UserId,
                        label = d.DropoffAddress.Label,
                        addressText = d.DropoffAddress.AddressText,
                        latitude = d.DropoffAddress.Location.Y,
                        longitude = d.DropoffAddress.Location.X,
                        createdAt = d.DropoffAddress.CreatedAt.ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                    } : null,
                    sender = d.Sender != null ? new
                    {
                        id = d.Sender.Id,
                        phoneNumber = d.Sender.PhoneNumber,
                        firstname = d.Sender.Firstname,
                        lastname = d.Sender.Lastname,
                        avatarUrl = d.Sender.AvatarUrl,
                        role = d.Sender.Role
                    } : null,
                    receiver = d.Receiver != null ? new
                    {
                        id = d.Receiver.Id,
                        phoneNumber = d.Receiver.PhoneNumber,
                        firstname = d.Receiver.Firstname,
                        lastname = d.Receiver.Lastname,
                        avatarUrl = d.Receiver.AvatarUrl,
                        role = d.Receiver.Role
                    } : null,
                    rider = d.Rider != null ? new
                    {
                        id = d.Rider.Id,
                        phoneNumber = d.Rider.PhoneNumber,
                        firstname = d.Rider.Firstname,
                        lastname = d.Rider.Lastname,
                        avatarUrl = d.Rider.AvatarUrl,
                        role = d.Rider.Role
                    } : null
                }).ToList();

                var successResponse = new SuccessResponse
                {
                    Status = ResponseStatus.Success,
                    Message = "Deliveries retrieved successfully",
                    Data = deliveryResponses
                };

                return Ok(successResponse);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                var errorResponse = new ErrorResponse
                {
                    Status = ResponseStatus.Error,
                    Message = "An error occurred while retrieving deliveries",
                    Details = null
                };

                return StatusCode(500, errorResponse);
            }
        }

        [HttpGet("sent/{userId:guid}")]
        public async Task<IActionResult> GetSentDeliveries(Guid userId)
        {
            try
            {
                var deliveries = await _context.Deliveries
                    .Include(d => d.PickupAddress)
                    .Include(d => d.DropoffAddress)
                    .Include(d => d.Receiver)
                    .Include(d => d.Rider)
                    .Where(d => d.SenderId == userId)
                    .OrderByDescending(d => d.CreatedAt)
                    .AsSplitQuery()
                    .ToListAsync();

                var deliveryResponses = deliveries.Select(d => new
                {
                    id = d.Id,
                    senderId = d.SenderId,
                    receiverId = d.ReceiverId,
                    pickupAddressId = d.PickupAddressId,
                    dropoffAddressId = d.DropoffAddressId,
                    riderId = d.RiderId,
                    baseStatus = d.BaseStatus,
                    createdAt = d.CreatedAt.ToString("yyyy-MM-ddTHH:mm:ss.fffZ"),
                    updatedAt = d.UpdatedAt.ToString("yyyy-MM-ddTHH:mm:ss.fffZ"),
                    pickupAddress = d.PickupAddress != null ? new
                    {
                        id = d.PickupAddress.Id,
                        userId = d.PickupAddress.UserId,
                        addressText = d.PickupAddress.AddressText,
                        latitude = d.PickupAddress.Location.Y,
                        longitude = d.PickupAddress.Location.X,
                        createdAt = d.PickupAddress.CreatedAt.ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                    } : null,
                    dropoffAddress = d.DropoffAddress != null ? new
                    {
                        id = d.DropoffAddress.Id,
                        userId = d.DropoffAddress.UserId,
                        label = d.DropoffAddress.Label,
                        addressText = d.DropoffAddress.AddressText,
                        latitude = d.DropoffAddress.Location.Y,
                        longitude = d.DropoffAddress.Location.X,
                        createdAt = d.DropoffAddress.CreatedAt.ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                    } : null,
                    receiver = d.Receiver != null ? new
                    {
                        id = d.Receiver.Id,
                        phoneNumber = d.Receiver.PhoneNumber,
                        firstname = d.Receiver.Firstname,
                        lastname = d.Receiver.Lastname,
                        avatarUrl = d.Receiver.AvatarUrl,
                        role = d.Receiver.Role
                    } : null,
                    rider = d.Rider != null ? new
                    {
                        id = d.Rider.Id,
                        phoneNumber = d.Rider.PhoneNumber,
                        firstname = d.Rider.Firstname,
                        lastname = d.Rider.Lastname,
                        avatarUrl = d.Rider.AvatarUrl,
                        role = d.Rider.Role
                    } : null
                }).ToList();

                var successResponse = new SuccessResponse
                {
                    Status = ResponseStatus.Success,
                    Message = "Sent deliveries retrieved successfully",
                    Data = deliveryResponses
                };

                return Ok(successResponse);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                var errorResponse = new ErrorResponse
                {
                    Status = ResponseStatus.Error,
                    Message = "An error occurred while retrieving sent deliveries",
                    Details = null
                };

                return StatusCode(500, errorResponse);
            }
        }

        [HttpGet("received/{userId:guid}")]
        public async Task<IActionResult> GetReceivedDeliveries(Guid userId)
        {
            try
            {
                var deliveries = await _context.Deliveries
                    .Include(d => d.PickupAddress)
                    .Include(d => d.DropoffAddress)
                    .Include(d => d.Sender)
                    .Include(d => d.Rider)
                    .Where(d => d.ReceiverId == userId)
                    .OrderByDescending(d => d.CreatedAt)
                    .AsSplitQuery()
                    .ToListAsync();

                var deliveryResponses = deliveries.Select(d => new
                {
                    id = d.Id,
                    senderId = d.SenderId,
                    receiverId = d.ReceiverId,
                    pickupAddressId = d.PickupAddressId,
                    dropoffAddressId = d.DropoffAddressId,
                    riderId = d.RiderId,
                    baseStatus = d.BaseStatus,
                    createdAt = d.CreatedAt.ToString("yyyy-MM-ddTHH:mm:ss.fffZ"),
                    updatedAt = d.UpdatedAt.ToString("yyyy-MM-ddTHH:mm:ss.fffZ"),
                    pickupAddress = d.PickupAddress != null ? new
                    {
                        id = d.PickupAddress.Id,
                        userId = d.PickupAddress.UserId,
                        addressText = d.PickupAddress.AddressText,
                        latitude = d.PickupAddress.Location.Y,
                        longitude = d.PickupAddress.Location.X,
                        createdAt = d.PickupAddress.CreatedAt.ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                    } : null,
                    dropoffAddress = d.DropoffAddress != null ? new
                    {
                        id = d.DropoffAddress.Id,
                        userId = d.DropoffAddress.UserId,
                        label = d.DropoffAddress.Label,
                        addressText = d.DropoffAddress.AddressText,
                        latitude = d.DropoffAddress.Location.Y,
                        longitude = d.DropoffAddress.Location.X,
                        createdAt = d.DropoffAddress.CreatedAt.ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                    } : null,
                    sender = d.Sender != null ? new
                    {
                        id = d.Sender.Id,
                        phoneNumber = d.Sender.PhoneNumber,
                        firstname = d.Sender.Firstname,
                        lastname = d.Sender.Lastname,
                        avatarUrl = d.Sender.AvatarUrl,
                        role = d.Sender.Role
                    } : null,
                    rider = d.Rider != null ? new
                    {
                        id = d.Rider.Id,
                        phoneNumber = d.Rider.PhoneNumber,
                        firstname = d.Rider.Firstname,
                        lastname = d.Rider.Lastname,
                        avatarUrl = d.Rider.AvatarUrl,
                        role = d.Rider.Role
                    } : null
                }).ToList();

                var successResponse = new SuccessResponse
                {
                    Status = ResponseStatus.Success,
                    Message = "Received deliveries retrieved successfully",
                    Data = deliveryResponses
                };

                return Ok(successResponse);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                var errorResponse = new ErrorResponse
                {
                    Status = ResponseStatus.Error,
                    Message = "An error occurred while retrieving received deliveries",
                    Details = null
                };

                return StatusCode(500, errorResponse);
            }
        }

        [HttpGet("user/{userId:guid}/status/{status}")]
        public async Task<IActionResult> GetDeliveriesByStatus(Guid userId, string status)
        {
            try
            {
                var deliveries = await _context.Deliveries
                    .Include(d => d.PickupAddress)
                    .Include(d => d.DropoffAddress)
                    .Include(d => d.Sender)
                    .Include(d => d.Receiver)
                    .Include(d => d.Rider)
                    .Where(d => (d.SenderId == userId || d.ReceiverId == userId)
                               && d.BaseStatus.ToLower() == status.ToLower())
                    .OrderByDescending(d => d.CreatedAt)
                    .AsSplitQuery()
                    .ToListAsync();

                var deliveryResponses = deliveries.Select(d => new
                {
                    id = d.Id,
                    senderId = d.SenderId,
                    receiverId = d.ReceiverId,
                    pickupAddressId = d.PickupAddressId,
                    dropoffAddressId = d.DropoffAddressId,
                    riderId = d.RiderId,
                    baseStatus = d.BaseStatus,
                    createdAt = d.CreatedAt.ToString("yyyy-MM-ddTHH:mm:ss.fffZ"),
                    updatedAt = d.UpdatedAt.ToString("yyyy-MM-ddTHH:mm:ss.fffZ"),
                    pickupAddress = d.PickupAddress != null ? new
                    {
                        id = d.PickupAddress.Id,
                        userId = d.PickupAddress.UserId,
                        addressText = d.PickupAddress.AddressText,
                        latitude = d.PickupAddress.Location.Y,
                        longitude = d.PickupAddress.Location.X,
                        createdAt = d.PickupAddress.CreatedAt.ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                    } : null,
                    dropoffAddress = d.DropoffAddress != null ? new
                    {
                        id = d.DropoffAddress.Id,
                        userId = d.DropoffAddress.UserId,
                        label = d.DropoffAddress.Label,
                        addressText = d.DropoffAddress.AddressText,
                        latitude = d.DropoffAddress.Location.Y,
                        longitude = d.DropoffAddress.Location.X,
                        createdAt = d.DropoffAddress.CreatedAt.ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                    } : null,
                    sender = d.Sender != null ? new
                    {
                        id = d.Sender.Id,
                        phoneNumber = d.Sender.PhoneNumber,
                        firstname = d.Sender.Firstname,
                        lastname = d.Sender.Lastname,
                        avatarUrl = d.Sender.AvatarUrl,
                        role = d.Sender.Role
                    } : null,
                    receiver = d.Receiver != null ? new
                    {
                        id = d.Receiver.Id,
                        phoneNumber = d.Receiver.PhoneNumber,
                        firstname = d.Receiver.Firstname,
                        lastname = d.Receiver.Lastname,
                        avatarUrl = d.Receiver.AvatarUrl,
                        role = d.Receiver.Role
                    } : null,
                    rider = d.Rider != null ? new
                    {
                        id = d.Rider.Id,
                        phoneNumber = d.Rider.PhoneNumber,
                        firstname = d.Rider.Firstname,
                        lastname = d.Rider.Lastname,
                        avatarUrl = d.Rider.AvatarUrl,
                        role = d.Rider.Role
                    } : null
                }).ToList();

                var successResponse = new SuccessResponse
                {
                    Status = ResponseStatus.Success,
                    Message = $"Deliveries with status '{status}' retrieved successfully",
                    Data = deliveryResponses
                };

                return Ok(successResponse);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                var errorResponse = new ErrorResponse
                {
                    Status = ResponseStatus.Error,
                    Message = "An error occurred while retrieving deliveries by status",
                    Details = null
                };

                return StatusCode(500, errorResponse);
            }
        }
    }
}