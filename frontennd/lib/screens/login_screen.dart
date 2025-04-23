import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'register_screen.dart';
import 'main_app_screen.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_main_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  String? error;

  void loginUser() async {
    setState(() {
      loading = true;
      error = null;
    });

    final res = await ApiService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (res['token'] != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainAppScreen()),
      );
    } else {
      setState(() {
        error = res['message'] ?? 'Une erreur s\'est produite';
        loading = false;
      });
    }
  }

  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', height: 80), // replace with your logo
            const SizedBox(height: 24),
            const Text('Sign in', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            CustomTextField(
              hintText: "Email ou numero de telephone",
              controller: emailController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: "Entrez votre mot de passe",
              obscureText: isObscure,
              controller: passwordController,
              suffixIcon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: Color(0xFFB6C2C9)),
              onSuffixTap: () => setState(() => isObscure = !isObscure),
            ),
            const SizedBox(height: 8),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            CustomMainButton(
              text: "S'identifier",
              onPressed: loginUser,
            ),
            const SizedBox(height: 16),
            // Social icons row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon('assets/icons/google.png'),
                const SizedBox(width: 12),
                _buildSocialIcon('assets/icons/facebook.png'),
                const SizedBox(width: 12),
                _buildSocialIcon('assets/icons/apple.png'),
              ],
            ),
            const SizedBox(height: 20),
            // Sign up text row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Vous n'avez pas de compte? "),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text('Sign Up', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(String path) {
    return CircleAvatar(
      backgroundColor: Colors.grey[200],
      radius: 22,
      child: Image.asset(path, height: 24),
    );
  }
}
