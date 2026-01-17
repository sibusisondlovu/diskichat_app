import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/match_provider.dart';
import '../../utils/themes/app_colors.dart';
import '../../utils/themes/text_styles.dart';
import '../../components/cards/match_card.dart';
import '../../components/common/loading_indicator.dart';
import '../../components/common/empty_state.dart';

class LiveMatchesScreen extends StatefulWidget {
  const LiveMatchesScreen({super.key});

  @override
  State<LiveMatchesScreen> createState() => _LiveMatchesScreenState();
}

class _LiveMatchesScreenState extends State<LiveMatchesScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to call AFTER build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLiveMatches();
    });
    
    // Auto-refresh every 60 seconds
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (mounted) {
        _loadLiveMatches(isAutoRefresh: true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadLiveMatches({bool isAutoRefresh = false}) async {
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);
    // Don't set isLoading if auto-refreshing to avoid flickering UI
    if (!isAutoRefresh) {
        // matchProvider will handle loading state if we call loadLiveMatches which sets _isLoading=true.
        // We might need to add silent refresh capability to provider, or just accept spinner?
        // Ideally silent. Let's call a method that doesn't trigger global loading if possible.
        // But MatchProvider.loadLiveMatches sets _isLoading=true.
        // For MVP, letting it spin or creating a separate silent load in provider is best.
        // Let's just call it. Spinner is okay for "Refresh" feedback, but maybe annoying every minute.
        // Better: Add `loadLiveMatches(silent: bool)` to provider?
        // Implementation plan didn't specify provider changes for silent load. 
        // For now, let's just call it.
    }
    await matchProvider.loadLiveMatches();
  }

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

          if (matchProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    matchProvider.errorMessage!,
                    style: AppTextStyles.body.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      matchProvider.loadLiveMatches();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final liveMatches = matchProvider.matches;

          if (liveMatches.isEmpty) {
            return EmptyState(
              icon: Icons.sports_soccer,
              title: 'No Live Matches',
              description: 'Check back when matches are in progress',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await matchProvider.loadLiveMatches();
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