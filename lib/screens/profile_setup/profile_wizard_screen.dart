import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';

import '../../providers/auth_provider.dart';
import '../../utils/themes/app_colors.dart';
import '../../utils/themes/text_styles.dart';
import '../../utils/themes/gradients.dart';
import '../../utils/constants/teams_constants.dart';
import '../../components/buttons/gradient_button.dart';
import '../../components/inputs/custom_text_field.dart';
import '../home_screen.dart';

class ProfileWizardScreen extends StatefulWidget {
  const ProfileWizardScreen({super.key});

  @override
  State<ProfileWizardScreen> createState() => _ProfileWizardScreenState();
}

class _ProfileWizardScreenState extends State<ProfileWizardScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nicknameController = TextEditingController();
  int _currentStep = 0;
  String? _selectedTeam;

  void _nextStep() {
    if (_currentStep == 0) {
      if (_nicknameController.text.trim().isEmpty) {
        _showToast("Please enter a nickname", icon: Icons.warning);
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      _completeProfile();
    }
  }

  void _completeProfile() async {
    if (_selectedTeam == null) {
      _showToast("Please select your favorite team", icon: Icons.sports_soccer);
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.updateProfile(
      username: _nicknameController.text.trim(),
      favoriteTeam: _selectedTeam,
    );

    if (success) {
      if (!mounted) return;
      _showToast("Profile Created Successfully!", icon: Icons.check_circle);
      
      // Navigate to Home after a short delay
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      if (!mounted) return;
      _showToast("Failed to update profile", icon: Icons.error);
    }
  }
  
  void _showToast(String message, {IconData icon = Icons.info}) {
    DelightToastBar(
      builder: (context) => ToastCard(
        leading: Icon(icon, size: 28, color: AppColors.textWhite),
        title: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textWhite),
        ),
        color: AppColors.cardSurface,
      ),
      position: DelightSnackbarPosition.top,
      autoDismiss: true,
      snackbarDuration: const Duration(seconds: 3),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / 2,
              backgroundColor: AppColors.cardSurface,
              color: AppColors.accentBlue,
            ),
            
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildNicknameStep(),
                  _buildTeamSelectionStep(),
                ],
              ),
            ),
            
            // Bottom Action Area
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: isLoading 
                ? const SpinKitThreeBounce(color: AppColors.accentBlue, size: 30)
                : GradientButton(
                    text: _currentStep == 0 ? 'Next' : 'Finish',
                    onPressed: _nextStep,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNicknameStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline, size: 80, color: AppColors.accentBlue),
          const SizedBox(height: 24),
          const Text(
            'What should we call you?',
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Choose a unique nickname for the community.',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          CustomTextField(
            controller: _nicknameController,
            hintText: 'Nickname',
            prefixIcon: Icons.badge,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSelectionStep() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                'Pick your Team',
                style: AppTextStyles.h2,
              ),
              SizedBox(height: 8),
              Text(
                'Show your colors! This cannot be changed easily.',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: TeamsConstants.pslTeams.length,
            itemBuilder: (context, index) {
              final team = TeamsConstants.pslTeams[index];
              final isSelected = _selectedTeam == team['name'];
              final teamColor = Color(int.parse(team['color']!));

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedTeam = team['name']);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? teamColor.withOpacity(0.2) : AppColors.cardSurface,
                    border: Border.all(
                      color: isSelected ? teamColor : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Placeholder for logo if asset doesn't exist yet, 
                      // but user has provided logo paths. Using icon for now if fails?
                      // Using Image.asset with errorBuilder just in case.
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Icon(
                            Icons.shield, // Placeholder icon
                            color: teamColor,
                            size: 40,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          team['name']!,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
