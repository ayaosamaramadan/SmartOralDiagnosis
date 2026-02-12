import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api.dart';
import '../theme/app_theme.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _selectedType = 'patient';
  final List<String> _userTypes = ['patient', 'doctor', 'admin'];
  bool _isLoading = false;

  // Use Api.baseUrl which chooses host depending on platform (web vs emulator)
  // For web this will be http://localhost:52552, for emulator it stays 10.0.2.2:5000
  final String _backendBaseUrl = Api.baseUrl;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _birthdateController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradientColors = isDark
        ? [appColors.gradientStart, appColors.gradientMiddle, appColors.gradientEnd]
        : [Colors.blue.shade200, Colors.blue.shade400, Colors.blue.shade700];

    final inputFillColor = isDark ? Colors.white.withOpacity(0.13) : Colors.white.withOpacity(0.8);
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
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/login');
          },
        ),
        centerTitle: true,
        title: Text(
          'Sign Up',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.blue.shade900,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            shadows: const [
              Shadow(
                color: Colors.black38,
                offset: Offset(1, 2),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 90),
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isLargeScreen = constraints.maxWidth > 1024;

                if (isLargeScreen) {
                  return Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/login-image.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 400,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade800,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.image, size: 100, color: Colors.white54),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(flex: 2, child: _buildForm(inputFillColor, iconColor, buttonColor, buttonTextColor)),
                    ],
                  );
                } else {
                  return _buildForm(inputFillColor, iconColor, buttonColor, buttonTextColor);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(Color inputFillColor, Color iconColor, Color buttonColor, Color buttonTextColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Card(
          color: inputFillColor.withOpacity(0.5),
          elevation: 12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Create Account',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),

                // Account Type Dropdown
                Container(
                  decoration: BoxDecoration(
                    color: inputFillColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.category, color: iconColor),
                      labelText: 'Account Type',
                      labelStyle: TextStyle(color: iconColor.withOpacity(0.7)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    dropdownColor: buttonColor,
                    style: TextStyle(color: Colors.white),
                    items: _userTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type.toUpperCase(), style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedType = val!),
                  ),
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(_firstNameController, 'First Name', TextInputType.text, false, Icons.person, inputFillColor, iconColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(_lastNameController, 'Last Name', TextInputType.text, false, Icons.person_outline, inputFillColor, iconColor),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                _buildTextField(_emailController, 'Email', TextInputType.emailAddress, false, Icons.email, inputFillColor, iconColor),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(child: _buildDateField(inputFillColor, iconColor)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_phoneController, 'Phone', TextInputType.phone, false, Icons.phone, inputFillColor, iconColor)),
                  ],
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(child: _buildTextField(_passwordController, 'Password', TextInputType.text, true, Icons.lock, inputFillColor, iconColor)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_confirmPasswordController, 'Confirm Password', TextInputType.text, true, Icons.lock_outline, inputFillColor, iconColor)),
                  ],
                ),
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
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
                              SizedBox(width: 12),
                              Text('Creating...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: Colors.white)),
                            ],
                          )
                        : Text('Sign Up', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: buttonTextColor)),
                  ),
                ),
                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account ? ", style: TextStyle(color: iconColor.withOpacity(0.7), fontSize: 10)),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text('Sign In', style: TextStyle(color: buttonColor, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, TextInputType? keyboardType, bool obscureText, IconData icon, Color fillColor, Color iconColor) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(color: iconColor),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: iconColor),
        labelText: labelText,
        filled: true,
        fillColor: fillColor,
        labelStyle: TextStyle(color: iconColor.withOpacity(0.7)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  Widget _buildDateField(Color fillColor, Color iconColor) {
    return TextField(
      controller: _birthdateController,
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: isDark
                    ? const ColorScheme.dark(primary: Color.fromARGB(255, 175, 199, 250), surface: Color(0xFF233A6A))
                    : ColorScheme.light(primary: Colors.blue.shade900, surface: Colors.blue.shade200),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          setState(() {
            _birthdateController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
          });
        }
      },
      style: TextStyle(color: iconColor),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.calendar_today, color: iconColor),
        labelText: 'Birthdate',
        filled: true,
        fillColor: fillColor,
        labelStyle: TextStyle(color: iconColor.withOpacity(0.7)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  Future<void> _register() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    final phone = _phoneController.text.trim();
    final birthdateText = _birthdateController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill required fields')));
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    if (birthdateText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select your birthdate')));
      return;
    }

    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final uri = Uri.parse('$_backendBaseUrl/api/auth/register');
      // Convert birthdate (dd/MM/yyyy) -> ISO yyyy-MM-dd expected by backend
      String dobIso;
      try {
        final parts = birthdateText.split('/');
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final dob = DateTime(year, month, day);
        dobIso = "${dob.year.toString().padLeft(4, '0')}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}";
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid birthdate format')));
        return;
      }

      final payload = {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phone,
        'role': _selectedType[0].toUpperCase() + _selectedType.substring(1),
        'dateOfBirth': dobIso,
      };

      final res = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final token = data['token'] as String?;
        if (token != null && token.isNotEmpty) await _secureStorage.write(key: 'jwt', value: token);

        if (!mounted) return;
        messenger.showSnackBar(const SnackBar(content: Text('Account created successfully')));
        navigator.pushReplacementNamed('/login');
      } else {
        String message = 'Registration failed';
        try {
          final body = jsonDecode(res.body);
          if (body is Map && body['message'] != null) message = body['message'].toString();
        } catch (_) {}
        if (mounted) messenger.showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
