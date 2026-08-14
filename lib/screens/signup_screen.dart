import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// todo: Import login_screen
import 'package:eschool_registration/screens/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      _showMessage('Please accept the terms and conditions.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // ==========================================
      // STEP 1: Firebase Authentication
      // ==========================================

      debugPrint('STEP 1: Creating Firebase account...');

      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-null',
          message: 'Unable to create account.',
        );
      }

      debugPrint('STEP 1 SUCCESS');
      debugPrint('Firebase UID: ${user.uid}');

      // ==========================================
      // STEP 2: Save data to Firestore
      // ==========================================

      debugPrint('STEP 2: Saving user to Firestore...');

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'fullName': name,
        'email': email,
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('STEP 2 SUCCESS: Firestore data saved.');

      // ==========================================
      // STEP 3: Send email verification
      // ==========================================

      debugPrint('STEP 3: Sending verification email...');

      await user.sendEmailVerification();

      debugPrint('STEP 3 SUCCESS: Verification email sent.');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Account created! Please check your email to verify your account.',
      );

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      debugPrint('======================================');
      debugPrint('FIREBASE AUTH ERROR');
      debugPrint('CODE: ${e.code}');
      debugPrint('MESSAGE: ${e.message}');
      debugPrint('======================================');

      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'weak-password':
          message = 'Password is too weak. Use at least 8 characters.';
          break;

        case 'network-request-failed':
          message = 'Please check your internet connection.';
          break;

        case 'operation-not-allowed':
          message = 'Email/Password authentication is not enabled in Firebase.';
          break;

        case 'too-many-requests':
          message = 'Too many requests. Please try again later.';
          break;

        case 'user-disabled':
          message = 'This user account has been disabled.';
          break;

        case 'user-null':
          message = 'Unable to create account.';
          break;

        default:
          message = 'Auth Error: ${e.code}\n${e.message ?? ''}';
      }

      _showMessage(message);
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      debugPrint('======================================');
      debugPrint('FIREBASE GENERAL ERROR');
      debugPrint('CODE: ${e.code}');
      debugPrint('MESSAGE: ${e.message}');
      debugPrint('======================================');

      _showMessage('Firebase Error: ${e.code}\n${e.message ?? ''}');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      debugPrint('======================================');
      debugPrint('UNKNOWN SIGNUP ERROR');
      debugPrint('$e');
      debugPrint('======================================');

      _showMessage('Error: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.inter()),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Full Name is required.';
    }

    if (name.length < 2) {
      return 'Enter your full name.';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email address is required.';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    if (value.length < 8) {
      return 'Use at least 8 characters.';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 30),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: _AuthCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Create your account',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Fill in the details below to get started.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),

                      const SizedBox(height: 28),

                      const _FieldLabel('Full Name'),
                      const SizedBox(height: 7),

                      _AuthTextField(
                        controller: _nameController,
                        hintText: 'e.g. Your Name',
                        prefixIcon: Icons.person_outline_rounded,
                        textInputAction: TextInputAction.next,
                        validator: _validateName,
                      ),

                      const SizedBox(height: 18),

                      const _FieldLabel('Email address'),
                      const SizedBox(height: 7),

                      _AuthTextField(
                        controller: _emailController,
                        hintText: 'example@gmail.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: _validateEmail,
                      ),

                      const SizedBox(height: 18),

                      const _FieldLabel('Password'),
                      const SizedBox(height: 7),

                      _AuthTextField(
                        controller: _passwordController,
                        hintText: '********',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                        validator: _validatePassword,
                      ),

                      const SizedBox(height: 18),

                      const _FieldLabel('Confirm password'),
                      const SizedBox(height: 7),

                      _AuthTextField(
                        controller: _confirmPasswordController,
                        hintText: '********',
                        prefixIcon: Icons.lock_reset_outlined,
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _signup(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                        validator: _validateConfirmPassword,
                      ),

                      const SizedBox(height: 16),

                      CheckboxListTile(
                        value: _acceptTerms,
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _acceptTerms = value ?? false;
                                });
                              },
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        activeColor: const Color(0xFF2563EB),
                        title: Text.rich(
                          TextSpan(
                            text: 'I agree to the ',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: const Color(0xFF64748B),
                            ),
                            children: [
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 11),

                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFF93B4F5),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 21,
                                  width: 21,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Create Account',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 12.5),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginScreen(),
                                      ),
                                    );
                                  },
                            child: Text(
                              'Sign in',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2563EB),
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
}

class _AuthCard extends StatelessWidget {
  final Widget child;

  const _AuthCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF334155),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;

  const _AuthTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF0F172A)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xFF94A3B8),
        ),
        prefixIcon: Icon(prefixIcon, size: 20, color: const Color(0xFF94A3B8)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: _border(const Color(0xFFE2E8F0)),
        enabledBorder: _border(const Color(0xFFE2E8F0)),
        focusedBorder: _border(const Color(0xFF2563EB), width: 1.5),
        errorBorder: _border(const Color(0xFFEF4444)),
        focusedErrorBorder: _border(const Color(0xFFEF4444), width: 1.5),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
