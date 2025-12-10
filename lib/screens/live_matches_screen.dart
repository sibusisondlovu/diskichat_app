import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/match_provider.dart';
import '../../utils/themes/app_colors.dart';
import '../../utils/themes/text_styles.dart';
import '../../components/cards/match_card.dart';
import '../../components/common/loading_indicator.dart';
import '../../components/common/empty_state.dart';

class LiveMatchesScreen extends StatelessWidget {
  const LiveMatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: AppColors.liveGreen,
                shape: BoxShape.circle,
              ),
            ),
            const Text('Live Now'),
          ],
        ),
        centerTitle: true,
      ),
      body: Consumer<MatchProvider>(
        builder: (context, matchProvider, child) {
          if (matchProvider.isLoading) {
            return const LoadingIndicator();
          }

          final liveMatches = matchProvider.liveMatches;

          if (liveMatches.isEmpty) {
            return EmptyState(
              icon: Icons.sports_soccer,
              title: 'No Live Matches',
              description: 'Check back when matches are in progress',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              matchProvider.loadLiveMatches();
            },
            color: AppColors.accentBlue,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: liveMatches.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: MatchCard(match: liveMatches[index]),
                );
              },
            ),
          );
        },
      ),
    );
  }
}