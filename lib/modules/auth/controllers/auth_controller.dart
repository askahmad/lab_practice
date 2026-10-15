import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Observables
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> currentUserModel = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  // Form Keys
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  // Text Controllers - Login
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  // Text Controllers - Signup
  final TextEditingController signupNameController = TextEditingController();
  final TextEditingController signupEmailController = TextEditingController();
  final TextEditingController signupPasswordController = TextEditingController();
  final TextEditingController signupConfirmPasswordController =
      TextEditingController();

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_authService.authStateChanges);
    ever(firebaseUser, _setInitialScreen);
  }

  void _setInitialScreen(User? user) async {
    if (user != null) {
      final profile = await _authService.getUserProfile(user.uid);
      if (profile != null) {
        currentUserModel.value = profile;
      } else {
        currentUserModel.value = UserModel(
          uid: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          createdAt: DateTime.now(),
        );
      }
    } else {
      currentUserModel.value = null;
    }
  }

  // Toggles
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Validation functions
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your password';
    }
    if (value.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please confirm your password';
    }
    if (value.trim() != signupPasswordController.text.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Login action
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      final user = await _authService.signInWithEmailAndPassword(
        email: loginEmailController.text.trim(),
        password: loginPasswordController.text.trim(),
      );

      currentUserModel.value = user;
      _clearLoginForm();

      Get.snackbar(
        'Success',
        'Welcome back, ${user.name.isNotEmpty ? user.name : 'User'}!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      );

      Get.offAllNamed(AppRoutes.HOME);
    } catch (e) {
      Get.snackbar(
        'Login Failed',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Sign up action
  Future<void> signUp() async {
    if (!signupFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      final user = await _authService.registerWithEmailAndPassword(
        name: signupNameController.text.trim(),
        email: signupEmailController.text.trim(),
        password: signupPasswordController.text.trim(),
      );

      currentUserModel.value = user;
      _clearSignupForm();

      Get.snackbar(
        'Account Created',
        'Welcome to TaskFlow, ${user.name}!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      );

      Get.offAllNamed(AppRoutes.HOME);
    } catch (e) {
      Get.snackbar(
        'Registration Failed',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Logout action with confirmation dialog
  Future<void> confirmLogout() async {
    Get.defaultDialog(
      title: 'Confirm Logout',
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      middleText: 'Are you sure you want to sign out of your account?',
      middleTextStyle: const TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
      radius: 16,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textConfirm: 'Log Out',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      cancelTextColor: AppColors.textSecondary,
      onConfirm: () async {
        Get.back(); // close dialog
        await logout();
      },
    );
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _authService.signOut();
      currentUserModel.value = null;
      Get.offAllNamed(AppRoutes.LOGIN);
      Get.snackbar(
        'Signed Out',
        'You have been logged out successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.info,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to log out: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _clearLoginForm() {
    loginEmailController.clear();
    loginPasswordController.clear();
  }

  void _clearSignupForm() {
    signupNameController.clear();
    signupEmailController.clear();
    signupPasswordController.clear();
    signupConfirmPasswordController.clear();
  }

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    signupNameController.dispose();
    signupEmailController.dispose();
    signupPasswordController.dispose();
    signupConfirmPasswordController.dispose();
    super.onClose();
  }
}
