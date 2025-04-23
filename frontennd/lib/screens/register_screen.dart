import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_main_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  bool loading = false;
  String? message;

  void registerUser() async {
    setState(() {
      loading = true;
      message = null;
    });

    final res = await ApiService.register(
      usernameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() {
      loading = false;
      message = res['message'];
    });

    if (res['message'] != null) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
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
            Image.asset('assets/images/logo.png', height: 80),
            const SizedBox(height: 24),
            const Text('Créer un compte', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            CustomTextField(
              controller: usernameController,
              hintText: 'Nom d\'utilisateur',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: emailController,
              hintText: 'Email',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: passwordController,
              hintText: 'Mot de Passe',
              obscureText: isObscure,
              suffixIcon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: Color(0xFFB6C2C9)),
              onSuffixTap: () => setState(() => isObscure = !isObscure),
            ),
            const SizedBox(height: 16),
            if (message != null)
              Text(message!, style: const TextStyle(color: Colors.green)),
            const SizedBox(height: 16),
            CustomMainButton(
              text: 'S\'inscrire',
              onPressed: loading? null : registerUser,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text("Déjà inscrit ? Se connecter", style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }
}
