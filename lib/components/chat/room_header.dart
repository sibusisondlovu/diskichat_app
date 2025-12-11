import 'package:flutter/material.dart';
import '../../data/models/match_model.dart';
import '../../utils/themes/app_colors.dart';
import '../../utils/themes/text_styles.dart';

class RoomHeader extends StatelessWidget {
  final MatchModel match;

  const RoomHeader({
    super.key,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Teams
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              match.homeTeam,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 8),
            Text(
              match.isLive || match.isFinished
                  ? match.scoreDisplay
                  : 'vs',
              style: AppTextStyles.bodyMedium.copyWith(
                color: match.isLive ? AppColors.liveGreen : AppColors.textGray,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              match.awayTeam,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),

        // Status
        if (match.isLive)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.liveGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'LIVE',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.liveGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
        else
          Text(
            match.statusDisplay,
            style: AppTextStyles.caption,
          ),
      ],
    );
  }
}