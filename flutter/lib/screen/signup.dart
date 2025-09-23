import 'package:flutter/material.dart';

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

  Color _getButtonColor() {
    switch (_selectedType) {
      case 'doctor':
        return Colors.green.shade600;
      case 'admin':
        return Colors.purple.shade600;
      default:
        return Colors.blue.shade600;
    }
  }

  Color _getButtonHoverColor() {
    switch (_selectedType) {
      case 'doctor':
        return Colors.green.shade700;
      case 'admin':
        return Colors.purple.shade700;
      default:
        return Colors.blue.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F050D),
              Color.fromARGB(255, 7, 3, 21),
              Color.fromARGB(255, 19, 22, 32),
              Color.fromARGB(255, 42, 46, 51),
              ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 0.8, 1.0],
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
                    onPressed: _isLoading ? null : () {
                      setState(() {
                        _isLoading = true;
                      });
                      // Simulate loading
                      Future.delayed(const Duration(seconds: 2), () {
                        setState(() {
                          _isLoading = false;
                        });
                      });
                    },
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
}
        