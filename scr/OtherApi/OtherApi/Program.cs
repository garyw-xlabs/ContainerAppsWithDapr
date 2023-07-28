using System.Net.Http.Headers;
using Azure.Core;
using Azure.Identity;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
app.UseSwagger();
app.UseSwaggerUI();


app.MapGet("/weatherforecastrelay",
        async () =>
        {
            var contents = string.Empty;
            try
            {
                var credential = new DefaultAzureCredential(new DefaultAzureCredentialOptions
                    { ManagedIdentityClientId = "24596425-e6d6-458e-944b-4c1ef9e16d4a" });
                var token = credential.GetToken(
                    new TokenRequestContext(new[] { "b73827cc-1587-46fb-8eac-a234662ccb0e" }));

                var httpClient = new HttpClient();
                httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("bearer", token.Token);
                httpClient.BaseAddress =
                    new Uri("https://ca-api-pqxgjxy6btr3i.jollypebble-8d13edbe.uksouth.azurecontainerapps.io");

                var response = await httpClient.GetAsync("/weatherforecast");
                contents = await response.Content.ReadAsStringAsync();
                var responsestring = await response.Content.ReadFromJsonAsync<string[]>();
                return responsestring.ToList();
            }
            catch (Exception ex)
            {
                return new List<string> { ex.Message, contents };
            }
        })
    .WithName("GetWeatherForecastRelay")
    .WithOpenApi();

app.Run();