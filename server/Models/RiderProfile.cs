using System;
using System.Collections.Generic;

namespace server.Models;

public partial class RiderProfile
{
    public Guid RiderId { get; set; }

    public string VehiclePlate { get; set; } = null!;

    public string VehiclePhotoUrl { get; set; } = null!;

    public virtual Account Rider { get; set; } = null!;
}
