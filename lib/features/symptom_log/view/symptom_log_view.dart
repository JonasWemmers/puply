import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:publy/l10n/app_localizations.dart';
import 'package:publy/core/theme/app_colors.dart';
import 'package:publy/core/theme/app_theme.dart';
import 'package:publy/features/symptom_log/data/symptom_log_model.dart';

/// Symptom Log Screen: Symptomauswahl, Schweregrad, Foto, Zeit, Notizen – Speicherung in Firebase.
class SymptomLogView extends StatefulWidget {
  const SymptomLogView({super.key});

  @override
  State<SymptomLogView> createState() => _SymptomLogViewState();
}

class _SymptomLogViewState extends State<SymptomLogView> {
  final Set<SymptomType> _selectedSymptoms = {SymptomType.vomiting};
  double _severity = 2; // 1–5, default "Moderate" (middle-ish)
  DateTime _loggedAt = DateTime.now();
  final _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
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

  String _severityLabel(AppLocalizations l10n) {
    if (_severity <= 1.5) return l10n.mild;
    if (_severity >= 4.5) return l10n.severe;
    return l10n.moderate;
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
    if (_selectedSymptoms.isEmpty) return;
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
          .collection('symptomLogs')
          .add({
            'symptoms': _selectedSymptoms.map((s) => s.name).toList(),
            'severity': _severity.round(),
            'loggedAt': Timestamp.fromDate(_loggedAt),
            'notes': _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
            'hasPhoto': false,
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

  void _toggleSymptom(SymptomType type) {
    setState(() {
      if (_selectedSymptoms.contains(type)) {
        _selectedSymptoms.remove(type);
      } else {
        _selectedSymptoms.add(type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.lightTheme;

    // Symptom options matching design order
    final symptomOptions = <(SymptomType, String, String)>[
      (SymptomType.vomiting, '🤮', l10n.vomiting),
      (SymptomType.noAppetite, '🍽️', l10n.noAppetite),
      (SymptomType.diarrhea, '💩', l10n.diarrhea),
      (SymptomType.lethargy, '😴', l10n.lethargy),
      (SymptomType.coughing, '😷', l10n.coughing),
      (SymptomType.other, '➕', l10n.other),
    ];

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
          l10n.symptomLog,
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
              // ── What's wrong? ──
              Text(
                l10n.whatsWrong,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepCharcoal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.selectOneOrMoreSymptoms,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.deepCharcoal.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 16),
              // ── Symptom grid (3x2) ──
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.35,
                children: symptomOptions.map((opt) {
                  final (type, emoji, label) = opt;
                  final isSelected = _selectedSymptoms.contains(type);
                  return _SymptomTile(
                    emoji: emoji,
                    label: label,
                    isSelected: isSelected,
                    onTap: () => _toggleSymptom(type),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              // ── Severity ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.severity,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepCharcoal,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.lightSage,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _severityLabel(l10n),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.sageGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.sageGreen,
                  inactiveTrackColor: AppColors.subtleGrey,
                  thumbColor: AppColors.sageGreen,
                ),
                child: Slider(
                  value: _severity,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (v) => setState(() => _severity = v),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.mild,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.deepCharcoal.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    l10n.severe,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.deepCharcoal.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // ── Photo Evidence ──
              Text(
                l10n.photoEvidence,
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
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.sageGreen.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.lightSage,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        size: 22,
                        color: AppColors.sageGreen,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.addPhotoForVet,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.deepCharcoal.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // ── Time ──
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
              // ── Notes ──
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
                child: TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: l10n.describeBehaviorTexture,
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.deepCharcoal.withValues(alpha: 0.45),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.deepCharcoal,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // ── Save Health Log ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (_isSaving || _selectedSymptoms.isEmpty)
                      ? null
                      : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sageGreen,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    disabledBackgroundColor: AppColors.sageGreen.withValues(
                      alpha: 0.5,
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
                      : const Icon(Icons.save_outlined, size: 22),
                  label: Text(
                    l10n.saveHealthLog,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Symptom tile widget ─────────────────────────────────────────────────────

class _SymptomTile extends StatelessWidget {
  const _SymptomTile({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.lightSage : AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.sageGreen : AppColors.subtleGrey,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.sageGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: AppColors.white,
                    ),
                  ),
                ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
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
