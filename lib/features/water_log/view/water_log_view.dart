import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:publy/l10n/app_localizations.dart';
import 'package:publy/core/theme/app_colors.dart';
import 'package:publy/core/theme/app_theme.dart';

/// Water Log Screen: Menge (Slider + Quick Add), Zeit, Notizen – Speicherung in Firebase.
class WaterLogView extends StatefulWidget {
  const WaterLogView({super.key});

  @override
  State<WaterLogView> createState() => _WaterLogViewState();
  static const int sliderMax = 1000;
}

class _WaterLogViewState extends State<WaterLogView> {
  double _amountMl = 200;
  DateTime _loggedAt = DateTime.now();
  final _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    return DateFormat('h:mm a').format(_loggedAt);
  }

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
                  onChanged: (_) {},
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
      final h = hour.clamp(0, 23);
      final m = minute.clamp(0, 59);
      setState(() {
        _loggedAt = DateTime(
          _loggedAt.year,
          _loggedAt.month,
          _loggedAt.day,
          h,
          m,
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
          .collection('waterLogs')
          .add({
            'amountMl': _amountMl.round(),
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
          l10n.waterLog,
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
              // Amount display: "200 ml"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${_amountMl.round()}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepCharcoal,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ml',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.deepCharcoal.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Slider 0 - 1000ml
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.sageGreen,
                  inactiveTrackColor: AppColors.subtleGrey,
                  thumbColor: AppColors.sageGreen,
                ),
                child: Slider(
                  value: _amountMl,
                  min: 0,
                  max: WaterLogView.sliderMax.toDouble(),
                  divisions: 50,
                  onChanged: (v) => setState(() => _amountMl = v),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '0ml',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.deepCharcoal.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    '1000ml',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.deepCharcoal.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // QUICK ADD
              Text(
                l10n.quickAdd,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepCharcoal,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _QuickAddChip(
                    label: l10n.smallBowl200ml,
                    icon: Icons.water_drop_outlined,
                    ml: 200,
                    currentMl: _amountMl.round(),
                    onTap: () => setState(() => _amountMl = 200),
                  ),
                  _QuickAddChip(
                    label: l10n.mediumBowl500ml,
                    icon: Icons.water_drop_outlined,
                    ml: 500,
                    currentMl: _amountMl.round(),
                    onTap: () => setState(() => _amountMl = 500),
                  ),
                  _QuickAddChip(
                    label: l10n.fullRefill,
                    icon: Icons.water_drop_outlined,
                    ml: 1000,
                    currentMl: _amountMl.round(),
                    onTap: () => setState(() => _amountMl = 1000),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // TIME
              Text(
                l10n.time,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepCharcoal,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _pickTime,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.subtleGrey.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.subtleGrey),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 22,
                          color: AppColors.terracotta,
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
                                l10n.autoDetected,
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
              // NOTES
              Text(
                l10n.notes,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepCharcoal,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.subtleGrey),
                ),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: l10n.waterNotesPlaceholder,
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.deepCharcoal.withValues(alpha: 0.5),
                        ),
                        contentPadding: const EdgeInsets.fromLTRB(
                          16,
                          16,
                          40,
                          16,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.deepCharcoal,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12, bottom: 12),
                      child: Icon(
                        Icons.note_outlined,
                        size: 20,
                        color: AppColors.deepCharcoal.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
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

class _QuickAddChip extends StatelessWidget {
  const _QuickAddChip({
    required this.label,
    required this.icon,
    required this.ml,
    required this.currentMl,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final int ml;
  final int currentMl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final isSelected = currentMl == ml;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.sageGreen
                : AppColors.subtleGrey.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? AppColors.white : AppColors.subtleGrey,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? AppColors.white
                    : AppColors.sageGreen.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? AppColors.white
                        : AppColors.deepCharcoal.withValues(alpha: 0.7),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
