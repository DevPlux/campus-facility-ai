# .Net BE Setup

```
cd backend/CampusFacility.Api

dotnet restore

dotnet user-secrets init

dotnet user-secrets set "Supabase:Url" "https://wglebrdozypxojunsnmn.supabase.co"

dotnet user-secrets set "Supabase:ServiceRoleKey" ""

dotnet user-secrets set "Gemini:ApiKey" ""

dotnet user-secrets set "Jwt:Key" ""

dotnet ef database update

dotnet run
```

## When the project failed to run with issues

```
dotnet clean
dotnet restore
dotnet build
dotnet run --urls "http://0.0.0.0:5066"
```
