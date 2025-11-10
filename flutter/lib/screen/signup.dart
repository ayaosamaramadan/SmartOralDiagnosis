import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  // TODO: adjust this base URL for your environment:
  // - Android emulator: use http://10.0.2.2:5000 (or the port Kestrel uses)
  // - iOS simulator / macOS: use http://localhost:5000
  // - Physical device: use your machine IP (http://192.168.x.y:5000)
  static const String _backendBaseUrl = 'http://10.0.2.2:5000';

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
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>{
            Navigator.pop(context),
            Navigator.pushNamed(context, '/login')
          }
        ),
        centerTitle: true,
        title: const Text(
          'Sign Up',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            shadows: [
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
            colors: [
              appColors.gradientStart,
              appColors.gradientMiddle,
              appColors.gradientEnd,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.5, 0.8],
          ),
        ),
        child: SingleChildScrollView(
          child: Container(
          
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
                      // Right side - Form
                      Expanded(
                        flex: 2,
                        child: _buildForm(),
                      ),
                    ],
                  );
                } else {
                  return _buildForm();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Card(
          color: Colors.white.withAlpha((0.07 * 255).round()),
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
            
                // Account Type Dropdown
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.13 * 255).round()),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.category, color: Color.fromARGB(255, 175, 199, 250)),
                      labelText: 'Account Type',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    dropdownColor: const Color(0xFF233A6A),
                    style: const TextStyle(color: Colors.white),
                    items: _userTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(
                          type.toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedType = newValue!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 18),

                // Name Fields Row
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(_firstNameController, 'First Name', TextInputType.text, false, Icons.person),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(_lastNameController, 'Last Name', TextInputType.text, false, Icons.person_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Email
                _buildTextField(_emailController, 'Email', TextInputType.emailAddress, false, Icons.email),
                const SizedBox(height: 18),

                // Birth Date and Phone Row
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(_phoneController, 'Phone', TextInputType.phone, false, Icons.phone),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Password and Confirm Password Row
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(_passwordController, 'Password', TextInputType.text, true, Icons.lock),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(_confirmPasswordController, 'Confirm Password', TextInputType.text, true, Icons.lock_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 14, 74, 206),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      elevation: 6,
                    ),
                    onPressed: _isLoading ? null : () => _register(),
                    child: _isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Creating...',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 1),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 18),

                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account ? ",
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Color(0xFFB3C7F9),
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
    );

  }

  Widget _buildTextField(TextEditingController controller, String labelText, [TextInputType? keyboardType, bool obscureText = false, IconData? icon]) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon, color: const Color.fromARGB(255, 175, 199, 250)) : null,
        labelText: labelText,
        filled: true,
        fillColor: Colors.white.withAlpha((0.13 * 255).round()),
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  Widget _buildDateField() {
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
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Color.fromARGB(255, 175, 199, 250),
                  surface: Color(0xFF233A6A),
                ),
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
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.calendar_today, color: Color.fromARGB(255, 175, 199, 250)),
        labelText: 'Birthdate',
        filled: true,
        fillColor: Colors.white.withAlpha((0.13 * 255).round()),
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  Future<void> _register() async {
    // Basic client-side validation
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    final phone = _phoneController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill required fields')));
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final uri = Uri.parse('$_backendBaseUrl/api/auth/register');
      final payload = {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phone,
        'role': _selectedType[0].toUpperCase() + _selectedType.substring(1) // 'patient' -> 'Patient'
      };

      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final token = data['token'] as String?;
        if (token != null && token.isNotEmpty) {
          await _secureStorage.write(key: 'jwt', value: token);
        }

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created successfully')));
        // navigate to login or home
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        String message = 'Registration failed';
        try {
          final body = jsonDecode(res.body);
          if (body is Map && body['message'] != null) message = body['message'].toString();
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
        