import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../reporter/reporter_home_screen.dart';
import '../technician/technician_home_screen.dart';

import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (!success) {
      return;
    }

    final user = authProvider.user;

    if (user == null) {
      return;
    }

    if (user.role == AppConstants.roleReporter) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const ReporterHomeScreen(),
        ),
        (route) => false,
      );

      return;
    }

    if (user.role == AppConstants.roleTechnician) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const TechnicianHomeScreen(),
        ),
        (route) => false,
      );

      return;
    }

    if (user.role == AppConstants.roleManager) {
      await authProvider.logout();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Managers should use the web dashboard.',
          ),
        ),
      );

      return;
    }

    await authProvider.logout();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unsupported user role.'),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI helpers (visual only)
  // ---------------------------------------------------------------------------

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    const radius = BorderRadius.all(Radius.circular(16));

    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Color(0xFF7A8797),
        fontSize: 14,
      ),
      floatingLabelStyle: const TextStyle(
        color: Color(0xFF1565C0),
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF7A8797)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF6F8FB),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: const OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: Color(0xFF1565C0), width: 1.6),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: Color(0xFFE53935)),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: Color(0xFFE53935), width: 1.6),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0x26FFFFFF),
            border: Border.all(
              color: const Color(0x4DFFFFFF),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.apartment_rounded,
            size: 46,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Campus Facility AI',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Facility Issue Management System',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xCCFFFFFF),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(AuthProvider authProvider) {
    return SizedBox(
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: authProvider.isLoading
                ? const [Color(0xFF9EC5E8), Color(0xFF9EC5E8)]
                : const [Color(0xFF1565C0), Color(0xFF1E88E5)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D1565C0),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: authProvider.isLoading ? null : _login,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: authProvider.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF5C2C0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 20,
            color: Color(0xFFD32F2F),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFD32F2F),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D47A1),
              Color(0xFF1565C0),
              Color(0xFF42A5F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),

                      const SizedBox(height: 32),

                      // -------------------------------------------------
                      // Form card
                      // -------------------------------------------------
                      Container(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x26000000),
                              blurRadius: 32,
                              offset: Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Welcome back',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A2433),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Sign in to continue to your dashboard.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF7A8797),
                              ),
                            ),

                            const SizedBox(height: 24),

                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: _fieldDecoration(
                                label: 'Email',
                                icon: Icons.email_outlined,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your email';
                                }

                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) {
                                if (!authProvider.isLoading) {
                                  _login();
                                }
                              },
                              decoration: _fieldDecoration(
                                label: 'Password',
                                icon: Icons.lock_outline,
                                suffixIcon: IconButton(
                                  splashRadius: 20,
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 20,
                                    color: const Color(0xFF7A8797),
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            if (authProvider.errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildErrorBanner(
                                  authProvider.errorMessage!,
                                ),
                              ),

                            _buildLoginButton(authProvider),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      const Text(
                        'Report  •  Track  •  Resolve',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xB3FFFFFF),
                          fontSize: 13,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w500,
                        ),
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