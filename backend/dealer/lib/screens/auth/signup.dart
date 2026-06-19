import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dealer/widgets/social_button.dart';
import 'package:dealer/widgets/custom_textfield.dart';
import 'package:dealer/screens/auth/dashboard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  Future<void> fetchCart({
    required String name,
    required String gmail,
    required String password,
    required String mobile_no,
    required String Address,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("http://localhost:3001/auth/register"),

        headers: {"Content-Type": "application/json"},

        body: jsonEncode({
          "name": name,
          "gmail": gmail,
          "password": password,
          "mobile_no": mobile_no,
          "Address": Address,
        }),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardPage(
              userName: name,
              successMessage: "Registration Successful",
            ),
          ),
        );
        debugPrint(data.toString());
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "all fields are required")),
        );

        debugPrint("ERROR: ${response.statusCode}");
      } else if (response.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data["message"] ?? "Email or Mobile number already exists",
            ),
          ),
        );

        debugPrint("ERROR: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("ERROR: $e");
    }
  }

  bool isChecked = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController nameController = TextEditingController();

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

                        Text(
                          "Sign Up",
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Text(
                          "Enter your email and password to sign up",
                          style: TextStyle(fontSize: 11),
                        ),

                        const SizedBox(height: 20),
                        BuildInputField(
                          controller: nameController,

                          hintText: "Name",
                        ),
                        SizedBox(height: 10),
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
                        SizedBox(height: 10),

                        BuildInputField(
                          controller: mobileController,
                          hintText: "mobile number",
                          icon: Icons.phone,
                        ),
                        SizedBox(height: 10),

                        BuildInputField(
                          controller: addressController,
                          hintText: "address",
                          icon: Icons.location_on,
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await fetchCart(
                                name: nameController.text,
                                gmail: emailController.text,
                                password: passwordController.text,
                                mobile_no: mobileController.text,
                                Address: addressController.text,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),

                        SizedBox(height: 10),
                        SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SocialButton(imagePath: "assets/icons/google.png"),
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
                            Text("Already have an account? "),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Log in",
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 25, 0, 255),
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    mobileController.dispose();
    addressController.dispose();

    super.dispose();
  }
}
