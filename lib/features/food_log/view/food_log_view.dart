import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:publy/l10n/app_localizations.dart';
import 'package:publy/core/theme/app_colors.dart';
import 'package:publy/core/theme/app_theme.dart';

/// Food Log Screen: Menge (Slider 0–500g), Was gefressen, Foto, Zeit, Notizen – Speicherung in Firebase.
class FoodLogView extends StatefulWidget {
  const FoodLogView({super.key});

  @override
  State<FoodLogView> createState() => _FoodLogViewState();
  static const int sliderMax = 500;
}

class _FoodLogViewState extends State<FoodLogView> {
  double _amountG = 250;
  final _foodController = TextEditingController();
  DateTime _loggedAt = DateTime.now();
  final _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _foodController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String get _formattedTime => DateFormat('h:mm a').format(_loggedAt);

  bool get _isToday {
    final now = DateTime.now();
    return _loggedAt.year == now.year &&
        _loggedAt.month == now.month &&
        _loggedAt.day == now.day;
  }

  Future<void> _pickTime() async {
    final hourController = TextEditingController(
      text: _loggedAt.hour.toString(),
    );
    final minuteController = TextEditingController(
      text: _loggedAt.minute.toString().padLeft(2, '0'),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.cream,
          title: Text(
            AppLocalizations.of(ctx)!.time,
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppColors.deepCharcoal,
            ),
          ),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 64,
                child: TextField(
                  controller: hourController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(ctx)!.hourLabel,
                    hintText: AppLocalizations.of(ctx)!.hourHint,
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  ':',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    color: AppColors.deepCharcoal,
                  ),
                ),
              ),
              SizedBox(
                width: 64,
                child: TextField(
                  controller: minuteController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(ctx)!.minuteLabel,
                    hintText: AppLocalizations.of(ctx)!.minuteHint,
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(AppLocalizations.of(ctx)!.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.sageGreen),
              child: Text(AppLocalizations.of(ctx)!.ok),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final hour = int.tryParse(hourController.text.trim()) ?? _loggedAt.hour;
      final minute =
          int.tryParse(minuteController.text.trim()) ?? _loggedAt.minute;
      setState(() {
        _loggedAt = DateTime(
          _loggedAt.year,
          _loggedAt.month,
          _loggedAt.day,
          hour.clamp(0, 23),
          minute.clamp(0, 59),
        );
      });
    }
  }

  Future<void> _onSave() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Not logged in'),
            backgroundColor: AppColors.terracotta,
          ),
        );
      }
      return;
    }
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('foodLogs')
          .add({
            'amountG': _amountG.round(),
            'foodDescription': _foodController.text.trim().isEmpty
                ? null
                : _foodController.text.trim(),
            'loggedAt': Timestamp.fromDate(_loggedAt),
            'notes': _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          });
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.terracotta,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.lightTheme;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          color: AppColors.deepCharcoal,
        ),
        title: Text(
          l10n.foodLog,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.deepCharcoal,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // AMOUNT
              Text(
                l10n.amount,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepCharcoal,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${_amountG.round()}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.sageGreen,
                    ),
                  ),
                  Text(
                    'g',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.sageGreen,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.sageGreen,
                  inactiveTrackColor: AppColors.subtleGrey,
                  thumbColor: AppColors.sageGreen,
                ),
                child: Slider(
                  value: _amountG,
                  min: 0,
                  max: FoodLogView.sliderMax.toDouble(),
                  divisions: 50,
                  onChanged: (v) => setState(() => _amountG = v),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '0g',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.deepCharcoal.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    '500g',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.deepCharcoal.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // What did they eat?
              Text(
                l10n.whatDidTheyEat,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepCharcoal,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _foodController,
                decoration: InputDecoration(
                  hintText: l10n.searchKibblePlaceholder,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.deepCharcoal.withValues(alpha: 0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.deepCharcoal.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.subtleGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.subtleGrey),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.deepCharcoal,
                ),
              ),
              const SizedBox(height: 28),
              // Photo
              Text(
                l10n.photo,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepCharcoal,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.sageGreen.withValues(alpha: 0.6),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      size: 28,
                      color: AppColors.sageGreen,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.snapAPic,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.sageGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Time
              Text(
                l10n.time,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepCharcoal,
                ),
              ),
              const SizedBox(height: 10),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _pickTime,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.subtleGrey.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.subtleGrey),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.terracotta,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.schedule,
                            size: 20,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isToday
                                    ? l10n.todayAtTime(_formattedTime)
                                    : DateFormat('d. MMM, ').format(_loggedAt) +
                                          _formattedTime,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.deepCharcoal,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.automaticEntry,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.deepCharcoal.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: AppColors.deepCharcoal.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Notes
              Text(
                l10n.notes,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepCharcoal,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: l10n.foodNotesPlaceholder,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.deepCharcoal.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.subtleGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.subtleGrey),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.deepCharcoal,
                ),
              ),
              const SizedBox(height: 32),
              // Save Log
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sageGreen,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.check, size: 22),
                  label: Text(l10n.saveLog),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
