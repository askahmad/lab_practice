import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'custom_widgets.dart';
import 'signup_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorText;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
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
        'Missing Fields',
        'Please enter both email and password',
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
      // 1. Sign in with Firebase Authentication
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('User authentication failed.');
      }

      // 2. Fetch the user's status/role directly from Firestore backend
      // Every user starts as 'user' / 'client'.
      // Admin access is granted only when changed to 'admin' in Firestore backend.
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final docSnapshot = await docRef.get();

      String status = 'user';
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        status = (data['status'] ?? data['role'] ?? 'user').toString();
      } else {
        // If document doesn't exist yet, save as default client 'user'
        await docRef.set({
          'uid': user.uid,
          'email': user.email ?? email,
          'status': 'user', // Default backend status
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Check whether status is admin
      final bool isAdmin = status.trim().toLowerCase() == 'admin';

      Get.snackbar(
        'Login Successful',
        isAdmin ? 'Logged in with Admin privileges' : 'Logged in as Client',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: isAdmin ? Colors.redAccent.shade700 : Colors.green.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );

      // 3. Navigate using GetX (No push navigation)
      Get.offAll(() => HomePage(
        isAdmin: isAdmin,
        userEmail: user.email ?? email,
        userStatus: status,
      ));
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during login: ${e.code} - ${e.message}');
      String errorMessage = e.message ?? 'Login failed. Please check your credentials.';

      if (e.code == 'user-not-found') {
        errorMessage = 'Is email se koi user nahi mila. Pehle Sign Up karein.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = 'Password ya email ghalat hai.';
      } else if (e.code == 'operation-not-allowed') {
        errorMessage = 'Firebase Console me "Email/Password" sign-in provider enable karein!';
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'Internet connection check karein.';
      }

      setState(() {
        errorText = errorMessage;
      });

      Get.snackbar(
        'Authentication Failed [${e.code}]',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      debugPrint('General Exception during login: $e');
      setState(() {
        errorText = 'Error: $e';
      });
      Get.snackbar(
        'Error',
        'An error occurred: $e',
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

  Future<void> signInWithGoogle() async {
    setState(() {
      isLoading = true;
      errorText = null;
    });

    try {
      final UserCredential userCredential;

      if (kIsWeb) {
        // Web: Use Firebase Auth native popup provider
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        // Mobile (Android / iOS): Use GoogleSignIn plugin
        final GoogleSignIn googleSignIn = GoogleSignIn(
          serverClientId: '664633188895-1hs72gtb1foshi3l3adauru8mbecofou.apps.googleusercontent.com',
        );
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          // User cancelled sign-in
          setState(() {
            isLoading = false;
          });
          return;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
      }

      final user = userCredential.user;

      if (user != null) {
        // Check / save user details in Firestore
        final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final docSnapshot = await docRef.get();
        String status = 'user';

        if (docSnapshot.exists && docSnapshot.data() != null) {
          status = (docSnapshot.data()!['status'] ?? docSnapshot.data()!['role'] ?? 'user').toString();
        } else {
          await docRef.set({
            'uid': user.uid,
            'email': user.email ?? '',
            'displayName': user.displayName ?? '',
            'status': 'user',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        Get.snackbar(
          'Login Successful',
          'Welcome, ${user.displayName ?? user.email ?? "User"}!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );

        // Navigate to HomePage
        Get.offAll(() => HomePage(
          isAdmin: status.trim().toLowerCase() == 'admin',
          userEmail: user.email ?? '',
          userStatus: status,
        ));
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      setState(() {
        errorText = 'Google Sign-In failed: $e';
      });
      Get.snackbar(
        'Google Sign-In Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              const Icon(Icons.lock_person, size: 100, color: Colors.deepPurple),
              const SizedBox(height: 20),
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Sign in to continue',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 30),
              
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
                  : Column(
                      children: [
                        CustomButton(
                          text: 'LOGIN',
                          onPressed: handleLogin,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // --- Google Sign-In Button ---
                        OutlinedButton(
                          onPressed: signInWithGoogle,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.white,
                            elevation: 1,
                            shadowColor: Colors.black12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/google_logo.png',
                                height: 24,
                                width: 24,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.network(
                                  'https://developers.google.com/identity/images/g-logo.png',
                                  height: 24,
                                  width: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Sign In with Google',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
              
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      // Navigate to SignUpPage using GetX (no push navigation)
                      Get.to(() => const SignUpPage());
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}