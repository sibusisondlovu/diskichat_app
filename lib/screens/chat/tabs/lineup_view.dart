import 'package:flutter/material.dart';
import '../../../data/models/lineup_model.dart';
import '../../../data/models/match_model.dart';
import '../../../utils/themes/app_colors.dart';
import '../../../utils/themes/text_styles.dart';

class LineupView extends StatelessWidget {
  final List<LineupModel> lineups;
  final MatchModel match;

  const LineupView({
    super.key,
    required this.lineups,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    if (lineups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.stadium, size: 48, color: AppColors.textGray),
            const SizedBox(height: 16),
            Text(
              'Lineups not available yet',
              style: AppTextStyles.body.copyWith(color: AppColors.textGray),
            ),
          ],
        ),
      );
    }

    // Identify Home and Away lineup
    // This logic assumes lineup teamId matches match home/away logic. 
    // Usually name matching is safer if IDs differ between providers, but we'll try order/name.
    final homeLineup = lineups.firstWhere(
        (l) => l.teamId.toString() == match.id || true, // Fallback to first if ID mismatch 
        orElse: () => lineups.first,
    );
     // To improve matching, we might need team IDs in MatchModel. For now, let's just display them.
    // Actually, normally API returns 2 lineups. 0 is usually Home, 1 is Away.
    
    final home = lineups.isNotEmpty ? lineups[0] : null;
    final away = lineups.length > 1 ? lineups[1] : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Formation Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTeamHeader(match.homeTeam, home?.formation ?? '-'),
              _buildTeamHeader(match.awayTeam, away?.formation ?? '-'),
            ],
          ),
          const SizedBox(height: 16),

          // Pitch
          Container(
            height: 600,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32), // Grass Green
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Pitch Lines (Simplified)
                Center(
                  child: Container(
                    height: 2,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                    ),
                  ),
                ),

                // Home Team Players (Top Half)
                if (home != null) ..._buildPlayers(home.startXI, true),

                // Away Team Players (Bottom Half)
                if (away != null) ..._buildPlayers(away.startXI, false),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Substitutes
          _buildSubstitutes(home, away),
        ],
      ),
    );
  }

  Widget _buildTeamHeader(String teamName, String formation) {
    return Column(
      children: [
        Text(
          teamName,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          formation,
          style: AppTextStyles.caption.copyWith(color: AppColors.textGray),
        ),
      ],
    );
  }

  List<Widget> _buildPlayers(List<Player> players, bool isHome) {
    List<Widget> playerWidgets = [];
    
    // 1. Parse and Group players by Row
    // Map<RowIndex, List<PlayerWithCol>>
    Map<int, List<_PlayerPosition>> rows = {};

    for (var p in players) {
      if (p.grid == null) continue;
      final parts = p.grid!.split(':');
      if (parts.length != 2) continue;

      final row = int.tryParse(parts[0]) ?? 1;
      final col = int.tryParse(parts[1]) ?? 1;

      if (!rows.containsKey(row)) {
        rows[row] = [];
      }
      rows[row]!.add(_PlayerPosition(player: p, col: col));
    }

    // 2. Build Widgets
    rows.forEach((rowIndex, playersInRow) {
      // Sort by column to ensure correct left-to-right order
      playersInRow.sort((a, b) => a.col.compareTo(b.col));

      final count = playersInRow.length;
      
      // Calculate Y (Vertical Position)
      // Home: Top to Center (0.05 to 0.45)
      // Away: Bottom to Center (0.95 to 0.55)
      double y;
      if (isHome) {
        y = (rowIndex - 1) * 0.12 + 0.08; 
      } else {
        y = 1.0 - ((rowIndex - 1) * 0.12 + 0.08); 
      }

      for (int i = 0; i < count; i++) {
        // Calculate X (Horizontal Position) - Centered
        // Divide width into (count + 1) segments
        // e.g. 1 player -> 0.5
        // e.g. 2 players -> 0.33, 0.66
        // e.g. 4 players -> 0.2, 0.4, 0.6, 0.8
        
        double x = (i + 1) / (count + 1);
        
        final player = playersInRow[i].player;

        playerWidgets.add(Positioned(
          top: y * 600, // 600 is container height
          left: x * (MediaQueryData.fromView(WidgetsBinding.instance.window).size.width - 64), 
          // Note: accessing MediaQuery like this in a build method is okay, 
          // but strictly we should use 'context' or LayoutBuilder constraint. 
          // Since we are inside SingleChildScrollView, let's assume width is roughly screen width - padding.
          // Better: Use FractionalTranslation or Alignment if we were inside a Stack of known size.
          // But here we set 'left' pixels. Let's stick to the relative calculation assuming container width matches screen roughly.
          // A safer way for 'left' in a Stack is using Alignment, but Positioned works with relative values if enclosed in LayoutBuilder.
          // For now, let's keep the existing logic:
          // x is 0.0 to 1.0. We multiply by available width.
          
          child: FractionalTranslation(
            translation: const Offset(-0.5, -0.5), // Center the widget on the point
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isHome ? Colors.blue : Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    player.number.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  player.name.split(' ').last,
                  style: const TextStyle(color: Colors.white, fontSize: 10, shadows: [
                    Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black),
                  ]),
                ),
              ],
            ),
          ),
        ));
      }
    });

    return playerWidgets;
  }

  Widget _buildSubstitutes(LineupModel? home, LineupModel? away) {
    if (home == null && away == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Substitutes", style: AppTextStyles.h3),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Home Subs
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (home?.substitutes ?? []).map((p) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text("${p.number}. ${p.name}", style: AppTextStyles.bodySmall),
                    )
                ).toList(),
              ),
            ),
            // Away Subs
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: (away?.substitutes ?? []).map((p) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text("${p.number}. ${p.name}", style: AppTextStyles.bodySmall),
                    )
                ).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PlayerPosition {
  final Player player;
  final int col;
  _PlayerPosition({required this.player, required this.col});
}
