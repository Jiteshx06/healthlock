import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'main_container.dart';
import 'responsive_utils.dart';
import 'api_service.dart';
import 'config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _isLoginTab = true;
  bool _isLoading = false;
  bool _isDoctorMode = false; // New state for doctor/patient toggle

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();
  File? _degreeFile;

  @override
  void initState() {
    super.initState();
    // Pre-fill with demo credentials for testing (only for login)
    if (_isLoginTab) {
      _emailController.text = AppConfig.demoEmail;
      _passwordController.text = AppConfig.demoPassword;
    }
  }

  // Login method with API integration
  Future<void> _handleLogin() async {
    // Validate input
    if (_emailController.text.trim().isEmpty) {
      _showErrorMessage('Please enter your email');
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      _showErrorMessage('Please enter your password');
      return;
    }

    // Basic email validation
    if (!_emailController.text.contains('@')) {
      _showErrorMessage('Please enter a valid email address');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isDoctorMode) {
        // Doctor login
        final response = await ApiService.doctorLogin(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (response.success) {
          // Login successful
          _showSuccessMessage(response.message);

          // Navigate to main screen
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainContainer()),
            );
          }
        } else {
          _showErrorMessage(response.message);
        }
      } else {
        // Patient login
        final response = await ApiService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (response.success) {
          // Login successful
          _showSuccessMessage(response.message);

          // Navigate to main screen
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainContainer()),
            );
          }
        } else {
          _showErrorMessage(response.message);
        }
      }
    } catch (e) {
      if (e.toString().contains('pending admin approval') ||
          e.toString().contains('Your account is pending')) {
        _showPendingMessage(e.toString());
      } else {
        _showErrorMessage(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Register method with API integration
  Future<void> _handleRegister() async {
    // Validate input
    if (_nameController.text.trim().isEmpty) {
      _showErrorMessage('Please enter your name');
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showErrorMessage('Please enter your email');
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      _showErrorMessage('Please enter your password');
      return;
    }

    // Basic email validation
    if (!_emailController.text.contains('@')) {
      _showErrorMessage('Please enter a valid email address');
      return;
    }

    // Password validation
    if (_passwordController.text.trim().length < 6) {
      _showErrorMessage('Password must be at least 6 characters');
      return;
    }

    if (_isDoctorMode) {
      // Doctor-specific validation
      if (_specializationController.text.trim().isEmpty) {
        _showErrorMessage('Please enter your specialization');
        return;
      }
    } else {
      // Patient-specific validation
      if (_ageController.text.trim().isEmpty) {
        _showErrorMessage('Please enter your age');
        return;
      }

      // Age validation
      final age = int.tryParse(_ageController.text.trim());
      if (age == null || age < 1 || age > 120) {
        _showErrorMessage('Please enter a valid age (1-120)');
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isDoctorMode) {
        // Doctor registration
        final response = await ApiService.doctorRegister(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          specialization: _specializationController.text.trim(),
          degreeFile: _degreeFile,
        );

        if (response.success) {
          // Registration successful
          _showSuccessMessage(response.message);

          // Navigate to main screen
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainContainer()),
            );
          }
        } else {
          _showErrorMessage(response.message);
        }
      } else {
        // Patient registration
        final age = int.tryParse(_ageController.text.trim())!;
        final response = await ApiService.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          age: age,
        );

        if (response.success) {
          // Registration successful
          _showSuccessMessage(response.message);

          // Navigate to main screen
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainContainer()),
            );
          }
        } else {
          _showErrorMessage(response.message);
        }
      }
    } catch (e) {
      if (e.toString().contains('pending admin approval') ||
          e.toString().contains('Registration submitted successfully')) {
        _showPendingMessage(e.toString());

        // Switch to login tab after showing pending message for doctor registration
        if (_isDoctorMode) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _switchTab(true); // Switch to login tab
              });
            }
          });
        }
      } else {
        _showErrorMessage(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearFields() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _ageController.clear();
    _specializationController.clear();
    _degreeFile = null;
  }

  Future<void> _pickDegreeFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _degreeFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      _showErrorMessage('Error picking file: $e');
    }
  }

  void _switchTab(bool isLogin) {
    setState(() {
      _isLoginTab = isLogin;
      _clearFields();

      // Pre-fill demo credentials only for login
      if (isLogin && !_isDoctorMode) {
        _emailController.text = AppConfig.demoEmail;
        _passwordController.text = AppConfig.demoPassword;
      }
    });
  }

  void _switchUserType(bool isDoctorMode) {
    setState(() {
      _isDoctorMode = isDoctorMode;
      _clearFields();

      // Pre-fill demo credentials only for patient login
      if (_isLoginTab && !isDoctorMode) {
        _emailController.text = AppConfig.demoEmail;
        _passwordController.text = AppConfig.demoPassword;
      }
    });
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showPendingMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (_isDoctorMode) ...[
                const SizedBox(height: 4),
                const Text(
                  'You will be redirected to the login page. Please try logging in after admin approval.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: ResponsiveUtils.getResponsiveConstraints(context),
            child: SingleChildScrollView(
              padding: ResponsiveUtils.getResponsiveHorizontalPadding(context),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Logo and Title Section
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4285F4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_hospital,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text('HealthLock', style: AppTextStyles.heading1(context)),

                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 8),
                  ),

                  Text(
                    'Your Health, Our Priority',
                    style: AppTextStyles.bodyMedium(
                      context,
                    ).copyWith(color: const Color(0xFF6B7280)),
                  ),

                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 32),
                  ),

                  // Patient/Doctor Toggle
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _switchUserType(false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isDoctorMode
                                    ? const Color(0xFF4285F4)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Text(
                                'Patient',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.button(context).copyWith(
                                  color: !_isDoctorMode
                                      ? Colors.white
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _switchUserType(true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isDoctorMode
                                    ? const Color(0xFF4285F4)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Text(
                                'Doctor',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.button(context).copyWith(
                                  color: _isDoctorMode
                                      ? Colors.white
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 24),
                  ),

                  // Doctor verification notice
                  if (_isDoctorMode && !_isLoginTab)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Doctor accounts require admin approval. After registration, you will be redirected to login page. Please wait for approval before attempting to login.',
                              style: AppTextStyles.bodySmall(context).copyWith(
                                color: Colors.blue.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_isDoctorMode && !_isLoginTab)
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(context, 16),
                    ),

                  // Login/Sign Up Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Tab Headers
                        Container(
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _switchTab(true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _isLoginTab
                                          ? Colors.transparent
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: _isLoginTab
                                          ? const Border(
                                              bottom: BorderSide(
                                                color: Color(0xFF4285F4),
                                                width: 2,
                                              ),
                                            )
                                          : null,
                                    ),
                                    child: Text(
                                      'Login',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.button(context)
                                          .copyWith(
                                            color: _isLoginTab
                                                ? const Color(0xFF4285F4)
                                                : const Color(0xFF6B7280),
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _switchTab(false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: !_isLoginTab
                                          ? Colors.transparent
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: !_isLoginTab
                                          ? const Border(
                                              bottom: BorderSide(
                                                color: Color(0xFF4285F4),
                                                width: 2,
                                              ),
                                            )
                                          : null,
                                    ),
                                    child: Text(
                                      'Sign Up',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.button(context)
                                          .copyWith(
                                            color: !_isLoginTab
                                                ? const Color(0xFF4285F4)
                                                : const Color(0xFF6B7280),
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Form Fields
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: _isLoginTab
                              ? _buildLoginForm()
                              : _buildRegisterForm(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email Field
        Text(
          'Email Address',
          style: AppTextStyles.bodySmall(context).copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Enter your email',
            hintStyle: AppTextStyles.bodyMedium(
              context,
            ).copyWith(color: const Color(0xFF9CA3AF)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4285F4)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),

        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20)),

        // Password Field
        Text(
          'Password',
          style: AppTextStyles.bodySmall(context).copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
        TextField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            hintStyle: AppTextStyles.bodyMedium(
              context,
            ).copyWith(color: const Color(0xFF9CA3AF)),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF9CA3AF),
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4285F4)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),

        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32)),

        // Login Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4285F4),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveUtils.getResponsiveSpacing(context, 16),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Login',
                    style: AppTextStyles.button(
                      context,
                    ).copyWith(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name Field
        Text(
          'Full Name',
          style: AppTextStyles.bodySmall(context).copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Enter your full name',
            hintStyle: AppTextStyles.bodyMedium(
              context,
            ).copyWith(color: const Color(0xFF9CA3AF)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4285F4)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),

        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20)),

        // Email Field
        Text(
          'Email Address',
          style: AppTextStyles.bodySmall(context).copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Enter your email',
            hintStyle: AppTextStyles.bodyMedium(
              context,
            ).copyWith(color: const Color(0xFF9CA3AF)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4285F4)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),

        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20)),

        // Conditional fields based on user type
        if (_isDoctorMode) ...[
          // Specialization Field for Doctor
          Text(
            'Specialization',
            style: AppTextStyles.bodySmall(context).copyWith(
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
          TextField(
            controller: _specializationController,
            decoration: InputDecoration(
              hintText: 'Enter your specialization (e.g., MBBS, MD)',
              hintStyle: AppTextStyles.bodyMedium(
                context,
              ).copyWith(color: const Color(0xFF9CA3AF)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF4285F4)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20)),

          // Degree File Upload for Doctor
          Text(
            'Degree Certificate (Optional)',
            style: AppTextStyles.bodySmall(context).copyWith(
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
          GestureDetector(
            onTap: _pickDegreeFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.upload_file, color: const Color(0xFF9CA3AF)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _degreeFile != null
                          ? _degreeFile!.path.split('/').last
                          : 'Upload degree certificate (PDF, JPG, PNG)',
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: _degreeFile != null
                            ? const Color(0xFF374151)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          // Age Field for Patient
          Text(
            'Age',
            style: AppTextStyles.bodySmall(context).copyWith(
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
          TextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter your age',
              hintStyle: AppTextStyles.bodyMedium(
                context,
              ).copyWith(color: const Color(0xFF9CA3AF)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF4285F4)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ],

        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20)),

        // Password Field
        Text(
          'Password',
          style: AppTextStyles.bodySmall(context).copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
        TextField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: 'Enter your password (min 6 characters)',
            hintStyle: AppTextStyles.bodyMedium(
              context,
            ).copyWith(color: const Color(0xFF9CA3AF)),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF9CA3AF),
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4285F4)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),

        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32)),

        // Register Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4285F4),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveUtils.getResponsiveSpacing(context, 16),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _isDoctorMode ? 'Create Doctor Account' : 'Create Account',
                    style: AppTextStyles.button(
                      context,
                    ).copyWith(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }
}
