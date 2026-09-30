using CampusFacility.Api.Enums;
using CampusFacility.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace CampusFacility.Api.Data
{
    public static class DbSeeder
    {
        public static async Task SeedAsync(AppDbContext context)
        {
            var defaultPassword = "Password123!";
            var passwordHash = BCrypt.Net.BCrypt.HashPassword(defaultPassword);

            var demoUsers = new List<User>
            {
                new User { Name = "Manager User", Email = "manager@campus.com", Role = Role.MANAGER, PasswordHash = passwordHash },
                new User { Name = "Reporter User", Email = "reporter@campus.com", Role = Role.REPORTER, PasswordHash = passwordHash },
                new User { Name = "Amal", Email = "amal@campus.com", Role = Role.TECHNICIAN, PasswordHash = passwordHash },
                new User { Name = "Kasun", Email = "kasun@campus.com", Role = Role.TECHNICIAN, PasswordHash = passwordHash },
                new User { Name = "Nimal", Email = "nimal@campus.com", Role = Role.TECHNICIAN, PasswordHash = passwordHash },
                new User { Name = "Saman", Email = "saman@campus.com", Role = Role.TECHNICIAN, PasswordHash = passwordHash },
                new User { Name = "Kamal", Email = "kamal@campus.com", Role = Role.TECHNICIAN, PasswordHash = passwordHash }
            };

            foreach (var user in demoUsers)
            {
                if (!await context.Users.AnyAsync(u => u.Email == user.Email))
                {
                    context.Users.Add(user);
                }
            }

            await context.SaveChangesAsync();

            await EnsureTechnician(context, "amal@campus.com", "ELECTRICAL", true);
            await EnsureTechnician(context, "kasun@campus.com", "PLUMBING", true);
            await EnsureTechnician(context, "nimal@campus.com", "PLUMBING", false);
            await EnsureTechnician(context, "saman@campus.com", "IT", true);
            await EnsureTechnician(context, "kamal@campus.com", "HVAC", true);

            await context.SaveChangesAsync();
        }

        private static async Task EnsureTechnician(AppDbContext context, string email, string skill, bool isAvailable)
        {
            var user = await context.Users.FirstOrDefaultAsync(u => u.Email == email);
            if (user != null && !await context.Technicians.AnyAsync(t => t.UserId == user.Id))
            {
                context.Technicians.Add(new Technician
                {
                    UserId = user.Id,
                    Skill = skill,
                    IsAvailable = isAvailable
                });
            }
        }
    }
}
