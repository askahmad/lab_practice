import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'custom_widgets.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorText;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleSignUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() {
      errorText = null;
    });

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorText = 'Please enter both email and password';
      });
      Get.snackbar(
        'Required Fields',
        'Please fill all required fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (password.length < 6) {
      setState(() {
        errorText = 'Password must be at least 6 characters long';
      });
      Get.snackbar(
        'Weak Password',
        'Password must be at least 6 characters',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        if (name.isNotEmpty) {
          try {
            await user.updateDisplayName(name);
          } catch (_) {}
        }

        // Store user in Firestore backend with default status 'user'
        // Sir requirement: When user registers/signs in, it is always a user client.
        // Status can only be changed to 'admin' in backend.
        try {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': name.isEmpty ? 'User' : name,
            'email': email,
            'status': 'user', // Default role in backend
            'createdAt': FieldValue.serverTimestamp(),
          });
        } catch (firestoreError) {
          debugPrint('Firestore write error: $firestoreError');
        }
      }

      Get.snackbar(
        'Account Created',
        'Account created successfully as User. Please login.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
      );

      // Navigate back using GetX (no push navigation)
      Get.back();
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during signup: ${e.code} - ${e.message}');
      String errorMessage = e.message ?? 'Authentication error occurred';

      if (e.code == 'operation-not-allowed') {
        errorMessage = 'Firebase Console me "Email/Password" sign-in provider enable karein!';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Yeh email pehle se registered hai. Please Login karein.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Email address sahi nahi hai (e.g. user@gmail.com).';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password kam az kam 6 characters ka hona chahiye.';
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'Internet connection check karein.';
      }

      setState(() {
        errorText = errorMessage;
      });

      Get.snackbar(
        'Registration Failed [${e.code}]',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      debugPrint('General Exception during signup: $e');
      setState(() {
        errorText = 'Error: $e';
      });
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(16),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_add_alt_1, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 20),
              const Text(
                'Create Account',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              
              CustomTextField(
                hintText: 'Full Name',
                icon: Icons.person,
                controller: nameController,
              ),
              CustomTextField(
                hintText: 'Email',
                icon: Icons.email,
                controller: emailController,
              ),
              CustomTextField(
                hintText: 'Password',
                icon: Icons.lock,
                isPassword: true,
                controller: passwordController,
              ),

              if (errorText != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.redAccent),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorText!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 20),
              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.deepPurple),
                    )
                  : CustomButton(
                      text: 'SIGN UP',
                      onPressed: handleSignUp,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}