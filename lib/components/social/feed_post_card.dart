import 'package:flutter/material.dart';
import '../../components/avatars/custom_avatar.dart';
import '../../data/models/post_model.dart';
import '../../utils/themes/app_colors.dart';
import '../../utils/themes/text_styles.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../utils/constants/teams_constants.dart';
import 'comments_sheet.dart';
import 'video_post_player.dart';

class FeedPostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onLike;

  const FeedPostCard({
    super.key,
    required this.post,
    required this.onLike,
  });

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsSheet(postId: post.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1), // Instagram-like separation
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                CustomAvatar(
                  imageUrl: post.userAvatar,
                  size: 32, // Smaller styling
                  placeholder: '?',
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.username, 
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (post.userTeam != null)
                        Text(
                          post.userTeam!,
                          style: AppTextStyles.caption.copyWith(color: AppColors.textGray),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: AppColors.textGray),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Media (Image or Video)
          if (post.imageUrl != null)
            GestureDetector(
              onDoubleTap: onLike,
              child: Image.network(
                post.imageUrl!, 
                fit: BoxFit.cover,
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    width: double.infinity,
                    color: Colors.black12,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            )
          else if (post.videoUrl != null)
             SizedBox(
               height: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
               child: VideoPostPlayer(videoUrl: post.videoUrl!),
             )
          else 
             // Text only post fallback or nothing
             const SizedBox.shrink(),
          
          const SizedBox(height: 12),
          
          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                 IconButton(
                   icon: Icon(post.isLiked ? Icons.favorite : Icons.favorite_border, color: post.isLiked ? Colors.red : Colors.white),
                   onPressed: onLike,
                   visualDensity: VisualDensity.compact,
                 ),
                 IconButton(
                   icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                   onPressed: () => _showComments(context),
                   visualDensity: VisualDensity.compact,
                 ),
                 IconButton(
                   icon: const Icon(Icons.send, color: Colors.white),
                   onPressed: () {}, // Share
                   visualDensity: VisualDensity.compact,
                 ),
                 const Spacer(),
                 IconButton(
                   icon: const Icon(Icons.bookmark_border, color: Colors.white),
                   onPressed: () {},
                   visualDensity: VisualDensity.compact,
                 ),
              ],
            ),
          ),
          
          // Likes & Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.likesCount > 0)
                  Text('${post.likesCount} likes', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                
                const SizedBox(height: 4),
                
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodySmall,
                    children: [
                      TextSpan(text: post.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: ' '),
                      TextSpan(text: post.content),
                    ],
                  ),
                ),
                
                const SizedBox(height: 4),
                
                if (post.commentsCount > 0)
                  GestureDetector(
                    onTap: () => _showComments(context),
                    child: Text(
                      'View all ${post.commentsCount} comments', 
                      style: AppTextStyles.caption.copyWith(color: AppColors.textGray),
                    ),
                  ),
                  
                const SizedBox(height: 4),
                Text(
                   timeago.format(post.createdAt),
                   style: AppTextStyles.caption.copyWith(color: AppColors.textGray, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: color)),
        ],
      ),
    );
  }
}
