import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/themes/app_colors.dart';
import '../../utils/themes/text_styles.dart';
import '../../utils/helpers/rank_helper.dart';
import '../../utils/constants/rank_constants.dart';
import '../../utils/routes.dart';
import '../../components/badges/rank_badge.dart';
import '../../components/avatars/custom_avatar.dart';
import 'edit_profile_screen.dart';
import 'auth/phone_auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Settings screen
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          final userProfile = authProvider.userProfile;

          if (user == null || userProfile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 80,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Not logged in',
                    style: AppTextStyles.h3,
                  ),
                ],
              ),
            );
          }

          final rank = RankHelper.getRankFromString(userProfile.rank);
          final rankProgress = RankHelper.getRankProgress(
            userProfile.points,
            rank,
          );
          final pointsToNext = RankConstants.getPointsToNextRank(userProfile.points);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryBlue,
                        AppColors.primaryDark,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // Avatar with rank badge
                      Stack(
                        children: [
                          CustomAvatar(
                            imageUrl: userProfile.avatarUrl,
                            size: 100,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: RankBadge(rank: rank),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Name
                      Text(
                        userProfile.displayName,
                        style: AppTextStyles.h2,
                      ),

                      const SizedBox(height: 4),

                      // Username
                      Text(
                        '@${userProfile.username}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textGray,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Points and rank
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatItem(
                            icon: Icons.stars,
                            label: 'Points',
                            value: userProfile.points.toString(),
                          ),
                          const SizedBox(width: 32),
                          _buildStatItem(
                            icon: Icons.emoji_events,
                            label: 'Rank',
                            value: RankHelper.getRankDisplayName(rank),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Rank progress
                      if (rank != UserRank.legend) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progress to ${RankHelper.getRankDisplayName(RankConstants.getNextRank(rank)!)}',
                                  style: AppTextStyles.bodySmall,
                                ),
                                Text(
                                  '$pointsToNext pts',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.accentBlue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: rankProgress,
                                minHeight: 8,
                                backgroundColor: AppColors.textMuted.withOpacity(0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.accentBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Edit Profile Button
                      OutlinedButton.icon(
                        onPressed: () {
                          AppRoutes.navigateTo(
                            context,
                            const EditProfileScreen(),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Profile'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accentBlue,
                          side: const BorderSide(color: AppColors.accentBlue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Menu items
                _buildMenuItem(
                  icon: Icons.bookmark,
                  title: 'Saved Matches',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.help,
                  title: 'Help & Support',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.info,
                  title: 'About',
                  onTap: () {},
                ),

                const SizedBox(height: 16),

                // Sign out button
                _buildMenuItem(
                  icon: Icons.logout,
                  title: 'Sign Out',
                  textColor: AppColors.errorRed,
                  onTap: () async {
                    await authProvider.signOut();
                    if (context.mounted) {
                      AppRoutes.navigateAndRemoveUntil(
                        context,
                        const PhoneAuthScreen(),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.accentBlue,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.h3,
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: textColor ?? AppColors.textWhite,
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            color: textColor ?? AppColors.textWhite,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textGray,
        ),
        tileColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}