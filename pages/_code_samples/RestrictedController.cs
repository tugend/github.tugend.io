using System;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace _code_samples
{
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class RestrictedController : ControllerBase
    {
        private readonly ILogger<RestrictedController> _logger;
        private readonly Random _rng;

        public RestrictedController(ILogger<RestrictedController> logger)
        {
            _logger = logger;
            _rng = new Random();
        }

        [AllowAnonymous]
        [HttpPost("authenticate")]
        public ActionResult<string> Authenticate([FromBody]AuthenticateModel model)
        {
            var accepted = model.Username.Equals("bob") 
                && model.Password.Equals("password");

            if (!accepted)
                return BadRequest(new { message = "Username or password is incorrect" });

            return Ok("You're welcome!");
        }

        [HttpGet("secret")]
        public int GetSecret()
        {
            return _rng.Next(-20, 55);
        }
    }
}