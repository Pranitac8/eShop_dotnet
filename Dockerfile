FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /app

COPY . .
RUN dotnet restore src/WebApp/WebApp.csproj
RUN dotnet publish src/WebApp/WebApp.csproj -c Release -o /out

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /out .

EXPOSE 8080
ENTRYPOINT ["dotnet", "WebApp.dll"]
