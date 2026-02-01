import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:publy/l10n/app_localizations.dart';
import 'package:publy/core/theme/app_colors.dart';
import 'package:publy/core/theme/app_theme.dart';
import 'package:publy/features/onboarding/view/onboarding_step4_view.dart';

/// Körperzustand (Body Condition) – wird im User-Dokument gespeichert.
enum BodyCondition { underweight, ideal, overweight }

/// Onboarding Schritt 3 von 4: Gewicht + Körperzustand.
class OnboardingStep3View extends StatefulWidget {
  const OnboardingStep3View({super.key, required this.dogName});

  final String dogName;

  static const int totalSteps = 4;

  @override
  State<OnboardingStep3View> createState() => _OnboardingStep3ViewState();
}

class _OnboardingStep3ViewState extends State<OnboardingStep3View> {
  final _weightController = TextEditingController(text: '0.0');
  BodyCondition? _selectedCondition = BodyCondition.ideal;
  bool _isLoading = false;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    final weightText = _weightController.text.trim().replaceAll(',', '.');
    final weight = double.tryParse(weightText);
    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.howHeavyIsName(widget.dogName),
          ),
          backgroundColor: AppColors.terracotta,
        ),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isLoading = true);
    try {
      String conditionValue;
      switch (_selectedCondition!) {
        case BodyCondition.underweight:
          conditionValue = 'underweight';
          break;
        case BodyCondition.ideal:
          conditionValue = 'ideal';
          break;
        case BodyCondition.overweight:
          conditionValue = 'overweight';
          break;
      }
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'dogWeightKg': weight,
        'dogBodyCondition': conditionValue,
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
        builder: (_) => OnboardingStep4View(dogName: widget.dogName),
      ),
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
                l10n.stepXOfY(3, OnboardingStep3View.totalSteps),
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
                  value: 3 / OnboardingStep3View.totalSteps,
                  backgroundColor: AppColors.subtleGrey,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.sageGreen,
                  ),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.howHeavyIsName(widget.dogName),
                style: theme.textTheme.displayLarge,
              ),
              const SizedBox(height: 32),
              // Gewicht
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: AppColors.deepCharcoal,
                      ),
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.subtleGrey),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.subtleGrey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.sageGreen,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.only(bottom: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'kg',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.deepCharcoal.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                l10n.bodyCondition,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepCharcoal.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _BodyConditionCard(
                      label: l10n.underweight,
                      isSelected:
                          _selectedCondition == BodyCondition.underweight,
                      onTap: () => setState(
                        () => _selectedCondition = BodyCondition.underweight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BodyConditionCard(
                      label: l10n.ideal,
                      isSelected: _selectedCondition == BodyCondition.ideal,
                      onTap: () => setState(
                        () => _selectedCondition = BodyCondition.ideal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BodyConditionCard(
                      label: l10n.overweight,
                      isSelected:
                          _selectedCondition == BodyCondition.overweight,
                      onTap: () => setState(
                        () => _selectedCondition = BodyCondition.overweight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
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

class _BodyConditionCard extends StatelessWidget {
  const _BodyConditionCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.cream,
          border: Border.all(
            color: isSelected ? AppColors.sageGreen : AppColors.subtleGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pets,
                  size: 40,
                  color: isSelected
                      ? AppColors.sageGreen
                      : AppColors.deepCharcoal.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.sageGreen
                        : AppColors.deepCharcoal.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
