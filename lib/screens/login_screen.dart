import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/social_sign_in_button.dart';

enum _LoginMode { signIn, register, forgotPassword }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _LoginMode _mode = _LoginMode.signIn;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchMode(_LoginMode mode) {
    if (_mode == mode) return;
    context.read<AuthProvider>().clearError();
    setState(() {
      _mode = mode;
      _formKey.currentState?.reset();
      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
      _confirmPasswordController.clear();
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();

    if (_mode == _LoginMode.signIn) {
      await auth.signInWithEmail(
        _emailController.text,
        _passwordController.text,
      );
    } else if (_mode == _LoginMode.register) {
      await auth.registerWithEmail(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
      );
    } else {
      await auth.sendPasswordReset(_emailController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent! Check your inbox.'),
            backgroundColor: AppTheme.primary,
          ),
        );
      }
    }
  }

  Future<void> _googleSignIn() async {
    await context.read<AuthProvider>().signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(child: _buildCard(auth)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          // Floating hearts background decoration
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: child,
              );
            },
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.35),
                    blurRadius: 24,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 44),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              _mode == _LoginMode.signIn
                  ? 'Welcome Back 💕'
                  : _mode == _LoginMode.register
                      ? 'Create Account 🌸'
                      : 'Reset Password 🔐',
              key: ValueKey(_mode),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryDark,
                letterSpacing: 0.5,
              ),
            ),
          ).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              _mode == _LoginMode.signIn
                  ? 'Sign in to your shared space'
                  : _mode == _LoginMode.register
                      ? 'Start your journey together'
                      : 'We\'ll send you a reset link',
              key: ValueKey('sub_$_mode'),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 500.ms),
        ],
      ),
    );
  }

  Widget _buildCard(AuthProvider auth) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Error message
            if (auth.errorMessage != null)
              _buildErrorBanner(auth.errorMessage!),

            // Name field (register only)
            if (_mode == _LoginMode.register) ...[
              _buildNameField()
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: -0.1, end: 0),
              const SizedBox(height: 16),
            ],

            // Email field
            _buildEmailField()
                .animate()
                .fadeIn(delay: 100.ms, duration: 400.ms)
                .slideX(begin: -0.1, end: 0),
            const SizedBox(height: 16),

            // Password field (not on forgot password)
            if (_mode != _LoginMode.forgotPassword) ...[
              _buildPasswordField()
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 400.ms)
                  .slideX(begin: -0.1, end: 0),
              const SizedBox(height: 16),
            ],

            // Confirm password (register only)
            if (_mode == _LoginMode.register) ...[
              _buildConfirmPasswordField()
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideX(begin: -0.1, end: 0),
              const SizedBox(height: 16),
            ],

            // Forgot password link (sign in only)
            if (_mode == _LoginMode.signIn)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _switchMode(_LoginMode.forgotPassword),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(color: AppTheme.primary),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 8),

            // Submit button
            GradientButton(
              onPressed: auth.isLoading ? null : _submit,
              isLoading: auth.isLoading,
              label: _mode == _LoginMode.signIn
                  ? 'Sign In'
                  : _mode == _LoginMode.register
                      ? 'Create Account'
                      : 'Send Reset Email',
            ).animate().fadeIn(delay: 250.ms, duration: 400.ms).slideY(
                  begin: 0.2,
                  end: 0,
                ),

            const SizedBox(height: 20),

            // Divider with OR
            if (_mode != _LoginMode.forgotPassword)
              _buildDivider()
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms),

            // Google Sign-In
            if (_mode != _LoginMode.forgotPassword) ...[
              const SizedBox(height: 16),
              SocialSignInButton(
                onPressed: auth.isLoading ? null : _googleSignIn,
                label: 'Continue with Google',
              )
                  .animate()
                  .fadeIn(delay: 350.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),
            ],

            const SizedBox(height: 24),

            // Mode switcher
            _buildModeSwitcher()
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ),
          GestureDetector(
            onTap: context.read<AuthProvider>().clearError,
            child: Icon(Icons.close, color: Colors.red.shade400, size: 18),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'Your Name',
        hintText: 'Enter your name',
        prefixIcon: Icon(Icons.person_outline),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Name is required';
        if (v.trim().length < 2) return 'Name is too short';
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email Address',
        hintText: 'your@email.com',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Email is required';
        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
        if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email';
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: '••••••••',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Password is required';
        if (_mode == _LoginMode.register && v.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        hintText: '••••••••',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () =>
              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Please confirm your password';
        if (v != _passwordController.text) return 'Passwords do not match';
        return null;
      },
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
      ],
    );
  }

  Widget _buildModeSwitcher() {
    if (_mode == _LoginMode.forgotPassword) {
      return TextButton(
        onPressed: () => _switchMode(_LoginMode.signIn),
        child: const Text.rich(
          TextSpan(
            text: 'Back to ',
            style: TextStyle(color: Colors.grey),
            children: [
              TextSpan(
                text: 'Sign In',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _mode == _LoginMode.signIn
              ? "Don't have an account? "
              : 'Already have an account? ',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        GestureDetector(
          onTap: () => _switchMode(
            _mode == _LoginMode.signIn
                ? _LoginMode.register
                : _LoginMode.signIn,
          ),
          child: Text(
            _mode == _LoginMode.signIn ? 'Sign Up' : 'Sign In',
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
