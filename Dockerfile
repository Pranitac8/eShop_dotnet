# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /app

# Copy NuGet config and central package versions first
COPY nuget.config .
COPY Directory.Packages.props .

# Copy only project files needed for restore (WebApp + its dependencies)
COPY src/WebApp/WebApp.csproj ./src/WebApp/
COPY src/eShop.ServiceDefaults/eShop.ServiceDefaults.csproj ./src/eShop.ServiceDefaults/
COPY src/WebAppComponents/WebAppComponents.csproj ./src/WebAppComponents/

# Restore dependencies (cached unless .csproj changes)
RUN dotnet restore src/WebApp/WebApp.csproj --disable-parallel

# Copy remaining source code (after restore) for build
COPY src ./src
COPY *.slnx . 
COPY Directory.Build.props .  
COPY Directory.Build.targets .

# Build and publish WebApp
RUN dotnet publish src/WebApp/WebApp.csproj -c Release -o /app/out

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

# Copy published output
COPY --from=build /app/out .

# Expose port and set entrypoint
EXPOSE 80
ENTRYPOINT ["dotnet", "WebApp.dll"]
