import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:publy/l10n/app_localizations.dart';
import 'package:publy/core/theme/app_colors.dart';
import 'package:publy/core/theme/app_theme.dart';
import 'package:publy/features/onboarding/data/dog_breeds.dart';
import 'package:publy/features/onboarding/view/onboarding_step3_view.dart';

/// Onboarding Schritt 2 von 4: Rasse + Geburtstag.
///
/// Erhält den Hundename aus Schritt 1. Speichert breed und birthday im User-Dokument.
class OnboardingStep2View extends StatefulWidget {
  const OnboardingStep2View({super.key, required this.dogName});

  final String dogName;

  static const int totalSteps = 4;

  @override
  State<OnboardingStep2View> createState() => _OnboardingStep2ViewState();
}

class _OnboardingStep2ViewState extends State<OnboardingStep2View> {
  String? _selectedBreed;
  DateTime? _birthday;
  bool _isLoading = false;

  Future<void> _onContinue() async {
    if (_selectedBreed == null || _selectedBreed!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.breed),
          backgroundColor: AppColors.terracotta,
        ),
      );
      return;
    }
    if (_birthday == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.birthday),
          backgroundColor: AppColors.terracotta,
        ),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'dogBreed': _selectedBreed,
        'dogBirthday': Timestamp.fromDate(_birthday!),
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.terracotta,
        ),
      );
      return;
    }
    setState(() => _isLoading = false);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OnboardingStep3View(dogName: widget.dogName),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _birthday ?? DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthday = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.lightTheme;
    final locale = Localizations.localeOf(context);
    final textStyle = theme.textTheme.bodyLarge?.copyWith(
      color: AppColors.deepCharcoal,
      fontSize: 16,
    );

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  color: AppColors.deepCharcoal,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.stepXOfY(2, OnboardingStep2View.totalSteps),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 2 / OnboardingStep2View.totalSteps,
                  backgroundColor: AppColors.subtleGrey,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.sageGreen,
                  ),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.tellUsMoreAboutName(widget.dogName),
                style: theme.textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.breedAgePersonalizeTips,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              // Rasse
              Text(
                l10n.breed,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedBreed,
                decoration: InputDecoration(
                  hintText: l10n.searchBreedsPlaceholder,
                  suffixIcon: Icon(
                    Icons.info_outline,
                    color: AppColors.sageGreen,
                    size: 22,
                  ),
                ),
                style: textStyle,
                dropdownColor: AppColors.white,
                isExpanded: true,
                menuMaxHeight: 300,
                items: dogBreeds
                    .map(
                      (b) => DropdownMenuItem<String>(
                        value: b,
                        child: Text(
                          getBreedDisplayName(b, locale),
                          style: textStyle,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedBreed = value),
              ),
              const SizedBox(height: 24),
              // Geburtstag
              Text(
                l10n.birthday,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: InputDecoration(
                    hintText: l10n.birthdayPlaceholder,
                    suffixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    _birthday != null
                        ? '${_birthday!.day.toString().padLeft(2, '0')}.${_birthday!.month.toString().padLeft(2, '0')}.${_birthday!.year}'
                        : '',
                    style: _birthday != null
                        ? theme.textTheme.bodyLarge
                        : theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.deepCharcoal.withValues(
                              alpha: 0.6,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  // TODO: Ungefähres Alter (Dialog oder alternative Eingabe)
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.sageGreen,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.iOnlyKnowApproximateAge,
                  style: theme.textTheme.labelSmall?.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _onContinue,
                child: Text(l10n.continueButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
