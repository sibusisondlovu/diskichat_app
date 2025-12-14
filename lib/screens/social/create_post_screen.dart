import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../data/models/post_model.dart';
import '../../services/image_upload_service.dart';
import '../../utils/themes/app_colors.dart';
import '../../utils/themes/text_styles.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isPosting = false;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _submitPost() async {
    final text = _contentController.text.trim();
    if (text.isEmpty && _selectedImage == null) return; 

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() => _isPosting = true);

    try {
      String? imageUrl;
      
      // Upload image if selected
      if (_selectedImage != null) {
        final ImageUploadService uploadService = ImageUploadService();
        imageUrl = await uploadService.uploadImage(_selectedImage!);
      }

    final profile = context.read<AuthProvider>().userProfile;
    
    // Fallback info if profile is missing (shouldn't happen with wizard, but safety first)
    final String username = profile?.username ?? user.displayName ?? 'Anonymous';
    final String? userTeam = profile?.favoriteTeam;
    final String? userAvatar = profile?.avatarUrl ?? user.photoURL;

      final newPost = PostModel(
        id: '', // Firestore will generate
        userId: user.uid,
        username: username,
        userTeam: userTeam,
        userAvatar: userAvatar,
        content: text,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      final FirestoreService firestoreService = FirestoreService();
      await firestoreService.createPost(newPost);
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.cardSurface,
        title: Text("Create Post", style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _submitPost,
            child: _isPosting 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text("Post", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accentBlue)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              maxLines: 5,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: "What's happening?",
                hintStyle: AppTextStyles.body.copyWith(color: AppColors.textGray),
                border: InputBorder.none,
              ),
            ),
            
            if (_selectedImage != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_selectedImage!, height: 200, fit: BoxFit.cover),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => setState(() => _selectedImage = null),
                  ),
                ],
              ),

             const Spacer(),
            
            // Actions
            Row(
              children: [
                 IconButton(
                   icon: const Icon(Icons.image, color: AppColors.accentBlue), 
                   onPressed: _pickImage,
                 ),
                 IconButton(
                   icon: const Icon(Icons.videocam, color: AppColors.accentBlue), 
                   onPressed: () {
                     // Video upload to be implemented
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Video upload coming soon!")));
                   }
                 ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
