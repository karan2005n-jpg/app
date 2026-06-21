import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dealer/widgets/social_button.dart';
import 'package:dealer/widgets/custom_textfield.dart';
import 'package:dealer/screens/auth/dashboard.dart';
import 'signup.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isChecked = false;
  bool isLoading = false;
  String message = "";
  Color messageColor = Colors.red;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _handleGoogleSignIn() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();

        final userCredential = await FirebaseAuth.instance.signInWithPopup(
          googleProvider,
        );

        final user = userCredential.user;

        if (user == null) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardPage(
              userName: user.displayName ?? "User",
              successMessage: "Google Login Successful",
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Google Sign-In failed: $e")));
    }
  }

  Future<void> _handleLogin({
    required String gmail,
    required String password,
  }) async {
    if (isLoading) return;
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://localhost:3001/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"gmail": gmail, "password": password}),
      );

      if (!mounted) return;

      final data = jsonDecode(response.body);
      debugPrint("Response: $data");

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        final userData = data["user"];
        if (userData == null) {
          throw Exception("Missing 'user' object in API response");
        }

        final int userId = userData["id"] ?? 0;
        final String userName = userData["name"] ?? "User";

        await prefs.setInt("user_id", userId);
        await prefs.setString("user_name", userName);

        if (!mounted) return;
        setState(() {
          message = "Login Successful";
          messageColor = Colors.green;
        });

        // 3. Fixed the exact error crash line by passing 'userName' variable
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardPage(
              userName: userName,
              successMessage: "Login Successful",
            ),
          ),
        );
      } else if (response.statusCode == 400) {
        setState(() {
          message = data["message"] ?? "Email and password are required";
          messageColor = Colors.red;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          message = data["message"] ?? "Invalid Email or Password";
          messageColor = Colors.red;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "An unknown error occurred"),
          ),
        );
      }
    } catch (e) {
      debugPrint("ERROR: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString().replaceAll('Exception: ', '')}"),
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/login_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        Center(
                          child: Image.asset(
                            "assets/icons/logo.png",
                            height: 90,
                          ),
                        ),

                        const SizedBox(height: 20),
                        if (message.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: messageColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: messageColor),
                            ),
                            child: Text(
                              message,
                              style: TextStyle(
                                color: messageColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                        Text(
                          "Login",
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Text(
                          "Enter your email and password to log in",
                          style: TextStyle(fontSize: 11),
                        ),

                        const SizedBox(height: 20),

                        BuildInputField(
                          controller: emailController,
                          hintText: "abcd@gmail.com",
                        ),

                        const SizedBox(height: 10),

                        BuildInputField(
                          controller: passwordController,
                          hintText: "********",
                          isPassword: true,
                        ),

                        Row(
                          children: [
                            Transform.scale(
                              scale: 0.9,
                              child: Checkbox(
                                value: isChecked,
                                activeColor: Colors.black,
                                onChanged: (value) {
                                  setState(() {
                                    isChecked = value!;
                                  });
                                },
                              ),
                            ),
                            const Text(
                              "Remember Me",
                              style: TextStyle(fontSize: 10),
                            ),
                            const Spacer(),
                            const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await _handleLogin(
                                gmail: emailController.text,
                                password: passwordController.text,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            child: const Text(
                              "Log in",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Center(child: Text("Or login with")),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _handleGoogleSignIn,
                              child: SocialButton(
                                imagePath: "assets/icons/google.png",
                              ),
                            ),
                            SizedBox(width: 10),
                            SocialButton(
                              imagePath: "assets/icons/facebook.png",
                            ),
                            SizedBox(width: 10),
                            SocialButton(icon: Icons.apple),
                            SizedBox(width: 10),
                            SocialButton(icon: Icons.phone_android),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? "),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignupPage(),
                                  ),
                                );
                              },
                              child: Text(
                                "Sign up",
                                style: TextStyle(color: Colors.blue),
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
