import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  void _nextPage(bool skip) {
    if (_currentPage == 2 || skip) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: [
          _buildPage("assets/images/onboarding_1.jpg", "Achetez des Produits Frais\nDirectement des Agriculteurs\nLocaux à Votre Porte."),
          _buildPage("assets/images/onboarding_2.jpg", "Des produits de qualité,\naccessibles à tous."),
          _buildPage("assets/images/onboarding_3.jpg", "Plus qu'une platforme d'achat,\nUN écosystème."),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentPage != 2)
              TextButton(
                onPressed: () => _nextPage(true),
                child: const Text("Passer"),
              ),
            IconButton(
              icon: const Icon(Icons.arrow_forward, color: Colors.green),
              onPressed: () => _nextPage(false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(String imagePath, String text) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundImage: AssetImage(imagePath),
          radius: 100,
        ),
        const SizedBox(height: 20),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
