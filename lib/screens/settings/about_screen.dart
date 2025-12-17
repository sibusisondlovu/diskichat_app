import 'package:flutter/material.dart';
import '../../utils/themes/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        title: const Text('About Diskichat'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            
            // Logo (No Border)
            Image.asset(
              'lib/assets/images/diskichat_icon.png',
              width: 80, // Slightly larger as requested implied by "remove container"
              height: 80,
              color: Colors.white,
            ),
            
            const SizedBox(height: 24),
            
            // Title removed as requested
            
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                color: AppColors.textGray,
              ),
            ),
            
            const SizedBox(height: 32),
            
            const Text(
              'Second screen platform for soccer fans to engage during match, banter with other members.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 14, // Reduced to 14pt
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 48),
            
            _buildSection(
              title: 'Features',
              items: [
                'Banter Rooms (where members will be trolling each other)',
                'Score Predictions & Rankings',
                'Real-time Live Scores',
              ],
            ),
            
            const SizedBox(height: 32),
            
            _buildSection(
              title: 'Credits',
              items: [
                'Developed by: Jaspa',
                'Data provided by: API-Football',
              ],
            ),
            
            const SizedBox(height: 48),
            
            const Text(
              'COPYRIGHT AT DISKICHAT (PTY) LTD', // Uppercase
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
            fontSize: 16, // Titles 16pt
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
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(color: AppColors.textWhite, fontSize: 14), // Body 14pt
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
