import 'package:flutter/material.dart';
import '../service/auth_service.dart';
import '../utils/shared_storage.dart';
import '../core/widgets/animated_background.dart';
import '../core/widgets/interactive_input_field.dart';
import '../core/widgets/premium_button.dart';
import '../core/theme/app_colors.dart';
import 'register_screen.dart';
import 'home_screen.dart';

/// 🎨 Formal Login Screen untuk Sekolah dengan Theme Support
///
/// Features:
/// - Formal professional design (bukan colorful)
/// - Light & Dark mode support
/// - Animated gradient background (formal colors)
/// - Interactive input fields dengan focus animations
/// - Premium button dengan press effects
/// - Theme toggle button
/// - Smooth page transitions
///
/// Context: Aplikasi Presensi Sekolah Premium 2025-2026
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // Theme mode
  bool _isDarkMode = false;

  // Fade & slide animations
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initFadeAnimations();
  }

  void _initFadeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.3,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      isDarkMode: _isDarkMode,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              // Main content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, _slideAnimation.value),
                        end: Offset.zero,
                      ).animate(_fadeController),
                      child: LoginForm(
                        isDarkMode: _isDarkMode,
                      ),
                    ),
                  ),
                ),
              ),

              // Theme toggle button
              Positioned(
                top: 16,
                right: 16,
                child: _buildThemeToggle(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: _isDarkMode
            ? AppColors.darkSurface.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          _isDarkMode ? Icons.light_mode : Icons.dark_mode,
          color: _isDarkMode ? AppColors.darkTextPrimary : AppColors.formalNavy,
        ),
        onPressed: _toggleTheme,
        tooltip: _isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  final bool isDarkMode;

  const LoginForm({
    super.key,
    required this.isDarkMode,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Error shake animation
  late AnimationController _shakeController;

  // Success animation
  late AnimationController _successController;

  @override
  void initState() {
    super.initState();
    _initShakeAnimation();
    _initSuccessAnimation();
  }

  void _initShakeAnimation() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void _initSuccessAnimation() {
    _successController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _shakeController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Premium Logo dengan Glow Effect (Formal)
          _buildPremiumLogo(),
          const SizedBox(height: 40),

          // Welcome Text
          _buildWelcomeText(),
          const SizedBox(height: 40),

          // Interactive Email Input (using reusable component)
          InteractiveInputField(
            label: 'Email',
            hintText: 'Masukkan email Anda',
            prefixIcon: Icons.email_outlined,
            focusColor: AppColors.formalNavy,
            controller: _emailController,
            enabled: !_isLoading,
            isDarkMode: isDarkMode,
            validator: (value) {
              if (value == null || value.isEmpty) {
                _triggerShakeAnimation();
                return 'Email harus diisi';
              }
              if (!value.contains('@') || !value.contains('.')) {
                _triggerShakeAnimation();
                return 'Email tidak valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Interactive Password Input (using reusable component)
          InteractiveInputField(
            label: 'Password',
            hintText: 'Masukkan password Anda',
            prefixIcon: Icons.lock_outlined,
            focusColor: AppColors.formalNavyDark,
            controller: _passwordController,
            obscureText: _obscurePassword,
            enabled: !_isLoading,
            isDarkMode: isDarkMode,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: isDarkMode
                    ? AppColors.darkTextSecondary
                    : Colors.grey.shade400,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                _triggerShakeAnimation();
                return 'Password harus diisi';
              }
              if (value.length < 6) {
                _triggerShakeAnimation();
                return 'Password minimal 6 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Forgot Password
          _buildForgotPassword(),
          const SizedBox(height: 30),

          // Premium Login Button (using reusable component)
          PremiumButton(
            text: 'Masuk',
            onPressed: _login,
            type: ButtonType.primary,
            size: ButtonSize.large,
            isLoading: _isLoading,
            loadingText: 'Signing in...',
            isFullWidth: true,
          ),
          const SizedBox(height: 24),

          // Register Link
          _buildRegisterLink(),
        ],
      ),
    );
  }

  Widget _buildPremiumLogo() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.formalNavy,
                AppColors.formalNavyLight,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.formalNavy.withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Icons.school,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Presensi',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sistem Absensi Siswa',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText() {
    return const Column(
      children: [
        Text(
          'Selamat Datang!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Silakan masuk untuk melanjutkan',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // TODO: Implement forgot password
        },
        child: const Text(
          'Lupa Password?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Belum punya akun? ',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const RegisterScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      )),
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
          child: const Text(
            'Daftar Sekarang',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (result['success'] == true) {
        await SharedStorage.saveToken(result['token']);
        await SharedStorage.saveUserData(result['user']);

        if (!mounted) return;

        // Success animation
        _successController.forward().then((_) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const HomeScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 500),
              ),
            );
          }
        });
      } else {
        _triggerShakeAnimation();
        _showErrorSnackBar(result['message'] ?? 'Login gagal');
      }
    } catch (e) {
      debugPrint('Error in _login: $e');
      if (mounted) {
        _triggerShakeAnimation();
        _showErrorSnackBar('Terjadi kesalahan. Silakan coba lagi.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _triggerShakeAnimation() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
