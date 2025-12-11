import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/themes/app_colors.dart';
import '../utils/themes/text_styles.dart';
import '../utils/routes.dart';
import '../services/storage_service.dart';
import 'auth/welcome_auth_screen.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('DEBUG: SplashScreen initState');
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    debugPrint('DEBUG: Starting _navigateToNext');
    
    // Initialize Storage Service (if not already)
    await StorageService().init();
    
    await Future.delayed(const Duration(seconds: 2));
    debugPrint('DEBUG: Timer completed');

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    debugPrint('DEBUG: Auth check - isAuthenticated: ${authProvider.isAuthenticated}');

    if (authProvider.isAuthenticated) {
      debugPrint('DEBUG: Navigating to HomeScreen');
      AppRoutes.navigateReplace(context, const HomeScreen());
    } else {
      // Check if onboarding is already done
      final bool onboardingDone = StorageService().isOnboardingDone;
      debugPrint('DEBUG: Onboarding done: $onboardingDone');

      if (onboardingDone) {
        debugPrint('DEBUG: Navigating to WelcomeAuthScreen');
        AppRoutes.navigateReplace(context, const WelcomeAuthScreen());
      } else {
        debugPrint('DEBUG: Navigating to OnboardingScreen');
        AppRoutes.navigateReplace(context, const OnboardingScreen());
      }
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
              child: Image.asset('lib/assets/images/diskichat_icon.png'
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