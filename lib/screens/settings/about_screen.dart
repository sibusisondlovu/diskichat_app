import 'package:flutter/material.dart';
import '../../utils/themes/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        title: const Text('About DiskiChat'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            
            // Logo Placeholder (Using Icon for now)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accentBlue, width: 2),
              ),
              child: const Icon(
                Icons.sports_soccer,
                size: 64,
                color: AppColors.accentBlue,
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'DiskiChat',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
            
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                color: AppColors.textGray,
              ),
            ),
            
            const SizedBox(height: 32),
            
            const Text(
              'The ultimate soccor companion app. Join the conversation, predict scores, and connect with fans around the world.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 48),
            
            _buildSection(
              title: 'Features',
              items: [
                'Live Match Chat Rooms',
                'Score Predictions & Rankings',
                'Real-time Live Scores',
                'Team News & Discussion',
              ],
            ),
            
            const SizedBox(height: 32),
            
            _buildSection(
              title: 'Credits',
              items: [
                'Developed by: DiskiChat Team',
                'Data provided by: API-Football',
              ],
            ),
            
            const SizedBox(height: 48),
            
            const Text(
              '© 2025 DiskiChat. All rights reserved.',
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<String> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.accentBlue,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, size: 16, color: AppColors.successGreen),
              const SizedBox(width: 8),
              Text(
                item,
                style: const TextStyle(color: AppColors.textWhite),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
