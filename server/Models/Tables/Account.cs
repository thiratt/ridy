using System;
using System.Collections.Generic;

namespace server.Models.Tables;

public partial class Account
{
    public Guid Id { get; set; }

    public string PhoneNumber { get; set; } = null!;

    public string PasswordHash { get; set; } = null!;

    public string Firstname { get; set; } = null!;

    public string? Lastname { get; set; }

    public string AvatarUrl { get; set; } = null!;

    public string Role { get; set; } = null!;

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }

    public virtual ICollection<Delivery> DeliveryReceivers { get; set; } = new List<Delivery>();

    public virtual ICollection<Delivery> DeliveryRiders { get; set; } = new List<Delivery>();

    public virtual ICollection<Delivery> DeliverySenders { get; set; } = new List<Delivery>();

    public virtual RiderActiveLock? RiderActiveLock { get; set; }

    public virtual ICollection<UserAddress> UserAddresses { get; set; } = new List<UserAddress>();

    public virtual ICollection<UserPickupAddress> UserPickupAddresses { get; set; } = new List<UserPickupAddress>();
}
