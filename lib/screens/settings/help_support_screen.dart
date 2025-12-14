import 'package:flutter/material.dart';
import '../../utils/themes/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  final List<Map<String, String>> _faqs = const [
    {
      'question': 'How do I earn points?',
      'answer': 'You earn points by correctly predicting match scores, creating popular discussion posts, and maintaining a daily login streak. Engage more to rank up!',
    },
    {
      'question': 'How can I change my profile avatar?',
      'answer': 'Go to your Profile page, tap "Edit Profile", and click on the camera icon on your avatar to upload a new picture.',
    },
    {
      'question': 'What are the different ranks?',
      'answer': 'The ranks are Amateur, Semi-Pro, Pro, World Class, and Legend. Your rank is determined by your total points.',
    },
    {
      'question': 'Can I follow other users?',
      'answer': 'Currently, you can view other users profiles. A full "Follow" system is coming soon in a future update!',
    },
    {
      'question': 'How do I create a match room?',
      'answer': 'Match rooms are automatically created for every live match. Just tap on a live match to join the conversation.',
    },
    {
      'question': 'Is DiskiChat free?',
      'answer': 'Yes! DiskiChat is completely free to download and use.',
    },
    {
      'question': 'How do I report abusive content?',
      'answer': 'Please use the "Report a Bug/Issue" feature in the Feedback section to report any inappropriate content or users.',
    },
    {
      'question': 'Can I change my username?',
      'answer': 'Yes, you can update your username in the "Edit Profile" section, provided the new username is not already taken.',
    },
    {
      'question': 'Do you support dark mode?',
      'answer': 'Yes, DiskiChat is designed with a dark-themed "Stadium Night" mode by default for the best viewing experience.',
    },
    {
      'question': 'How can I contact support?',
      'answer': 'You can use the "Feature Request & Feedback" form to send us a direct message, or email us at support@diskichat.app.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return Card(
            color: AppColors.cardSurface,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              title: Text(
                faq['question']!,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
              iconColor: AppColors.accentBlue,
              collapsedIconColor: AppColors.textGray,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    faq['answer']!,
                    style: const TextStyle(
                      color: AppColors.textGray,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
