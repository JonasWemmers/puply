import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:publy/l10n/app_localizations.dart';
import 'package:publy/core/theme/app_colors.dart';
import 'package:publy/core/theme/app_theme.dart';
import 'package:publy/features/auth/viewmodel/auth_view_model.dart';
import 'package:publy/features/onboarding/view/onboarding_step1_view.dart';

/// Registrierungs-Schritt 2: Name + Passwort, dann Konto erstellen.
///
/// Erhält die E-Mail aus Schritt 1. Zurück-Icon oben links, kein Fortschrittsbalken.
class RegisterStep2View extends StatefulWidget {
  const RegisterStep2View({super.key, required this.email});

  final String email;

  @override
  State<RegisterStep2View> createState() => _RegisterStep2ViewState();
}

class _RegisterStep2ViewState extends State<RegisterStep2View> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    final name = _nameController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty) {
      _showError(AppLocalizations.of(context)!.enterYourFullName);
      return;
    }
    if (password.length < 8) {
      _showError(AppLocalizations.of(context)!.atLeast8Characters);
      return;
    }

    final viewModel = context.read<AuthViewModel>();
    final uid = await viewModel.registerWithEmailAndPassword(
      email: widget.email,
      password: password,
      displayName: name,
    );

    if (!mounted) return;
    if (uid != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingStep1View()),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.createAccount),
          backgroundColor: AppColors.sageGreen,
        ),
      );
    } else if (viewModel.errorCode != null) {
      _showError(_errorMessageForCode(viewModel.errorCode!));
    }
  }

  String _errorMessageForCode(String code) {
    final l10n = AppLocalizations.of(context)!;
    switch (code) {
      case AuthErrorCode.emailAlreadyInUse:
        return l10n.errorEmailAlreadyInUse;
      case AuthErrorCode.invalidEmail:
        return l10n.errorInvalidEmail;
      case AuthErrorCode.weakPassword:
        return l10n.errorWeakPassword;
      case AuthErrorCode.operationNotAllowed:
        return l10n.errorOperationNotAllowed;
      default:
        return l10n.errorRegistrationFailed;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.terracotta),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Zurück-Button (ohne Fortschrittspunkte)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  color: AppColors.deepCharcoal,
                ),
              ),
              const SizedBox(height: 8),
              // Titel
              Text(
                l10n.almostThere,
                style: AppTheme.lightTheme.textTheme.displayLarge,
              ),
              const SizedBox(height: 32),
              // Name Label + Feld
              Text(
                l10n.yourName,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(hintText: l10n.enterYourFullName),
              ),
              const SizedBox(height: 24),
              // Passwort Label + Feld
              Text(
                l10n.createPassword,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: l10n.atLeast8Characters,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.deepCharcoal.withValues(alpha: 0.5),
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.deepCharcoal.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.atLeast8Characters,
                    style: AppTheme.lightTheme.textTheme.labelSmall,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: viewModel.isLoading ? null : _createAccount,
                child: Text(l10n.createAccount),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.termsAndConditions,
                style: AppTheme.lightTheme.textTheme.labelSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
