using System;
using System.Collections.Generic;

namespace server.Models.Tables;

public partial class DeliveryPhoto
{
    public long Id { get; set; }

    public Guid DeliveryId { get; set; }

    public string Status { get; set; } = null!;

    public string PhotoUrl { get; set; } = null!;

    public DateTime CreatedAt { get; set; }

    public virtual Delivery Delivery { get; set; } = null!;
}
