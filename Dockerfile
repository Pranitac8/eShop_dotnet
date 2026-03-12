# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build

WORKDIR /app

# Copy central NuGet/package version files
COPY nuget.config .
COPY Directory.Packages.props .

# Copy all project folders
COPY src ./src

# Copy solution file (includes all projects)
COPY eShop.slnx .

# Restore all projects in solution
RUN dotnet restore eShop.slnx --disable-parallel

# Copy everything else
COPY . .

# Build & publish WebApp
RUN dotnet publish src/WebApp/WebApp.csproj -c Release -o /app/out

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
COPY --from=build /app/out .

EXPOSE 80
ENTRYPOINT ["dotnet", "WebApp.dll"]
