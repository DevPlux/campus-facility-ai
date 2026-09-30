using CampusFacility.Api.Enums;
using CampusFacility.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace CampusFacility.Api.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Issue> Issues { get; set; }
        public DbSet<IssueImage> IssueImages { get; set; }
        public DbSet<Technician> Technicians { get; set; }
        public DbSet<Assignment> Assignments { get; set; }
        public DbSet<IssueStatusHistory> IssueStatusHistory { get; set; }
        public DbSet<AgentRun> AgentRuns { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // A. User.Email unique index
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            // B. Technician.UserId unique index
            modelBuilder.Entity<Technician>()
                .HasIndex(t => t.UserId)
                .IsUnique();

            // C. User -> Technician one-to-zero-or-one
            modelBuilder.Entity<Technician>()
                .HasOne(t => t.User)
                .WithOne(u => u.Technician)
                .HasForeignKey<Technician>(t => t.UserId);

            // D. Assignment.ApprovedBy -> User DeleteBehavior.Restrict
            modelBuilder.Entity<Assignment>()
                .HasOne(a => a.ApprovedByUser)
                .WithMany()
                .HasForeignKey(a => a.ApprovedBy)
                .OnDelete(DeleteBehavior.Restrict);

            // E. IssueStatusHistory.ChangedBy -> User DeleteBehavior.Restrict
            modelBuilder.Entity<IssueStatusHistory>()
                .HasOne(ish => ish.ChangedByUser)
                .WithMany()
                .HasForeignKey(ish => ish.ChangedBy)
                .OnDelete(DeleteBehavior.Restrict);

            // F. Normal FK relationships
            modelBuilder.Entity<Issue>()
                .HasOne(i => i.Reporter)
                .WithMany(u => u.ReportedIssues)
                .HasForeignKey(i => i.ReporterId);

            modelBuilder.Entity<IssueImage>()
                .HasOne(ii => ii.Issue)
                .WithMany(i => i.Images)
                .HasForeignKey(ii => ii.IssueId);

            modelBuilder.Entity<Assignment>()
                .HasOne(a => a.Issue)
                .WithMany(i => i.Assignments)
                .HasForeignKey(a => a.IssueId);

            modelBuilder.Entity<Assignment>()
                .HasOne(a => a.Technician)
                .WithMany(t => t.Assignments)
                .HasForeignKey(a => a.TechnicianId);

            modelBuilder.Entity<IssueStatusHistory>()
                .HasOne(ish => ish.Issue)
                .WithMany(i => i.StatusHistory)
                .HasForeignKey(ish => ish.IssueId);

            modelBuilder.Entity<AgentRun>()
                .HasOne(ar => ar.Issue)
                .WithMany(i => i.AgentRuns)
                .HasForeignKey(ar => ar.IssueId);

            // G. Enums as strings
            modelBuilder.Entity<User>()
                .Property(u => u.Role)
                .HasConversion<string>();

            modelBuilder.Entity<Issue>()
                .Property(i => i.Status)
                .HasConversion<string>();

            modelBuilder.Entity<Issue>()
                .Property(i => i.Category)
                .HasConversion<string>();

            modelBuilder.Entity<Issue>()
                .Property(i => i.Priority)
                .HasConversion<string>();

            modelBuilder.Entity<IssueImage>()
                .Property(ii => ii.ImageType)
                .HasConversion<string>();

            modelBuilder.Entity<AgentRun>()
                .Property(ar => ar.AgentType)
                .HasConversion<string>();

            modelBuilder.Entity<AgentRun>()
                .Property(ar => ar.Status)
                .HasConversion<string>();

            modelBuilder.Entity<IssueStatusHistory>()
                .Property(ish => ish.OldStatus)
                .HasConversion<string>();

            modelBuilder.Entity<IssueStatusHistory>()
                .Property(ish => ish.NewStatus)
                .HasConversion<string>();
        }
    }
}
