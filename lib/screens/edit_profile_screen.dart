import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/themes/app_colors.dart';
import '../../utils/routes.dart';
import '../../components/buttons/gradient_button.dart';
import '../../components/inputs/custom_text_field.dart';
import '../../components/avatars/custom_avatar.dart';


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _favoriteTeamController;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profile = authProvider.userProfile;

    _displayNameController = TextEditingController(text: profile?.displayName);
    _usernameController = TextEditingController(text: profile?.username);
    _bioController = TextEditingController(text: profile?.bio);
    _favoriteTeamController = TextEditingController(text: profile?.favoriteTeam);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _favoriteTeamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final profile = authProvider.userProfile;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      CustomAvatar(
                        imageUrl: profile?.avatarUrl,
                        size: 100,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            // TODO: Image picker
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.accentBlue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryDark,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: AppColors.textWhite,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Display Name
                  CustomTextField(
                    controller: _displayNameController,
                    labelText: 'Display Name',
                    hintText: 'Enter your display name',
                    prefixIcon: Icons.person,
                  ),

                  const SizedBox(height: 16),

                  // Username
                  CustomTextField(
                    controller: _usernameController,
                    labelText: 'Username',
                    hintText: 'Enter your username',
                    prefixIcon: Icons.alternate_email,
                  ),

                  const SizedBox(height: 16),

                  // Favorite Team
                  CustomTextField(
                    controller: _favoriteTeamController,
                    labelText: 'Favorite Team',
                    hintText: 'Enter your favorite team',
                    prefixIcon: Icons.sports_soccer,
                  ),

                  const SizedBox(height: 16),

                  // Bio
                  CustomTextField(
                    controller: _bioController,
                    labelText: 'Bio',
                    hintText: 'Tell us about yourself',
                    prefixIcon: Icons.info,
                    maxLines: 4,
                    maxLength: 150,
                  ),

                  const SizedBox(height: 32),

                  // Save button
                  GradientButton(
                    text: 'Save Changes',
                    isLoading: authProvider.isLoading,
                    onPressed: () => _saveProfile(authProvider),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveProfile(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await authProvider.updateProfile(
      displayName: _displayNameController.text.trim(),
      username: _usernameController.text.trim(),
      favoriteTeam: _favoriteTeamController.text.trim(),
      bio: _bioController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      AppRoutes.navigateBack(context);
    }
  }
}