import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:publy/l10n/app_localizations.dart';
import 'package:publy/core/theme/app_colors.dart';
import 'package:publy/core/theme/app_theme.dart';
import 'package:publy/features/onboarding/view/onboarding_step2_view.dart';

/// Geschlecht des Hundes (wird im User-Dokument gespeichert).
enum DogGender { boy, girl }

/// Onboarding Schritt 1 von 4: Hundename + Geschlecht.
///
/// Fortschrittsbalken "STEP 1 OF 4", Zurück-Pfeil, Daten werden im User-Dokument gespeichert.
class OnboardingStep1View extends StatefulWidget {
  const OnboardingStep1View({super.key});

  static const int totalSteps = 4;

  @override
  State<OnboardingStep1View> createState() => _OnboardingStep1ViewState();
}

class _OnboardingStep1ViewState extends State<OnboardingStep1View> {
  final _dogNameController = TextEditingController();
  DogGender? _selectedGender = DogGender.girl;
  bool _isLoading = false;

  @override
  void dispose() {
    _dogNameController.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    final name = _dogNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.dogsName),
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
        'dogName': name,
        'dogGender': _selectedGender == DogGender.boy ? 'male' : 'female',
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
      MaterialPageRoute(builder: (_) => OnboardingStep2View(dogName: name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.lightTheme;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Zurück-Pfeil
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  color: AppColors.deepCharcoal,
                ),
              ),
              // Fortschritt: STEP 1 OF 4 + Balken
              const SizedBox(height: 8),
              Text(
                l10n.stepXOfY(1, OnboardingStep1View.totalSteps),
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
                  value: 1 / OnboardingStep1View.totalSteps,
                  backgroundColor: AppColors.subtleGrey,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.sageGreen,
                  ),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 32),
              // Titel + Untertitel
              Text(
                l10n.whosYourBestFriend,
                style: theme.textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(l10n.createProfileForPup, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 32),
              // Hundename
              TextField(
                controller: _dogNameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(hintText: l10n.dogsName),
              ),
              const SizedBox(height: 24),
              // Geschlecht Label
              Text(
                l10n.gender,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              // Boy / Girl Karten
              Row(
                children: [
                  Expanded(
                    child: _GenderCard(
                      label: l10n.boy,
                      icon: Icons.male,
                      isSelected: _selectedGender == DogGender.boy,
                      onTap: () =>
                          setState(() => _selectedGender = DogGender.boy),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _GenderCard(
                      label: l10n.girl,
                      icon: Icons.female,
                      isSelected: _selectedGender == DogGender.girl,
                      onTap: () =>
                          setState(() => _selectedGender = DogGender.girl),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _isLoading ? null : _onNext,
                child: Text(l10n.nextArrow),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.sageGreen : AppColors.subtleGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 48,
                    color: isSelected
                        ? AppColors.sageGreen
                        : AppColors.deepCharcoal.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 4,
                right: 8,
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.sageGreen,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
