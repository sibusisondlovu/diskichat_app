import 'package:flutter/material.dart';
import '../../utils/themes/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final String? message;

  const LoadingIndicator({
    super.key,
    this.size = 40,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                color: AppColors.textGray,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}