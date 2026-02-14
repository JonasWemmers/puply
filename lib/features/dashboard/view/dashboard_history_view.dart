import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:publy/l10n/app_localizations.dart';
import 'package:publy/core/theme/app_colors.dart';
import 'package:publy/core/theme/app_theme.dart';

/// Verlauf: alle Logs gruppiert nach Tag, Suchleiste, Filter (All, Food, Health, Walk).
class DashboardHistoryView extends StatefulWidget {
  const DashboardHistoryView({super.key});

  @override
  State<DashboardHistoryView> createState() => _DashboardHistoryViewState();
}

enum _HistoryFilter { all, food, health, walk }

class _HistoryEntry {
  _HistoryEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.loggedAt,
    required this.value,
    required this.iconBgColor,
    required this.icon,
    this.hasImage = false,
  });

  final String id;
  final String type; // 'water' | 'potty'
  final String title;
  final DateTime loggedAt;
  final String value;
  final Color iconBgColor;
  final Widget icon;
  final bool hasImage;
}

class _DashboardHistoryViewState extends State<DashboardHistoryView> {
  List<_HistoryEntry> _entries = [];
  bool _loading = true;
  String _searchQuery = '';
  _HistoryFilter _filter = _HistoryFilter.all;
  final _searchController = TextEditingController();
  bool _loadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadStarted) {
      _loadStarted = true;
      _loadLogs();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) {
        setState(() {
          _entries = [];
          _loading = false;
        });
      }
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    try {
      final waterSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('waterLogs')
          .orderBy('loggedAt', descending: true)
          .get();

      final pottySnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('pottyLogs')
          .orderBy('loggedAt', descending: true)
          .get();

      final foodSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('foodLogs')
          .orderBy('loggedAt', descending: true)
          .get();

      final walkSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('walkLogs')
          .orderBy('loggedAt', descending: true)
          .get();

      final symptomSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('symptomLogs')
          .orderBy('loggedAt', descending: true)
          .get();

      final list = <_HistoryEntry>[];

      for (final doc in waterSnap.docs) {
        final d = doc.data();
        final loggedAt = (d['loggedAt'] as Timestamp?)?.toDate();
        if (loggedAt == null) continue;
        list.add(
          _HistoryEntry(
            id: doc.id,
            type: 'water',
            title: l10n.waterRefill,
            loggedAt: loggedAt,
            value: '${d['amountMl'] ?? 0} ml',
            iconBgColor: const Color(0xFFB8D4E3),
            icon: Icon(
              Icons.water_drop_outlined,
              size: 24,
              color: Colors.blue.shade700,
            ),
            hasImage: false,
          ),
        );
      }

      for (final doc in pottySnap.docs) {
        final d = doc.data();
        final loggedAt = (d['loggedAt'] as Timestamp?)?.toDate();
        if (loggedAt == null) continue;
        final pottyType = d['type'] as String? ?? 'poop';
        final quality = d['quality'] as String? ?? 'normal';
        String qualityLabel;
        switch (quality) {
          case 'hard':
            qualityLabel = l10n.hard;
            break;
          case 'soft':
            qualityLabel = l10n.soft;
            break;
          default:
            qualityLabel = l10n.normal;
        }
        list.add(
          _HistoryEntry(
            id: doc.id,
            type: 'potty',
            title: pottyType == 'pee' ? l10n.pee : l10n.poop,
            loggedAt: loggedAt,
            value: qualityLabel,
            iconBgColor: pottyType == 'pee'
                ? const Color(0xFFB8D4E3)
                : const Color(0xFFD4A574),
            icon: Text(
              pottyType == 'pee' ? '💦' : '💩',
              style: const TextStyle(fontSize: 24),
            ),
            hasImage: false,
          ),
        );
      }

      for (final doc in foodSnap.docs) {
        final d = doc.data();
        final loggedAt = (d['loggedAt'] as Timestamp?)?.toDate();
        if (loggedAt == null) continue;
        final amountG = d['amountG'] as int? ?? 0;
        list.add(
          _HistoryEntry(
            id: doc.id,
            type: 'food',
            title: l10n.food,
            loggedAt: loggedAt,
            value: '${amountG}g',
            iconBgColor: const Color(0xFFF5E6C8),
            icon: Icon(
              Icons.restaurant_outlined,
              size: 24,
              color: Colors.brown.shade700,
            ),
            hasImage: false,
          ),
        );
      }

      for (final doc in walkSnap.docs) {
        final d = doc.data();
        final loggedAt = (d['loggedAt'] as Timestamp?)?.toDate();
        if (loggedAt == null) continue;
        final duration = d['durationMinutes'] as int? ?? 0;
        list.add(
          _HistoryEntry(
            id: doc.id,
            type: 'walk',
            title: l10n.walkEntry,
            loggedAt: loggedAt,
            value: '$duration min',
            iconBgColor: const Color(0xFFD4E8D0),
            icon: Icon(
              Icons.directions_walk_outlined,
              size: 24,
              color: Colors.green.shade700,
            ),
            hasImage: d['hasPhoto'] as bool? ?? false,
          ),
        );
      }

      for (final doc in symptomSnap.docs) {
        final d = doc.data();
        final loggedAt = (d['loggedAt'] as Timestamp?)?.toDate();
        if (loggedAt == null) continue;
        final symptoms =
            (d['symptoms'] as List<dynamic>?)?.cast<String>() ?? [];
        final severity = d['severity'] as int? ?? 1;
        String sevLabel;
        if (severity <= 2) {
          sevLabel = l10n.mild;
        } else if (severity >= 4) {
          sevLabel = l10n.severe;
        } else {
          sevLabel = l10n.moderate;
        }
        list.add(
          _HistoryEntry(
            id: doc.id,
            type: 'symptom',
            title: symptoms.isNotEmpty ? l10n.symptomEntry : l10n.symptomEntry,
            loggedAt: loggedAt,
            value: sevLabel,
            iconBgColor: const Color(0xFFF5D5D5),
            icon: Icon(
              Icons.medical_services_outlined,
              size: 24,
              color: Colors.red.shade400,
            ),
            hasImage: d['hasPhoto'] as bool? ?? false,
          ),
        );
      }

      list.sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
      if (mounted) {
        setState(() {
          _entries = list;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _entries = [];
          _loading = false;
        });
      }
    }
  }

  List<_HistoryEntry> get _filteredEntries {
    var list = _entries;
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list
          .where(
            (e) =>
                e.title.toLowerCase().contains(q) ||
                e.value.toLowerCase().contains(q),
          )
          .toList();
    }
    switch (_filter) {
      case _HistoryFilter.food:
        list = list.where((e) => e.type == 'food').toList();
        break;
      case _HistoryFilter.health:
        list = list
            .where(
              (e) =>
                  e.type == 'potty' ||
                  e.type == 'health' ||
                  e.type == 'symptom',
            )
            .toList();
        break;
      case _HistoryFilter.walk:
        list = list.where((e) => e.type == 'walk').toList();
        break;
      case _HistoryFilter.all:
        break;
    }
    return list;
  }

  List<(String, List<_HistoryEntry>)> _groupByDay(List<_HistoryEntry> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode == 'de'
        ? 'de'
        : 'en';

    final map = <DateTime, List<_HistoryEntry>>{};
    for (final e in entries) {
      final day = DateTime(e.loggedAt.year, e.loggedAt.month, e.loggedAt.day);
      map.putIfAbsent(day, () => []).add(e);
    }
    final days = map.keys.toList()..sort((a, b) => b.compareTo(a));
    final result = <(String, List<_HistoryEntry>)>[];
    for (final day in days) {
      String label;
      if (day == today) {
        label = l10n.today;
      } else if (day == yesterday) {
        label = l10n.yesterday;
      } else {
        label = DateFormat('d. MMMM', locale).format(day);
      }
      result.add((label, map[day]!));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.lightTheme;
    final filtered = _filteredEntries;
    final grouped = _groupByDay(filtered);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.history,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.deepCharcoal,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Suchleiste
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: l10n.searchLogsPlaceholder,
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
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.deepCharcoal,
                ),
              ),
            ),
            // Filter-Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: l10n.all,
                      isSelected: _filter == _HistoryFilter.all,
                      onTap: () => setState(() => _filter = _HistoryFilter.all),
                    ),
                    const SizedBox(width: 10),
                    _FilterChip(
                      label: l10n.food,
                      isSelected: _filter == _HistoryFilter.food,
                      onTap: () =>
                          setState(() => _filter = _HistoryFilter.food),
                    ),
                    const SizedBox(width: 10),
                    _FilterChip(
                      label: l10n.health,
                      isSelected: _filter == _HistoryFilter.health,
                      onTap: () =>
                          setState(() => _filter = _HistoryFilter.health),
                    ),
                    const SizedBox(width: 10),
                    _FilterChip(
                      label: l10n.walk,
                      isSelected: _filter == _HistoryFilter.walk,
                      onTap: () =>
                          setState(() => _filter = _HistoryFilter.walk),
                    ),
                  ],
                ),
              ),
            ),
            // Log-Liste nach Tag
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : grouped.isEmpty
                  ? Center(
                      child: Text(
                        l10n.searchLogsPlaceholder,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.deepCharcoal.withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      itemCount: grouped.fold<int>(
                        0,
                        (total, pair) => total + 1 + pair.$2.length,
                      ),
                      itemBuilder: (context, index) {
                        int i = 0;
                        for (final pair in grouped) {
                          final (label, dayEntries) = pair;
                          if (index == i) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Text(
                                label,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.deepCharcoal,
                                ),
                              ),
                            );
                          }
                          i++;
                          for (final entry in dayEntries) {
                            if (index == i) {
                              return _HistoryEntryCard(entry: entry);
                            }
                            i++;
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.sageGreen : AppColors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? AppColors.sageGreen : AppColors.subtleGrey,
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isSelected ? AppColors.white : AppColors.deepCharcoal,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryEntryCard extends StatelessWidget {
  const _HistoryEntryCard({required this.entry});

  final _HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final timeStr = DateFormat('h:mm a').format(entry.loggedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.subtleGrey),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: entry.iconBgColor.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: entry.icon,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepCharcoal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeStr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.deepCharcoal.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: (entry.type == 'water' || entry.type == 'food')
                      ? AppColors.sageGreen
                      : AppColors.deepCharcoal,
                ),
              ),
              if (entry.hasImage)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 18,
                    color: AppColors.deepCharcoal.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
