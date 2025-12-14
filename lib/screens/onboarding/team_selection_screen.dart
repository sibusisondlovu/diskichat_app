import 'package:flutter/material.dart';
import '../../data/models/team_model.dart';
import '../../services/teams_service.dart'; // Need to ensure this service exists or create it
import '../../services/follow_service.dart';
import '../../services/subscription_service.dart';
import '../../utils/themes/app_colors.dart';
import '../../components/common/loading_indicator.dart';

class TeamSelectionScreen extends StatefulWidget {
  final String userId;
  final String subscriptionType;
  final int currentFollowCount;

  const TeamSelectionScreen({
    super.key,
    required this.userId,
    required this.subscriptionType,
    required this.currentFollowCount,
  });

  @override
  State<TeamSelectionScreen> createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen> {
  final TeamsService _teamsService = TeamsService();
  final FollowService _followService = FollowService();
  final SubscriptionService _subscriptionService = SubscriptionService();
  
  List<Team> _allTeams = [];
  List<Team> _filteredTeams = [];
  bool _isLoading = true;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    try {
      // Mocking fetch all teams or need to implement getTeams in service
      // Assuming getTeams returns list of teams
      final teams = await _teamsService.getTeams(); 
      setState(() {
        _allTeams = teams;
        _filteredTeams = teams;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load teams: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterTeams(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredTeams = _allTeams;
      } else {
        _filteredTeams = _allTeams.where((team) {
          return team.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _handleFollow(Team team) async {
    if (!_subscriptionService.canFollowMoreTeams(widget.currentFollowCount, widget.subscriptionType)) {
      _showLimitDialog();
      return;
    }

    try {
      await _followService.followTeam(widget.userId, team.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Followed ${team.name}')),
        );
        Navigator.pop(context, team); // Return team object
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limit Reached'),
        content: Text(
          'You are on the ${widget.subscriptionType} plan. You can only follow ${_subscriptionService.getTeamLimit(widget.subscriptionType)} team(s). Upgrade to PRO to follow more.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          // TODO: Add Upgrade button
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        title: const Text('Follow a Team'),
        backgroundColor: AppColors.primaryDark,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterTeams,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search teams...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: AppColors.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: LoadingIndicator())
                : ListView.builder(
                    itemCount: _filteredTeams.length,
                    itemBuilder: (context, index) {
                      final team = _filteredTeams[index];
                      return ListTile(
                        leading: Image.network(
                          team.logo,
                          width: 40,
                          height: 40,
                          errorBuilder: (_, __, ___) => const Icon(Icons.error),
                        ),
                        title: Text(
                          team.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _handleFollow(team),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentBlue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Follow'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
