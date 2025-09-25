using System;
using System.Collections.Generic;

namespace server.Models;

public partial class RiderActiveLock
{
    public Guid RiderId { get; set; }

    public Guid DeliveryId { get; set; }

    public DateTime LockedAt { get; set; }

    public virtual Delivery Delivery { get; set; } = null!;

    public virtual Account Rider { get; set; } = null!;
}
