import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/provider.dart';
import 'package:hadafi_application/signup_widget.dart';
import 'package:hadafi_application/StudentHomepage.dart';
import 'package:hadafi_application/TrainingProviderHomepage.dart';
import 'package:hadafi_application/forget_password_page.dart';

final isLoadingProvider = StateProvider<bool>((ref) => false);
final isPasswordVisibleProvider = StateProvider<bool>((ref) => false);
final errorMessageProvider = StateProvider<String?>((ref) => null);
final successMessageProvider = StateProvider<String?>((ref) => null);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool backFromForget = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(isLoadingProvider.notifier).state = false;
      ref.read(isPasswordVisibleProvider.notifier).state = false;
      ref.read(errorMessageProvider.notifier).state = null;
      ref.read(successMessageProvider.notifier).state = null;
    });

    _emailController.clear();
    _passwordController.clear();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    final bool isLoading = ref.watch(isLoadingProvider);
    final bool isPasswordVisible = ref.watch(isPasswordVisibleProvider);
    final String? errorMessage = ref.watch(errorMessageProvider);
    final String? successMessage = ref.watch(successMessageProvider);
    

    if (isLoading && backFromForget) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(isLoadingProvider.notifier).state = false;
        backFromForget=false;
      });
    }

    Future<void> _login() async {
      if (!_formKey.currentState!.validate()) return;

      ref.read(isLoadingProvider.notifier).state = true;
      ref.read(errorMessageProvider.notifier).state = null;
      ref.read(successMessageProvider.notifier).state = null;

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (!mounted) return;

        User? user = userCredential.user;

        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();
          if (!mounted) return;
          ref.read(successMessageProvider.notifier).state =
              "Verification email sent. Please verify to log in.";
        } else if (user != null && user.emailVerified) {
          final userDoc = await FirebaseFirestore.instance
              .collection('Student')
              .doc(user.uid)
              .get();
          if (!mounted) return;
          ref.read(uidProvider.notifier).state = user.uid;

          _emailController.clear();
          _passwordController.clear();
          ref.read(isPasswordVisibleProvider.notifier).state = false;

          if (userDoc.exists && userDoc.get('role') == 'student') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StudentHomePage()),
            );
          } else {
            final providerDoc = await FirebaseFirestore.instance
                .collection('TrainingProvider')
                .doc(user.uid)
                .get();
            if (!mounted) return;
            if (providerDoc.exists &&
                providerDoc.get('role') == 'training_provider') {
              ref.read(uidProvider.notifier).state = user.uid;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => TrainingProviderHomePage()),
              );
            }
          }
        }
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        ref.read(errorMessageProvider.notifier).state =
            _handleAuthError(e.code);
      } catch (e) {
        if (!mounted) return;
        ref.read(errorMessageProvider.notifier).state =
            'Log in failed due to an unexpected error. Please try again.';
      } finally {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SignupWidget(
        child: Column(
          children: [
            const SizedBox(height: 125),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F9FB),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF113F67),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildEmailField(),
                        const SizedBox(height: 15),
                        _buildPasswordField(isPasswordVisible, ref),
                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgetPasswordPage(),
                                ),
                              ).then((_){
                                setState(() {
                                  backFromForget=true;
                                });
                                
                              });
                            },
                            child: const Text(
                              'Forget Password?',
                              style: TextStyle(
                                color: Color(0xFF113F67),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              errorMessage,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        if (successMessage != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  successMessage,
                                  style: const TextStyle(
                                    color: Color(0xFF113F67),
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 15),
                        isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF113F67),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 50,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFFF3F9FB),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _handleAuthError(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'invalid-email':
        return 'Invalid email format. Please enter a valid email.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Log in failed due to an unexpected error. Please try again.';
    }
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        final emailRegex =
            RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
        if (!emailRegex.hasMatch(value)) {
          return 'Invalid email format. Please enter a valid email.';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(bool isPasswordVisible, WidgetRef ref) {
    return TextFormField(
      controller: _passwordController,
      obscureText: !isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            ref.read(isPasswordVisibleProvider.notifier).state =
                !isPasswordVisible;
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }
}
