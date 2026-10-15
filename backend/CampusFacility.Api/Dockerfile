FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build

WORKDIR /src

COPY CampusFacility.Api.csproj ./
RUN dotnet restore CampusFacility.Api.csproj

COPY . ./

RUN dotnet publish CampusFacility.Api.csproj \
    -c Release \
    -o /app/publish \
    --no-restore \
    /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime

WORKDIR /app

COPY --from=build /app/publish ./

ENV ASPNETCORE_ENVIRONMENT=Production

EXPOSE 10000

CMD ["sh", "-c", "exec dotnet CampusFacility.Api.dll --urls http://0.0.0.0:${PORT:-10000}"]