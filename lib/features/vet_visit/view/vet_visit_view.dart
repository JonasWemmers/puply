import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:publy/l10n/app_localizations.dart';
import 'package:publy/core/theme/app_colors.dart';
import 'package:publy/core/theme/app_theme.dart';
import 'package:publy/features/vet_visit/data/vet_visit_model.dart';
import 'package:publy/features/vet_visit/viewmodel/vet_visit_provider.dart';

/// Screen zum Eintragen/Bearbeiten eines Tierarzttermins (Design 1:1).
class VetVisitView extends StatefulWidget {
  const VetVisitView({super.key, this.existingVisit});

  final VetVisitModel? existingVisit;

  @override
  State<VetVisitView> createState() => _VetVisitViewState();
}

class _VetVisitViewState extends State<VetVisitView> {
  late DateTime _date;
  late (int, int) _timeOfDay;
  final _vetNameController = TextEditingController();
  final _prepNotesController = TextEditingController();
  VetVisitReason _reason = VetVisitReason.vaccination;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingVisit != null) {
      final visit = widget.existingVisit!;
      _date = visit.date;
      _timeOfDay = visit.timeOfDay;
      _vetNameController.text = visit.vetName;
      _prepNotesController.text = visit.prepNotes ?? '';
      _reason = visit.reasonForVisit;
    } else {
      final now = DateTime.now();
      _date = now;
      _timeOfDay = (now.hour, now.minute);
    }
  }

  @override
  void dispose() {
    _vetNameController.dispose();
    _prepNotesController.dispose();
    super.dispose();
  }

  String get _formattedDate {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('d. MMMM', locale == 'de' ? 'de' : 'en').format(_date);
  }

  String get _formattedTime {
    final (h, m) = _timeOfDay;
    final am = h < 12;
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour:${m.toString().padLeft(2, '0')} ${am ? 'AM' : 'PM'}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.sageGreen,
              onPrimary: AppColors.white,
              surface: AppColors.cream,
              onSurface: AppColors.deepCharcoal,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.sageGreen),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _timeOfDay.$1, minute: _timeOfDay.$2),
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.cream,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodBorderSide: const BorderSide(color: AppColors.sageGreen),
              dayPeriodColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? AppColors.sageGreen
                    : AppColors.subtleGrey.withValues(alpha: 0.3),
              ),
              dayPeriodTextColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? AppColors.white
                    : AppColors.deepCharcoal,
              ),
              hourMinuteColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? AppColors.sageGreen
                    : AppColors.subtleGrey.withValues(alpha: 0.3),
              ),
              hourMinuteTextColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? AppColors.white
                    : AppColors.deepCharcoal,
              ),
              dialHandColor: AppColors.sageGreen,
              dialBackgroundColor: AppColors.subtleGrey.withValues(alpha: 0.3),
              dialTextColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? AppColors.white
                    : AppColors.deepCharcoal,
              ),
              entryModeIconColor: AppColors.sageGreen,
              helpTextStyle: const TextStyle(
                color: AppColors.deepCharcoal,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.sageGreen),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _timeOfDay = (picked.hour, picked.minute));
    }
  }

  Future<void> _onSave() async {
    final vetName = _vetNameController.text.trim();
    if (vetName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.vetNameRequired),
          backgroundColor: AppColors.terracotta,
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    final model = VetVisitModel(
      date: _date,
      timeOfDay: _timeOfDay,
      vetName: vetName,
      reasonForVisit: _reason,
      prepNotes: _prepNotesController.text.trim().isEmpty
          ? null
          : _prepNotesController.text.trim(),
    );
    try {
      await context.read<VetVisitProvider>().setNextVetVisit(model);
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
          widget.existingVisit != null ? l10n.editAppointment : l10n.vetVisit,
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
              // Termin-Karte (Icon + editierbar Datum, Uhrzeit, Tierarztname)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.subtleGrey),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.lightSage,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.medical_services,
                        size: 28,
                        color: AppColors.sageGreen,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _pickDate,
                          child: Text(
                            _formattedDate,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepCharcoal,
                            ),
                          ),
                        ),
                        Text(
                          ', ',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepCharcoal,
                          ),
                        ),
                        GestureDetector(
                          onTap: _pickTime,
                          child: Text(
                            _formattedTime,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepCharcoal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _vetNameController,
                      decoration: InputDecoration(
                        hintText: l10n.vetNamePlaceholder,
                        hintStyle: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.deepCharcoal.withValues(alpha: 0.5),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 4,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.deepCharcoal.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Reason for visit
              Text(
                l10n.reasonForVisit,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepCharcoal,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _ReasonChip(
                    label: l10n.vaccination,
                    isSelected: _reason == VetVisitReason.vaccination,
                    onTap: () =>
                        setState(() => _reason = VetVisitReason.vaccination),
                  ),
                  _ReasonChip(
                    label: l10n.checkup,
                    isSelected: _reason == VetVisitReason.checkup,
                    onTap: () =>
                        setState(() => _reason = VetVisitReason.checkup),
                  ),
                  _ReasonChip(
                    label: l10n.emergency,
                    isSelected: _reason == VetVisitReason.emergency,
                    onTap: () =>
                        setState(() => _reason = VetVisitReason.emergency),
                  ),
                  _ReasonChip(
                    label: l10n.surgery,
                    isSelected: _reason == VetVisitReason.surgery,
                    onTap: () =>
                        setState(() => _reason = VetVisitReason.surgery),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              // Prep-Notes
              Text(
                l10n.prepNotes,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepCharcoal,
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
                      controller: _prepNotesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: l10n.notesForVetPlaceholder,
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
              const SizedBox(height: 22),
              // Attachments
              Text(
                l10n.attachments,
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
                    color: AppColors.sageGreen.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      size: 36,
                      color: AppColors.sageGreen.withValues(alpha: 0.8),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.uploadDocumentPhoto,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.deepCharcoal.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Save Appointment
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sageGreen,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        )
                      : Text(l10n.saveAppointment),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReasonChip extends StatelessWidget {
  const _ReasonChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.sageGreen
              : AppColors.subtleGrey.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? AppColors.white : AppColors.deepCharcoal,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
