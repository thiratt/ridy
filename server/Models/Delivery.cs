using System;
using System.Collections.Generic;

namespace server.Models;

public partial class Delivery
{
    public Guid Id { get; set; }

    public Guid SenderId { get; set; }

    public Guid ReceiverId { get; set; }

    public long PickupAddressId { get; set; }

    public long DropoffAddressId { get; set; }

    public Guid? RiderId { get; set; }

    public string BaseStatus { get; set; } = null!;

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }

    public virtual ICollection<DeliveryPhoto> DeliveryPhotos { get; set; } = new List<DeliveryPhoto>();

    public virtual UserAddress DropoffAddress { get; set; } = null!;

    public virtual UserPickupAddress PickupAddress { get; set; } = null!;

    public virtual Account Receiver { get; set; } = null!;

    public virtual Account? Rider { get; set; }

    public virtual RiderActiveLock? RiderActiveLock { get; set; }

    public virtual Account Sender { get; set; } = null!;
}
