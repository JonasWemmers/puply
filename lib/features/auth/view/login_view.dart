import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:publy/l10n/app_localizations.dart';
import 'package:publy/core/theme/app_colors.dart';
import 'package:publy/core/theme/app_theme.dart';
import 'package:publy/features/auth/viewmodel/auth_view_model.dart';

/// Login Screen View
/// 
/// Zeigt Login-Optionen: Google, Apple, Email/Password
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Welcome Back Heading
              Text(
                l10n.welcomeBack,
                style: AppTheme.lightTheme.textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Subheading
              Text(
                l10n.loginToCheckPup,
                style: AppTheme.lightTheme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Google Button
              _buildGoogleButton(
                onPressed: () {
                  // TODO: Google Login
                },
              ),
              const SizedBox(height: 16),
              // Apple Button
              _buildAppleButton(
                onPressed: () {
                  // TODO: Apple Login
                },
              ),
              const SizedBox(height: 32),
              // Separator
              _buildSeparator(l10n.or),
              const SizedBox(height: 32),
              // Email Input
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: l10n.email,
                  suffixIcon: Icon(
                    Icons.email_outlined,
                    color: AppColors.deepCharcoal.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Password Input
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: l10n.password,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.deepCharcoal.withValues(alpha: 0.5),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Forgot Password
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.sageGreen,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    l10n.forgotPassword,
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppColors.sageGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Log In Button
              ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () {
                        // TODO: Email/Password Login
                      },
                child: Text(l10n.logIn),
              ),
              const SizedBox(height: 32),
              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.dontHaveAccount,
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to Register
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.deepCharcoal,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l10n.signUp,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
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
    );
  }

  Widget _buildGoogleButton({
    required VoidCallback onPressed,
  }) {
    // Platform-spezifisches Google Logo
    final googleLogoPath = Platform.isIOS
        ? 'assets/img/ios_neutral_rd_ctn.svg'
        : 'assets/img/android_neutral_rd_ctn.svg';

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: SvgPicture.asset(
          googleLogoPath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildAppleButton({
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: Image.asset(
          'assets/img/appleid_button@2x.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildSeparator(String text) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.subtleGrey,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.subtleGrey,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
