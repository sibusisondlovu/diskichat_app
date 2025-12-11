import 'package:flutter/material.dart';
import '../../data/models/match_model.dart';
import '../../utils/themes/app_colors.dart';
import '../../utils/themes/text_styles.dart';
import '../../utils/themes/gradients.dart';
import '../../components/inputs/custom_text_field.dart';

class ChatRoomScreen extends StatefulWidget {
  final MatchModel match;

  const ChatRoomScreen({
    super.key,
    required this.match,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Mock messages for now
  final List<Map<String, dynamic>> _messages = [
    {'user': 'Khune_Is_King', 'text': 'What a save!', 'time': '65\''},
    {'user': 'Bucs4Life', 'text': 'Offside surely??', 'time': '66\''},
    {'user': 'Ref_Check', 'text': 'VAR checking...', 'time': '67\''},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildMatchHeader(),
            Expanded(
              child: _buildMessageList(),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row: Back Button + Competition
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  widget.match.competitionName,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Balance back button
            ],
          ),
          const SizedBox(height: 8),
          
          // Match Info: Team A vs Team B + Score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Home Team
              Expanded(
                child: Text(
                  widget.match.homeTeam,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.right,
                ),
              ),
              
              // Score & Time
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accentBlue.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.match.scoreDisplay,
                      style: AppTextStyles.scoreMedium.copyWith(fontSize: 18),
                    ),
                    Text(
                      widget.match.elapsedTime ?? widget.match.status,
                      style: AppTextStyles.caption.copyWith(color: AppColors.liveGreen),
                    ),
                  ],
                ),
              ),

              // Away Team
              Expanded(
                child: Text(
                  widget.match.awayTeam,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isMe = index % 2 == 0; // Mock current user logic
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe) ...[
                const CircleAvatar(
                  backgroundColor: AppColors.textGray,
                  radius: 16,
                  child: Icon(Icons.person, size: 20, color: AppColors.primaryDark),
                ),
                const SizedBox(width: 8),
              ],
              
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.accentBlue : AppColors.cardSurface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMe)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            msg['user'],
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textWhite, // Fixed undefined color
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Text(
                        msg['text'],
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        msg['time'],
                        style: AppTextStyles.caption.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.cardSurface,
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              controller: _messageController,
              hintText: 'Join the conversation...',
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.primaryButton,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                if (_messageController.text.isNotEmpty) {
                  setState(() {
                    _messages.add({
                      'user': 'Me',
                      'text': _messageController.text,
                      'time': 'Now',
                    });
                    _messageController.clear();
                  });
                  // Scroll to bottom
                  Future.delayed(const Duration(milliseconds: 100), () {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
