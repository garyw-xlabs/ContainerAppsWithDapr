using Dapr.Client;
using Microsoft.AspNetCore.Mvc;

namespace CreateUser.Subscriber.Controllers
{
    public record CreateUserRequest(string Name, string Email);
    [ApiController]
    [Route("[controller]")]
    public class CreateUserController : ControllerBase
    {
        private readonly ILogger<CreateUserController> _logger;
        private readonly DaprClient _daprClient;

        public CreateUserController(ILogger<CreateUserController> logger, DaprClient daprClient)
        {
            _logger = logger;
            _daprClient = daprClient;
        }

        [Dapr.Topic("pubsub", "createuser","createuser-dl",false)]
        [HttpPost("CreateUser")]
        public IActionResult CreateUser([FromBody] CreateUserRequest createUserRequest)
        {
            
            _logger.LogInformation($"Creating user {createUserRequest.Email}");

            if(createUserRequest.Email.Contains("@")) return Ok();
            
            return BadRequest($"Failed create user: {createUserRequest.Email}");
        }

        [Dapr.Topic("pubsub","createuser-dl")]
        [HttpPost("CreateUser-DeadLetter")]
        public async Task<IActionResult> CreateUserDeadLetter([FromBody] object createUserRequest)
        {
            
            _logger.LogInformation($"Found Error user {createUserRequest}");
            IReadOnlyDictionary<string,string> metaData = new Dictionary<string, string>()
                   {
                       { "blobName", $"test_{DateTime.UtcNow.Ticks}.json" },
                   };
           await _daprClient.InvokeBindingAsync("errorqueueblobstore", "create", createUserRequest,metaData); 
            
        
            return Ok($"Failed create user: {createUserRequest}");
        }
    }
}