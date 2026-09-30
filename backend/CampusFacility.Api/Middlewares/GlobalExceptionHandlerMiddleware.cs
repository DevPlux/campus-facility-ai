using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Threading.Tasks;

namespace CampusFacility.Api.Middlewares
{
    public class GlobalExceptionHandlerMiddleware
    {
        private readonly RequestDelegate _next;

        public GlobalExceptionHandlerMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (Exception ex)
            {
                await HandleExceptionAsync(context, ex);
            }
        }

        private static Task HandleExceptionAsync(HttpContext context, Exception exception)
        {
            context.Response.ContentType = "application/json";
            
            var statusCode = StatusCodes.Status500InternalServerError;
            var message = "An internal server error occurred.";

            switch (exception)
            {
                case KeyNotFoundException:
                    statusCode = StatusCodes.Status404NotFound;
                    message = exception.Message; // Safe to expose missing resource IDs typically
                    break;
                case UnauthorizedAccessException:
                    statusCode = StatusCodes.Status403Forbidden;
                    message = exception.Message;
                    break;
                case InvalidOperationException:
                case ArgumentException:
                    statusCode = StatusCodes.Status400BadRequest;
                    message = exception.Message; // Safe business validation logic
                    break;
                default:
                    Console.WriteLine($"[GLOBAL ERROR]: {exception}");
                    break;
            }

            context.Response.StatusCode = statusCode;

            var result = JsonSerializer.Serialize(new
            {
                success = false,
                message = message,
                errors = Array.Empty<string>()
            });

            return context.Response.WriteAsync(result);
        }
    }
}



