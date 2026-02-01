import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:publy/l10n/app_localizations.dart';
import 'package:publy/core/theme/app_colors.dart';
import 'package:publy/core/theme/app_theme.dart';
import 'package:publy/features/auth/viewmodel/auth_view_model.dart';
import 'package:publy/features/auth/view/login_view.dart';
import 'package:publy/features/auth/view/register_step2_view.dart';

/// Registrierungs-Screen (erster Schritt)
///
/// Zeigt "Join the Pack", Social-Login (Google, Apple) und E-Mail-Eingabe.
/// Navigation zur Login-View über "Already have an account? Login".
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
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
              // Join the Pack Heading
              Text(
                l10n.joinThePack,
                style: AppTheme.lightTheme.textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Subheading
              Text(
                l10n.createAccountToStartTracking,
                style: AppTheme.lightTheme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Google Button
              _buildGoogleButton(
                onPressed: () {
                  // TODO: Google Sign Up
                },
              ),
              const SizedBox(height: 16),
              // Apple Button
              _buildAppleButton(
                onPressed: () {
                  // TODO: Apple Sign Up
                },
              ),
              const SizedBox(height: 32),
              // Separator
              _buildSeparator(l10n.or),
              const SizedBox(height: 32),
              // Email Input (icon links wie im Screenshot)
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: l10n.emailAddress,
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppColors.deepCharcoal.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Next Button
              ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () {
                        final email = _emailController.text.trim();
                        if (email.isEmpty) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RegisterStep2View(email: email),
                          ),
                        );
                      },
                child: Text(l10n.next),
              ),
              const SizedBox(height: 32),
              // Already have account? Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.alreadyHaveAccount,
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginView()),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.sageGreen,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l10n.logIn,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.sageGreen,
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

  Widget _buildGoogleButton({required VoidCallback onPressed}) {
    final googleLogoPath = Platform.isIOS
        ? 'assets/img/ios_neutral_rd_ctn.svg'
        : 'assets/img/android_neutral_rd_ctn.svg';

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: SvgPicture.asset(googleLogoPath, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildAppleButton({required VoidCallback onPressed}) {
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
        Expanded(child: Divider(color: AppColors.subtleGrey, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(text, style: AppTheme.lightTheme.textTheme.bodyMedium),
        ),
        Expanded(child: Divider(color: AppColors.subtleGrey, thickness: 1)),
      ],
    );
  }
}
