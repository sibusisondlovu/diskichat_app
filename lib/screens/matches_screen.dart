import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/match_provider.dart';
import '../../utils/themes/app_colors.dart';
import '../../utils/themes/text_styles.dart';
import '../../components/cards/match_card.dart';
import '../../components/common/loading_indicator.dart';
import '../../components/common/empty_state.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  @override
  void initState() {
    super.initState();
    // Load matches when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MatchProvider>(context, listen: false).loadMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        title: Text(
          'TODAY MATCH',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: Consumer<MatchProvider>(
        builder: (context, matchProvider, child) {
          if (matchProvider.isLoading) {
            return const LoadingIndicator();
          }

          final matches = matchProvider.matches;

          if (matches.isEmpty) {
            return EmptyState(
              icon: Icons.sports_soccer,
              title: 'No Matches Today',
              description: 'Check back later for live action',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              matchProvider.loadMatches();
            },
            color: AppColors.accentBlue,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: MatchCard(match: matches[index]),
                );
              },
            ),
          );
        },
      ),
    );
  }
}