import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:publy/l10n/app_localizations.dart';
import 'package:publy/core/theme/app_colors.dart';
import 'package:publy/core/theme/app_theme.dart';
import 'package:publy/features/vet_visit/data/vet_visit_model.dart';
import 'package:publy/features/vet_visit/viewmodel/vet_visit_provider.dart';
import 'package:publy/features/vet_visit/view/vet_visit_view.dart';

/// Detail-View für einen Tierarzttermin: Anzeige mit Bearbeiten/Löschen-Buttons.
class VetVisitDetailView extends StatelessWidget {
  const VetVisitDetailView({super.key, required this.visit});

  final VetVisitModel visit;

  Future<void> _onDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.terracotta),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<VetVisitProvider>().clearNextVetVisit();
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  void _onEdit(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => VetVisitView(existingVisit: visit),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.lightTheme;
    final locale = Localizations.localeOf(context).languageCode;

    final dateStr = DateFormat(
      'd. MMMM',
      locale == 'de' ? 'de' : 'en',
    ).format(visit.date);
    final (h, m) = visit.timeOfDay;
    final timeStr =
        '${h > 12 ? h - 12 : (h == 0 ? 12 : h)}:${m.toString().padLeft(2, '0')} ${h < 12 ? 'AM' : 'PM'}';

    String reasonLabel;
    switch (visit.reasonForVisit) {
      case VetVisitReason.vaccination:
        reasonLabel = l10n.vaccination;
        break;
      case VetVisitReason.checkup:
        reasonLabel = l10n.checkup;
        break;
      case VetVisitReason.emergency:
        reasonLabel = l10n.emergency;
        break;
      case VetVisitReason.surgery:
        reasonLabel = l10n.surgery;
        break;
    }

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
          l10n.appointmentDetails,
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
              // Termin-Karte (Icon + Datum, Uhrzeit, Tierarztname)
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
                    Text(
                      '$dateStr, $timeStr',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepCharcoal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      visit.vetName,
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.sageGreen,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  reasonLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 22),
              // Prep-Notes (falls vorhanden)
              if (visit.prepNotes != null && visit.prepNotes!.isNotEmpty) ...[
                Text(
                  l10n.prepNotes,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepCharcoal,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.subtleGrey),
                  ),
                  child: Text(
                    visit.prepNotes!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.deepCharcoal,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
              ],
              const SizedBox(height: 8),
              // Edit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _onEdit(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sageGreen,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(l10n.editAppointment),
                ),
              ),
              const SizedBox(height: 12),
              // Delete Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _onDelete(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.terracotta,
                    side: const BorderSide(color: AppColors.terracotta),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(l10n.deleteAppointment),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
