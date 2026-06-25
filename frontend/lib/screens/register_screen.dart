import 'package:flutter/material.dart';
import '../service/auth_service.dart';
import '../core/widgets/animated_background.dart';
import '../core/widgets/interactive_input_field.dart';
import '../core/widgets/premium_button.dart';
import '../core/theme/app_colors.dart';
import '../providers/theme_provider.dart';
import '../widgets/common/theme_toggle_button.dart';
import 'login_screen.dart';

/// 🎨 Formal Register Screen untuk Sekolah dengan Theme Support
///
/// Features:
/// - Formal professional design (sama seperti login)
/// - Light & Dark mode support
/// - Animated gradient background (formal colors)
/// - Interactive input fields dengan focus animations
/// - Premium button dengan press effects
/// - Theme toggle button
/// - Smooth page transitions
///
/// Context: Aplikasi Presensi Sekolah Premium 2025-2026
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final ThemeProvider _themeProvider = ThemeProvider();

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

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      isDarkMode: _themeProvider.isDarkMode,
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
                      child: RegisterForm(
                        isDarkMode: _themeProvider.isDarkMode,
                      ),
                    ),
                  ),
                ),
              ),

              // Theme toggle button
              Positioned(
                top: 16,
                right: 16,
                child: const ThemeToggleButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  final bool isDarkMode;

  const RegisterForm({
    super.key,
    required this.isDarkMode,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _nisnController = TextEditingController();
  final _kelasController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
    _fullnameController.dispose();
    _nisnController.dispose();
    _kelasController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          const SizedBox(height: 32),

          // Interactive Fullname Input
          InteractiveInputField(
            label: 'Nama Lengkap',
            hintText: 'Masukkan nama lengkap',
            prefixIcon: Icons.person_outlined,
            focusColor: AppColors.formalNavy,
            controller: _fullnameController,
            enabled: !_isLoading,
            isDarkMode: isDarkMode,
            validator: (value) {
              if (value == null || value.isEmpty) {
                _triggerShakeAnimation();
                return 'Nama lengkap harus diisi';
              }
              if (value.length < 3) {
                _triggerShakeAnimation();
                return 'Nama minimal 3 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Interactive NISN Input
          InteractiveInputField(
            label: 'NISN',
            hintText: 'Masukkan NISN (10 digit)',
            prefixIcon: Icons.badge_outlined,
            focusColor: AppColors.formalNavy,
            controller: _nisnController,
            keyboardType: TextInputType.number,
            enabled: !_isLoading,
            isDarkMode: isDarkMode,
            validator: (value) {
              if (value == null || value.isEmpty) {
                _triggerShakeAnimation();
                return 'NISN harus diisi';
              }
              if (value.length < 10) {
                _triggerShakeAnimation();
                return 'NISN minimal 10 digit';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Interactive Kelas Input
          InteractiveInputField(
            label: 'Kelas',
            hintText: 'Contoh: 10, 11, 12',
            prefixIcon: Icons.school_outlined,
            focusColor: AppColors.formalNavy,
            controller: _kelasController,
            keyboardType: TextInputType.text,
            enabled: !_isLoading,
            isDarkMode: isDarkMode,
            validator: (value) {
              if (value == null || value.isEmpty) {
                _triggerShakeAnimation();
                return 'Kelas harus diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Interactive Email Input
          InteractiveInputField(
            label: 'Email',
            hintText: 'Masukkan email Anda',
            prefixIcon: Icons.email_outlined,
            focusColor: AppColors.formalNavyLight,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
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
          const SizedBox(height: 16),

          // Interactive Password Input
          InteractiveInputField(
            label: 'Password',
            hintText: 'Minimal 6 karakter',
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
          const SizedBox(height: 16),

          // Interactive Confirm Password Input
          InteractiveInputField(
            label: 'Konfirmasi Password',
            hintText: 'Ulangi password',
            prefixIcon: Icons.verified_user_outlined,
            focusColor: AppColors.formalGreen,
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            enabled: !_isLoading,
            isDarkMode: isDarkMode,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: isDarkMode
                    ? AppColors.darkTextSecondary
                    : Colors.grey.shade400,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                _triggerShakeAnimation();
                return 'Konfirmasi password harus diisi';
              }
              if (value != _passwordController.text) {
                _triggerShakeAnimation();
                return 'Password tidak cocok';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Premium Register Button
          PremiumButton(
            text: 'Daftar Sekarang',
            onPressed: _register,
            type: ButtonType.primary,
            size: ButtonSize.large,
            isLoading: _isLoading,
            loadingText: 'Mendaftar...',
            isFullWidth: true,
          ),
          const SizedBox(height: 20),

          // Login Link
          _buildLoginLink(),
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
            Icons.person_add,
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
          'Buat Akun Baru 🎓',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Isi formulir untuk mendaftar',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Sudah punya akun? ',
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
                    const LoginScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.1),
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
            'Masuk sekarang',
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

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      _triggerShakeAnimation();
      _showErrorSnackBar('Password tidak cocok');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.register(
        fullname: _fullnameController.text.trim(),
        nisn: _nisnController.text.trim(),
        kelas: _kelasController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (result['success'] == true) {
        _successController.forward().then((_) {
          if (mounted) {
            _showSuccessSnackBar();
          }
        });
      } else {
        String errorMessage = result['message'] ?? 'Pendaftaran gagal';
        if (result['errors'] != null) {
          final errors = Map<String, dynamic>.from(result['errors']);
          errorMessage += '\n${errors.values.join('\n')}';
        }
        _triggerShakeAnimation();
        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      debugPrint('Error in _register: $e');
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

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Pendaftaran berhasil! Silakan login.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.formalGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );

    // Navigate to login after success
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
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
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
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
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
