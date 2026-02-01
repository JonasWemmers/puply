import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:publy/core/theme/app_colors.dart';
import 'package:publy/core/theme/app_theme.dart';
import 'package:publy/features/auth/view/login_view.dart';
import 'package:publy/features/dashboard/view/dashboard_view.dart';

/// Splash Screen View
///
/// Zeigt das Pfoten-Icon und den App-Namen "Puply" zentriert an.
/// Navigiert nach 2 Sekunden zum Dashboard (wenn eingeloggt) oder zum Login.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateAfterSplash();
  }

  void _navigateAfterSplash() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              user != null ? const DashboardView() : const LoginView(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pfoten-Icon (Material Icon)
            Icon(Icons.pets, size: 80, color: AppColors.terracotta),
            const SizedBox(height: 32),
            // App Name "Puply"
            Text('Puply', style: AppTheme.lightTheme.textTheme.displayLarge),
          ],
        ),
      ),
    );
  }
}
