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

    final iconColor = isDark ? Colors.white : Colors.blue.shade900;
    final buttonColor = isDark ? cs.primary : Colors.blue.shade900;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/login');
          },
        ),
        centerTitle: true,
        title: Text(
          'Sign Up',
          style: TextStyle(
            color: iconColor,
            fontSize: 26,
            fontWeight: FontWeight.bold,
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
            child: _buildForm(isDark, iconColor, buttonColor),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(bool isDark, Color iconColor, Color buttonColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Card(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.white.withOpacity(0.95),
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),

                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: _inputDecoration(
                    'Account Type',
                    Icons.category,
                    isDark,
                    iconColor,
                  ),
                  dropdownColor: isDark ? const Color(0xFF1E2A44) : Colors.white,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  items: _userTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedType = val!),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(child: _buildTextField(_firstNameController, 'First Name', false, Icons.person, isDark, iconColor)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_lastNameController, 'Last Name', false, Icons.person_outline, isDark, iconColor)),
                  ],
                ),

                const SizedBox(height: 18),

                _buildTextField(_emailController, 'Email', false, Icons.email, isDark, iconColor),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(child: _buildDateField(isDark, iconColor)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_phoneController, 'Phone', false, Icons.phone, isDark, iconColor)),
                  ],
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(child: _buildTextField(_passwordController, 'Password', true, Icons.lock, isDark, iconColor)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_confirmPasswordController, 'Confirm Password', true, Icons.lock_outline, isDark, iconColor)),
                  ],
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 18),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text(
                    'Already have an account? Sign In',
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, bool isDark, Color iconColor) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: iconColor),
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
      labelStyle: TextStyle(color: iconColor.withOpacity(0.7)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: isDark ? Colors.white24 : Colors.blue.shade200,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: iconColor,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      bool obscure, IconData icon, bool isDark, Color iconColor) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: iconColor),
      decoration: _inputDecoration(label, icon, isDark, iconColor),
    );
  }

  Widget _buildDateField(bool isDark, Color iconColor) {
    return TextField(
      controller: _birthdateController,
      readOnly: true,
      style: TextStyle(color: iconColor),
      decoration: _inputDecoration('Birthdate', Icons.calendar_today, isDark, iconColor),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          _birthdateController.text =
              "${picked.day}/${picked.month}/${picked.year}";
        }
      },
    );
  }

  Future<void> _register() async {
  }
}
