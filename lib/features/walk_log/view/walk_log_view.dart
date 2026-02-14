import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:publy/l10n/app_localizations.dart';
import 'package:publy/core/theme/app_colors.dart';
import 'package:publy/core/theme/app_theme.dart';
import 'package:publy/features/walk_log/data/walk_log_model.dart';

/// Walk Log Screen: Dauer (Slider), Typ (Quick Break / Standard Walk),
/// Map-Vorschau mit Route + GPS-Toggle, Foto, Zeit, Notizen – Speicherung in Firebase.
class WalkLogView extends StatefulWidget {
  const WalkLogView({super.key});

  @override
  State<WalkLogView> createState() => _WalkLogViewState();
}

class _WalkLogViewState extends State<WalkLogView> {
  double _durationMinutes = 45;
  WalkType _walkType = WalkType.standardWalk;
  bool _trackGps = true;
  DateTime _loggedAt = DateTime.now();
  final _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final h = _loggedAt.hour;
    final m = _loggedAt.minute;
    final period = h < 12 ? 'AM' : 'PM';
    final displayH = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '${displayH.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
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
          .collection('walkLogs')
          .add({
            'durationMinutes': _durationMinutes.round(),
            'walkType': _walkType.name,
            'trackGps': _trackGps,
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
          l10n.walkLog,
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
              // ── Duration display ──
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${_durationMinutes.round()}',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 72,
                      color: AppColors.deepCharcoal,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'min',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.deepCharcoal.withValues(alpha: 0.5),
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // ── Duration slider ──
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.sageGreen,
                  inactiveTrackColor: AppColors.subtleGrey,
                  thumbColor: AppColors.sageGreen,
                ),
                child: Slider(
                  value: _durationMinutes,
                  min: 5,
                  max: 120,
                  divisions: 23,
                  onChanged: (v) => setState(() => _durationMinutes = v),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.fiveMin,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.deepCharcoal.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    l10n.twoHours,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.deepCharcoal.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // ── Walk Type Chips ──
              Row(
                children: [
                  Expanded(
                    child: _WalkTypeChip(
                      label: l10n.quickBreak,
                      emoji: '🚶',
                      isSelected: _walkType == WalkType.quickBreak,
                      onTap: () =>
                          setState(() => _walkType = WalkType.quickBreak),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _WalkTypeChip(
                      label: l10n.standardWalk,
                      emoji: '🌿',
                      isSelected: _walkType == WalkType.standardWalk,
                      onTap: () =>
                          setState(() => _walkType = WalkType.standardWalk),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // ── Map preview card ──
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.subtleGrey),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Map placeholder
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(color: const Color(0xFFD4E8D0)),
                      child: Stack(
                        children: [
                          // Background map pattern
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _MapPlaceholderPainter(),
                            ),
                          ),
                          // Navigation pin
                          Positioned(
                            left: 24,
                            bottom: 24,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.sageGreen,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.navigation,
                                size: 18,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Route name + GPS toggle
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 20,
                            color: AppColors.sageGreen,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Central Park Loop',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.deepCharcoal,
                              ),
                            ),
                          ),
                          Text(
                            l10n.trackGps,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.deepCharcoal.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 28,
                            child: Switch(
                              value: _trackGps,
                              onChanged: (v) => setState(() => _trackGps = v),
                              activeTrackColor: AppColors.sageGreen,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // ── Photo + Time row ──
              Row(
                children: [
                  // Snap a pic
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.deepCharcoal.withValues(alpha: 0.2),
                          width: 1.5,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 28,
                            color: AppColors.terracotta.withValues(alpha: 0.7),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.snapAPic,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.deepCharcoal.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Time display
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _pickTime,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.subtleGrey),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Icon(
                                      Icons.schedule,
                                      size: 16,
                                      color: AppColors.deepCharcoal.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                l10n.time,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.deepCharcoal.withValues(
                                    alpha: 0.5,
                                  ),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formattedTime,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.deepCharcoal,
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // ── Notes ──
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.subtleGrey),
                ),
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: l10n.addNotesAboutWalk,
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.deepCharcoal.withValues(alpha: 0.45),
                        ),
                        contentPadding: const EdgeInsets.fromLTRB(
                          44,
                          16,
                          16,
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
                    Positioned(
                      left: 14,
                      top: 18,
                      child: Icon(
                        Icons.notes_outlined,
                        size: 20,
                        color: AppColors.deepCharcoal.withValues(alpha: 0.35),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // ── Save Button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sageGreen,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
                      : const Icon(Icons.check_circle_outline, size: 22),
                  label: Text(
                    l10n.saveLog,
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

// ── Walk type chip ──────────────────────────────────────────────────────────

class _WalkTypeChip extends StatelessWidget {
  const _WalkTypeChip({
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
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.deepCharcoal : AppColors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? AppColors.deepCharcoal : AppColors.subtleGrey,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected ? AppColors.white : AppColors.deepCharcoal,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Text(emoji, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Map placeholder painter ─────────────────────────────────────────────────

class _MapPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Light map-like background with subtle "street" lines
    final bgPaint = Paint()..color = const Color(0xFFCFE8CF);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Water-like area
    final waterPaint = Paint()..color = const Color(0xFFB8D8E8);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.6, size.height * 0.4),
        width: size.width * 0.35,
        height: size.height * 0.5,
      ),
      waterPaint,
    );

    // "Streets"
    final streetPaint = Paint()
      ..color = const Color(0xFFE8E8D8)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.35),
      streetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, 0),
      Offset(size.width * 0.25, size.height),
      streetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.55, size.height),
      streetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.8, 0),
      Offset(size.width * 0.75, size.height),
      streetPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.65),
      streetPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
