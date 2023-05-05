using Dapr.Client;
using Microsoft.AspNetCore.Mvc;

namespace Publisher.Controllers;

[ApiController]
[Route("[controller]")]
public class UserController : ControllerBase
{
    private readonly DaprClient _daprClient;
    private readonly ILogger<UserController> _logger;

    public UserController(DaprClient daprClient, ILogger<UserController> logger)
    {
        _daprClient = daprClient;
        _logger = logger;
    }


    [HttpPost]
    public async Task<IActionResult> CreateUser(CreateUserRequest request)
    {
        _logger.LogInformation("creating message");

        await _daprClient.PublishEventAsync("pubsub", "createuser", request,new Dictionary<string, string>{{"sessionId", "test"}});
        
         _logger.LogInformation("created message");
        return Accepted();
    }
}