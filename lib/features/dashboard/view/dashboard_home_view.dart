import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:publy/l10n/app_localizations.dart';
import 'package:publy/core/theme/app_colors.dart';
import 'package:publy/core/theme/app_theme.dart';
import 'package:publy/features/vet_visit/viewmodel/vet_visit_provider.dart';
import 'package:publy/features/vet_visit/view/vet_visit_view.dart';
import 'package:publy/features/vet_visit/view/vet_visit_detail_view.dart';
import 'package:publy/features/water_log/view/water_log_view.dart';
import 'package:publy/features/potty_log/view/potty_log_view.dart';
import 'package:publy/features/food_log/view/food_log_view.dart';

/// Home-Inhalt des Dashboards: Begrüßung, Quick Log, Stimmung, Health Snapshot.
class DashboardHomeView extends StatefulWidget {
  const DashboardHomeView({super.key});

  @override
  State<DashboardHomeView> createState() => _DashboardHomeViewState();
}

class _DashboardHomeViewState extends State<DashboardHomeView> {
  String? _userName;
  String? _dogName;
  int _selectedMoodIndex = 0; // 0 = Playful
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _userName = 'User';
        _dogName = 'Sammy';
        _loading = false;
      });
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _userName = data['displayName'] as String? ?? 'User';
          _dogName = data['dogName'] as String? ?? 'Sammy';
          _loading = false;
        });
      } else {
        setState(() {
          _userName = FirebaseAuth.instance.currentUser?.displayName ?? 'User';
          _dogName = 'Sammy';
          _loading = false;
        });
      }
      // Tierarzttermin aus User-Dokument laden
      if (mounted) {
        await context.read<VetVisitProvider>().loadFromFirestore(uid);
      }
    } catch (e) {
      setState(() {
        _userName = 'User';
        _dogName = 'Sammy';
        _loading = false;
      });
    }
  }

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning(_userName ?? '');
    if (hour < 18) return l10n.goodAfternoon(_userName ?? '');
    return l10n.goodEvening(_userName ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.lightTheme;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Begrüßung + Hundebild (Design 1:1)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting(l10n),
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.howIsNameDoingToday(_dogName ?? ''),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          color: AppColors.deepCharcoal.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Platzhalter Profilbild Hund (Kreis mit grünem Ring + Punkt)
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.sageGreen, width: 2),
                    color: AppColors.subtleGrey,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Center(
                        child: Icon(
                          Icons.pets,
                          size: 32,
                          color: AppColors.deepCharcoal.withValues(alpha: 0.5),
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.sageGreen,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.cream,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Quick Log
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  l10n.quickLog,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.sageGreen,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(l10n.edit),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.35,
              children: [
                _QuickLogTile(
                  icon: Icons.restaurant_outlined,
                  label: l10n.food,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const FoodLogView(),
                      ),
                    );
                  },
                ),
                _QuickLogTile(
                  icon: Icons.water_drop_outlined,
                  label: l10n.water,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const WaterLogView(),
                      ),
                    );
                  },
                ),
                _QuickLogTile(
                  icon: Icons.directions_walk_outlined,
                  label: l10n.walk,
                  onTap: () {},
                ),
                _QuickLogTile(
                  icon: Icons.park_outlined,
                  label: l10n.potty,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const PottyLogView(),
                      ),
                    );
                  },
                ),
                _QuickLogTile(
                  icon: Icons.medical_services_outlined,
                  label: l10n.symptoms,
                  onTap: () {},
                ),
                _QuickLogTile(
                  icon: Icons.calendar_today_outlined,
                  label: l10n.cycle,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 22),
            // Current Mood
            Text(
              l10n.currentMood,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _MoodChip(
                    label: l10n.playful,
                    icon: Icons.sports_tennis_outlined,
                    isSelected: _selectedMoodIndex == 0,
                    onTap: () => setState(() => _selectedMoodIndex = 0),
                  ),
                  const SizedBox(width: 10),
                  _MoodChip(
                    label: l10n.sleepy,
                    icon: Icons.bedtime_outlined,
                    isSelected: _selectedMoodIndex == 1,
                    onTap: () => setState(() => _selectedMoodIndex = 1),
                  ),
                  const SizedBox(width: 10),
                  _MoodChip(
                    label: l10n.hungry,
                    icon: Icons.restaurant_outlined,
                    isSelected: _selectedMoodIndex == 2,
                    onTap: () => setState(() => _selectedMoodIndex = 2),
                  ),
                  const SizedBox(width: 10),
                  _MoodChip(
                    label: l10n.happy,
                    icon: Icons.sentiment_satisfied_outlined,
                    isSelected: _selectedMoodIndex == 3,
                    onTap: () => setState(() => _selectedMoodIndex = 3),
                  ),
                  const SizedBox(width: 10),
                  _MoodChip(
                    label: l10n.sick,
                    icon: Icons.sick_outlined,
                    isSelected: _selectedMoodIndex == 4,
                    onTap: () => setState(() => _selectedMoodIndex = 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Health Snapshot Card: Plus wenn kein Termin, sonst Termin anzeigen
            Consumer<VetVisitProvider>(
              builder: (context, vetProvider, _) {
                final visit = vetProvider.nextVetVisit;
                final hasVisit = visit != null;
                final locale = Localizations.localeOf(context).languageCode;
                final dateStr = hasVisit
                    ? DateFormat(
                        'd. MMMM',
                        locale == 'de' ? 'de' : 'en',
                      ).format(visit.date)
                    : '';
                final (h, m) = hasVisit ? visit.timeOfDay : (0, 0);
                final timeStr = hasVisit
                    ? '${h > 12 ? h - 12 : (h == 0 ? 12 : h)}:${m.toString().padLeft(2, '0')} ${h < 12 ? 'AM' : 'PM'}'
                    : '';

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (hasVisit) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) =>
                                VetVisitDetailView(visit: visit),
                          ),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => const VetVisitView(),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.subtleGrey),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.medical_services_outlined,
                                      size: 16,
                                      color: AppColors.sageGreen,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      l10n.healthSnapshot,
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            fontSize: 11,
                                            color: AppColors.sageGreen,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.nextVetVisit,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                if (hasVisit) ...[
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.schedule_outlined,
                                        size: 16,
                                        color: AppColors.deepCharcoal
                                            .withValues(alpha: 0.6),
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          '$dateStr • $timeStr',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: AppColors.deepCharcoal
                                                    .withValues(alpha: 0.7),
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    visit.vetName,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.deepCharcoal.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ] else
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.add_circle_outline,
                                        size: 20,
                                        color: AppColors.sageGreen,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        l10n.addVetVisit,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: AppColors.sageGreen,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (hasVisit)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/img/ta_image.png',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: AppColors.lightSage.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.add,
                                size: 40,
                                color: AppColors.sageGreen.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _QuickLogTile extends StatelessWidget {
  const _QuickLogTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;

    return Material(
      color: AppColors.cream,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.subtleGrey),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: AppColors.sageGreen),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
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

class _MoodChip extends StatelessWidget {
  const _MoodChip({
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
    final theme = AppTheme.lightTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.terracotta
              : AppColors.subtleGrey.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? AppColors.white
                  : AppColors.deepCharcoal.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? AppColors.white
                    : AppColors.deepCharcoal.withValues(alpha: 0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
