import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/match_model.dart';
import '../../utils/themes/app_colors.dart';
import '../../utils/themes/text_styles.dart';
import '../../components/chat/room_header.dart';
import '../../components/chat/message_bubble.dart';
import '../../components/chat/message_input.dart';
import '../../components/chat/quick_reactions.dart';
import '../../components/common/loading_indicator.dart';

class MatchRoomScreen extends StatefulWidget {
  final MatchModel match;

  const MatchRoomScreen({
    super.key,
    required this.match,
  });

  @override
  State<MatchRoomScreen> createState() => _MatchRoomScreenState();
}

class _MatchRoomScreenState extends State<MatchRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initRoom();
  }

  void _initRoom() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.loadMessages(widget.match.id);
    chatProvider.loadActiveUsersCount(widget.match.id);
    chatProvider.joinRoom(widget.match.id);
  }

  @override
  void dispose() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.leaveRoom(widget.match.id);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        title: RoomHeader(match: widget.match),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Share match room
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show room options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Active users count
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface.withOpacity(0.5),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.textMuted.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.people,
                      size: 16,
                      color: AppColors.liveGreen,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${chatProvider.activeUsersCount} fans in room',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Messages
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.isLoading) {
                  return const LoadingIndicator();
                }

                final messages = chatProvider.messages;

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: AppColors.textMuted.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to comment!',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  reverse: false,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final authProvider = Provider.of<AuthProvider>(context);
                    final isOwnMessage = message.userId == authProvider.user?.uid;

                    return MessageBubble(
                      message: message,
                      isOwnMessage: isOwnMessage,
                      matchId: widget.match.id,
                    );
                  },
                );
              },
            ),
          ),

          // Quick reactions
          QuickReactions(
            onReactionTap: (reaction) {
              _sendReaction(reaction);
            },
          ),

          // Message input
          MessageInput(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.sendMessage(
      matchId: widget.match.id,
      message: message,
    );

    _messageController.clear();
    _scrollToBottom();
  }

  void _sendReaction(String reaction) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.sendMessage(
      matchId: widget.match.id,
      message: reaction,
      messageType: 'reaction',
    );

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}