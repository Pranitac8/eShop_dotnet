# ---------------------------------------
# Stage 1: Build WebApp (optimized)
# ---------------------------------------
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /app

# Copy NuGet & package versions first (cached)
COPY nuget.config .
COPY Directory.Packages.props .

# Copy only project files needed for restore
COPY src/WebApp/WebApp.csproj ./src/WebApp/
COPY src/eShop.ServiceDefaults/eShop.ServiceDefaults.csproj ./src/eShop.ServiceDefaults/
COPY src/WebAppComponents/WebAppComponents.csproj ./src/WebAppComponents/

# Restore dependencies (cache-friendly)
RUN dotnet restore src/WebApp/WebApp.csproj --disable-parallel

# Copy only WebApp source and dependencies (skip tests)
COPY src/WebApp ./src/WebApp
COPY src/eShop.ServiceDefaults ./src/eShop.ServiceDefaults
COPY src/WebAppComponents ./src/WebAppComponents

# Build & publish WebApp using all cores (faster)
RUN dotnet publish src/WebApp/WebApp.csproj -c Release -o /app/out -maxcpucount

# ---------------------------------------
# Stage 2: Runtime
# ---------------------------------------
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

# Copy published output from build stage
COPY --from=build /app/out .

# Expose HTTP port
EXPOSE 80

# Run the WebApp
ENTRYPOINT ["dotnet", "WebApp.dll"]
