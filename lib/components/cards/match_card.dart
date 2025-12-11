import 'package:flutter/material.dart';
import '../../data/models/match_model.dart';
import '../../screens/chat/chat_room_screen.dart';
import '../../utils/themes/app_colors.dart';
import '../../utils/themes/text_styles.dart';
import '../../utils/themes/gradients.dart';
import '../../utils/helpers/time_helper.dart';
import '../../utils/routes.dart';
import '../badges/live_indicator.dart';


class MatchCard extends StatelessWidget {
  final MatchModel match;

  const MatchCard({
    super.key,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppRoutes.navigateTo(
          context,
          ChatRoomScreen(match: match),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.matchCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cardSurface.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  // Competition name
                  Expanded(
                    child: Text(
                      match.competitionName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textGray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Fan Count Badge
                  if (match.fanCount > 0)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.accentBlue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.people, size: 12, color: AppColors.accentBlue),
                          const SizedBox(width: 4),
                          Text(
                            '${match.fanCount}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accentBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Live indicator or time
                  if (match.isLive)
                    const LiveIndicator()
                  else
                    Text(
                      TimeHelper.formatMatchTime(match.matchDate),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textGray,
                      ),
                    ),
                ],
              ),
            ),

            // Match info
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Teams and score
                  Row(
                    children: [
                      // Home team
                      Expanded(
                        child: Column(
                          children: [
                            _buildTeamLogo(match.homeLogo),
                            const SizedBox(height: 8),
                            Text(
                              match.homeTeam,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Score
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            if (match.isLive || match.isFinished)
                              Text(
                                match.scoreDisplay,
                                style: AppTextStyles.scoreMedium,
                              )
                            else
                              Text(
                                'VS',
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            if (match.isLive || match.isFinished)
                              Text(
                                match.elapsedTime ?? match.statusDisplay,
                                style: AppTextStyles.caption.copyWith(
                                  color: match.isLive
                                      ? AppColors.liveGreen
                                      : AppColors.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Away team
                      Expanded(
                        child: Column(
                          children: [
                            _buildTeamLogo(match.awayLogo),
                            const SizedBox(height: 8),
                            Text(
                              match.awayTeam,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Join button
                  Container(
                    width: double.infinity,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primaryButton,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          AppRoutes.navigateTo(
                            context,
                            ChatRoomScreen(match: match),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.chat_bubble,
                              color: AppColors.textWhite,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Join Match Room',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textWhite,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward,
                              color: AppColors.textWhite,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamLogo(String? logoUrl) {
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.cardSurface,
          image: DecorationImage(
            image: NetworkImage(logoUrl),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.cardSurface,
      ),
      child: const Icon(
        Icons.sports_soccer,
        color: AppColors.textGray,
        size: 30,
      ),
    );
  }
}