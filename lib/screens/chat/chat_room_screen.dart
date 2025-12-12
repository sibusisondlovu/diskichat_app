import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/match_model.dart';
import '../../data/models/message_model.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/themes/app_colors.dart';
import '../../utils/themes/text_styles.dart';
import '../../utils/themes/gradients.dart';
import '../../components/inputs/custom_text_field.dart';
import '../../components/common/loading_indicator.dart';
import '../../components/common/empty_state.dart';

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

  @override
  void initState() {
    super.initState();
    // Load messages and join room
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _joinRoom();
      context.read<ChatProvider>().loadMessages(widget.match.id);
      context.read<ChatProvider>().loadActiveUsersCount(widget.match.id);
    });
  }

  Future<void> _joinRoom() async {
    try {
      await context.read<ChatProvider>().joinRoom(widget.match.id);
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Room Check'),
          content: Text(e.toString().replaceAll('Exception: ', '')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Close screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _leaveRoom() {
    context.read<ChatProvider>().leaveRoom(widget.match.id);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final chatProvider = context.read<ChatProvider>();
    
    // Clear immediately for better UX
    _messageController.clear();

    final success = await chatProvider.sendMessage(
      matchId: widget.match.id,
      message: text,
    );

    if (!success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(chatProvider.errorMessage ?? 'Failed to send message')),
      );
    } else {
      // Scroll to bottom
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0, // Lists are often reversed for chat
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.primaryDark,
        appBar: AppBar(
          backgroundColor: AppColors.cardSurface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
            onPressed: () => Navigator.pop(context), // Resume later (keep joined)
          ),
          title: Text(
            widget.match.competitionName,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textWhite),
          ),
          centerTitle: true,
          actions: [
            // Live User Count
            Center(
              child: Consumer<ChatProvider>(
                builder: (_, provider, __) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    '${provider.activeUsersCount}/100',
                    style: AppTextStyles.caption.copyWith(
                      color: provider.activeUsersCount >= 100 
                          ? AppColors.errorRed 
                          : AppColors.liveGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.exit_to_app, color: AppColors.errorRed),
              onPressed: _leaveRoom,
              tooltip: 'Leave Room',
            ),
          ],
        ),
        body: Column(
          children: [
            _buildMatchHeader(),
            Container(
              color: AppColors.cardSurface,
              child: const TabBar(
                labelColor: AppColors.accentBlue,
                unselectedLabelColor: AppColors.textGray,
                indicatorColor: AppColors.accentBlue,
                tabs: [
                  Tab(text: "Chat"),
                  Tab(text: "Line Ups"),
                  Tab(text: "Events"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Chat (Existing Logic)
                  Column(
                    children: [
                      Expanded(child: _buildMessageList()),
                      _buildMessageInput(),
                    ],
                  ),
                  
                  // Tab 2: Line Ups (Placeholder)
                  _buildPlaceholderTab("Line Ups coming soon 📋"),
                  
                  // Tab 3: Events (Placeholder)
                  _buildPlaceholderTab("Match Events coming soon ⚽"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderTab(String message) {
    return Center(
      child: Text(
        message,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGray),
      ),
    );
  }

  Widget _buildMatchHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
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
              border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.3)),
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
    );
  }

  Widget _buildMessageList() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.isLoading && chatProvider.messages.isEmpty) {
          return const LoadingIndicator();
        }

        final messages = chatProvider.messages;

        if (messages.isEmpty) {
          return EmptyState(
            icon: Icons.chat_bubble_outline,
            title: 'No messages yet',
            description: 'Be the first to cheer for your team!',
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          reverse: true, // Chat usually starts from bottom
          itemBuilder: (context, index) {
            final msg = messages[index];
            final currentUser = context.read<AuthProvider>().user;
            final isMe = currentUser != null && msg.userId == currentUser.uid;
            
            return _buildMessageItem(msg, isMe);
          },
        );
      },
    );
  }

  Widget _buildMessageItem(MessageModel msg, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
             CircleAvatar(
              backgroundColor: AppColors.textGray,
              radius: 16,
              backgroundImage: msg.avatarUrl != null ? NetworkImage(msg.avatarUrl!) : null,
              child: msg.avatarUrl == null 
                  ? const Icon(Icons.person, size: 20, color: AppColors.primaryDark) 
                  : null,
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
                  if (!isMe && msg.username != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        msg.username!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    msg.message,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(msg.createdAt),
                    style: AppTextStyles.caption.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
