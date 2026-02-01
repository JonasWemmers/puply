import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:publy/l10n/app_localizations.dart';
import 'package:publy/core/theme/app_colors.dart';
import 'package:publy/core/theme/app_theme.dart';
import 'package:publy/features/dashboard/view/dashboard_view.dart';

/// Special-Needs-Optionen (Werte für Firestore).
const List<String> specialNeedsKeys = [
  'allergies',
  'daily_medication',
  'senior_dog',
  'puppy_training',
  'none',
];

/// Onboarding Schritt 4 von 4: Besondere Bedürfnisse.
class OnboardingStep4View extends StatefulWidget {
  const OnboardingStep4View({super.key, required this.dogName});

  final String dogName;

  static const int totalSteps = 4;

  @override
  State<OnboardingStep4View> createState() => _OnboardingStep4ViewState();
}

class _OnboardingStep4ViewState extends State<OnboardingStep4View> {
  final Set<String> _selectedNeeds = {};
  bool _isLoading = false;

  bool get _hasNone => _selectedNeeds.contains('none');

  void _toggleNeed(String key) {
    setState(() {
      if (key == 'none') {
        _selectedNeeds.clear();
        _selectedNeeds.add('none');
      } else {
        _selectedNeeds.remove('none');
        if (_selectedNeeds.contains(key)) {
          _selectedNeeds.remove(key);
        } else {
          _selectedNeeds.add(key);
        }
      }
    });
  }

  Future<void> _onFinish() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'dogSpecialNeeds': _selectedNeeds.isEmpty
            ? ['none']
            : _selectedNeeds.toList(),
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
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DashboardView()),
      (route) => false,
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
                l10n.stepXOfY(4, OnboardingStep4View.totalSteps),
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
                  value: 4 / OnboardingStep4View.totalSteps,
                  backgroundColor: AppColors.subtleGrey,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.sageGreen,
                  ),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 32),
              Text(l10n.anySpecialNeeds, style: theme.textTheme.displayLarge),
              const SizedBox(height: 8),
              Text(
                l10n.specialNeedsSubtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.deepCharcoal.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),
              // Chips: 2x2 + None (volle Breite)
              Row(
                children: [
                  Expanded(
                    child: _SpecialNeedChip(
                      label: l10n.allergies,
                      isSelected: _selectedNeeds.contains('allergies'),
                      onTap: () => _toggleNeed('allergies'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SpecialNeedChip(
                      label: l10n.dailyMedication,
                      isSelected: _selectedNeeds.contains('daily_medication'),
                      onTap: () => _toggleNeed('daily_medication'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SpecialNeedChip(
                      label: l10n.seniorDog,
                      isSelected: _selectedNeeds.contains('senior_dog'),
                      onTap: () => _toggleNeed('senior_dog'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SpecialNeedChip(
                      label: l10n.puppyTraining,
                      isSelected: _selectedNeeds.contains('puppy_training'),
                      onTap: () => _toggleNeed('puppy_training'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: _SpecialNeedChip(
                  label: l10n.none,
                  isSelected: _hasNone,
                  onTap: () => _toggleNeed('none'),
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _onFinish,
                icon: Icon(
                  Icons.favorite,
                  size: 22,
                  color: _isLoading ? null : AppColors.terracotta,
                ),
                label: Text(l10n.finishAndExploreDashboard),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecialNeedChip extends StatelessWidget {
  const _SpecialNeedChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const double _chipHeight = 48;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: double.infinity,
        height: _chipHeight,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.sageGreen : AppColors.cream,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.sageGreen : AppColors.subtleGrey,
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? AppColors.white : AppColors.deepCharcoal,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
