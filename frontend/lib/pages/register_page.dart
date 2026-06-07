import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.register(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please login.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<AppTheme>();

    return Scaffold(
      backgroundColor: theme.baseBg,
      appBar: AppBar(
        backgroundColor: theme.baseBg,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.primaryTextColor),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: theme.baseTextStyle(theme.primaryTextColor).copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Georgia',
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign up to get started',
                    textAlign: TextAlign.center,
                    style: theme.baseTextStyle(
                      theme.primaryTextColor.withOpacity(0.5),
                    ).copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 28),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: theme
                                  .baseTextStyle(Colors.red)
                                  .copyWith(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  Text(
                    'Username',
                    style: theme.baseTextStyle(theme.primaryTextColor).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _usernameController,
                    style: theme.baseTextStyle(theme.primaryTextColor),
                    decoration: InputDecoration(
                      hintText: 'Enter username',
                      hintStyle: theme.baseTextStyle(
                        theme.primaryTextColor.withOpacity(0.35),
                      ),
                      prefixIcon: Icon(Icons.person_outline,
                          color: theme.primaryTextColor.withOpacity(0.4)),
                      filled: true,
                      fillColor: theme.surfaceBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: theme.accentColor, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Username cannot be empty.';
                      }
                      if (value.trim().length < 3) {
                        return 'Username must be at least 3 characters.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  Text(
                    'Email Address',
                    style: theme.baseTextStyle(theme.primaryTextColor).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    style: theme.baseTextStyle(theme.primaryTextColor),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter email',
                      hintStyle: theme.baseTextStyle(
                        theme.primaryTextColor.withOpacity(0.35),
                      ),
                      prefixIcon: Icon(Icons.mail_outline,
                          color: theme.primaryTextColor.withOpacity(0.4)),
                      filled: true,
                      fillColor: theme.surfaceBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: theme.accentColor, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email cannot be empty.';
                      }
                      final emailRegex =
                          RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Please enter a valid email format.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  Text(
                    'Password',
                    style: theme.baseTextStyle(theme.primaryTextColor).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: theme.baseTextStyle(theme.primaryTextColor),
                    decoration: InputDecoration(
                      hintText: 'Strong pass',
                      hintStyle: theme.baseTextStyle(
                        theme.primaryTextColor.withOpacity(0.35),
                      ),
                      prefixIcon: Icon(Icons.lock_outlined,
                          color: theme.primaryTextColor.withOpacity(0.4)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: theme.primaryTextColor.withOpacity(0.4),
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      filled: true,
                      fillColor: theme.surfaceBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: theme.accentColor, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password cannot be empty.';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters.';
                      }
                      if (!RegExp(r'[a-z]').hasMatch(value)) {
                        return 'Requires at least one lowercase letter.';
                      }
                      if (!RegExp(r'[A-Z]').hasMatch(value)) {
                        return 'Requires at least one uppercase letter.';
                      }
                      if (!RegExp(r'[0-9]').hasMatch(value)) {
                        return 'Requires at least one number.';
                      }
                      if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_+\-=\[\]{};'
                              r"'"
                              r'\\\/|`~]')
                          .hasMatch(value)) {
                        return 'Requires at least one special character.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  Text(
                    'Confirm Password',
                    style: theme.baseTextStyle(theme.primaryTextColor).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: theme.baseTextStyle(theme.primaryTextColor),
                    decoration: InputDecoration(
                      hintText: 'Confirm pass',
                      hintStyle: theme.baseTextStyle(
                        theme.primaryTextColor.withOpacity(0.35),
                      ),
                      prefixIcon: Icon(Icons.lock_clock_outlined,
                          color: theme.primaryTextColor.withOpacity(0.4)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: theme.primaryTextColor.withOpacity(0.4),
                        ),
                        onPressed: () {
                          setState(() => _obscureConfirmPassword =
                              !_obscureConfirmPassword);
                        },
                      ),
                      filled: true,
                      fillColor: theme.surfaceBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: theme.accentColor, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirm password cannot be empty.';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isLoading ? null : _handleRegister,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Have account? ',
                        style: theme.baseTextStyle(
                          theme.primaryTextColor.withOpacity(0.6),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Login',
                          style: theme.baseTextStyle(theme.accentColor).copyWith(
                                fontWeight: FontWeight.bold,
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
    );
  }
}
