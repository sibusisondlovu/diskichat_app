import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart';
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

    // Sort: Latest first (Top of list)
    final sortedEvents = List<EventModel>.from(match.events)
      ..sort((a, b) => b.time.compareTo(a.time));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedEvents.length,
      itemBuilder: (context, index) {
        final event = sortedEvents[index];
        // Default to Home (Left) if ID is missing or matches homeTeamId.
        // If match.homeTeamId is null, use alternating sides for visual logic.
        final bool isHome;
        if (match.homeTeamId != null) {
          isHome = event.teamId == match.homeTeamId;
        } else {
          // Fallback if APIs don't return IDs: Alternate sides
          isHome = index % 2 == 0;
        }

        return TimelineTile(
          nodePosition: 0.5,
          node: TimelineNode(
            indicator: _buildIndicator(event),
            startConnector: index == 0 ? null : const SolidLineConnector(color: AppColors.textGray),
            endConnector: index == sortedEvents.length - 1 ? null : const SolidLineConnector(color: AppColors.textGray),
          ),
          contents: isHome 
              ? Padding(padding: const EdgeInsets.only(right: 12, bottom: 24), child: _buildEventCard(event, isRight: false)) 
              : null, 
          oppositeContents: !isHome 
              ? Padding(padding: const EdgeInsets.only(left: 12, bottom: 24), child: _buildEventCard(event, isRight: true)) 
              : null,
        );
      },
    );
  }

  Widget _buildIndicator(EventModel event) {
    Color color;
    switch (event.type.toLowerCase()) {
      case 'goal': color = AppColors.liveGreen; break;
      case 'card': color = event.detail.toLowerCase().contains('red') ? Colors.red : Colors.yellow; break;
      case 'subst': color = AppColors.accentBlue; break;
      default: color = AppColors.textGray;
    }
    return Container(
       padding: const EdgeInsets.all(4),
       decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryDark),
       child: DotIndicator(color: color, size: 10),
    );
  }

  Widget _buildEventCard(EventModel event, {required bool isRight}) {
    IconData icon;
    Color color;

    switch (event.type.toLowerCase()) {
      case 'goal':
        icon = Icons.sports_soccer;
        color = AppColors.liveGreen;
        break;
      case 'card':
        icon = Icons.style;
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
    
    return Row(
      mainAxisAlignment: isRight ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (!isRight) ...[ // Content on Left
           Expanded(child: _buildContent(event, isRight)),
           const SizedBox(width: 8),
           _buildIcon(icon, color),
           const SizedBox(width: 8),
           Text("${event.time}'", style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
        ],
        if (isRight) ...[ // Content on Right
           Text("${event.time}'", style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
           const SizedBox(width: 8),
           _buildIcon(icon, color),
           const SizedBox(width: 8),
           Expanded(child: _buildContent(event, isRight)),
        ],
      ],
    );
  }
  
  Widget _buildIcon(IconData icon, Color color) {
     return Icon(icon, size: 16, color: color);
  }

  Widget _buildContent(EventModel event, bool isRight) {
     return Column(
       crossAxisAlignment: isRight ? CrossAxisAlignment.start : CrossAxisAlignment.end,
       children: [
          Text(
            event.player, 
            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold), 
            textAlign: isRight ? TextAlign.left : TextAlign.right
          ),
          if (event.detail.isNotEmpty)
             Text(
               event.detail, 
               style: AppTextStyles.caption.copyWith(color: AppColors.textGray), 
               textAlign: isRight ? TextAlign.left : TextAlign.right
             ),
       ],
     );
  }
}
