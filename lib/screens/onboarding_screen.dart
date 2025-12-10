import 'package:flutter/material.dart';
import '../utils/themes/app_colors.dart';
import '../utils/themes/text_styles.dart';
import '../utils/routes.dart';
import '../components/buttons/gradient_button.dart';
import 'auth/phone_auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.chat_bubble_rounded,
      title: 'Welcome to Diskichat',
      description: 'Making Beautiful Game More Social',
    ),
    OnboardingPage(
      icon: Icons.sports_soccer,
      title: 'Join ANY Match\nWorldwide',
      description:
      'AFCON, Premier League, Champions League\nYour local derby, your national team\nEvery match has a room',
    ),
    OnboardingPage(
      icon: Icons.emoji_events,
      title: 'Engage & Earn\nYour Status',
      description:
      'Amateur → Semi-Pro → Pro\nWorld Class → Legend\n\nEvery comment counts, every vote matters',
    ),
    OnboardingPage(
      icon: Icons.auto_awesome,
      title: 'Smart Football\nInsights',
      description:
      'AI match predictions\nLive sentiment analysis\nThe beautiful game, smarter',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _goToAuth,
                child: Text(
                  'Skip',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textGray,
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                    (index) => _buildDot(index),
              ),
            ),

            const SizedBox(height: 32),

            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _currentPage == _pages.length - 1
                  ? GradientButton(
                text: 'Join Diskichat',
                onPressed: _goToAuth,
              )
                  : GradientButton(
                text: 'Next',
                onPressed: _nextPage,
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
            child: Icon(
              page.icon,
              size: 60,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: AppTextStyles.h1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: _currentPage == index
            ? AppColors.accentBlue
            : AppColors.textMuted,
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToAuth() {
    AppRoutes.navigateReplace(context, const PhoneAuthScreen());
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}