import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import '../../utils/themes/app_colors.dart';
import '../../utils/themes/text_styles.dart';
import 'package:intl/intl.dart';

class FeedPostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onLike;
  final VoidCallback onComment;

  const FeedPostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: post.userAvatar != null ? NetworkImage(post.userAvatar!) : null,
                child: post.userAvatar == null 
                    ? const Icon(Icons.person, color: Colors.white) 
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.username, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    DateFormat.yMMMd().add_jm().format(post.createdAt),
                    style: AppTextStyles.caption.copyWith(color: AppColors.textGray),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Content
          Text(post.content, style: AppTextStyles.body),
          
          if (post.imageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: double.infinity,
                height: 300,
                child: Image.network(
                  post.imageUrl!, 
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(
                icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                color: post.isLiked ? Colors.red : AppColors.textGray,
                label: '${post.likesCount}',
                onTap: onLike,
              ),
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                color: AppColors.textGray,
                label: '${post.commentsCount}',
                onTap: onComment,
              ),
              _buildActionButton(
                icon: Icons.share,
                color: AppColors.textGray,
                label: 'Share',
                onTap: () {},
              ),
            ],
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
