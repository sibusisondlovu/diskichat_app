import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../data/models/post_model.dart';
import '../../services/image_upload_service.dart';
import '../../utils/themes/app_colors.dart';
import '../../utils/themes/text_styles.dart';
import 'package:video_player/video_player.dart'; // Add video_player here for preview
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
  File? _selectedVideo;
  VideoPlayerController? _videoController;

  bool _isPosting = false;

  @override
  void dispose() {
    _contentController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _selectedVideo = null;
        _videoController?.dispose();
        _videoController = null;
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      final file = File(video.path);
      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      
      setState(() {
        _selectedVideo = file;
        _selectedImage = null; // Only one media type
        _videoController = controller;
      });
    }
  }

  void _submitPost() async {
    final text = _contentController.text.trim();
    if (text.isEmpty && _selectedImage == null && _selectedVideo == null) return; 

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() => _isPosting = true);

    try {
      String? imageUrl;
      String? videoUrl;
      
      final ImageUploadService uploadService = ImageUploadService();

      if (_selectedImage != null) {
        imageUrl = await uploadService.uploadImage(_selectedImage!);
      } else if (_selectedVideo != null) {
        videoUrl = await uploadService.uploadVideo(_selectedVideo!);
      }

    final profile = context.read<AuthProvider>().userProfile;
    
    // Fallback info if profile is missing
    final String username = profile?.username ?? user.displayName ?? 'Anonymous';
    final String? userTeam = profile?.favoriteTeam;
    final String? userTeamLogo = profile?.favoriteTeamLogo;
    final String? userAvatar = profile?.avatarUrl ?? user.photoURL;

      final newPost = PostModel(
        id: '', // Firestore will generate
        userId: user.uid,
        username: username,
        userTeam: userTeam,
        userTeamLogo: userTeamLogo,
        userAvatar: userAvatar,
        content: text,
        imageUrl: imageUrl,
        videoUrl: videoUrl,
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
      body: SingleChildScrollView(
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

             if (_selectedVideo != null && _videoController != null && _videoController!.value.isInitialized)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 200,
                      child: AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      _videoController?.dispose();
                      setState(() {
                         _selectedVideo = null;
                         _videoController = null;
                      });
                    },
                  ),
                ],
              ),

             const SizedBox(height: 20),
            
            // Actions
            Row(
              children: [
                 IconButton(
                   icon: const Icon(Icons.image, color: AppColors.accentBlue), 
                   onPressed: _pickImage,
                   tooltip: 'Pick Image',
                 ),
                 IconButton(
                   icon: const Icon(Icons.videocam, color: AppColors.accentBlue), 
                   onPressed: _pickVideo,
                   tooltip: 'Pick Video',
                 ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
