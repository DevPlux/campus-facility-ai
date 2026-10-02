using CampusFacility.Api.Data;
using CampusFacility.Api.Services;
using CampusFacility.Api.Services.Agents;
using CampusFacility.Api.Middlewares;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using System;
using System.Linq;

var builder = WebApplication.CreateBuilder(args);

// ============================================================
// 1. CONFIGURATION VALIDATION
// ============================================================

var requiredKeys = new[]
{
    "ConnectionStrings:DefaultConnection",

    "Jwt:Key",
    "Jwt:Issuer",
    "Jwt:Audience",

    "Supabase:Url",
    "Supabase:ServiceRoleKey",
    "Supabase:StorageBucket",

    "Gemini:ApiKey",
    "Gemini:Model"
};

foreach (var key in requiredKeys)
{
    if (string.IsNullOrWhiteSpace(builder.Configuration[key]))
    {
        throw new Exception(
            $"Startup failed: Missing required configuration key '{key}'.");
    }
}


// ============================================================
// 2. CORS
// ============================================================

var allowedOrigins =
    builder.Configuration
        .GetSection("AllowedOrigins")
        .Get<string[]>()
    ?? Array.Empty<string>();

builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        if (allowedOrigins.Length > 0)
        {
            policy.WithOrigins(allowedOrigins)
                  .AllowAnyHeader()
                  .AllowAnyMethod()
                  .AllowCredentials();
        }
        else
        {
            // Development fallback
            policy.AllowAnyOrigin()
                  .AllowAnyHeader()
                  .AllowAnyMethod();
        }
    });
});


// ============================================================
// 3. DATABASE
// ============================================================

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(
        builder.Configuration.GetConnectionString(
            "DefaultConnection")));


// ============================================================
// 4. APPLICATION SERVICES
// ============================================================

builder.Services.AddScoped<AuthService>();

builder.Services.AddHttpClient<
    ISupabaseStorageService,
    SupabaseStorageService>();


// ============================================================
// 5. AGENTIC AI SERVICES
// ============================================================

// Agent 1:
// Analyzes the reported facility issue using Gemini.
builder.Services.AddHttpClient<IssueAnalysisAgent>();

// Agent 2:
// Recommends an eligible technician using Gemini.
builder.Services.AddHttpClient<TechnicianAssignmentAgent>();


// ============================================================
// 6. BUSINESS SERVICES
// ============================================================

builder.Services.AddScoped<IssueService>();
builder.Services.AddScoped<AssignmentService>();
builder.Services.AddScoped<TechnicianService>();


// ============================================================
// 7. CONTROLLERS + VALIDATION RESPONSE
// ============================================================

builder.Services
    .AddControllers()
    .ConfigureApiBehaviorOptions(options =>
    {
        options.InvalidModelStateResponseFactory = context =>
        {
            var errors = context.ModelState
                .Where(e =>
                    e.Value != null &&
                    e.Value.Errors.Count > 0)
                .SelectMany(e =>
                    e.Value!.Errors.Select(
                        x => x.ErrorMessage))
                .ToArray();

            var result = new
            {
                success = false,
                message = "Validation failed.",
                errors = errors
            };

            return new Microsoft.AspNetCore.Mvc
                .BadRequestObjectResult(result);
        };
    });


// ============================================================
// 8. JWT AUTHENTICATION
// ============================================================

var jwtKey = builder.Configuration["Jwt:Key"]!;

builder.Services
    .AddAuthentication(
        JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters =
            new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidateLifetime = true,
                ValidateIssuerSigningKey = true,

                ValidIssuer =
                    builder.Configuration["Jwt:Issuer"],

                ValidAudience =
                    builder.Configuration["Jwt:Audience"],

                IssuerSigningKey =
                    new SymmetricSecurityKey(
                        Encoding.UTF8.GetBytes(jwtKey))
            };
    });

builder.Services.AddAuthorization();


// ============================================================
// 9. NSWAG / SWAGGER + JWT
// ============================================================

builder.Services.AddEndpointsApiExplorer();

builder.Services.AddOpenApiDocument(config =>
{
    config.Title = "Campus Facility API";

    config.AddSecurity(
        "Bearer",
        System.Linq.Enumerable.Empty<string>(),
        new NSwag.OpenApiSecurityScheme
        {
            Type =
                NSwag.OpenApiSecuritySchemeType.ApiKey,

            Name = "Authorization",

            In =
                NSwag.OpenApiSecurityApiKeyLocation.Header,

            Description =
                "Type into the textbox: Bearer {your JWT token}."
        });

    config.OperationProcessors.Add(
        new NSwag.Generation.Processors.Security
            .AspNetCoreOperationSecurityScopeProcessor(
                "Bearer"));
});


// ============================================================
// BUILD APPLICATION
// ============================================================

var app = builder.Build();


// ============================================================
// 10. DATABASE SEEDING
// ============================================================

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;

    var context =
        services.GetRequiredService<AppDbContext>();

    await DbSeeder.SeedAsync(context);
}


// ============================================================
// 11. GLOBAL ERROR HANDLING
// ============================================================

app.UseMiddleware<
    GlobalExceptionHandlerMiddleware>();


// ============================================================
// 12. SWAGGER - DEVELOPMENT ONLY
// ============================================================

if (app.Environment.IsDevelopment())
{
    app.UseOpenApi();
    app.UseSwaggerUi();
}


// ============================================================
// 13. HTTP PIPELINE
// ============================================================

app.UseHttpsRedirection();

// CORS must execute before authentication.
app.UseCors();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();


// ============================================================
// RUN
// ============================================================

app.Run();