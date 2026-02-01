import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:publy/l10n/app_localizations.dart';
import 'package:publy/core/theme/app_colors.dart';
import 'package:publy/core/theme/app_theme.dart';
import 'package:publy/features/potty_log/data/potty_log_model.dart';

/// Potty Log Screen: Pee/Poop, Quality, Time, Snap a pic, Abnormalities – Speicherung in Firebase.
class PottyLogView extends StatefulWidget {
  const PottyLogView({super.key});

  @override
  State<PottyLogView> createState() => _PottyLogViewState();
}

class _PottyLogViewState extends State<PottyLogView> {
  PottyLogType _type = PottyLogType.poop;
  PottyLogQuality _quality = PottyLogQuality.normal;
  DateTime _loggedAt = DateTime.now();
  final _abnormalitiesController = TextEditingController();
  bool _isSaving = false;

  static const Color _lightBlue = Color(0xFFB8D4E3);
  static const Color _lightBrown = Color(0xFFD4A574);

  @override
  void dispose() {
    _abnormalitiesController.dispose();
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
          .collection('pottyLogs')
          .add({
            'type': _type.name,
            'quality': _quality.name,
            'loggedAt': Timestamp.fromDate(_loggedAt),
            'abnormalities': _abnormalitiesController.text.trim().isEmpty
                ? null
                : _abnormalitiesController.text.trim(),
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
          l10n.pottyLog,
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
              // Pee / Poop Auswahl
              Row(
                children: [
                  Expanded(
                    child: _TypeCard(
                      type: PottyLogType.pee,
                      label: l10n.pee,
                      isSelected: _type == PottyLogType.pee,
                      circleColor: _lightBlue,
                      icon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.water_drop_outlined,
                            size: 28,
                            color: _lightBlue.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.water_drop_outlined,
                            size: 28,
                            color: _lightBlue.withValues(alpha: 0.9),
                          ),
                        ],
                      ),
                      onTap: () => setState(() => _type = PottyLogType.pee),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TypeCard(
                      type: PottyLogType.poop,
                      label: l10n.poop,
                      isSelected: _type == PottyLogType.poop,
                      circleColor: _lightBrown,
                      icon: const Text('💩', style: TextStyle(fontSize: 32)),
                      onTap: () => setState(() => _type = PottyLogType.poop),
                      showCheckmark: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // QUALITY
              Text(
                l10n.quality,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepCharcoal,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _QualityChip(
                      label: l10n.hard,
                      emoji: '🧱',
                      isSelected: _quality == PottyLogQuality.hard,
                      onTap: () =>
                          setState(() => _quality = PottyLogQuality.hard),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QualityChip(
                      label: l10n.normal,
                      emoji: '🍦',
                      isSelected: _quality == PottyLogQuality.normal,
                      onTap: () =>
                          setState(() => _quality = PottyLogQuality.normal),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QualityChip(
                      label: l10n.soft,
                      emoji: '💧',
                      isSelected: _quality == PottyLogQuality.soft,
                      onTap: () =>
                          setState(() => _quality = PottyLogQuality.soft),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Time (Card mit Label „Time“ und Uhrzeit)
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
                                l10n.time,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.deepCharcoal.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
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
              // Snap a pic (gestrichelter Bereich mit Icon + Text)
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.subtleGrey, width: 2),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      size: 36,
                      color: AppColors.deepCharcoal.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.snapAPic,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.deepCharcoal.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Abnormalities (Textfeld mit Platzhalter)
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
                      controller: _abnormalitiesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: l10n.anyAbnormalities,
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
                        Icons.list_alt_outlined,
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

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.type,
    required this.label,
    required this.isSelected,
    required this.circleColor,
    required this.icon,
    required this.onTap,
    this.showCheckmark = false,
  });

  final PottyLogType type;
  final String label;
  final bool isSelected;
  final Color circleColor;
  final Widget icon;
  final VoidCallback onTap;
  final bool showCheckmark;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.lightSage : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.sageGreen : AppColors.subtleGrey,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (showCheckmark && isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    Icons.check_circle,
                    size: 22,
                    color: AppColors.sageGreen,
                  ),
                ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: circleColor.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: icon,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.deepCharcoal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QualityChip extends StatelessWidget {
  const _QualityChip({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.lightSage : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.sageGreen : AppColors.subtleGrey,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.deepCharcoal,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
