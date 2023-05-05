var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers().AddDapr();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Logging.AddConsole();
builder.Services.AddApplicationInsightsTelemetry();
builder.Services.AddCors(x => x.AddPolicy("test", p => p.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod()));

var app = builder.Build();

app.UseCors("test");


app.UseSwagger();
    app.UseSwaggerUI();


app.UseCloudEvents();

app.MapControllers();
app.MapSubscribeHandler();
app.Run();
