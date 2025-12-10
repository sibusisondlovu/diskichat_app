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
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Diskichat'),
            Text(
              'Making Beautiful Game More Social',
              style: AppTextStyles.caption.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
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
      body: Column(
        children: [
          // Filter chips
          _buildFilterChips(),

          // Matches list
          Expanded(
            child: Consumer<MatchProvider>(
              builder: (context, matchProvider, child) {
                if (matchProvider.isLoading) {
                  return const LoadingIndicator();
                }

                final matches = matchProvider.displayedMatches;

                if (matches.isEmpty) {
                  return EmptyState(
                    icon: Icons.sports_soccer,
                    title: 'No Matches Available',
                    description: 'Check back soon for upcoming matches',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    matchProvider.loadMatches();
                    matchProvider.loadLiveMatches();
                    matchProvider.loadTodayMatches();
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
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 'all'),
            const SizedBox(width: 8),
            _buildFilterChip('Live', 'live'),
            const SizedBox(width: 8),
            _buildFilterChip('Today', 'today'),
            const SizedBox(width: 8),
            _buildFilterChip('AFCON', 'afcon'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
        matchProvider.setFilter(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [AppColors.accentBlue, AppColors.accentBlue.withOpacity(0.7)],
          )
              : null,
          color: isSelected ? null : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            if (value == 'live')
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 6),
                decoration: const BoxDecoration(
                  color: AppColors.liveGreen,
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.textWhite : AppColors.textGray,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}