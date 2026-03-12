FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build

WORKDIR /app

# Central package and nuget files
COPY nuget.config .
COPY Directory.Packages.props .

# Copy only src (skip tests)
COPY src ./src

# Restore WebApp and dependencies only
RUN dotnet restore src/WebApp/WebApp.csproj --disable-parallel

# Copy full source for build
COPY . .

# Publish WebApp
RUN dotnet publish src/WebApp/WebApp.csproj -c Release -o /app/out

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
COPY --from=build /app/out .
EXPOSE 80
ENTRYPOINT ["dotnet", "WebApp.dll"]
