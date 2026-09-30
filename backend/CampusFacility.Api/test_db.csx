using System;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using CampusFacility.Api.Data;
using CampusFacility.Api.Models;

var options = new DbContextOptionsBuilder<AppDbContext>()
    .UseNpgsql("Host=db.wglebrdozypxojunsnmn.supabase.co;Port=5432;Database=postgres;Username=postgres;Password=DevpluxIT2026;SSL Mode=Require;Trust Server Certificate=true")
    .Options;
using var context = new AppDbContext(options);
var techs = context.Technicians.Include(t => t.User).ToList();
foreach(var t in techs) {
    Console.WriteLine($"ID: {t.Id}, UserId: {t.UserId}, User: {t.User.Email}, Skill: '{t.Skill}', Avail: {t.IsAvailable}");
}
