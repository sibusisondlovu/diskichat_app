import 'package:flutter/material.dart';
import '../../../data/models/event_model.dart';
import '../../../data/models/match_model.dart';
import '../../../utils/themes/app_colors.dart';
import '../../../utils/themes/text_styles.dart';

class EventsView extends StatelessWidget {
  final MatchModel match;

  const EventsView({
    super.key,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    if (match.events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_note, size: 48, color: AppColors.textGray),
            const SizedBox(height: 16),
            Text(
              'No match events yet',
              style: AppTextStyles.body.copyWith(color: AppColors.textGray),
            ),
          ],
        ),
      );
    }

    // Sort events by time (descending usually better for "latest first")
    // But timeline usually goes Top (Start) -> Bottom (End) or vice versa.
    // Let's do Ascending (0' -> 90')
    final sortedEvents = List<EventModel>.from(match.events)
      ..sort((a, b) => a.time.compareTo(b.time));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedEvents.length,
      itemBuilder: (context, index) {
        final event = sortedEvents[index];
        final isHome = event.teamId.toString() == match.id || 
                       event.teamId.toString() == match.apiMatchId || // Match API ID logic
                       true; // Needs robust Team ID check. 
                       // Current MatchModel doesn't store team IDs clearly exposed from API side except names.
                       // Backend: `fixture_events` has `team_id`.
                       // API response for live matches has `home_team: { id: ... }` but we flattened it to `homeTeam` string.
                       // FIX: We need Team IDs in MatchModel to align events correctly Left/Right.
                       // For now, let's assume we don't know side and center it, or try name match if available?
                       // EventModel has teamName. MatchModel has homeTeam name.
        
        // Let's try name match eventually.
        // For now, simple list.
        
        return _buildEventItem(event);
      },
    );
  }

  Widget _buildEventItem(EventModel event) {
    IconData icon;
    Color color;

    switch (event.type.toLowerCase()) {
      case 'goal':
        icon = Icons.sports_soccer;
        color = AppColors.liveGreen;
        break;
      case 'card':
        icon = Icons.style; // Card icon
        color = event.detail.toLowerCase().contains('red') ? Colors.red : Colors.yellow;
        break;
      case 'subst':
        icon = Icons.compare_arrows;
        color = AppColors.accentBlue;
        break;
      case 'var':
        icon = Icons.remove_red_eye;
        color = AppColors.textGray;
        break;
      default:
        icon = Icons.info;
        color = AppColors.textGray;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Time
          SizedBox(
            width: 40,
            child: Text(
              "${event.time}'",
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 16),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.player,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  "${event.detail} ${event.player2.isNotEmpty ? '(${event.player2})' : ''}",
                  style: AppTextStyles.caption.copyWith(color: AppColors.textGray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
