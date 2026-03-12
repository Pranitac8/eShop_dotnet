# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build

WORKDIR /app

# Copy only the project files first (for caching restore)
COPY src/WebApp/WebApp.csproj ./src/WebApp/
# Copy other csproj files if you have multiple projects
# COPY src/OtherProject/OtherProject.csproj ./src/OtherProject/

# Restore dependencies (Docker caches this unless csproj changes)
RUN dotnet restore src/WebApp/WebApp.csproj --disable-parallel

# Copy the full source code
COPY . .

# Build the project
RUN dotnet publish src/WebApp/WebApp.csproj -c Release -o /app/out

# Stage 2: Runtime image
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

# Copy the built output from build stage
COPY --from=build /app/out .

# Expose port (if your app uses default 80)
EXPOSE 80

# Set entrypoint
ENTRYPOINT ["dotnet", "WebApp.dll"]
