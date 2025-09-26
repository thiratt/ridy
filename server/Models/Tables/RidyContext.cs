using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace server.Models.Tables;

public partial class RidyContext : DbContext
{
    public RidyContext(DbContextOptions<RidyContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Account> Accounts { get; set; }

    public virtual DbSet<Delivery> Deliveries { get; set; }

    public virtual DbSet<DeliveryPhoto> DeliveryPhotos { get; set; }

    public virtual DbSet<RiderActiveLock> RiderActiveLocks { get; set; }

    public virtual DbSet<RiderProfile> RiderProfiles { get; set; }

    public virtual DbSet<UserAddress> UserAddresses { get; set; }

    public virtual DbSet<UserPickupAddress> UserPickupAddresses { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder
            .UseCollation("utf8mb4_0900_ai_ci")
            .HasCharSet("utf8mb4");

        modelBuilder.Entity<Account>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("account");

            entity.HasIndex(e => e.PhoneNumber, "phone").IsUnique();

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.AvatarUrl)
                .HasMaxLength(255)
                .HasColumnName("avatar_url");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP(3)")
                .HasColumnType("timestamp(3)")
                .HasColumnName("created_at");
            entity.Property(e => e.Firstname)
                .HasMaxLength(30)
                .HasColumnName("firstname");
            entity.Property(e => e.Lastname)
                .HasMaxLength(30)
                .HasColumnName("lastname");
            entity.Property(e => e.PasswordHash)
                .HasColumnType("text")
                .HasColumnName("password_hash");
            entity.Property(e => e.PhoneNumber)
                .HasMaxLength(10)
                .HasColumnName("phone_number");
            entity.Property(e => e.Role)
                .HasColumnType("enum('USER','RIDER')")
                .HasColumnName("role");
            entity.Property(e => e.UpdatedAt)
                .ValueGeneratedOnAddOrUpdate()
                .HasDefaultValueSql("CURRENT_TIMESTAMP(3)")
                .HasColumnType("timestamp(3)")
                .HasColumnName("updated_at");
        });

        modelBuilder.Entity<Delivery>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("delivery");

            entity.HasIndex(e => e.DropoffAddressId, "fk_delivery_dropoff");

            entity.HasIndex(e => e.PickupAddressId, "fk_delivery_pickup");

            entity.HasIndex(e => e.ReceiverId, "fk_delivery_receiver");

            entity.HasIndex(e => e.RiderId, "fk_delivery_rider");

            entity.HasIndex(e => e.SenderId, "fk_delivery_sender");

            entity.HasIndex(e => new { e.Id, e.RiderId }, "uq_delivery_rider_once").IsUnique();

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.BaseStatus)
                .HasDefaultValueSql("'WAITING'")
                .HasColumnType("enum('WAITING','ACCEPTED','PICKED_UP','DELIVERED')")
                .HasColumnName("base_status");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP(3)")
                .HasColumnType("timestamp(3)")
                .HasColumnName("created_at");
            entity.Property(e => e.DropoffAddressId).HasColumnName("dropoff_address_id");
            entity.Property(e => e.PickupAddressId).HasColumnName("pickup_address_id");
            entity.Property(e => e.ReceiverId).HasColumnName("receiver_id");
            entity.Property(e => e.RiderId).HasColumnName("rider_id");
            entity.Property(e => e.SenderId).HasColumnName("sender_id");
            entity.Property(e => e.UpdatedAt)
                .ValueGeneratedOnAddOrUpdate()
                .HasDefaultValueSql("CURRENT_TIMESTAMP(3)")
                .HasColumnType("timestamp(3)")
                .HasColumnName("updated_at");

            entity.HasOne(d => d.DropoffAddress).WithMany(p => p.Deliveries)
                .HasForeignKey(d => d.DropoffAddressId)
                .HasConstraintName("fk_delivery_dropoff");

            entity.HasOne(d => d.PickupAddress).WithMany(p => p.Deliveries)
                .HasForeignKey(d => d.PickupAddressId)
                .HasConstraintName("fk_delivery_pickup");

            entity.HasOne(d => d.Receiver).WithMany(p => p.DeliveryReceivers)
                .HasForeignKey(d => d.ReceiverId)
                .HasConstraintName("fk_delivery_receiver");

            entity.HasOne(d => d.Rider).WithMany(p => p.DeliveryRiders)
                .HasForeignKey(d => d.RiderId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("fk_delivery_rider");

            entity.HasOne(d => d.Sender).WithMany(p => p.DeliverySenders)
                .HasForeignKey(d => d.SenderId)
                .HasConstraintName("fk_delivery_sender");
        });

        modelBuilder.Entity<DeliveryPhoto>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("delivery_photo");

            entity.HasIndex(e => new { e.DeliveryId, e.Status }, "uq_photo_once_per_status").IsUnique();

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP(3)")
                .HasColumnType("timestamp(3)")
                .HasColumnName("created_at");
            entity.Property(e => e.DeliveryId).HasColumnName("delivery_id");
            entity.Property(e => e.PhotoUrl)
                .HasMaxLength(255)
                .HasColumnName("photo_url");
            entity.Property(e => e.Status)
                .HasColumnType("enum('WAITING','PICKED_UP','DELIVERED')")
                .HasColumnName("status");

            entity.HasOne(d => d.Delivery).WithMany(p => p.DeliveryPhotos)
                .HasForeignKey(d => d.DeliveryId)
                .HasConstraintName("fk_photo_delivery");
        });

        modelBuilder.Entity<RiderActiveLock>(entity =>
        {
            entity.HasKey(e => e.RiderId).HasName("PRIMARY");

            entity.ToTable("rider_active_lock");

            entity.HasIndex(e => e.DeliveryId, "delivery_id").IsUnique();

            entity.Property(e => e.RiderId)
                .ValueGeneratedOnAdd()
                .HasColumnName("rider_id");
            entity.Property(e => e.DeliveryId).HasColumnName("delivery_id");
            entity.Property(e => e.LockedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP(3)")
                .HasColumnType("timestamp(3)")
                .HasColumnName("locked_at");

            entity.HasOne(d => d.Delivery).WithOne(p => p.RiderActiveLock)
                .HasForeignKey<RiderActiveLock>(d => d.DeliveryId)
                .HasConstraintName("fk_lock_delivery");

            entity.HasOne(d => d.Rider).WithOne(p => p.RiderActiveLock)
                .HasForeignKey<RiderActiveLock>(d => d.RiderId)
                .HasConstraintName("fk_lock_rider");
        });

        modelBuilder.Entity<RiderProfile>(entity =>
        {
            entity.HasKey(e => e.RiderId).HasName("PRIMARY");

            entity.ToTable("rider_profile");

            entity.Property(e => e.RiderId)
                .ValueGeneratedOnAdd()
                .HasColumnName("rider_id");
            entity.Property(e => e.VehiclePhotoUrl)
                .HasMaxLength(255)
                .HasColumnName("vehicle_photo_url");
            entity.Property(e => e.VehiclePlate)
                .HasMaxLength(50)
                .HasColumnName("vehicle_plate");

            entity.HasOne(d => d.Rider).WithOne(p => p.RiderProfile)
                .HasForeignKey<RiderProfile>(d => d.RiderId)
                .HasConstraintName("fk_riderprofile_account");
        });

        modelBuilder.Entity<UserAddress>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("user_address");

            entity.HasIndex(e => e.UserId, "fk_useraddr_user");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.AddressText)
                .HasMaxLength(400)
                .HasColumnName("address_text");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP(3)")
                .HasColumnType("timestamp(3)")
                .HasColumnName("created_at");
            entity.Property(e => e.Label)
                .HasMaxLength(60)
                .HasColumnName("label");
            entity.Property(e => e.Location).HasColumnName("location");
            entity.Property(e => e.UserId).HasColumnName("user_id");

            entity.HasOne(d => d.User).WithMany(p => p.UserAddresses)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("fk_useraddr_user");
        });

        modelBuilder.Entity<UserPickupAddress>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("user_pickup_address");

            entity.HasIndex(e => e.UserId, "fk_userpickup_user");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.AddressText)
                .HasMaxLength(400)
                .HasColumnName("address_text");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP(3)")
                .HasColumnType("timestamp(3)")
                .HasColumnName("created_at");
            entity.Property(e => e.Location)
                .HasAnnotation("MySql:SpatialReferenceSystemId", 4326)
                .HasColumnName("location");
            entity.Property(e => e.UserId).HasColumnName("user_id");

            entity.HasOne(d => d.User).WithMany(p => p.UserPickupAddresses)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("fk_userpickup_user");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
