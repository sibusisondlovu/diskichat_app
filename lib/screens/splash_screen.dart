import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/themes/app_colors.dart';
import '../utils/themes/text_styles.dart';
import '../utils/routes.dart';
import 'onboarding_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isAuthenticated) {
      AppRoutes.navigateReplace(context, const HomeScreen());
    } else {
      AppRoutes.navigateReplace(context, const OnboardingScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentBlue,
                    AppColors.accentBlue.withOpacity(0.6),
                  ],
                ),
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                size: 60,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Diskichat',
              style: AppTextStyles.h1,
            ),
            const SizedBox(height: 8),
            Text(
              'Making Beautiful Game More Social',
              style: AppTextStyles.tagline,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
            ),
          ],
        ),
      ),
    );
  }
}