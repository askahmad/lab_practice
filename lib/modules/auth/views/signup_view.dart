import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/constants/app_strings.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(AppIcons.back, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: controller.signupFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header text
                    const Text(
                      AppStrings.createAccount,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      AppStrings.signupSubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Full Name Field
                    CustomTextField(
                      controller: controller.signupNameController,
                      labelText: AppStrings.fullName,
                      hintText: 'John Doe',
                      prefixIcon: AppIcons.person,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      validator: controller.validateName,
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    CustomTextField(
                      controller: controller.signupEmailController,
                      labelText: AppStrings.email,
                      hintText: 'name@example.com',
                      prefixIcon: AppIcons.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: controller.validateEmail,
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    Obx(
                      () => CustomTextField(
                        controller: controller.signupPasswordController,
                        labelText: AppStrings.password,
                        hintText: 'Create a password (min 6 chars)',
                        prefixIcon: AppIcons.password,
                        obscureText: !controller.isPasswordVisible.value,
                        textInputAction: TextInputAction.next,
                        validator: controller.validatePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? AppIcons.visibilityOff
                                : AppIcons.visibility,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password Field
                    Obx(
                      () => CustomTextField(
                        controller: controller.signupConfirmPasswordController,
                        labelText: AppStrings.confirmPassword,
                        hintText: 'Re-enter your password',
                        prefixIcon: AppIcons.password,
                        obscureText: !controller.isConfirmPasswordVisible.value,
                        textInputAction: TextInputAction.done,
                        validator: controller.validateConfirmPassword,
                        onSubmitted: (_) => controller.signUp(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isConfirmPasswordVisible.value
                                ? AppIcons.visibilityOff
                                : AppIcons.visibility,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: controller.toggleConfirmPasswordVisibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Submit Button
                    Obx(
                      () => CustomButton(
                        text: AppStrings.signup,
                        isLoading: controller.isLoading.value,
                        onPressed: controller.signUp,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Already have account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          AppStrings.haveAccount,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.offNamed(AppRoutes.LOGIN),
                          child: const Text(
                            AppStrings.login,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
