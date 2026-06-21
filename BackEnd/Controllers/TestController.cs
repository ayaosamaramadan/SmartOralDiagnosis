using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace MedicalManagement.API.Controllers;

[ApiController]
[Route("api/test")]
public class TestController : ControllerBase
{
    [AllowAnonymous]
    [HttpGet]
    public IActionResult Get()
    {
        return Ok(new { message = "API is working" });
    }

    [AllowAnonymous]
    [HttpPost]
    public IActionResult Post([FromBody] object data)
    {
        return Ok(new
        {
            message = "Data received",
            data
        });
    }
}
