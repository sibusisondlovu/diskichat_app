import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/routes.dart';
import '../../utils/themes/app_colors.dart';
import '../../utils/themes/text_styles.dart';
import '../../components/buttons/gradient_button.dart';
import '../../components/inputs/custom_text_field.dart';
import 'otp_verification_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _countryCode = '+27'; // South Africa default

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accentBlue,
                          AppColors.accentBlue.withOpacity(0.6),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_rounded,
                      size: 50,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                const Text(
                  'Welcome to Diskichat',
                  style: AppTextStyles.h2,
                ),

                const SizedBox(height: 8),

                Text(
                  'Enter your phone number to get started',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textGray,
                  ),
                ),

                const SizedBox(height: 40),

                // Country code & phone number
                Text(
                  'Phone Number',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    // Country code dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: _countryCode,
                        underline: const SizedBox(),
                        dropdownColor: AppColors.cardSurface,
                        style: AppTextStyles.bodyLarge,
                        items: const [
                          DropdownMenuItem(value: '+27', child: Text('🇿🇦 +27')),
                          DropdownMenuItem(value: '+234', child: Text('🇳🇬 +234')),
                          DropdownMenuItem(value: '+254', child: Text('🇰🇪 +254')),
                          DropdownMenuItem(value: '+233', child: Text('🇬🇭 +233')),
                          DropdownMenuItem(value: '+44', child: Text('🇬🇧 +44')),
                          DropdownMenuItem(value: '+1', child: Text('🇺🇸 +1')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _countryCode = value ?? '+27';
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Phone number input
                    Expanded(
                      child: CustomTextField(
                        controller: _phoneController,
                        hintText: 'Phone number',
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (value.length < 9) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Send OTP button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return GradientButton(
                      text: 'Send OTP',
                      isLoading: authProvider.isLoading,
                      onPressed: () => _sendOTP(authProvider),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Terms & conditions
                Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Error message
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.errorMessage != null) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.errorRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.errorRed.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppColors.errorRed,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authProvider.errorMessage!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.errorRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendOTP(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final phoneNumber = '$_countryCode${_phoneController.text.trim()}';

    final success = await authProvider.sendOTP(phoneNumber);

    if (success && mounted) {
      AppRoutes.navigateTo(
        context,
        OTPVerificationScreen(phoneNumber: phoneNumber),
      );
    }
  }
}