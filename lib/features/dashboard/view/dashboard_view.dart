import 'package:flutter/material.dart';
import 'package:publy/core/theme/app_colors.dart';
import 'package:publy/core/widgets/app_nav_bar.dart';
import 'package:publy/features/dashboard/view/dashboard_home_view.dart';
import 'package:publy/features/dashboard/view/dashboard_history_view.dart';

/// Dashboard-Shell mit Bottom-NavBar.
/// Zeigt je nach [currentIndex] Home, History, Analytics oder Profile.
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          DashboardHomeView(),
          DashboardHistoryView(),
          _PlaceholderView(title: 'Analytics'),
          _PlaceholderView(title: 'Profile'),
        ],
      ),
      bottomNavigationBar: AppNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _PlaceholderView extends StatelessWidget {
  const _PlaceholderView({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}
