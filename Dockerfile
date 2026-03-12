# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build

WORKDIR /app

# Copy all project files
COPY Directory.Packages.props .
COPY src/eShop.ServiceDefaults/eShop.ServiceDefaults.csproj ./src/eShop.ServiceDefaults/
COPY src/EventBusRabbitMQ/EventBusRabbitMQ.csproj ./src/EventBusRabbitMQ/
COPY src/WebAppComponents/WebAppComponents.csproj ./src/WebAppComponents/
COPY src/WebApp/WebApp.csproj ./src/WebApp/

# Restore
RUN dotnet restore src/WebApp/WebApp.csproj --disable-parallel

# Copy everything else
COPY . .

# Build and publish
RUN dotnet publish src/WebApp/WebApp.csproj -c Release -o /app/out

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
COPY --from=build /app/out .
EXPOSE 80
ENTRYPOINT ["dotnet", "WebApp.dll"]
