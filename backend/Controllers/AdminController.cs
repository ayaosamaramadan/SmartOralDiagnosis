using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using MedicalManagement.API.Services;

namespace MedicalManagement.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "admin")]
    public class AdminController : ControllerBase
    {
        private readonly IAdminService _adminService;

        public AdminController(IAdminService adminService)
        {
            _adminService = adminService;
        }

        [HttpGet("dashboard-stats")]
        public async Task<ActionResult> GetDashboardStats()
        {
            try
            {
                var stats = await _adminService.GetDashboardStatsAsync();
                return Ok(stats);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }

        [HttpGet("users")]
        public async Task<ActionResult> GetAllUsers()
        {
            try
            {
                var users = await _adminService.GetAllUsersAsync();
                return Ok(users);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }

        [HttpPut("users/{userId}/deactivate")]
        public async Task<ActionResult> DeactivateUser(string userId)
        {
            try
            {
                var result = await _adminService.DeactivateUserAsync(userId);
                if (!result)
                {
                    return NotFound(new { message = "User not found" });
                }

                return Ok(new { message = "User deactivated successfully" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }

        [HttpPut("users/{userId}/activate")]
        public async Task<ActionResult> ActivateUser(string userId)
        {
            try
            {
                var result = await _adminService.ActivateUserAsync(userId);
                if (!result)
                {
                    return NotFound(new { message = "User not found" });
                }

                return Ok(new { message = "User activated successfully" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }
    }
}
