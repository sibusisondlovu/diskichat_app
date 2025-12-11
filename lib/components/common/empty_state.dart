import 'package:flutter/material.dart';
import '../../utils/themes/app_colors.dart';
import '../../utils/themes/text_styles.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cardSurface,
              ),
              child: Icon(
                icon,
                size: 50,
                color: AppColors.textMuted,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              title,
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textGray,
              ),
              textAlign: TextAlign.center,
            ),

            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}