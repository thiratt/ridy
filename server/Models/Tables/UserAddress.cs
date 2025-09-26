using System;
using System.Collections.Generic;
using NetTopologySuite.Geometries;

namespace server.Models.Tables;

public partial class UserAddress
{
    public long Id { get; set; }

    public Guid UserId { get; set; }

    public string Label { get; set; } = null!;

    public string AddressText { get; set; } = null!;

    public Point Location { get; set; } = null!;

    public DateTime CreatedAt { get; set; }

    public virtual ICollection<Delivery> Deliveries { get; set; } = new List<Delivery>();

    public virtual Account User { get; set; } = null!;
}
