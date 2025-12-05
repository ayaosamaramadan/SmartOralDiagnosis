import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../theme/app_theme.dart';
import '../services/api.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  static final String apiBase = Api.baseUrl;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // اختيار gradient و text colors بناءً على الثيم
    final gradientColors = isDark
        ? [appColors.gradientStart, appColors.gradientMiddle, appColors.gradientEnd]
        : [Colors.blue.shade200, Colors.blue.shade400, Colors.blue.shade700];

    final inputFillColor = isDark
        ? Colors.white.withOpacity(0.13)
        : Colors.white.withOpacity(0.8);

    final iconColor = isDark ? cs.primary : Colors.blue.shade900;
    final buttonColor = isDark ? cs.primary : Colors.blue.shade900;
    final buttonTextColor = Colors.white;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.blue.shade900),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Sign In',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.blue.shade900,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                color: Colors.black38,
                offset: const Offset(1, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                color: isDark
                    ? Colors.white.withAlpha((0.07 * 255).round())
                    : Colors.white.withAlpha((0.9 * 255).round()),
                elevation: 12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.asset(
                          'assets/login-image.png',
                          width: 240,
                          height: 240,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _buildTextField(_emailController, 'Email', Icons.email, inputFillColor, iconColor),
                      const SizedBox(height: 18),
                      _buildTextField(_passwordController, 'Password', Icons.lock, inputFillColor, iconColor,
                          obscureText: true),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                            elevation: 6,
                          ),
                          onPressed: _login,
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              color: buttonTextColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account ? ",
                            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 15),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: isDark ? Colors.lightBlue.shade200 : Colors.blue.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, Color fillColor,
      Color iconColor, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: iconColor),
        labelText: label,
        filled: true,
        fillColor: fillColor,
        labelStyle: TextStyle(color: iconColor.withOpacity(0.7)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      ),
      style: TextStyle(color: iconColor),
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter your email and password.');
      return;
    }

    final uri = Uri.parse('$apiBase/api/Auth/login');

    try {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
      }

      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (mounted) Navigator.of(context).pop(); // dismiss loading

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final token = body['token'];
        if (token != null) await _secureStorage.write(key: 'jwt', value: token.toString());
        // Store the returned user object so other screens (home/profile) can read it
        try {
          final user = body['user'];
          if (user != null) {
            await _secureStorage.write(key: 'user', value: jsonEncode(user));
          }
        } catch (_) {}
        if (!mounted) return;
        _showMessage('Logged in successfully', success: true);
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      } else if (resp.statusCode == 401 || resp.statusCode == 400) {
        String msg = 'Login credentials are incorrect';
        try {
          final body = jsonDecode(resp.body);
          if (body is Map && body['message'] != null) msg = body['message'];
        } catch (_) {}
        _showMessage(msg);
      } else {
        _showMessage('An unexpected error occurred, please try again later.');
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      _showMessage('Unable to connect to the server. Check if the backend is running.');
    }
  }

  void _showMessage(String message, {bool success = false}) {
    final snack = SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green : Colors.redAccent,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }
}
